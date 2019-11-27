var documenterSearchIndex = {"docs":
[{"location":"RTE.html#Radiative-Transfer-Equation-(RTE)-1","page":"Radiative Transfer Equation (RTE)","title":"Radiative Transfer Equation (RTE)","text":"","category":"section"},{"location":"RTE.html#","page":"Radiative Transfer Equation (RTE)","title":"Radiative Transfer Equation (RTE)","text":"This document outlines the equations solved in the RTE.","category":"page"},{"location":"References.html#References-1","page":"References","title":"References","text":"","category":"section"},{"location":"References.html#Scattering-1","page":"References","title":"Scattering","text":"","category":"section"},{"location":"References.html#","page":"References","title":"References","text":"Costa, S. M. S., & Shine, K. P. (2006, April). An estimate of the global impact of multiple scattering by clouds on outgoing long-wave radiation. Quart. J. Royal Met. Soc., 132(616), 885–895.","category":"page"},{"location":"References.html#","page":"References","title":"References","text":"Kuo, C.P., Yang, P., Huang, X., Feldman, D., Flanner, M., Kuo, C., & Mlawer, E. J. (2017, December). Impact of Multiple Scattering on Longwave Radiative Transfer Involving Clouds. J. Adv. Model. Earth Syst., 9(8), 3082–3098.","category":"page"},{"location":"References.html#Two-stream-1","page":"References","title":"Two-stream","text":"","category":"section"},{"location":"References.html#","page":"References","title":"References","text":"Meador, W. E., & Weaver, W. R. (1980). Two-Stream Approximations to Radiative Transfer in Planetary Atmospheres: A Unified Description of Existing Methods and a New Improvement. J. Atmos. Sci., 37(3), 630–643.","category":"page"},{"location":"References.html#Transport-1","page":"References","title":"Transport","text":"","category":"section"},{"location":"References.html#","page":"References","title":"References","text":"Shonk, J. K. P., & Hogan, R. J. (2008, June). Tripleclouds: An Efficient Method for Representing Horizontal Cloud Inhomogeneity in 1D Radiation Schemes by Using Three Regions at Each Height. J. Climate, 21(11), 2352–2370.","category":"page"},{"location":"References.html#Longwave-and-Shortwave-1","page":"References","title":"Longwave & Shortwave","text":"","category":"section"},{"location":"References.html#","page":"References","title":"References","text":"Fu, Q., & Liou, K. N. (1992). On the correlated k-distribution method for radiative transfer in nonhomogeneous atmospheres. J. Atmos. Sci., 49(22), 2139–2156.","category":"page"},{"location":"References.html#","page":"References","title":"References","text":"Fu, Q., Liou, K. N., Cribb, M. C., Charlock, T. P., & Grossman, A. (1997, December). Multiple Scattering Parameterization in Thermal Infrared Radiative Transfer. J. Atmos. Sci., 54(24), 2799–2812.","category":"page"},{"location":"References.html#","page":"References","title":"References","text":"Clough, S. A., Iacono, M. J., & Moncet, J.L. (1992). Line-by-line calculations of atmospheric fluxes and cooling rates: Application to water vapor. J. Geophys. Res., 97(D14), 15761–15785.","category":"page"},{"location":"References.html#","page":"References","title":"References","text":"Zdunkowski, W. G., Welch, R. M., & Korb, G. J. (1980, September). An investigation of the structure of typical two-stream methods for the calculation of solar fluxes and heating rates in clouds. Beitr ̈age zur Physik Atmosph ̈ere , 53 , 147–166.","category":"page"},{"location":"RTE/OpticalProps.html#Optical-Properties-1","page":"Optical Properties","title":"Optical Properties","text":"","category":"section"},{"location":"RTE/OpticalProps.html#","page":"Optical Properties","title":"Optical Properties","text":"CurrentModule = RRTMGP.OpticalProps","category":"page"},{"location":"RTE/OpticalProps.html#","page":"Optical Properties","title":"Optical Properties","text":"OpticalPropsBase\nOneScalar\nTwoStream","category":"page"},{"location":"RTE/OpticalProps.html#RRTMGP.OpticalProps.OpticalPropsBase","page":"Optical Properties","title":"RRTMGP.OpticalProps.OpticalPropsBase","text":"OpticalPropsBase{FT,I} <: AbstractOpticalProps{FT,I}\n\nBase class for optical properties. Describes the spectral discretization including the wavenumber limits of each band (spectral region) and the mapping between g-points and bands.\n\n(begin g-point, end g-point) = band2gpt(2,band)\nband = gpt2band(g-point)\n(upper and lower wavenumber by band) = bandlimswvn(2,band)\n\nFields\n\nband2gpt\ngpt2band\nband_lims_wvn\nname\n\n\n\n\n\n","category":"type"},{"location":"RTE/OpticalProps.html#RRTMGP.OpticalProps.OneScalar","page":"Optical Properties","title":"RRTMGP.OpticalProps.OneScalar","text":"OneScalar{FT,I} <: AbstractOpticalPropsArry{FT,I}\n\nHolds absorption optical depth tau, used in calculations accounting for extinction and emission\n\nFields\n\nbase\ntau\n\n\n\n\n\n","category":"type"},{"location":"RTE/OpticalProps.html#RRTMGP.OpticalProps.TwoStream","page":"Optical Properties","title":"RRTMGP.OpticalProps.TwoStream","text":"TwoStream{FT,I} <: AbstractOpticalPropsArry{FT,I}\n\nHolds extinction optical depth tau, single-scattering albedo (ssa), and asymmetry parameter g.\n\nFields\n\nbase\ntau\nssa\ng\n\n\n\n\n\n","category":"type"},{"location":"RTE/OpticalProps.html#","page":"Optical Properties","title":"Optical Properties","text":"delta_scale!\nvalidate!\nincrement!\nexpand\nbands_are_equal\ngpoints_are_equal","category":"page"},{"location":"RTE/OpticalProps.html#RRTMGP.OpticalProps.delta_scale!","page":"Optical Properties","title":"RRTMGP.OpticalProps.delta_scale!","text":"delta_scale!(...)\n\nclass(OneScalar), intent(inout) :: this\nreal(FT), dimension(:,:,:), optional, intent(in   ) :: for_\n\n\n\n\n\ndelta_scale!()\n\nclass(TwoStream), intent(inout) :: this\nreal(FT), dimension(:,:,:), optional, intent(in   ) :: for_\n# Forward scattering fraction; g**2 if not provided\n\ninteger :: ncol, nlay, ngpt\n\n\n\n\n\n","category":"function"},{"location":"RTE/OpticalProps.html#RRTMGP.OpticalProps.validate!","page":"Optical Properties","title":"RRTMGP.OpticalProps.validate!","text":"validate!(this::OneScalar{FT}) where FT\n\n\n\n\n\nvalidate!(this::TwoStream{FT}) where FT\n\n\n\n\n\n","category":"function"},{"location":"RTE/OpticalProps.html#RRTMGP.OpticalProps.increment!","page":"Optical Properties","title":"RRTMGP.OpticalProps.increment!","text":"increment!(opin::AbstractOpticalPropsArry, opio::AbstractOpticalPropsArry)\n\n\n\n\n\n","category":"function"},{"location":"RTE/OpticalProps.html#RRTMGP.OpticalProps.expand","page":"Optical Properties","title":"RRTMGP.OpticalProps.expand","text":"expand(this::AbstractOpticalProps{FT}, arr_in) where FT\n\nExpand an array of dimension arrin(nband) to dimension arrout(ngpt)\n\nclass(AbstractOpticalProps), intent(in) :: this\nreal(FT), dimension(:),  intent(in) :: arr_in # (nband)\nreal(FT), dimension(size(this%gpt2band)) :: arr_out\n\ninteger :: iband\n\n\n\n\n\n","category":"function"},{"location":"RTE/OpticalProps.html#RRTMGP.OpticalProps.bands_are_equal","page":"Optical Properties","title":"RRTMGP.OpticalProps.bands_are_equal","text":"bands_are_equal(this::AbstractOpticalProps{FT}, that::AbstractOpticalProps{FT}) where FT\n\nAre the bands of two objects the same? (same number, same wavelength limits)\n\nclass(AbstractOpticalProps), intent(in) :: this, that\nlogical                             :: bands_are_equal\n\n\n\n\n\n","category":"function"},{"location":"RTE/OpticalProps.html#RRTMGP.OpticalProps.gpoints_are_equal","page":"Optical Properties","title":"RRTMGP.OpticalProps.gpoints_are_equal","text":"gpoints_are_equal(this::AbstractOpticalProps{FT}, that::AbstractOpticalProps{FT}) where {FT}\n\nIs the g-point structure of two objects the same?   (same bands, same number of g-points, same mapping between bands and g-points)\n\nclass(AbstractOpticalProps), intent(in) :: this, that\nlogical                             :: gpoints_are_equal\n\n\n\n\n\n","category":"function"},{"location":"RRTMGP/GasConcs.html#Gas-Concentrations-1","page":"Gas Concentrations","title":"Gas Concentrations","text":"","category":"section"},{"location":"RRTMGP/GasConcs.html#","page":"Gas Concentrations","title":"Gas Concentrations","text":"CurrentModule = RRTMGP.GasConcentrations","category":"page"},{"location":"RRTMGP/GasConcs.html#","page":"Gas Concentrations","title":"Gas Concentrations","text":"GasConcSize\nConcField\nGasConcs","category":"page"},{"location":"RRTMGP/GasConcs.html#RRTMGP.GasConcentrations.GasConcSize","page":"Gas Concentrations","title":"RRTMGP.GasConcentrations.GasConcSize","text":"GasConcSize\n\nSizes for gas concentrations\n\n\n\n\n\n","category":"type"},{"location":"RRTMGP/GasConcs.html#RRTMGP.GasConcentrations.ConcField","page":"Gas Concentrations","title":"RRTMGP.GasConcentrations.ConcField","text":"ConcField\n\nGas concentration arrays\n\n\n\n\n\n","category":"type"},{"location":"RRTMGP/GasConcs.html#RRTMGP.GasConcentrations.GasConcs","page":"Gas Concentrations","title":"RRTMGP.GasConcentrations.GasConcs","text":"GasConcs{FT}\n\nEncapsulates a collection of volume mixing ratios (concentrations) of gases.  Each concentration is associated with a name, normally the chemical formula.\n\nFields\n\ngas_name\ngas names\nconcs\ngas concentrations\nncol\nnumber of columns\nnlay\nnumber of layers\ngsc\ngas concentration problem size\n\n\n\n\n\n","category":"type"},{"location":"RRTMGP/GasConcs.html#","page":"Gas Concentrations","title":"Gas Concentrations","text":"set_vmr!\nget_vmr!","category":"page"},{"location":"RRTMGP/GasConcs.html#RRTMGP.GasConcentrations.set_vmr!","page":"Gas Concentrations","title":"RRTMGP.GasConcentrations.set_vmr!","text":"set_vmr!(this::GasConcs{FT}, gas::String, w) where FT\n\nSet volume mixing ratio (vmr)\n\n\n\n\n\n","category":"function"},{"location":"RRTMGP/GasConcs.html#RRTMGP.GasConcentrations.get_vmr!","page":"Gas Concentrations","title":"RRTMGP.GasConcentrations.get_vmr!","text":"get_vmr!(array::AbstractArray{FT,2}, this::GasConcs{FT}, gas::String) where FT\n\nVolume mixing ratio ( nlay dependence only)\n\n\n\n\n\n","category":"function"},{"location":"RTE/RTESolver.html#RTE-Solver-1","page":"RTE Solver","title":"RTE Solver","text":"","category":"section"},{"location":"RTE/RTESolver.html#","page":"RTE Solver","title":"RTE Solver","text":"CurrentModule = RRTMGP.RTESolver","category":"page"},{"location":"RTE/RTESolver.html#","page":"RTE Solver","title":"RTE Solver","text":"rte_sw!\nrte_lw!\nexpand_and_transpose","category":"page"},{"location":"RTE/RTESolver.html#RRTMGP.RTESolver.rte_sw!","page":"RTE Solver","title":"RRTMGP.RTESolver.rte_sw!","text":"rte_sw!(atmos::AbstractOpticalPropsArry,\n             top_at_1,\n             mu0::Array{FT},\n             inc_flux,\n             sfc_alb_dir,\n             sfc_alb_dif,\n             fluxes,\n             inc_flux_dif=nothing)\n\nCompute fluxes fluxes (AbstractFluxes), given\n\natmos Optical properties provided as arrays (AbstractOpticalPropsArry)\ntop_at_1 bool indicating if the top of the domain is at index 1           (if not, ordering is bottom-to-top)\nmu0 cosine of solar zenith angle (ncol)\ninc_flux incident flux at top of domain W/m2\nsfc_alb_dir surface albedo for direct and\nsfc_alb_dif diffuse radiation (nband, ncol)\n\nand, optionally,\n\ninc_flux_dif incident diffuse flux at top of domain W/m2\n\n\n\n\n\n","category":"function"},{"location":"RTE/RTESolver.html#RRTMGP.RTESolver.rte_lw!","page":"RTE Solver","title":"RRTMGP.RTESolver.rte_lw!","text":"rte_lw!(optical_props, top_at_1,\n            sources, sfc_emis,\n            fluxes,\n            inc_flux=nothing, n_gauss_angles=nothing)\n\nInterface using only optical properties and source functions as inputs; fluxes as outputs.\n\noptical_props optical properties\ntop_at_1 indicates that the top of the domain is at index 1\nsources radiation sources\nsfc_emis emissivity at surface (nband, ncol)\nfluxes Array of AbstractFluxes. Default computes broadband fluxes at all levels          if output arrays are defined. Can be extended per user desires.\n[inc_flux] incident flux at domain top W/m2\n[n_gauss_angles] Number of angles used in Gaussian quadrature (no-scattering solution)\n\n\n\n\n\n","category":"function"},{"location":"RTE/RTESolver.html#RRTMGP.RTESolver.expand_and_transpose","page":"RTE Solver","title":"RRTMGP.RTESolver.expand_and_transpose","text":"expand_and_transpose(ops::AbstractOpticalProps,arr_in::Array{FT}) where FT\n\nExpand from band to g-point dimension, transpose dimensions (nband, ncol) -> (ncol,ngpt), of arr_out, given\n\nops - a AbstractOpticalProps\narr_in - input array\n\n\n\n\n\n","category":"function"},{"location":"RTE/Fluxes.html#Fluxes-1","page":"Fluxes","title":"Fluxes","text":"","category":"section"},{"location":"RTE/Fluxes.html#","page":"Fluxes","title":"Fluxes","text":"CurrentModule = RRTMGP.Fluxes","category":"page"},{"location":"RTE/Fluxes.html#","page":"Fluxes","title":"Fluxes","text":"FluxesBroadBand\nFluxesByBand","category":"page"},{"location":"RTE/Fluxes.html#RRTMGP.Fluxes.FluxesBroadBand","page":"Fluxes","title":"RRTMGP.Fluxes.FluxesBroadBand","text":"FluxesBroadBand{FT} <: AbstractFluxes{FT}\n\nContains upward, downward, net, and direct downward fluxes\n\nFields\n\nflux_up\nupward flux\nflux_dn\ndownward flux\nflux_net\nnet flux\nflux_dn_dir\ndownward direct flux\n\n\n\n\n\n","category":"type"},{"location":"RTE/Fluxes.html#RRTMGP.Fluxes.FluxesByBand","page":"Fluxes","title":"RRTMGP.Fluxes.FluxesByBand","text":"FluxesByBand{FT} <: AbstractFluxes{FT}\n\nContains both broadband and by-band fluxes\n\nFields\n\nfluxes_broadband\nbnd_flux_up\nupward flux\nbnd_flux_dn\ndownward flux\nbnd_flux_net\nnet flux\nbnd_flux_dn_dir\ndownward direct flux\n\n\n\n\n\n","category":"type"},{"location":"RTE/Fluxes.html#","page":"Fluxes","title":"Fluxes","text":"reduce!\nare_desired","category":"page"},{"location":"RTE/Fluxes.html#RRTMGP.Fluxes.reduce!","page":"Fluxes","title":"RRTMGP.Fluxes.reduce!","text":"reduce!(this::FluxesBroadBand,\n             gpt_flux_up::A,\n             gpt_flux_dn::A,\n             spectral_disc::AbstractOpticalProps,\n             top_at_1::Bool,\n             gpt_flux_dn_dir=nothing)\n\nCompute FluxesBroadBand this by summing over the spectral dimension, given\n\ngpt_flux_up upward fluxes by gpoint [W/m2]\ngpt_flux_dn downward fluxes by gpoint [W/m2]\nspectral_disc optical properties containing spectral information\ntop_at_1 bool indicating at top\n\noptional:\n\ngpt_flux_dn_dir downward direct flux\n\n\n\n\n\nreduce!(this::FluxesByBand,\n                   gpt_flux_up::Array{FT,3},\n                   gpt_flux_dn::Array{FT,3},\n                   spectral_disc::AbstractOpticalProps,\n                   top_at_1::Bool,\n                   gpt_flux_dn_dir::Union{Nothing,Array{FT,3}}=nothing)\n\nReduces fluxes by-band to broadband in FluxesByBand this, given\n\ngpt_flux_up fluxes by gpoint [W/m2]\ngpt_flux_dn fluxes by gpoint [W/m2]\nspectral_disc a AbstractOpticalProps struct containing spectral information\ntop_at_1 bool indicating at top\n\nand, optionally,\n\ngpt_flux_dn_dir direct flux downward\n\n\n\n\n\n","category":"function"},{"location":"RTE/Fluxes.html#RRTMGP.Fluxes.are_desired","page":"Fluxes","title":"RRTMGP.Fluxes.are_desired","text":"are_desired(this::FluxesBroadBand)\n\nBool indicating if any fluxes desired from this set of g-point fluxes. We can tell because memory will be allocated for output\n\n\n\n\n\nare_desired(this::FluxesByBand)\n\nBoolean indicating if any fluxes desired from this set of g-point fluxes.\n\n\n\n\n\n","category":"function"},{"location":"index.html#RRTMGP.jl-1","page":"Home","title":"RRTMGP.jl","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"Julia implementation of Rapid and accurate Radiative Transfer Model for General Circulation Models in Parallel (RRTMGP).","category":"page"},{"location":"index.html#Code-structure-1","page":"Home","title":"Code structure","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"RRTMGP is fundamentally split into two parts:","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"RRTMGP Compute optical depth given atmospheric conditions (pressure, temperature, gas concentrations, grid)\nRTE Compute fluxes given optical depth","category":"page"},{"location":"RRTMGP/GasOptics.html#Gas-Optics-1","page":"Gas Optics","title":"Gas Optics","text":"","category":"section"},{"location":"RRTMGP/GasOptics.html#","page":"Gas Optics","title":"Gas Optics","text":"CurrentModule = RRTMGP.GasOptics","category":"page"},{"location":"RRTMGP/GasOptics.html#","page":"Gas Optics","title":"Gas Optics","text":"Reference\nAuxVars\nGasOpticsVars\nInternalSourceGasOptics\nExternalSourceGasOptics","category":"page"},{"location":"RRTMGP/GasOptics.html#RRTMGP.GasOptics.Reference","page":"Gas Optics","title":"RRTMGP.GasOptics.Reference","text":"Reference{FT}\n\nReference variables for look-up tables / interpolation\n\nFields\n\npress\npress_log\ntemp\npress_min\npress_max\ntemp_min\ntemp_max\npress_log_delta\ntemp_delta\npress_trop_log\nvmr\n\n\n\n\n\n","category":"type"},{"location":"RRTMGP/GasOptics.html#RRTMGP.GasOptics.AuxVars","page":"Gas Optics","title":"RRTMGP.GasOptics.AuxVars","text":"AuxVars{I}\n\nAuxiliary indexes for variables in the upper and lower levels of the atmosphere.\n\nFields\n\nidx_minor\nindexes for determining col_gas\nidx_minor_scaling\nindexes that have special treatment in density scaling\n\n\n\n\n\n","category":"type"},{"location":"RRTMGP/GasOptics.html#RRTMGP.GasOptics.GasOpticsVars","page":"Gas Optics","title":"RRTMGP.GasOptics.GasOpticsVars","text":"GasOpticsVars{FT,I}\n\nVariables defined at\n\nupper  (log(p) < ref.presstroplog)\nlower  (log(p) > ref.presstroplog)\n\nlevels of the atmosphere for both full and reduced sets of gases.\n\nFields\n\nminor_limits_gpt\nminor g-point limits\nminor_scales_with_density\nminor scales with density\nscale_by_complement\nscale by complement\nkminor_start\nkminor start\nkminor\nkminor\nscaling_gas\nscaling gas\nminor_gases\nminor gases\n\n\n\n\n\n","category":"type"},{"location":"RRTMGP/GasOptics.html#RRTMGP.GasOptics.InternalSourceGasOptics","page":"Gas Optics","title":"RRTMGP.GasOptics.InternalSourceGasOptics","text":"InternalSourceGasOptics{FT,I} <: AbstractGasOptics{FT,I}\n\nGas optics with internal sources (for longwave radiation)\n\nFields\n\nref\nReference data\noptical_props\nBase optical properties\nlower\nGasOpticsVars in the lower atmosphere\nupper\nGasOpticsVars in the upper atmosphere\nlower_aux\nAuxiliary variables (index maps) in the lower atmosphere\nupper_aux\nAuxiliary variables (index maps) in the upper atmosphere\ngas_names\nPresent gas names\nkmajor\nAbsorption coefficient for major species (g-point,eta,pressure,temperature)\nflavor\nmajor species pair; [2, nflav]\ngpoint_flavor\nFlavor per g-point: lower.flavor = gpoint_flavor[1, 1:ngpt], upper.flavor = gpoint_flavor[2, 1:ngpt]\nis_key\nIndicates whether a key species is in any band\nplanck_frac\nStored fraction of Planck irradiance in band for given g-point\ntotplnk\nintegrated Planck irradiance by band; [Planck temperatures,band]\ntotplnk_delta\ntemperature steps in totplnk\nkrayl\nAbsorption coefficient for Rayleigh scattering [g-point,eta,temperature,upper/lower atmosphere]\n\n\n\n\n\n","category":"type"},{"location":"RRTMGP/GasOptics.html#RRTMGP.GasOptics.ExternalSourceGasOptics","page":"Gas Optics","title":"RRTMGP.GasOptics.ExternalSourceGasOptics","text":"ExternalSourceGasOptics{FT,I} <: AbstractGasOptics{FT,I}\n\nGas optics with external sources (for shortwave radiation)\n\nFields\n\nref\nReference data\noptical_props\nBase optical properties\nlower\nGasOpticsVars in the lower atmosphere\nupper\nGasOpticsVars in the upper atmosphere\nlower_aux\nAuxiliary variables (index maps) in the lower atmosphere\nupper_aux\nAuxiliary variables (index maps) in the upper atmosphere\ngas_names\nPresent gas names\nkmajor\nAbsorption coefficient for major species (g-point,eta,pressure,temperature)\nflavor\nmajor species pair; [2, nflav]\ngpoint_flavor\nFlavor per g-point: lower.flavor = gpointflavor[1, g-point], upper.flavor = gpointflavor[2, g-point]\nis_key\nIndicates whether a key species is in any band\nsolar_src\nincoming solar irradiance (g-point)\nkrayl\nabsorption coefficient for Rayleigh scattering (g-point,eta,temperature,upper/lower atmosphere)\n\n\n\n\n\n","category":"type"}]
}
