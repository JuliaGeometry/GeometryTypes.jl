#! /usr/bin/env julia

using Documenter
using GeometryTypes


makedocs(
    format = :html,
    sitename = "GeometryTypes.jl",
    pages = [
        "index.md",
        "operations.md",
        "types.md",
    ],
    modules = [GeometryTypes]
)

deploydocs(
    repo = "github.com/JuliaGeometry/GeometryTypes.jl.git",
    julia  = "1.0",
    latest = "master",
    target = "build",
    deps = nothing,  # we use the `format = :html`, without `mkdocs`
    make = nothing,  # we use the `format = :html`, without `mkdocs`
)
