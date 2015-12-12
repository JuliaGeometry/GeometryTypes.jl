context("SimpleRectangle") do
    s = SimpleRectangle(1,2,3,4)
    @fact typeof(s) --> SimpleRectangle{Int}
    h = HyperRectangle(s)
    @fact typeof(h) --> HyperRectangle{2,Int}
    @fact h --> HyperRectangle(1,2,4,6)
end
