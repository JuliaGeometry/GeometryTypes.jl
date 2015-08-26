using GeometryTypes, ColorTypes
using FactCheck
typealias Vec3f0 Vec{3, Float32}


facts("GeometryTypes") do
    include("test_hyperrectangles.jl")
    include("meshtypes.jl")
end

FactCheck.exitstatus()
