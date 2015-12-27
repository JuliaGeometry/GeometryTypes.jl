using GeometryTypes, ColorTypes
using FactCheck
typealias Vec3f0 Vec{3, Float32}


facts("GeometryTypes") do
    include("hyperrectangles.jl")
    include("faces.jl")
    include("meshes.jl")
    include("distancefields.jl")
    include("primitives.jl")
    include("decompose.jl")
    include("simplerectangle.jl")
    include("hypersphere.jl")
end

FactCheck.exitstatus()
