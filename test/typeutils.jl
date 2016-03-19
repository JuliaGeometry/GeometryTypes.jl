context("eltype") do
    @fact eltype_or(HyperCube, nothing) --> nothing
    @fact eltype_or(HyperCube{2}, nothing) --> nothing
    @fact eltype_or(HyperCube{2, Float32}, nothing) --> Float32
    @fact eltype_or(SimpleRectangle, Int) --> Int
    @fact eltype_or(SimpleRectangle{Float32}, Int) --> Float32

    @fact eltype(SimpleRectangle) --> Any
    @fact eltype(HyperCube{2}) --> Any
    @fact eltype(HyperCube{2, Float32}) --> Float32
    @fact eltype(SimpleRectangle{Float32}) --> Float32
end
context("ndims") do
    @fact ndims_or(HyperCube, nothing) --> nothing
    @fact ndims_or(HyperCube{2}, nothing) --> 2
    @fact ndims_or(HyperCube{2, Float32}, nothing) --> 2
    @fact ndims_or(SimpleRectangle, 0) --> 2

    @fact ndims(SimpleRectangle) --> 2
    @fact ndims(HyperCube{2}) --> 2
    @fact ndims(HyperCube{2, Float32}) --> 2
    @fact_throws ndims(HyperCube)
end
