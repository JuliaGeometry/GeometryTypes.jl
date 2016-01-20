context("eltype_or") do
    @fact eltype_or(HyperCube, nothing) --> nothing
    @fact eltype_or(HyperCube{2}, nothing) --> nothing
    @fact eltype_or(HyperCube{2, Float32}, nothing) --> Float32
end
context("ndims_or") do
    @fact ndims_or(HyperCube, nothing) --> nothing
    @fact ndims_or(HyperCube{2}, nothing) --> 2
    @fact ndims_or(HyperCube{2, Float32}, nothing) --> 2
end
