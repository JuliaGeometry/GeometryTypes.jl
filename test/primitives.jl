context("Primitives") do
    @fact Pyramid(Point(0,0,0),1,2) --> Pyramid{Int}(Point{3,Int}((0,0,0)),1,2)
    @fact Particle(Point(0,0,0), Vec(1,1,1)) --> Particle{3,Int}(Point{3,Int}((0,0,0)),Vec{3,Int}((1,1,1)))
    @fact HyperCube(Vec(0,0,0), 1) --> HyperCube{3,Int}(Vec{3,Int}(0,0,0), 1)

    centered_rect = centered(HyperCube)
    @fact centered_rect --> HyperCube{3,Float32}(Vec3f0(-0.5), 1f0)
    centered_rect = centered(HyperCube{2})
    @fact centered_rect --> HyperCube{2,Float32}(Vec2f0(-0.5f0), 1f0)

    centered_rect = centered(HyperCube{2, Float64})
    @fact centered_rect --> HyperCube{2,Float64}(Vec(-0.5,-0.5), 1.)

    centered_rect = centered(HyperCube{3, Float32})
    @fact centered_rect --> HyperCube{3,Float32}(Vec3f0(-0.5), 1f0)

end

context("Simplex") do
    s = Simplex(Point(1,2,3))
    @fact s --> Simplex{1,Point{3,Int}}((Point{3,Int}((1,2,3)),))
    s = Simplex(Point(1,2), Point(2,3))
    @fact s --> Simplex{2,Point{2,Int}}((Point{2,Int}((1,2)),Point{2,Int}((2,3))))
end
