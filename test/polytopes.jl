context("Polytopes") do

context("Constructors") do
    p = Polyhedron(Simplex(:a,:b,:c),
                   Simplex(:b,:a,:d),
                   Simplex(:c,:b,:d),
                   Simplex(:a,:c,:d))
    @fact typeof(p) --> Polytope{3,Simplex{3,Symbol}}
    @fact length(elements(p)) --> 4
    p1 = Polygon(Point(0,0), Point(1,0), Point(1,1), Point(0,1))
    @fact typeof(p1) --> Polytope{2,Point{2,Int}}
    @fact length(p1.elements) --> 4
end

context("scale") do
    p1 = Polygon(Point(0,0), Point(1,0), Point(1,1), Point(0,1))
    scale!(p1, Point(5,4))
    @fact p1.elements --> [Point(0,0), Point(5,0), Point(5,4), Point(0,4)]
end

context("Polygon volume") do
    p = Polygon(Point(-.5,-.5), Point(-.5, .5), Point(.5,.5))
    @fact volume(p) --> 0.5
    p = Polygon(Point(-.5,-.5), Point(.5,-.5), Point(.5,.5))
    @fact volume(p) --> -0.5
end

context("Polygon centroid") do
    p1 = Polygon(Point(-.5,-.5), Point(-.5, .5), Point(.5,.5), Point(.5,-.5))
    p2 = Polygon(Point(-.5,-.5), Point(.5,-.5), Point(.5,.5), Point(-.5,.5))
    @fact centroid(p1) --> Point(0,0)
    @fact centroid(p1) --> centroid(p2)
    p3 = Polygon(Point(0.,0), Point(4., 0), Point(4.,2), Point(0.,2))
    @fact centroid(p3) --> Point(2,1)
end

end
