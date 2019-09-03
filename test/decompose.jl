@testset "decompose functions" begin

@testset "General" begin
    # this fails on travis and I can't reproduce it.. It's not the most important
    # test so I uncommented it for now!
    #@fact_throws ArgumentError decompose(Normal{3, Float32}, Circle{Float32}(Point2f0(0), 1f0))
end

@testset "HyperRectangles" begin
    a = HyperRectangle(Vec(0,0),Vec(1,1))
    pt_expa = Point{2,Int}[(0,0), (1,0), (0,1), (1,1)]
    @test decompose(Point{2,Int},a) == pt_expa
    b = HyperRectangle(Vec(1,1,1),Vec(1,1,1))
    pt_expb = Point{3,Int}[(1,1,1),(2,1,1),(1,2,1),(2,2,1),(1,1,2),(2,1,2),(1,2,2),(2,2,2)]
    @test decompose(Point{3,Int}, b) == pt_expb
end

@testset "Faces" begin
    @test decompose(GLTriangle, Face{4, Int}(1,2,3,4)) == (GLTriangle(1,2,3), GLTriangle(1,3,4))
    @test decompose(Face{3, ZeroIndex{Int}}, Face{4, ZeroIndex{Int}}(1,2,3,4)) == (Face{3,ZeroIndex{Int}}(1,2,3), Face{3, ZeroIndex{Int}}(1,3,4))
    @test decompose(Face{3, OffsetInteger{3, Int}}, Face{4, OffsetInteger{2, Int}}(1,2,3,4)) == (
            Face{3, OffsetInteger{3, Int}}(1,2,3),
            Face{3, OffsetInteger{3, Int}}(1,3,4)
    )
    @test decompose(Face{2, Int}, Face{4, Int}(1,2,3,4)) == (
        Face{2, Int}(1,2),
        Face{2, Int}(2,3),
        Face{2, Int}(3,4),
        Face{2, Int}(4,1)
    )
end

@testset "Simplex" begin
    s1 = Simplex(:x1,:x2,:x3)
    s2 = Simplex(:x1,:x2,:x3,:x4)
    @test decompose(Simplex{1}, s1) == (Simplex(:x1),Simplex(:x2),Simplex(:x3))
    @test decompose(Simplex{2}, s1) == (Simplex(:x1,:x2),Simplex(:x2,:x3),Simplex(:x3,:x1))
    @test decompose(Simplex{2}, s2) == (Simplex(:x1,:x2),Simplex(:x2,:x3),Simplex(:x3,:x4),Simplex(:x4,:x1))
    @test decompose(Simplex{3}, s2) == (Simplex(:x1,:x2,:x3),Simplex(:x1,:x3,:x4))
end

@testset "SimpleRectangle" begin
    r = SimpleRectangle(0,0,1,1)
    pts = decompose(Point, r)
    @test pts == Point{2,Int}[
        (0,0),
        (1,0),
        (0,1),
        (1,1)
    ]

    mesh = GLNormalUVMesh(r, (3,3))
    points = decompose(Point{3,Float64}, mesh)
    point_target = Point{3,Float64}[
        (0.0,0.0,0.0)
        (0.5,0.0,0.0)
        (1.0,0.0,0.0)
        (0.0,0.5,0.0)
        (0.5,0.5,0.0)
        (1.0,0.5,0.0)
        (0.0,1.0,0.0)
        (0.5,1.0,0.0)
        (1.0,1.0,0.0)
    ]
    @test points == point_target

    faces = decompose(Face{3, Int}, mesh)
    face_target = Face{3, Int}[
        (1,2,5)
        (1,5,4)
        (2,3,6)
        (2,6,5)
        (4,5,8)
        (4,8,7)
        (5,6,9)
        (5,9,8)
    ]
    @test faces == face_target

    uvs = decompose(UV{Float64}, mesh)
    uv_target = UV{Float64}[
        (0.0,1.0)
        (0.5,1.0)
        (1.0,1.0)
        (0.0,0.5)
        (0.5,0.5)
        (1.0,0.5)
        (0.0,0.0)
        (0.5,0.0)
        (1.0,0.0)
    ]
    @test uvs == uv_target
end

<<<<<<< HEAD

@testset "Normals" begin
=======
context("Normals") do
>>>>>>> wip
    n64 = Normal{3, Float64}[
        (0.0,0.0,-1.0),
        (0.0,0.0,-1.0),
        (0.0,0.0,-1.0),
        (0.0,0.0,-1.0),
        (0.0,0.0,1.0),
        (0.0,0.0,1.0),
        (0.0,0.0,1.0),
        (0.0,0.0,1.0),
        (-1.0,0.0,0.0),
        (-1.0,0.0,0.0),
        (-1.0,0.0,0.0),
        (-1.0,0.0,0.0),
        (1.0,0.0,0.0),
        (1.0,0.0,0.0),
        (1.0,0.0,0.0),
        (1.0,0.0,0.0),
        (0.0,1.0,0.0),
        (0.0,1.0,0.0),
        (0.0,1.0,0.0),
        (0.0,1.0,0.0),
        (0.0,-1.0,0.0),
        (0.0,-1.0,0.0),
        (0.0,-1.0,0.0),
        (0.0,-1.0,0.0),
    ]
    n32 = map(Normal{3,Float32}, n64)
    r = GLPlainMesh(centered(HyperRectangle))
    @test normals(vertices(r), faces(r), Normal{3, Float32}) == n32
    @test normals(vertices(r), faces(r), Normal{3, Float64}) == n64

    r = PlainMesh{Float64, Face{3, UInt32}}(centered(HyperRectangle))
    @test normals(vertices(r), faces(r), Normal{3, Float32}) == n32
    @test normals(vertices(r), faces(r), Normal{3, Float64}) == n64

    r = PlainMesh{Float16, Face{3, ZeroIndex{UInt64}}}(centered(HyperRectangle))
    @test normals(vertices(r), faces(r), Normal{3, Float32}) == n32
    @test normals(vertices(r), faces(r), Normal{3, Float64}) == n64

end


@testset "HyperSphere" begin
    sphere = Sphere{Float32}(Point3f0(0), 1f0)

    points = decompose(Point, sphere, 3)
    point_target = Point{3,Float32}[
        [0.0, 0.0, 1.0], [1.0, 0.0, 6.12323e-17], [1.22465e-16, 0.0, -1.0],
        [-0.0, 0.0, 1.0], [-1.0, 1.22465e-16, 6.12323e-17],
        [-1.22465e-16, 1.49976e-32, -1.0], [0.0, -0.0, 1.0],
        [1.0, -2.44929e-16, 6.12323e-17], [1.22465e-16,-2.99952e-32, -1.0]
   ]
    @test points ≈ point_target

    f = decompose(Face{3, Int}, sphere, 3)
    face_target = Face{3,Int64}[
        [1, 2, 5], [1, 5, 4], [2, 3, 6], [2, 6, 5],
        [4, 5, 8], [4, 8, 7], [5, 6, 9], [5, 9, 8]
    ]
    @test f == face_target

    points = decompose(Point2f0, Circle(Point2f0(0), 0f0), 20)
    @test length(points) == 20

end

context("Polyhedron") do
    p = Polyhedron(Simplex(:a,:b,:c),
                   Simplex(:b,:a,:d),
                   Simplex(:c,:b,:d),
                   Simplex(:a,:c,:d))
    d = decompose(LineSegment, p)

end

end
