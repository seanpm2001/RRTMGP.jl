pushfirst!(LOAD_PATH, joinpath(@__DIR__, ".."))
using Documenter
using LaTeXStrings
using RRTMGP

makedocs(
    sitename = "RRTMGP.jl",
    doctest = false,
    strict = false,
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        mathengine = MathJax(Dict(
            :TeX => Dict(
                :equationNumbers => Dict(:autoNumber => "AMS"),
                :Macros => Dict(),
            ),
        )),
    ),
    clean = false,
    modules = [Documenter, RRTMGP],
    pages = Any[
        "Home"=>"index.md",
        "Mathematical Formulation"=>"MathFormulation.md",
        "Optics"=>Any[
            "Angular Discretization" => "optics/AngularDiscretizations.md"
            "Atmospheric State" => "optics/AtmosphericStates.md"
            "Boundary Conditions" => "optics/BCs.md"
            "Fluxes" => "optics/Fluxes.md"
            "Utilities for gray radiation simulation" => "optics/GrayUtils.md"
            "Lookup Tables" => "optics/LookUpTables.md"
            "Optics" => "optics/Optics.md"
            "Solver struct" => "optics/RTE.md"
            "Source Functions" => "optics/Sources.md"
            "Volume Mixing Ratios" => "optics/Vmrs.md"
        ],
        "RTE"=>Any["RTE Solver"=>"rte/RTESolver.md"],
        "References"=>"References.md",
    ],
)

deploydocs(repo = "github.com/CliMA/RRTMGP.jl.git", target = "build")
