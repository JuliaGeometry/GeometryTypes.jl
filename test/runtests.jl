using GeometryTypes, ColorTypes
using FactCheck
import Base.Test.@inferred

facts("GeometryTypes") do
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
    include("convexhulls.jl")
    include("gjk.jl")
    include("lines.jl")
end

FactCheck.exitstatus()
