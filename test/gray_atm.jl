using Test
using RRTMGP.Device: array_type, array_device, CPU, CUDADevice
using CUDA
using RRTMGP
using RRTMGP.AngularDiscretizations
using RRTMGP.Fluxes
using RRTMGP.RTE
using RRTMGP.RTESolver
using RRTMGP.Optics
using RRTMGP.GrayUtils
using RRTMGP.AtmosphericStates
using RRTMGP.Sources
using RRTMGP.BCs

using CLIMAParameters
import CLIMAParameters.Planet: cp_d, grav, R_d
struct EarthParameterSet <: AbstractEarthParameterSet end
const param_set = EarthParameterSet()
# overriding CLIMAParameters as different precision is needed by RRTMGP

#using Plots

DA = array_type()

"""
Example program to demonstrate the calculation of longwave radiative fluxes in a model gray atmosphere.
"""
function gray_atmos_lw_equil(
    ::Type{OPC},
    ::Type{FT},
    ::Type{I},
    ::Type{DA},
    ncol::Int,
) where {FT<:AbstractFloat,I<:Int,DA,OPC}
    opc = Symbol(OPC)
    nlay = 60                               # number of layers
    p0 = FT(100000)                         # surface pressure (Pa)
    pe = FT(9000)                           # TOA pressure (Pa)
    nbnd, ngpt = 1, 1                       # # of nbands/g-points (=1 for gray radiation)
    nlev = nlay + 1                         # # of layers
    tb = FT(320)                            # surface temperature
    tstep = 6.0                             # timestep in hours
    Δt = FT(60 * 60 * tstep)                # timestep in seconds
    ndays = 365 * 40                        # # of simulation days
    nsteps = ndays * (24 / tstep)           # number of timesteps
    temp_toler = FT(0.1)                    # tolerance for temperature (Kelvin)
    flux_grad_toler = FT(1e-5)              # tolerance for flux gradient
    n_gauss_angles = I(1)                   # for non-scattering calculation
    sfc_emis = Array{FT}(undef, nbnd, ncol) # surface emissivity
    sfc_emis .= FT(1.0)
    inc_flux = nothing                      # incoming flux
    max_threads = Int(256)                  # maximum number of threads for KA kernels

    if ncol == 1
        lat = DA{FT}([0])                   # latitude
    else
        lat = DA{FT}(range(FT(-π / 2), FT(π / 2), length = ncol)) # latitude
    end

    as = setup_gray_as_pr_grid(nlay, lat, p0, pe, param_set, DA)
    op = OPC(FT, ncol, nlay, DA)
    src_lw = source_func_longwave(FT, ncol, nlay, opc, DA)
    bcs_lw = LwBCs(DA{FT,2}(sfc_emis), inc_flux)
    fluxb_lw = nothing
    flux_lw = FluxLW(ncol, nlay, FT, DA)

    slv = Solver{
        FT,
        I,
        DA{FT,1},
        DA{FT,2},
        typeof(as),
        typeof(op),
        typeof(src_lw),
        Nothing,
        typeof(bcs_lw),
        Nothing,
        typeof(fluxb_lw),
        Nothing,
        typeof(flux_lw),
        Nothing,
    }(
        as,
        op,
        src_lw,
        nothing,
        bcs_lw,
        nothing,
        fluxb_lw,
        nothing,
        flux_lw,
        nothing,
    )

    flux = slv.flux_lw
    flux_up = slv.flux_lw.flux_up
    flux_dn = slv.flux_lw.flux_dn
    flux_net = slv.flux_lw.flux_net
    gray_as = slv.as
    t_lay = gray_as.t_lay
    p_lay = gray_as.p_lay
    t_lev = gray_as.t_lev
    p_lev = gray_as.p_lev
    optical_props = slv.op
    source = slv.src_lw
    #----------------------------------------------------
    hr_lay = DA{FT}(undef, nlay, ncol)
    T_ex_lev = DA{FT}(undef, nlev, ncol)
    flux_grad = DA{FT}(undef, nlay, ncol)
    flux_grad_err = FT(0)
    for i = 1:nsteps
        # calling the long wave gray radiation solver
        solve_lw!(slv, max_threads)
        # computing heating rate
        compute_gray_heating_rate!(
            hr_lay,
            p_lev,
            ncol,
            nlay,
            flux_net,
            param_set,
            FT,
        )
        # updating t_lay and t_lev based on heating rate
        update_profile_lw!(
            t_lay,
            t_lev,
            flux_dn,
            flux_net,
            hr_lay,
            flux_grad,
            T_ex_lev,
            Δt,
            nlay,
            nlev,
            ncol,
            FT,
        )
        #----------------------------------------
        flux_grad_err = maximum(flux_grad)
        if flux_grad_err < flux_grad_toler
            break
        end
        #----------------------------------------------------
    end

    t_error = maximum(abs.(T_ex_lev .- gray_as.t_lev))
    println("*************************************************")
    println("Longwave test for gray atmosphere model - $opc; ncol = $ncol; DA = $DA")
    println("Integration time = $(FT(nsteps)/FT(24.0/tstep) / FT(365.0)) years")
    println("t_error = $(t_error); flux_grad_err = $(flux_grad_err)")

    @test maximum(t_error) < temp_toler
    #--------------------------------------------------------
