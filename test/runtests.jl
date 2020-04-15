using GeometryTypes, ColorTypes
using Test
using Test: @inferred


@test !isnan(Point3f0(1))
@test isnan(Point3f0(NaN))
@test unit(Point3f0, 1) == Point3f0(1, 0, 0)
@test unit(Point3f0, 2) == Point3f0(0, 1, 0)
@test unit(Point3f0, 3) == Point3f0(0, 0, 1)

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
    include("capsule.jl")
    include("algorithms.jl")
end
