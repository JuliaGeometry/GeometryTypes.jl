@testset "eltype" begin
    @test eltype_or(HyperCube, nothing) == nothing
    @test eltype_or(HyperCube{2}, nothing) == nothing
    @test eltype_or(HyperCube{2, Float32}, nothing) == Float32
    @test eltype_or(SimpleRectangle, Int) == Int
    @test eltype_or(SimpleRectangle{Float32}, Int) == Float32

    @test eltype(SimpleRectangle(0,0,1,1)) == Int
    @test eltype(SimpleRectangle) == Any
    @test eltype(HyperCube{2}) == Any
    @test eltype(HyperCube{2, Float32}) == Float32
    @test eltype(SimpleRectangle{Float32}) == Float32
end
@testset "ndims" begin
    @test ndims_or(HyperCube, nothing) == nothing
    @test ndims_or(HyperCube{2}, nothing) == 2
    @test ndims_or(HyperCube{2, Float32}, nothing) == 2
    @test ndims_or(SimpleRectangle, 0) == 2

    @test ndims(SimpleRectangle(0,0,1,1)) == 2
    @test ndims(SimpleRectangle) == 2
    @test ndims(HyperCube{2}) == 2
    @test ndims(HyperCube{2, Float32}) == 2
    @test_throws Exception ndims(HyperCube)
end