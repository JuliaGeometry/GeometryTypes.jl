@testset "Polygons" begin

@testset "construction" begin
    points = Point2f0[
        (0,6),
        (0,0),
        (3,0),
        (4,1),
        (6,1),
        (8,0),
        (12,0),
        (13,2),
        (8,2),
        (8,4),
        (11,4),
        (11,6),
        (6,6),
        (4,3),
        (2,6)
    ]
    mesh = GLNormalMesh(points)
    faces = polygon2faces(points, Triangle{Int})
    @test eltype(faces) == Triangle{Int}
    @test facetype(mesh) == GLTriangle

end

@testset "area-2d" begin
    points = Point2f0[
        (0,0),
        (1,0),
        (1,1),
        (0,1)
    ]
    @test area(points) ≈ 1f0
end

@testset "area-3d" begin
    points = Point3f0[
        (0,0,0),
        (1,0,0),
        (1,1,0),
        (0,1,0)
    ]
    @test area(points) ≈ 1f0
end

end
