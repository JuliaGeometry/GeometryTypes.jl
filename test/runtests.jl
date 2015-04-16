using HyperRectangles
using HyperRectangles.Relations
using HyperRectangles.Operations
using Base.Test

# test constructors and containment
let
    a = HyperRectangle(Float64, 4)
    @test a == HyperRectangle{Float64,4}([Inf,Inf,Inf,Inf],[-Inf,-Inf,-Inf,-Inf])

    update!(a, [1,2,3,4])

    @test a == HyperRectangle{Float64,4}([1.0,2.0,3.0,4.0],[1.0,2.0,3.0,4.0])
    @test a != HyperRectangle{Float64,4}([3.0,2.0,3.0,4.0],[1.0,2.0,3.0,4.0])

    update!(a, [5,6,7,8])

    b = HyperRectangle{Float64,4}([1.0,2.0,3.0,4.0],[5.0,6.0,7.0,8.0])
    @test a == b
    @test isequal(a,b)

    @test max(a) == [5.0,6.0,7.0,8.0]
    @test min(a) == [1.0,2.0,3.0,4.0]

    @test_throws ErrorException HyperRectangle([1.0,2.0,3.0],[1.0,2.0,3.0,4.0])

    @test in(a,b) && in(b,a) && contains(a,b) && contains(b,a)

    c = HyperRectangle([1.1,2.1,3.1,4.1],[4.0,5.0,6.0,7.0])

    @test !in(a,c) && in(c,a) && contains(a,c) && !contains(c,a)
end

# Testing split function
let
    d = HyperRectangle{Float64,4}([1.0,2.0,3.0,4.0],[2.0,3.0,4.0,5.0])
    d1, d2 = split(d, 3, 3.5)

    @test d1.max[3] == 3.5 && d1.min[3] == 3.0
    @test d2.max[3] == 4.0 && d2.min[3] == 3.5
end
