context("SimpleRectangle") do
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
