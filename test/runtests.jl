using GeometryTypes, ColorTypes
using Test
using Test: @inferred
using LinearAlgebra


@testset "GeometryTypes" begin
    include("baseutils.jl")
    include("convexhulls.jl")
    include("polygons.jl")
    include("hyperrectangles.jl")
    include("faces.jl")
    include("meshes.jl")
    include("distancefields.jl")
    include("primitives.jl")
    include("decompose.jl")
    include("simplerectangle.jl")
    include("hypersphere.jl")
    include("typeutils.jl")
    include("simplices.jl")
    include("gjk.jl")
    include("lines.jl")
    include("polygons.jl")
    include("cylinder.jl")
end