end
#------------------------------------------------------------------------------

function gray_atmos_sw_test(
    ::Type{OPC},
    ::Type{FT},
    ::Type{I},
    ::Type{DA},
    ncol::Int,
) where {FT<:AbstractFloat,I<:Int,DA,OPC}
    opc = Symbol(OPC)
    nlay = 60                         # number of layers
    p0 = FT(100000)                   # surface pressure (Pa)
    pe = FT(9000)                     # TOA pressure (Pa)
    nbnd, ngpt = 1, 1                 # # of nbands/g-points (=1 for gray radiation)
    nlev = nlay + 1                   # # of layers
    tb = FT(320)                      # surface temperature
    tstep = 6.0                       # timestep in hours
    Δt = FT(60 * 60 * tstep)          # timestep in seconds
    ndays = 365 * 40                  # # of simulation days
    nsteps = ndays * (24 / tstep)     # number of timesteps
    n_gauss_angles = I(1)             # for non-scattering calculation
    sfc_emis = Array{FT}(undef, nbnd, ncol) # surface emissivity
    sfc_emis .= FT(1.0)
    max_threads = Int(256)            # maximum number of threads for KA kernels
    deg2rad = FT(π) / FT(180)

    zenith = DA{FT,1}(undef, ncol)   # solar zenith angle in radians
    toa_flux = DA{FT,1}(undef, ncol) # top of atmosphere flux
    sfc_alb_direct = DA{FT,2}(undef, nbnd, ncol) # surface albedo (direct)
    sfc_alb_diffuse = DA{FT,2}(undef, nbnd, ncol) # surface albedo (diffuse)
    inc_flux_diffuse = nothing

    top_at_1 = false                          # Top-of-atmos at pt# 1 (true/false)

    if ncol == 1
        lat = DA{FT}([0])                     # latitude
    else
        lat = DA{FT}(range(FT(-π / 2), FT(π / 2), length = ncol)) # latitude
    end

    zenith .= deg2rad * 52.95 #acsc(FT(1.66))               # corresponding to ~52.95 deg zenith angle    
    toa_flux .= FT(1407.679)
    sfc_alb_direct .= FT(0.1)
    sfc_alb_diffuse .= FT(0.1)

    as = setup_gray_as_pr_grid(nlay, lat, p0, pe, param_set, DA) # init gray atmos state
    op = OPC(FT, ncol, nlay, DA)
    src_sw = source_func_shortwave(FT, ncol, nlay, opc, DA)
    bcs_sw = SwBCs(
        zenith,
        toa_flux,
        sfc_alb_direct,
        inc_flux_diffuse,
        sfc_alb_diffuse,
    )
    fluxb_sw = FluxSW(ncol, nlay, FT, DA)
    flux_sw = FluxSW(ncol, nlay, FT, DA)

    slv = Solver{
        FT,
        I,
        DA{FT,1},
        DA{FT,2},
        typeof(as),
        typeof(op),
        Nothing,
        typeof(src_sw),
        Nothing,
        typeof(bcs_sw),
        Nothing,
        typeof(fluxb_sw),
        Nothing,
        typeof(flux_sw),
    }(
        as,
        op,
        nothing,
        src_sw,
        nothing,
        bcs_sw,
        nothing,
        fluxb_sw,
        nothing,
        flux_sw,
    )
    solve_sw!(slv, max_threads)

    τ = Array(slv.op.τ)
    zenith = Array(zenith)
    flux_dn_dir = Array(slv.flux_sw.flux_dn_dir)
    toa_flux = Array(toa_flux)

    # testing with exact solution
    ot_tot = sum(τ[:, 1]) / cos(zenith[1])
    exact = (toa_flux[1] * cos(zenith[1])) * exp(-ot_tot)

    rel_toler = FT(0.001)
    rel_error = abs(flux_dn_dir[1] - exact) / exact
    println("*************************************************")
    println("Running shortwave test for gray atmosphere model - $(opc); ncol = $ncol; DA = $DA")
    println("relative error = $rel_error")
    @test rel_error < rel_toler
end

if DA == CuArray
    gray_atmos_lw_equil(OneScalar, Float64, Int, DA, Int(4096))
    gray_atmos_lw_equil(TwoStream, Float64, Int, DA, Int(4096))
else
    gray_atmos_lw_equil(OneScalar, Float64, Int, DA, Int(9))
    gray_atmos_lw_equil(TwoStream, Float64, Int, DA, Int(9))
end

gray_atmos_sw_test(OneScalar, Float64, Int, DA, Int(1))
gray_atmos_sw_test(TwoStream, Float64, Int, DA, Int(1))
