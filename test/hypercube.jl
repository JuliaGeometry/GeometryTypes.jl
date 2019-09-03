context("HyperCubes") do
    h = HyperCube(Vec(0,1,2), 4)
    @fact origin(h) --> Point(0,1,2)
    @fact widths(h) --> Point(4,4,4)
    @fact minimum(h) --> Point(0,1,2)
    @fact maximum(h) --> Point(4,5,6)
end
