context("SimpleRectangle") do
context("constructors") do
    s = SimpleRectangle(1,2,3,4)
    @fact typeof(s) --> SimpleRectangle{Int}
    @fact width(s) --> 3
    @fact height(s) --> 4
    @fact area(s) --> 12
    @fact minimum(s) --> Point(1,2)
    @fact maximum(s) --> Point(4,6)
    h = HyperRectangle(s)
    @fact typeof(h) --> HyperRectangle{2,Int}
    @fact h --> HyperRectangle(1,2,4,6)
    h = HyperRectangle{3,Int}(s)
    @fact h --> HyperRectangle(1,2,0,4,6,0)

    @fact SimpleRectangle(Vec(2,3)) --> SimpleRectangle(0,0,2,3)
end

context("setops") do
    r1 = SimpleRectangle(0,0,2,2)
    r2 = SimpleRectangle(2,2,2,2)
    r3 = SimpleRectangle(1,1,2,2)
    r4 = SimpleRectangle(0.5,0.5,3.,3.)
    @fact intersect(r1,r2) --> SimpleRectangle(2,2,0,0)
    @fact intersect(r1,r3) --> SimpleRectangle(1,1,1,1)
    @fact intersect(r1,r4) --> SimpleRectangle(0.5,0.5,1.5,1.5)
end
end
