@testset "HyperSphere" begin
    @test Sphere(Point(0,0,0), 4) == HyperSphere{3,Int}(Point{3,Int}((0,0,0)),4)
    c = Circle(Point(0,0), 1)
    @test c == HyperSphere(Point(0,0), 1)
    @test origin(c) == Point(0,0)
    @test !( isinside(c, 1, 2) )
    @test isinside(c, 0.5, 0.5)

    centered_rect = centered(HyperSphere)
    @test centered_rect == HyperSphere{3,Float32}(Point3f0(0), 0.5f0)
    centered_rect = centered(HyperSphere{2})
    @test centered_rect == HyperSphere{2,Float32}(Point2f0(0),0.5f0)

    centered_rect = centered(HyperSphere{2, Float64})
    @test centered_rect == HyperSphere{2,Float64}(Point(0.,0.), 0.5)

    centered_rect = centered(HyperSphere{3, Float32})
    @test centered_rect == HyperSphere{3,Float32}(Point3f0(0), 0.5f0)

    @test widths(centered_rect) == Vec3f0(1)
    @test radius(centered_rect) == 0.5f0
    @test maximum(centered_rect) == Vec3f0(0.5f0)
    @test minimum(centered_rect) == Vec3f0(-0.5f0)
    s = Sphere(Point3f0(0), 1f0)
    f = decompose(Face{2, Int}, s, 3)
    # TODO 54 linesegments for 3 facets is too much.
    @test length(f) == 54
end
