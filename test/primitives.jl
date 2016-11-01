@testset "Primitives" begin
    @test Pyramid(Point(0,0,0),1,2) == Pyramid{Int}(Point{3,Int}((0,0,0)),1,2)
    @test Particle(Point(0,0,0), Vec(1,1,1)) == Particle{3,Int}(Point{3,Int}((0,0,0)),Vec{3,Int}((1,1,1)))
    @test HyperCube(Vec(0,0,0), 1) == HyperCube{3,Int}(Vec{3,Int}(0,0,0), 1)

    centered_rect = centered(HyperCube)
    @test centered_rect == HyperCube{3,Float32}(Vec3f0(-0.5), 1f0)
    centered_rect = centered(HyperCube{2})
    @test centered_rect == HyperCube{2,Float32}(Vec2f0(-0.5f0), 1f0)

    centered_rect = centered(HyperCube{2, Float64})
    @test centered_rect == HyperCube{2,Float64}(Vec(-0.5,-0.5), 1.)

    centered_rect = centered(HyperCube{3, Float32})
    @test centered_rect == HyperCube{3,Float32}(Vec3f0(-0.5), 1f0)

end

@testset "Simplex" begin
    s = Simplex(Point(1,2,3))
    @test s == Simplex{1,Point{3,Int}}((Point{3,Int}((1,2,3)),))
    s = Simplex(Point(1,2), Point(2,3))
    @test s == Simplex{2,Point{2,Int}}((Point{2,Int}((1,2)),Point{2,Int}((2,3))))
end