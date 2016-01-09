context("Polytopes") do

context("Constructors") do
    p1 = Polygon(Point(0,0), Point(1,0), Point(1,1), Point(0,1))
    @fact typeof(p1) --> Polytope{2,Point{2,Int}}
    @fact length(p1.elements) --> 4
end

context("scale") do
    p1 = Polygon(Point(0,0), Point(1,0), Point(1,1), Point(0,1))
    scale!(p1, Point(5,4))
    @fact p1.elements --> [Point(0,0), Point(5,0), Point(5,4), Point(0,4)]
end

context("Polygon Volume") do
    p = Polygon(Point(-.5,-.5), Point(-.5, .5), Point(.5,.5))
    @fact volume(p) --> 0.5
    p = Polygon(Point(-.5,-.5), Point(.5,-.5), Point(.5,.5))
    @fact volume(p) --> -0.5
end
end
