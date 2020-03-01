using LinearAlgebra

@testset "Hyper Cubes" begin
    @testset "Core" begin
        x = centered(HyperCube)
        @test origin(x) == Vec3f0(-0.5)
        @test width(x) == 1.0f0
        @test widths(x) == Vec3f0(1.0)
        @test maximum(x) == Vec3f0(0.5)
        @test minimum(x) == Vec3f0(-0.5)
    end
end
@testset "Hyper Rectangles" begin


@testset "constructors and containment" begin
    # HyperRectangle(vals...)
    a = HyperRectangle(0,0,1,1)
    @test a == HyperRectangle{2,Int}(Vec(0,0),Vec(1,1))

    b = HyperRectangle(0,0,1,1,1,2)
    @test b == HyperRectangle{3,Int}(Vec(0,0,1),Vec(1,1,2))

    a = AABB(0,0,0,1,1,1)
    b = AABB(Vec(0,0,0), Vec(1,1,1))
    @test a == HyperRectangle(0,0,0,1,1,1)
    @test a == b

    a = HyperRectangle{4, Float64}()
    @test a == HyperRectangle{4, Float64}(Vec(Inf,Inf,Inf,Inf), Vec(-Inf,-Inf,-Inf,-Inf))

    a = update(a, Vec(1,2,3,4))

    @test a == HyperRectangle{4, Float64}(Vec(1.0,2.0,3.0,4.0),Vec4f0(0.0))
    @test !( a == HyperRectangle{4, Float64}(Vec(3.0,2.0,3.0,4.0),Vec(1.0,2.0,3.0,4.0)) )

    a = update(a, Vec(5,6,7,8))


    b = HyperRectangle{4, Float64}(Vec(1.0,2.0,3.0,4.0),Vec4f0(4.0))
    @test widths(b) == Vec(4., 4., 4., 4.)
    @test a == b
    @test isequal(a,b)

    @test maximum(a) == Vec(5.0,6.0,7.0,8.0)
    @test minimum(a) == Vec(1.0,2.0,3.0,4.0)
    @test origin(a) == Vec(1.0,2.0,3.0,4.0)

    @test_throws MethodError HyperRectangle(Vec(1.0,2.0,3.0), Vec(1.0,2.0,3.0,4.0))

    @test (in(a,b) && in(b,a) && contains(a,b) && contains(b,a))

    c = HyperRectangle(Vec(1.1,2.1,3.1,4.1),Vec4f0(3.8))

    @test (!in(a,c) && in(c,a) && contains(a,c) && !contains(c,a))

    #conversion
    h = HyperRectangle(0,0,1,1)
    @test HyperRectangle{2,Float64}(h) == HyperRectangle(0.,0.,1.,1.)

    # AABB
    a = AABB(0,0,1,1)
    @test a == HyperRectangle{3,Int}(Vec(0,0, 0),Vec(1,1,0))

    centered_rect = centered(HyperRectangle)
    @test centered_rect == HyperRectangle{3,Float32}(Vec3f0(-0.5),Vec3f0(1))
    centered_rect = centered(HyperRectangle{2})
    @test centered_rect == HyperRectangle{2,Float32}(Vec2f0(-0.5),Vec2f0(1))

    centered_rect = centered(HyperRectangle{2, Float64})
    @test centered_rect == HyperRectangle{2,Float64}(Vec(-0.5, -0.5),Vec(1.,1.))

    centered_rect = centered(HyperRectangle{3, Float32})
    @test centered_rect == HyperRectangle{3,Float64}(Vec(-0.5,-0.5,-0.5),Vec(1.,1.,1.))


end

# Testing split function
@testset "Testing split function" begin
    d = HyperRectangle{4, Float64}(Vec(1.0,2.0,3.0,4.0),Vec4f0(1.0))
    d1, d2 = split(d, 3, 3.5)

    @test maximum(d1)[3] == 3.5
    @test minimum(d1)[3] == 3.0
    @test maximum(d2)[3] == 4.0
    @test minimum(d2)[3] == 3.5

    d = HyperRectangle(0,0,2,2)
    d1, d2 = split(d, 1, 1)
    @test d1 == HyperRectangle(0,0,1,2)
    @test d2 == HyperRectangle(1,0,1,2)
end


@testset "Test distance functions" begin
    a = HyperRectangle(Vec(0.0,0.0), Vec(1.0, 1.0))
    b = HyperRectangle(Vec(2.0,3.0), Vec(1.0, 1.0))
    p = Vec(2.5, 1.5)

    # Rect - Rect
    @test min_dist_dim(a, b, 1) == 1.0
    @test min_dist_dim(a, b, 2) == 2.0
    @test max_dist_dim(a, b, 1) == 3.0
    @test max_dist_dim(a, b, 2) == 4.0

    @test min_euclideansq(a, b) == 5.0
    @test max_euclideansq(a, b) == 25.0
    @test minmax_euclideansq(a, b) == (5.0, 25.0)

    @test min_euclidean(a, b) == sqrt(5.0)
    @test max_euclidean(a, b) == sqrt(25.0)
    @test minmax_euclidean(a, b) == (sqrt(5.0), sqrt(25.0))

    # Rect - Point
    @test min_dist_dim(a, p, 1) == 1.5
    @test max_dist_dim(a, p, 1) == 2.5
    @test minmax_dist_dim(a, p, 1) == (1.5, 2.5)

    @test min_dist_dim(a, p, 2) == 0.5
    @test max_dist_dim(a, p, 2) == 1.5
    @test minmax_dist_dim(a, p, 2) == (0.5, 1.5)

    @test min_euclideansq(a, p) == 2.5
    @test max_euclideansq(a, p) == 8.5
    @test minmax_euclideansq(a, p) == (2.5, 8.5)

    @test min_euclidean(a, p) == sqrt(2.5)
    @test max_euclidean(a, p) == sqrt(8.5)
    @test minmax_euclidean(a, p) == (sqrt(2.5), sqrt(8.5))

    p2 = Vec(0.75, 0.75)
    @test min_dist_dim(a, p2, 1) == 0.0
    @test min_dist_dim(a, p2, 2) == 0.0

    b2  = HyperRectangle(Vec(0.25, 0.25), Vec(0.75,0.75))
    @test min_dist_dim(a, b2, 1) == 0
    @test min_dist_dim(a, b2, 2) == 0
