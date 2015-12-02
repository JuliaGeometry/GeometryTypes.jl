context("Primitives") do

    @fact Pyramid(Point(0,0,0),1,2) --> Pyramid{Int64}(Point{3,Int64}((0,0,0)),1,2)
    @fact Particle(Point(0,0,0), Vec(1,1,1)) --> Particle{3,Int64}(Point{3,Int64}((0,0,0)),Vec{3,Int64}((1,1,1)))
    @fact Sphere(Point(0,0,0), 4) --> HyperSphere{3,Int64}(Point{3,Int64}((0,0,0)),4)
end

context("Simplex") do
    s = Simplex(Point(1,2,3))
    @fact s --> Simplex{1,Point{3,Int64}}((Point{3,Int64}((1,2,3)),))
    s = Simplex(Point(1,2), Point(2,3))
    @fact s --> Simplex{2,Point{2,Int64}}((Point{2,Int64}((1,2)),Point{2,Int64}((2,3))))
end

context("PureSimplicialComplex") do
    p = PureSimplicialComplex{3,Symbol}()
    # symbolically construct a tetrahedra
    push!(p, Simplex(:x1, :x2, :x3))
    push!(p, Simplex(:x3, :x2, :x4))
    push!(p, Simplex(:x1, :x4, :x2))
    push!(p, Simplex(:x1, :x3, :x4))
    @fact length(p.simplices) --> 3
    @fact length(p.simplices[1]) --> 4
    @fact length(p.simplices[2]) --> 12
    @fact length(p.simplices[3]) --> 4
    @fact isclosed(p) --> true
    p2 = PureSimplicialComplex{3,Point{2,Int}}()
    push!(p2, Simplex(Point(0,0), Point(0,1), Point(1,0)))
    push!(p2, Simplex(Point(1,0), Point(1,0), Point(1,1)))
    @fact isclosed(p2) --> false
    @fact length(p2.simplices[1]) --> 4
    @fact length(p2.simplices[2]) --> 6
    @fact length(p2.simplices[3]) --> 2
end
