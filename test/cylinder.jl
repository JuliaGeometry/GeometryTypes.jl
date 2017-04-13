@testset "Cylinder" begin
@testset "constructors" begin
    s = Cylinder(Point([1,2]),Point([3,4]),5)
    @test typeof(s) == Cylinder{2,Int}
    @test typeof(s) == Cylinder2{Int}
    @test origin(s) == Point{2,Int}([1,2])
    @test extremity(s) == Point{2,Int}([3,4])
    @test radius(s) == 5
    @test height(s) == norm([1,2]-[3,4])
    @test norm(direction(s) - [2,2]./norm([1,2]-[3,4]))<1e-10

    v1 = rand(Float64,3); v2 = rand(Float64,3); R = rand()
    s = Cylinder(Point(v1),Point(v2),R)
    @test typeof(s) == Cylinder{3,Float64}
    @test typeof(s) == Cylinder3{Float64}
    @test origin(s) == Point{3,Float64}(v1)
    @test extremity(s) == Point{3,Float64}(v2)
    @test radius(s) == R
    @test height(s) == norm(v2-v1)
    @test norm(direction(s) - (v2-v1)./norm(v2-v1))<1e-10
  end
end

@testset "decompose" begin
    s = Cylinder(Point([1,2]),Point([3,4]),5)

  end
end