end
@testset "set operations" begin
    a = HyperRectangle(Vec(0,0),Vec(1,1))
    b = HyperRectangle(Vec(1,1),Vec(1,1))

    @test union(a,b) == union(b,a)
    @test union(a,b) == HyperRectangle(Vec(0,0), Vec(2,2))
    @test intersect(a,b) == intersect(b,a)
    @test intersect(a,b) == HyperRectangle(Vec(1,1), Vec(0,0))
    @test diff(a,b) == a
    @test diff(b,a) == b

    c = HyperRectangle(Vec(0,0),Vec(2,2))
    d = HyperRectangle(Vec(1,1),Vec(2,2))
    @test union(c,d) == union(d,c)
    @test union(c,d) == HyperRectangle(Vec(0,0), Vec(3,3))
    @test intersect(c,d) == intersect(d,c)
    @test intersect(c,d) == HyperRectangle(Vec(1,1), Vec(1,1))
    @test diff(c,d) == c
    @test diff(d,c) == d

end

# fact relations
@testset "relations" begin
    a = HyperRectangle(Vec(0,0),Vec(1,1))
    b = HyperRectangle(Vec(1,1),Vec(1,1))
    c = HyperRectangle(Vec(0,0),Vec(2,2))
    d = HyperRectangle(Vec(1,1),Vec(2,2))
    e = HyperRectangle(Vec(3,3),Vec(1,1))
    d = HyperRectangle(Vec(0.25,0.25),Vec(0.5,0.5))
    f = HyperRectangle(Vec(0.9,0.9), Vec(1.1,1.1))

    @test (finishes(b,c) && !finishes(c,b))
    @test (!finishes(a,b))
    @test (meets(a,b) && !meets(b,a))
    @test (before(a,e) && !before(e,a))
    @test (during(d,a) && !during(a,d))
    @test (starts(a,c) && !starts(c,a))
    @test (!starts(a,b))
    @test (!overlaps(a,b) && !overlaps(b,a))
    @test (overlaps(a,f) && !overlaps(f,a))
end

@testset "point membership" begin
    a = HyperRectangle{4, Float64}(Vec(1.0,2.0,3.0,4.0),Vec4f0(4.0))
    @test (in(Vec(4,5,6,7),a) && contains(a,Vec(4,5,6,7)))
    @test (in(Vec(5,6,7,8),a) && contains(a,Vec(5,6,7,8)))
    @test (!in(Vec(6,7,8,9),a) && !contains(a,Vec(6,7,8,9)))
end

@testset "from Points" begin
    a = HyperRectangle([Point(1,1), Point(2,3), Point(4,5), Point(0,-1)])
    @test a == HyperRectangle(0, -1, 4, 6)
    a = HyperRectangle{3,Int}([Point(1,1), Point(2,3), Point(4,5), Point(0,-1)])
    @test a == HyperRectangle(0,-1,0,4,6,0)
end

@testset "transforms" begin
    t = Mat3(
        1, 0, 0,
        0, 1, 0,
        1, 2, 0
    )

    h = t * HyperRectangle(0, 0, 1, 1)
    @test h == HyperRectangle(1, 2, 1, 1)
    t = Mat{2, 2}(0, 1, 1, 0)
    h = t * HyperRectangle(0, 0, 1, 2)

    @test h == HyperRectangle(0, 0, 2, 1)
    m = Mat4f0(1.0I)
    h = centered(HyperRectangle{3, Float32})
    @test h == h

end

@testset "boundingboxes" begin
    s = Sphere(Point3f0(0), 1f0)
    f = decompose(Face{2, Int}, s, 3)
    v = decompose(Point3f0, s, 3)
    x = view(v, f)
    bb1 = HyperRectangle(x)
    bb2 = HyperRectangle(v)
    @test bb1 == bb2
end

@testset "face-orientation" begin
    cube = HyperRectangle(Vec3f0(-0.5), Vec3f0(1))

    cube_faces = decompose(Face{3,Int32}, cube)
    cube_vertices = decompose(Point{3,Float32}, cube)

    cube_tris = [cube_vertices[f] for f in cube_faces]

    normals = [cross(t[2] - t[1], t[3] - t[1]) for t in cube_tris]
    centroids = sum.(cube_tris) ./ 3f0

    for (p, n) in zip(centroids, normals)
        @test (p ⋅ n) > 0f0
    end
end

end
