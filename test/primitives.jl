context("Primitives") do

    @fact Pyramid(Point(0,0,0),1,2) --> Pyramid{Int64}(Point{3,Int64}((0,0,0)),1,2)
    @fact Particle(Point(0,0,0), Vec(1,1,1)) --> Particle{3,Int64}(Point{3,Int64}((0,0,0)),Vec{3,Int64}((1,1,1)))
    @fact Sphere(Point(0,0,0), 4) --> HyperSphere{3,Int64}(Point{3,Int64}((0,0,0)),4)
    @fact Circle(Point(0,0), 1) --> HyperSphere(Point(0,0), 1)
end

context("Simplex") do
    s = Simplex(Point(1,2,3))
    @fact s --> Simplex{1,Point{3,Int64}}((Point{3,Int64}((1,2,3)),))
    s = Simplex(Point(1,2), Point(2,3))
    @fact s --> Simplex{2,Point{2,Int64}}((Point{2,Int64}((1,2)),Point{2,Int64}((2,3))))
end
