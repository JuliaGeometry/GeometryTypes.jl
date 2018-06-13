
@testset "Lines" begin
    @testset "linesegment intersect" begin
        a = LineSegment(Point2f0(0,0), Point2f0(1,0))
        b = LineSegment(Point2f0(0.5,0.5), Point2f0(0.5,-0.5))
        @test intersects(a,b) == (true, Point2f0(0.5,0.0))

        a = LineSegment(Point2f0(0,0), Point2f0(0.499,0))
        b = LineSegment(Point2f0(0.5,0.5), Point2f0(0.5,-0.5))
        @test intersects(a,b) == (false, zero(Point2f0))


        l = LineSegment(Point(6.0,11), Point(12.0,11))
        r1 = LineSegment(Point(9.0,10.0), Point(9.0, 13.0))
        r2 = LineSegment(Point(9.34365, 10.890), Point(9.34365, 13.402))
        intersect, p = intersects(l, r2)
        @test intersect
        @test p ≈ Point(9.34365, 11.0)
        intersect, p = intersects(l, r1)
        @test intersect
        @test p == Point(9.0, 11.0)

    end
    @testset "poly self intersections" begin
        p1 = Point2f0[(x, sin(x)) for x in 0:.5:6]
        p2 = Point2f0[(p1[i][1], 0) for i=length(p1):-1:1]
        points = vcat(p1, p2)
        inds, intersects = self_intersections(points)
        @test inds == [7,19]
        @test intersects ≈ Point2f0[(3.1434426,0.0)]
        polys = split_intersections(points)
        @test length(polys) == 2
        @test length(polys[1]) == 12
        @test length(polys[2]) == 15


        u = range(0, stop=2pi, length=200)
        points = Point2f0[(sin(x), sin(2x)) for x in u]

        inds, intersects = self_intersections(points)
        @test inds == [1,100]
        @test intersects == Point2f0[(0.0,0.0)]
        polys = split_intersections(points)
        @test length(polys) == 2
        @test length(polys[1]) == 99
        @test length(polys[2]) == 102
    end
end
