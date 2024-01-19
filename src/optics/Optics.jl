module Optics

using DocStringExtensions
using CUDA
using Adapt
using Random
import ClimaComms

using ..Vmrs
import ..pow_fast
using ..LookUpTables
using ..AtmosphericStates
using ..Sources
using ..AngularDiscretizations
import ..Parameters as RP

export AbstractOpticalProps, OneScalar, TwoStream, compute_col_gas!, compute_optical_props!

"""
    AbstractOpticalProps

Optical properties for one scalar and two stream calculations.
"""
abstract type AbstractOpticalProps end

"""
    OneScalar{FTA2D,AD} <: AbstractOpticalProps

Single scalar approximation for optical depth, used in
calculations accounting for extinction and emission

# Fields
$(DocStringExtensions.FIELDS)
"""
struct OneScalar{FTA2D, AD} <: AbstractOpticalProps
    "Optical Depth"
    τ::FTA2D
    "Angular discretization"
    angle_disc::AD
end
Adapt.@adapt_structure OneScalar

function OneScalar(::Type{FT}, ncol::Int, nlay::Int, ::Type{DA}) where {FT <: AbstractFloat, DA}
    τ = DA{FT, 2}(undef, nlay, ncol)
    ad = AngularDiscretization(FT, DA, 1)

    return OneScalar{typeof(τ), typeof(ad)}(τ, ad)
end

"""
    TwoStream{FTA2D} <: AbstractOpticalProps

Two stream approximation for optical properties, used in
calculations accounting for extinction and emission

# Fields
$(DocStringExtensions.FIELDS)
"""
struct TwoStream{FTA2D} <: AbstractOpticalProps
    "Optical depth"
    τ::FTA2D
    "Single-scattering albedo"
    ssa::FTA2D
    "Asymmetry parameter"
    g::FTA2D
end
Adapt.@adapt_structure TwoStream

function TwoStream(::Type{FT}, ncol::Int, nlay::Int, ::Type{DA}) where {FT <: AbstractFloat, DA}
    τ = DA{FT, 2}(zeros(nlay, ncol))
    ssa = DA{FT, 2}(zeros(nlay, ncol))
    g = DA{FT, 2}(zeros(nlay, ncol))
    return TwoStream{typeof(τ)}(τ, ssa, g)
end

"""
    compute_col_gas!(
        context,
        p_lev,
        col_dry,
        param_set,
        vmr_h2o,
        lat,
        max_threads = Int(256),
    )

This function computes the column amounts of dry or moist air.

"""
function compute_col_gas!(
    context,
    p_lev::FTA2D,
    col_dry::FTA2D,
    param_set::RP.ARP,
    vmr_h2o::Union{AbstractArray{FT, 2}, Nothing} = nothing,
    lat::Union{AbstractArray{FT, 1}, Nothing} = nothing,
    max_threads::Int = Int(256),
) where {FT <: AbstractFloat, FTA2D <: AbstractArray{FT, 2}}
    nlay, ncol = size(col_dry)
    mol_m_dry = FT(RP.molmass_dryair(param_set))
    mol_m_h2o = FT(RP.molmass_water(param_set))
    avogadro = FT(RP.avogad(param_set))
    helmert1 = FT(RP.grav(param_set))
    args = (p_lev, mol_m_dry, mol_m_h2o, avogadro, helmert1, vmr_h2o, lat)
    device = ClimaComms.device(context)
    if device isa ClimaComms.CUDADevice
        tx = min(nlay * ncol, max_threads)
        bx = cld(nlay * ncol, tx)
        @cuda threads = (tx) blocks = (bx) compute_col_gas_CUDA!(col_dry, args...)
    else
        @inbounds begin
            ClimaComms.@threaded device for icnt in 1:(nlay * ncol)
                gcol = cld(icnt, nlay)
                glay = (icnt % nlay == 0) ? nlay : (icnt % nlay)
                compute_col_gas_kernel!(col_dry, args..., glay, gcol)
            end
        end
    end
    return nothing
end

