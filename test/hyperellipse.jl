@testset "HyperEllipse" begin
    @test Ellipsoid(Point(0,0,0), Vec(4, 3, 2)) == HyperEllipse{3,Int}(Point{3,Int}((0,0,0)),Vec{3,Int}((4,3,2)))
    c = Ellipse(Point(0,0), Vec(1,2))
    @test c == HyperEllipse(Point(0,0), Vec(1,2))
    @test origin(c) == Point(0,0)
    @test !( isinside(c, 1, 2) )
    @test isinside(c, 0.5, 0.5)

    centered_rect = centered(HyperEllipse)
    @test centered_rect == HyperEllipse{3,Float32}(Point3f0(0), Vec3f0(0.5))
    centered_rect = centered(HyperEllipse{2})
    @test centered_rect == HyperEllipse{2,Float32}(Point2f0(0), Vec2f0(0.5))

    centered_rect = centered(HyperEllipse{2, Float64})
    @test centered_rect == HyperEllipse{2,Float64}(Point(0.,0.), Vec(0.5, 0.5))

    centered_rect = centered(HyperEllipse{3, Float32})
    @test centered_rect == HyperEllipse{3,Float32}(Point3f0(0), Vec3f0(0.5))

    @test widths(centered_rect) == Vec3f0(1)
    @test radius(centered_rect) == Vec3f0(0.5)
    @test maximum(centered_rect) == Vec3f0(0.5f0)
    @test minimum(centered_rect) == Vec3f0(-0.5f0)
    s = Ellipsoid(Point3f0(0), Vec3f0(1))
    f = decompose(Face{2, Int}, s, 3)
    # TODO 54 linesegments for 3 facets is too much.
    @test length(f) == 16

    s = Ellipsoid(Point3f0(-1, 10, 5), Vec3f0(3))
    ps = decompose(Point3f0, s)
    bb = AABB(ps)
    # The maximum radius doesn't get sampled in the ellipsoid mesh, hence the smaller widths
    @test all(x-> x > 5.9 && x <= 6.0, widths(bb))
    middle = (minimum(bb) .+ (widths(bb) ./ 2))
    @test all(((x,y),)-> isapprox(x, y, atol = 0.05), zip((-1, 10, 5), middle))
end
