@testset "SimpleRectangle" begin
@testset "constructors" begin
    s = SimpleRectangle(1,2,3,4)
    @test typeof(s) == SimpleRectangle{Int}
    @test width(s) == 3
    @test height(s) == 4
    @test area(s) == 12
    @test xwidth(s) == 4
    @test yheight(s) == 6
    @test minimum(s) == Point(1,2)
    @test maximum(s) == Point(4,6)
    @test origin(s) == Point(1,2)
    h = HyperRectangle(s)
    @test typeof(h) == HyperRectangle{2,Int}
    @test h == HyperRectangle(1,2,3,4)
    h = HyperRectangle{3,Int}(s)
    @test h == HyperRectangle(1,2,0,3,4,0)

    @test SimpleRectangle(Vec(2,3)) == SimpleRectangle(0,0,2,3)
end

@testset "setops" begin
    r1 = SimpleRectangle(0,0,2,2)
    r2 = SimpleRectangle(2,2,2,2)
    r3 = SimpleRectangle(1,1,2,2)
    r4 = SimpleRectangle(0.5,0.5,3.,3.)
    @test intersect(r1,r2) == SimpleRectangle(2,2,0,0)
    @test intersect(r1,r3) == SimpleRectangle(1,1,1,1)
    @test intersect(r1,r4) == SimpleRectangle(0.5,0.5,1.5,1.5)
end

@testset "indexing" begin
    r = SimpleRectangle(0,0,2,2)
    a = Matrix(1.0I, 4, 4)
    @test a[r] == Matrix(1.0I, 2, 2)
    a[r] = Matrix(I, 2, 2)*2
    @test a == [2 0 0 0; 0 2 0 0; 0 0 1 0; 0 0 0 1]
end

end