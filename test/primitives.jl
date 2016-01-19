context("Primitives") do
    @fact Pyramid(Point(0,0,0),1,2) --> Pyramid{Int}(Point{3,Int}((0,0,0)),1,2)
    @fact Particle(Point(0,0,0), Vec(1,1,1)) --> Particle{3,Int}(Point{3,Int}((0,0,0)),Vec{3,Int}((1,1,1)))
end

context("Simplex") do
    s = Simplex(Point(1,2,3))
    @fact s --> Simplex{1,Point{3,Int}}((Point{3,Int}((1,2,3)),))
    s = Simplex(Point(1,2), Point(2,3))
    @fact s --> Simplex{2,Point{2,Int}}((Point{2,Int}((1,2)),Point{2,Int}((2,3))))
end