function compute_col_gas_CUDA!(col_dry, args...)
    glx = threadIdx().x + (blockIdx().x - 1) * blockDim().x # global id
    nlay, ncol = size(col_dry)
    if glx ≤ nlay * ncol
        glay = (glx % nlay == 0) ? nlay : (glx % nlay)
        gcol = cld(glx, nlay)
        compute_col_gas_kernel!(col_dry, args..., glay, gcol)
    end
    return nothing
end

"""
    compute_optical_props!(
        op::AbstractOpticalProps,
        as::AtmosphericState{FT},
        sf::AbstractSourceLW{FT},
        gcol::Int,
        igpt::Int,
        lkp::LookUpLW{FT},
        lkp_cld::Union{LookUpCld,PadeCld,Nothing} = nothing,
    ) where {FT<:AbstractFloat}

Computes optical properties for the longwave problem.
"""
@inline function compute_optical_props!(
    op::AbstractOpticalProps,
    as::AtmosphericState{FT},
    sf::AbstractSourceLW{FT},
    gcol::Int,
    igpt::Int,
    lkp::LookUpLW,
    lkp_cld::Union{LookUpCld, PadeCld, Nothing} = nothing,
) where {FT <: AbstractFloat}
    (; nlay, vmr) = as
    @inbounds begin
        ibnd = lkp.major_gpt2bnd[igpt]
        t_sfc = as.t_sfc[gcol]
        col_dry_col = view(as.col_dry, :, gcol)
        p_lay_col = view(as.p_lay, :, gcol)
        t_lay_col = view(as.t_lay, :, gcol)
        t_lev_col = view(as.t_lev, :, gcol)
        lay_source = view(sf.lay_source, :, gcol)
        lev_source_inc = view(sf.lev_source_inc, :, gcol)
        lev_source_dec = view(sf.lev_source_dec, :, gcol)
        sfc_source = sf.sfc_source
        τ = view(op.τ, :, gcol)
    end
    planck_args = (lkp.t_planck, lkp.totplnk, ibnd)
    if op isa TwoStream
        ssa = view(op.ssa, :, gcol)
        g = view(op.g, :, gcol)
    end
    @inbounds t_lev_dec = t_lev_col[1]
    @inbounds for glay in 1:nlay
        col_dry = col_dry_col[glay]
        p_lay = p_lay_col[glay]
        t_lay = t_lay_col[glay]
        t_lev_inc = t_lev_col[glay + 1]
        # compute gas optics
        if op isa TwoStream
            τ[glay], ssa[glay], g[glay], p_frac =
                compute_gas_optics(lkp, vmr, col_dry, igpt, ibnd, p_lay, t_lay, glay, gcol)
        else
            τ[glay], _, _, p_frac = compute_gas_optics(lkp, vmr, col_dry, igpt, ibnd, p_lay, t_lay, glay, gcol)
        end
        # compute Planck sources
        lay_source[glay] = interp1d(t_lay, planck_args...) * p_frac
        lev_source_inc[glay] = interp1d(t_lev_inc, planck_args...) * p_frac
        lev_source_dec[glay] = interp1d(t_lev_dec, planck_args...) * p_frac

        if glay == 1
            sfc_source[gcol] = interp1d(t_sfc, planck_args...) * p_frac
        end
        t_lev_dec = t_lev_inc
    end
    if !isnothing(lkp_cld) # clouds need TwoStream optics
        cld_r_eff_liq = view(as.cld_r_eff_liq, :, gcol)
        cld_r_eff_ice = view(as.cld_r_eff_ice, :, gcol)
        cld_path_liq = view(as.cld_path_liq, :, gcol)
        cld_path_ice = view(as.cld_path_ice, :, gcol)
        cld_mask = view(as.cld_mask_lw, :, gcol)

        add_cloud_optics_2stream(
            τ,
            ssa,
            g,
            cld_mask,
            cld_r_eff_liq,
            cld_r_eff_ice,
            cld_path_liq,
            cld_path_ice,
            as.ice_rgh,
            lkp_cld,
            ibnd;
            delta_scaling = false,
        )
    end
    return nothing
end

