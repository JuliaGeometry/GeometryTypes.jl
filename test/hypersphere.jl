context("HyperSphere") do
    @fact Sphere(Point(0,0,0), 4) --> HyperSphere{3,Int64}(Point{3,Int64}((0,0,0)),4)
    c = Circle(Point(0,0), 1)
    @fact c --> HyperSphere(Point(0,0), 1)
    @fact isinside(c, 1, 2) --> false
    @fact isinside(c, 0.5, 0.5) --> true
end
