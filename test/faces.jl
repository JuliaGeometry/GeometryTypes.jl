@testset "faces" begin

@testset "constructors" begin
    f1 = Face(1,2,3)
    @test f1 == Face{3,Int,0}(1,2,3)
    @test Face{3,Int,0}(f1) == f1
    @test Face{3,UInt8,0}(f1) == Face{3,UInt8,0}(1,2,3)
    @test Face{3,Int,-1}(f1) == Face{3,Int,-1}(0,1,2)
end

@testset "getindex" begin
    a = [1,2,3,4]
    @test a[Face{3,Int,0}(1,2,3)] == (1,2,3)
    @test a[Face{3,Int,-1}(0,1,2)] == (1,2,3)
    @test a[Face{3,Int,1}(2,3,4)] == (1,2,3)
end

@testset "setindex" begin
    a = [1,2,3,4]
    a[Face(1,2,3)] = [7,6,5]
    @test a == [7,6,5,4]
end

end