context("Polytopes") do
    p1 = Polygon(Point(0,0), Point(1,0), Point(1,1), Point(0,1))
    @fact typeof(p1) --> Polytope{2,Point{2,Int}}
    @fact length(p1.elements) --> 4
end
