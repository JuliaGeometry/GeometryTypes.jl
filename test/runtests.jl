using GeometryTypes, ColorTypes
using Base.Test
import Base.Test.@inferred

# StaticArrays needs to get tagged first!
Pkg.checkout("StaticArrays", "sd/fixedsizearrays")

@testset "GeometryTypes" begin
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
    include("lines.jl")
    include("polygons.jl")
    #include("convexhulls.jl")
    #include("gjk.jl")
end
