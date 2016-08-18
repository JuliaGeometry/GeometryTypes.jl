
context("Lines") do
    context("linesegment intersect") do
        a = LineSegment(Point2f0(0,0), Point2f0(1,0))
        b = LineSegment(Point2f0(0.5,0.5), Point2f0(0.5,-0.5))
        @fact intersects(a,b) --> (true, Point2f0(0.5,0.0))

        a = LineSegment(Point2f0(0,0), Point2f0(0.499,0))
        b = LineSegment(Point2f0(0.5,0.5), Point2f0(0.5,-0.5))
        @fact intersects(a,b) --> (false, zero(Point2f0))
    end
    context("poly self intersections") do
        p1 = Point2f0[(x, sin(x)) for x in 0:.5:6]
        p2 = Point2f0[(p1[i][1], 0) for i=length(p1):-1:1]
        points = vcat(p1, p2)
        inds, intersects = self_intersections(points)
        @fact inds --> [7,19]
        @fact intersects --> Point2f0[(3.1434426,0.0)]
        polys = split_intersections(points)
        @fact length(polys) --> 2
        @fact length(polys[1]) --> 12
        @fact length(polys[2]) --> 15


        u = linspace(0, 2pi, 200)
        points = Point2f0[(sin(x), sin(2x)) for x in u]

        inds, intersects = self_intersections(points)
        @fact inds --> [1,100]
        @fact intersects --> Point2f0[(0.0,0.0)]
        polys = split_intersections(points)
        @fact length(polys) --> 2
        @fact length(polys[1]) --> 99
        @fact length(polys[2]) --> 102
    end
end
