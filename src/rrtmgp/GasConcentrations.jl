"""
    GasConcentrations

Encapsulates a collection of volume mixing ratios (concentrations) of gases.
 Each concentration is associated with a name, normally the chemical formula.

Values may be provided as scalars, 1-dimensional profiles (nlay), or 2-D fields (ncol,nlay).
 (nlay and ncol are determined from the input arrays; self-consistency is enforced)
 example:
 set_vmr!(gas_concs, "h2o", values(:,:))
 set_vmr!(gas_concs, "o3" , values(:)  )
 set_vmr!(gas_concs, "co2", value      )

Values can be requested as profiles (valid only if there are no 2D fields present in the object)
 or as 2D fields. Values for all columns are returned although the entire collection
 can be subsetted in the column dimension

Subsets can be extracted in the column dimension
"""
module GasConcentrations

using DocStringExtensions
using ..FortranIntrinsics
using ..Utilities
export GasConcs
export set_vmr!, get_vmr!
export GasConcSize

"""
    GasConcSize

Sizes for gas concentrations
"""
struct GasConcSize{N,I}
  ncol::I
  nlay::I
  s::NTuple{N,I}
  nconcs::I
end

"""
    ConcField

Gas concentration arrays
"""
struct ConcField{FT}
  conc::Array{FT,2}
end

"""
    GasConcs{FT}

Encapsulates a collection of volume mixing ratios (concentrations) of gases.
 Each concentration is associated with a name, normally the chemical formula.

# Fields
$(DocStringExtensions.FIELDS)
"""
struct GasConcs{FT,I}
  "gas names"
  gas_name::Vector{String}
  "gas concentrations"
  concs::Vector{ConcField{FT}}
  "number of columns"
  ncol::I
  "number of layers"
  nlay::I
  "gas concentration problem size"
  gsc::GasConcSize
end

function GasConcs(::Type{FT}, ::Type{I}, gas_names, ncol, nlay, gsc::GasConcSize) where {FT<:AbstractFloat,I<:Int}
  concs = ConcField[ConcField(zeros(FT, gsc.s...)) for i in 1:gsc.nconcs]
  return GasConcs{FT,I}(gas_names, concs, gsc.s..., gsc)
end

"""
    set_vmr!(this::GasConcs{FT}, gas::String, w) where FT

Set volume mixing ratio (vmr)
"""
function set_vmr!(this::GasConcs{FT}, gas::String, w::FT) where FT
  @assert !(w < FT(0) || w > FT(1))
  igas = loc_in_array(gas, this.gas_name)
  this.concs[igas].conc .= w
  this.gas_name[igas] = gas
end
function set_vmr!(this::GasConcs{FT}, gas::String, w::Vector{FT}) where FT
  @assert !any(w .< FT(0)) || any(w .> FT(1))
  @assert !(this.nlay ≠ nothing && length(w) ≠ this.nlay)
  igas = loc_in_array(gas, this.gas_name)
  @assert igas ≠ -1 # assert gas is found
  this.concs[igas].conc .= reshape(w, 1, this.nlay)
  this.gas_name[igas] = gas
end
function set_vmr!(this::GasConcs, gas::String, w::Array{FT, 2}) where FT
  @assert !any(w .< FT(0)) || any(w .> FT(1))
  @assert !(this.ncol ≠ nothing && size(w, 1) ≠ this.ncol)
  @assert !(this.nlay ≠ nothing && size(w, 2) ≠ this.nlay)
  igas = loc_in_array(gas, this.gas_name)
  @assert igas ≠ -1 # assert gas is found
  this.concs[igas].conc .= w
  this.gas_name[igas] = gas
end

"""
    get_vmr!(array::AbstractArray{FT,2}, this::GasConcs{FT}, gas::String) where FT

Volume mixing ratio (nlay dependence only)
"""
function get_vmr!(array::AbstractArray{FT,2}, this::GasConcs{FT}, gas::String) where FT
  igas = loc_in_array(gas, this.gas_name)
  @assert igas ≠ -1 # assert gas is found
  @assert !(this.ncol ≠ nothing && this.ncol ≠ size(array,1))
  @assert !(this.nlay ≠ nothing && this.nlay ≠ size(array,2))
  conc = this.concs[igas].conc
  array .= conc
  return nothing
end

end # module