"""
    compute_optical_props!(
        op::AbstractOpticalProps,
        as::AtmosphericState{FT},
        gcol::Int,
        igpt::Int,
        lkp::LookUpSW{FT},
        lkp_cld::Union{LookUpCld,PadeCld,Nothing} = nothing,
    ) where {FT<:AbstractFloat}

Computes optical properties for the shortwave problem.
"""
@inline function compute_optical_props!(
    op::AbstractOpticalProps,
    as::AtmosphericState{FT},
    gcol::Int,
    igpt::Int,
    lkp::LookUpSW,
    lkp_cld::Union{LookUpCld, PadeCld, Nothing} = nothing,
) where {FT <: AbstractFloat}
    (; nlay, vmr) = as
    @inbounds ibnd = lkp.major_gpt2bnd[igpt]
    @inbounds t_sfc = as.t_sfc[gcol]
    col_dry_col = view(as.col_dry, :, gcol)
    p_lay_col = view(as.p_lay, :, gcol)
    t_lay_col = view(as.t_lay, :, gcol)
    τ = view(op.τ, :, gcol)
    if op isa TwoStream
        ssa = view(op.ssa, :, gcol)
        g = view(op.g, :, gcol)
    end

    @inbounds for glay in 1:nlay
        col_dry = col_dry_col[glay]
        p_lay = p_lay_col[glay]
        t_lay = t_lay_col[glay]
        # compute gas optics
        if op isa TwoStream
            τ[glay], ssa[glay], g[glay] = compute_gas_optics(lkp, vmr, col_dry, igpt, ibnd, p_lay, t_lay, glay, gcol)
        else
            τ[glay], _, _ = compute_gas_optics(lkp, vmr, col_dry, igpt, ibnd, p_lay, t_lay, glay, gcol)
        end
    end
    if !isnothing(lkp_cld) # clouds need TwoStream optics
        cld_r_eff_liq = view(as.cld_r_eff_liq, :, gcol)
        cld_r_eff_ice = view(as.cld_r_eff_ice, :, gcol)
        cld_path_liq = view(as.cld_path_liq, :, gcol)
        cld_path_ice = view(as.cld_path_ice, :, gcol)
        cld_mask = view(as.cld_mask_sw, :, gcol)

        add_cloud_optics_2stream(
            τ,
            ssa,
            g,
            cld_mask,
            cld_r_eff_liq,
            cld_r_eff_ice,
            cld_path_liq,
            cld_path_ice,
            as.ice_rgh,
            lkp_cld,
            ibnd;
            delta_scaling = true,
        )
    end
    return nothing
end

"""
    compute_optical_props!(
        op::AbstractOpticalProps,
        as::GrayAtmosphericState{FT},
        sf::AbstractSourceLW{FT},
        gcol::Int,
        igpt::Int = 1,
    ) where {FT<:AbstractFloat}

Computes optical properties for the longwave gray radiation problem.
"""
function compute_optical_props!(
    op::AbstractOpticalProps,
    as::GrayAtmosphericState{FT},
    sf::AbstractSourceLW{FT},
    gcol::Int,
    igpt::Int = 1,
    lkp::Union{AbstractLookUp, Nothing} = nothing,
    lkp_cld::Union{AbstractLookUp, Nothing} = nothing,
) where {FT <: AbstractFloat}
    nlay = as.nlay
    @inbounds for ilay in 1:nlay
        compute_optical_props_kernel!(op, as, ilay, gcol, sf)
    end
    return nothing
end

"""
    compute_optical_props!(
        op::AbstractOpticalProps,
        as::GrayAtmosphericState{FT},
        gcol::Int,
        igpt::Int = 1,
    ) where {FT<:AbstractFloat}

Computes optical properties for the shortwave gray radiation problem.
"""
function compute_optical_props!(
    op::AbstractOpticalProps,
    as::GrayAtmosphericState{FT},
    gcol::Int,
    igpt::Int = 1,
    lkp::Union{AbstractLookUp, Nothing} = nothing,
    lkp_cld::Union{AbstractLookUp, Nothing} = nothing,
) where {FT <: AbstractFloat}
    nlay = as.nlay
    @inbounds for ilay in 1:nlay
        compute_optical_props_kernel!(op, as, ilay, gcol)
    end
    return nothing
end

include("OpticsUtils.jl")
include("GasOptics.jl")
include("CloudOptics.jl")
include("GrayOpticsKernels.jl")

end
