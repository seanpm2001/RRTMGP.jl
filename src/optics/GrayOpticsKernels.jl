
# Calculate optical properties for gray radiation solver.

"""
    compute_optical_props_kernel!(
        op::AbstractOpticalProps,
        as::GrayAtmosphericState{FT},
        glay, gcol,
        source::AbstractSourceLW{FT},
    ) where {FT<:AbstractFloat}

This function computes the optical properties using the gray atmosphere assumption
for the longwave solver.
"""
function compute_optical_props_kernel!(
    op::AbstractOpticalProps,
    as::GrayAtmosphericState{FT},
    glay,
    gcol,
    source::AbstractSourceLW{FT},
) where {FT <: AbstractFloat}

    compute_optical_props_kernel_lw!(op, as, glay, gcol)     # computing optical thickness
    compute_sources_gray_kernel!(source, as, glay, gcol) # computing Planck sources
    return nothing
end

"""
    compute_optical_props_kernel!(
        op::AbstractOpticalProps,
        as::GrayAtmosphericState{FT},
        glay, gcol,
    ) where {FT<:AbstractFloat}


This function computes the optical properties using the gray atmosphere assumption
for the longwave solver.
"""
function compute_optical_props_kernel_lw!(
    op::AbstractOpticalProps,
    as::GrayAtmosphericState{FT},
    glay,
    gcol,
) where {FT <: AbstractFloat}
    # setting references
    (; p_lay, p_lev, otp, lat) = as
    @inbounds p0 = p_lev[1, gcol]
    @inbounds Δp = p_lev[glay + 1, gcol] - p_lev[glay, gcol]
    @inbounds p = p_lay[glay, gcol]
    @inbounds lat = as.lat[gcol]
    @inbounds op.τ[glay, gcol] = compute_gray_optical_thickness_lw(otp, glay, gcol, p0, Δp, p, lat)
    return nothing
end
"""
    compute_sources_gray_kernel!(
        source::AbstractSourceLW{FT},
        as::GrayAtmosphericState{FT},
        glay, gcol,
    ) where {FT<:AbstractFloat}

This function computes the Planck sources for the gray longwave solver.
"""
function compute_sources_gray_kernel!(
    source::AbstractSourceLW{FT},
    as::GrayAtmosphericState{FT},
    glay,
    gcol,
) where {FT <: AbstractFloat}
    # computing Planck sources
    (; t_lay, t_lev) = as
    (; lay_source, lev_source_inc, lev_source_dec, sfc_source) = source

    sbc = FT(RP.Stefan(source.param_set))
    @inbounds lay_source[glay, gcol] = sbc * t_lay[glay, gcol]^FT(4) / FT(π)   # computing lay_source
    @inbounds lev_source_inc[glay, gcol] = sbc * t_lev[glay + 1, gcol]^FT(4) / FT(π)
    @inbounds lev_source_dec[glay, gcol] = sbc * t_lev[glay, gcol]^FT(4) / FT(π)
    if glay == 1
        @inbounds sfc_source[gcol] = sbc * as.t_sfc[gcol]^FT(4) / FT(π)   # computing sfc_source
    end
    return nothing
end

"""
    compute_optical_props_kernel!(
        op::AbstractOpticalProps,
        as::GrayAtmosphericState{FT},
        glay, gcol,
    ) where {FT<:AbstractFloat}
This function computes the optical properties using the gray atmosphere assumption
for the shortwave solver.
"""
function compute_optical_props_kernel!(
    op::AbstractOpticalProps,
    as::GrayAtmosphericState{FT},
    glay,
    gcol,
) where {FT <: AbstractFloat}
    # setting references
    (; p_lay, p_lev, otp) = as
    @inbounds p0 = p_lev[1, gcol]
    @inbounds Δp = p_lev[glay + 1, gcol] - p_lev[glay, gcol]
    @inbounds p = p_lay[glay, gcol]

    @inbounds op.τ[glay, gcol] = compute_gray_optical_thickness_sw(otp, glay, gcol, p0, Δp, p)

    if op isa TwoStream
        op.ssa[glay, gcol] = FT(0)
        op.g[glay, gcol] = FT(0)
    end
    return nothing
end
"""
    compute_gray_optical_thickness_lw(
        params::GrayOpticalThicknessSchneider2004{FT},
        glay, gcol,
        p0,
        Δp,
        p,
        lat,
    ) where {FT<:AbstractFloat}

This functions calculates the optical thickness based on pressure 
and lapse rate for a gray atmosphere. 
See Schneider 2004, J. Atmos. Sci. (2004) 61 (12): 1317–1340.
DOI: https://doi.org/10.1175/1520-0469(2004)061<1317:TTATTS>2.0.CO;2
"""
function compute_gray_optical_thickness_lw(
    params::GrayOpticalThicknessSchneider2004{FT},
    glay,
    gcol,
    p0,
    Δp,
    p,
    lat,
) where {FT <: AbstractFloat}
    (; α, te, tt, Δt) = params
    ts = te + Δt * (FT(1) / FT(3) - sin(lat / FT(180) * FT(π))^2) # surface temp at a given latitude (K)
    d0 = FT((ts / tt)^FT(4) - FT(1)) # optical depth
    @inbounds τ = (α * d0 * pow_fast(p / p0, α) / p) * Δp
    return abs(τ)
end

compute_gray_optical_thickness_sw(params::GrayOpticalThicknessSchneider2004{FT}, rest...) where {FT} = FT(0)

"""
    compute_gray_optical_thickness_lw(
        params::GrayOpticalThicknessOGorman2008{FT},
        glay, gcol,
        p0,
        Δp,
        p,
        lat,
    ) where {FT}

This functions calculates the optical thickness based on pressure 
and lapse rate for a gray atmosphere. 
See O'Gorman 2008, Journal of Climate Vol 21, Page(s): 3815–3832.
DOI: https://doi.org/10.1175/2007JCLI2065.1
"""
function compute_gray_optical_thickness_lw(
    params::GrayOpticalThicknessOGorman2008{FT},
    glay,
    gcol,
    p0,
    Δp,
    p,
    lat,
) where {FT}
    (; α, fₗ, τₑ, τₚ) = params
    σ = p / p0

    @inbounds τ = (α * Δp / p) * (fₗ * σ + (1 - fₗ) * 4 * σ^4) * (τₑ + (τₚ - τₑ) * sin(lat / FT(180) * FT(π))^2)

    return abs(τ)
end
"""
    compute_gray_optical_thickness_sw(
        params::GrayOpticalThicknessOGorman2008{FT},
        glay, gcol,
        p0,
        Δp,
        p,
        rest...,
    ) where {FT}
 
This functions calculates the optical thickness based on pressure 
for a gray atmosphere. 
See O'Gorman 2008, Journal of Climate Vol 21, Page(s): 3815–3832.
DOI: https://doi.org/10.1175/2007JCLI2065.1
"""
function compute_gray_optical_thickness_sw(
    params::GrayOpticalThicknessOGorman2008{FT},
    glay,
    gcol,
    p0,
    Δp,
    p,
    rest...,
) where {FT}
    (; τ₀) = params
    @inbounds τ = 2 * τ₀ * (p / p0) * (Δp / p0)
    return abs(τ)
end
