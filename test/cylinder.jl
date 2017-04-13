@testset "Cylinder" begin
@testset "constructors" begin
    s = Cylinder(Point{2,Float32}([1,2]),Point{2,Float32}([3,4]),Float32(5.))
    @test typeof(s) == Cylinder{2,Float32}
    @test typeof(s) == Cylinder2{Float32}
    @test origin(s) == Point{2,Float32}([1,2])
    @test extremity(s) == Point{2,Float32}([3,4])
    @test radius(s) == 5
    @test abs(height(s)- norm([1,2]-[3,4]))<1e-5
    @test norm(direction(s) - Point{2,Float32}([2,2]./norm([1,2]-[3,4])))<1e-5

    v1 = rand(Float64,3); v2 = rand(Float64,3); R = rand()
    s = Cylinder(Point(v1),Point(v2),R)
    @test typeof(s) == Cylinder{3,Float64}
    @test typeof(s) == Cylinder3{Float64}
    @test origin(s) == Point{3,Float64}(v1)
    @test extremity(s) == Point{3,Float64}(v2)
    @test radius(s) == R
    @test height(s) == norm(v2-v1)
    @test norm(direction(s) - Point{3,Float64}((v2-v1)./norm(v2-v1)))<1e-10
  end

  @testset "decompose" begin
    s = Cylinder(Point{2,Float32}([1,2]),Point{2,Float32}([3,4]),Float32(5.))
    @test decompose(Point3{Float32},s,(2,3)) == [Point{3,Float32}(-0.7677671,3.767767,0.0),
                                                 Point{3,Float32}(2.767767,0.23223293,0.0),
                                                 Point{3,Float32}(0.23223293,4.767767,0.0),
                                                 Point{3,Float32}(3.767767,1.2322329,0.0),
                                                 Point{3,Float32}(1.2322329,5.767767,0.0),
                                                 Point{3,Float32}(4.767767,2.232233,0.0)]
    @test decompose(Face{3,Int,0},s,(2,3)) == [Face(1,2,4),
                                               Face(1,4,3),
                                               Face(3,4,6),
                                               Face(3,6,5)]
    v1 = Float64[1,2,3]; v2 = Float64[4,5,6]; R = Float64(5)
    s = Cylinder(Point(v1),Point(v2),R)
    @test decompose(Point3{Float64},s,8) == [Point{3,Float64}(4.535533905932738,-1.5355339059327373,3.0),
                                             Point{3,Float64}(7.535533905932738,1.4644660940672627,6.0),
                                             Point{3,Float64}(3.0412414523193148,4.041241452319315,-1.0824829046386295),
                                             Point{3,Float64}(6.041241452319315,7.041241452319315,1.9175170953613705),
                                             Point{3,Float64}(-2.535533905932737,5.535533905932738,2.9999999999999996),
                                             Point{3,Float64}(0.46446609406726314,8.535533905932738,6.0),
                                             Point{3,Float64}(-1.0412414523193152,-0.04124145231931431,7.0824829046386295),
                                             Point{3,Float64}(1.9587585476806848,2.9587585476806857,10.08248290463863)]
  @test decompose(Face{3,Int,0},s,6) == [Face(1,2,3),
                                         Face(3,2,4),
                                         Face(3,4,5),
                                         Face(5,4,6),
                                         Face(5,6,7),
                                         Face(7,6,8),
                                         Face(7,8,1),
                                         Face(1,8,2)]

  end
end
