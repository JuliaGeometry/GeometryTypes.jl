using GeometryTypes: slice
@testset "Mesh Types" begin

@testset "Merging Mesh" begin
    baselen = 0.4f0
    dirlen = 2f0
    a = [
        (HyperRectangle{3,Float32}(Vec3f0(baselen), Vec3f0(dirlen, baselen, baselen)), RGBA(1f0,0f0,0f0,1f0)),
        (HyperRectangle{3,Float32}(Vec3f0(baselen), Vec3f0(baselen, dirlen, baselen)), RGBA(0f0,1f0,0f0,1f0)),
        (HyperRectangle{3,Float32}(Vec3f0(baselen), Vec3f0(baselen, baselen, dirlen)), RGBA(0f0,0f0,1f0,1f0))
    ]

    am = map(GLNormalMesh, a)
    axis = merge(am)
    axis2 = merge(am)
    @test axis == axis2 # test ==
    @test typeof(am[1]) == GLNormalColorMesh

    @test typeof(axis) == GLNormalAttributeMesh
    @test typeof(GLPlainMesh(axis)) == GLPlainMesh

    @test vertextype(axis) == Point{3, Float32}
    @test normaltype(axis) == Normal{3, Float32}
    @test facetype(axis) == Face{3, GLIndex}
    @test hasvertices(axis)
    @test hasfaces(axis)
    @test hasnormals(axis)
    @test !hascolors(axis)
end

@testset "Show" begin
    baselen = 0.4f0
    dirlen = 2f0
    m = GLNormalMesh(HyperRectangle{3,Float32}(Vec3f0(baselen),
                     Vec3f0(dirlen, baselen, baselen)))
    io = IOBuffer()
    show(io,m)
    seekstart(io)
    s = "HomogenousMesh(\n    faces: 12xGeometryTypes.Face{3,UInt32,-1},     normals: 24xGeometryTypes.Normal{3,Float32},     vertices: 24xFixedSizeArrays.Point{3,Float32}, )\n"
    #@fact readall(io) --> s #Win32 and Win64 have different ordering it seems.
end



@testset "Primitives" begin
    # issue #16
    #m = HomogenousMesh{Point{3,Float64},Face{3, Int}}(Sphere(Point(0,0,0), 1))
    #@fact length(vertices(m)) --> 145
    #@fact length(faces(m)) --> 288
end


@testset "Slice" begin
    test_mesh = HomogenousMesh(
        Point{3, Float64}[
            (0.0,0.0,10.0),
            (0.0,10.0,10.0),
            (0.0,0.0,0.0),
            (0.0,10.0,0.0),
            (10.0,0.0,10.0),
            (10.0,10.0,10.0),
            (10.0,0.0,0.0),
            (10.0,10.0,0.0)
        ],
        Face{3, Int}[
            (3,7,5),
            (1,3,5),
            (1,2,3),
            (2,4,3),
            (1,5,6),
            (2,1,6),
            (4,8,3),
            (3,8,7),
            (7,8,6),
            (7,6,5),
            (2,6,4),
            (4,6,8)
    ])
    s1 = slice(test_mesh, 1.0)
    s2 = slice(test_mesh, 2.0)
    s3 = slice(test_mesh, 0.0)

    @test length(s1) == 8
    @test length(s1) == length(s2)
    @test length(s3) == 0
    exp1 = [([0.0,1.0],[0.0,0.0]),([0.0,0.0],[1.0,0.0]),
                      ([1.0,0.0],[10.0,0.0]),([10.0,0.0],[10.0,1.0]),
                      ([10.0,1.0],[10.0,10.0]),([10.0,10.0],[1.0,10.0]),
                      ([1.0,10.0],[0.0,10.0]),([0.0,10.0],[0.0,1.0])]
    exp2 = [([0.0,2.0],[0.0,0.0]),([0.0,0.0],[2.0,0.0]),
                      ([2.0,0.0],[10.0,0.0]),([10.0,0.0],[10.0,2.0]),
                      ([10.0,2.0],[10.0,10.0]),([10.0,10.0],[2.0,10.0]),
                      ([2.0,10.0],[0.0,10.0]),([0.0,10.0],[0.0,2.0])]
    @test length(s1) == length(exp1)
    @test length(s2) == length(exp2)
end

@testset "checkbounds" begin
    m1 = HomogenousMesh([Point{3, Float64}(0.0,0.0,10.0),
                         Point{3, Float64}(0.0,10.0,10.0),
                         Point{3, Float64}(0.0,0.0,0.0)],
                        [Face{3, Int}(1,2,3)])
    @test checkbounds(m1)

    m2 = HomogenousMesh([Point{3, Float64}(0.0,0.0,10.0),
                         Point{3, Float64}(0.0,10.0,10.0),
                         Point{3, Float64}(0.0,0.0,0.0)],
                        [Face{3, GLIndex}(5,1,2)])
    @test !checkbounds(m2)

    # empty case
    m3 = HomogenousMesh([Point{3, Float64}(0.0,0.0,10.0),
                         Point{3, Float64}(0.0,10.0,10.0),
                         Point{3, Float64}(0.0,0.0,0.0)],
                        Face{3, GLIndex}[])
    @test checkbounds(m3)
end

@testset "vertex normals" begin
    test_mesh = HomogenousMesh(
    Point{3,Float64}[
        (0.0,0.0,10.0),
        (0.0,10.0,10.0),
        (0.0,0.0,0.0),
        (0.0,10.0,0.0),
        (10.0,0.0,10.0),
        (10.0,10.0,10.0),
        (10.0,0.0,0.0),
        (10.0,10.0,0.0),
    ], Face{3, Int}[
        (3,7,5),
        (1,3,5),
        (1,2,3),
        (3,2,4),
        (1,5,6),
        (2,1,6),
        (4,8,3),
        (3,8,7),
        (7,8,6),
        (5,7,6),
        (2,6,4),
        (4,6,8)
    ])
    ns = normals(test_mesh.vertices, test_mesh.faces, Normal{3, Float32})
    @test length(ns) == length(test_mesh.vertices)
    expect = Normal{3, Float32}[
        (-0.408248,-0.408248,0.816497),
        (-0.816497,0.408248,0.408248),
        (-0.57735,-0.57735,-0.57735),
        (-0.408248,0.816497,-0.408248),
        (0.408248,-0.816497,0.408248),
        (0.57735,0.57735,0.57735),
        (0.816497,-0.408248,-0.408248),
        (0.408248,0.408248,-0.816497)
    ]
    @test all(isapprox.(ns, expect))
end

@testset "conversion" begin
    VT = vertextype(GLNormalMesh)
    FT = facetype(GLNormalMesh)
    vs = [VT(0., 0, 0), VT(1., 0, 0), VT(0., 1, 0)]
    fs = [FT(1, 2, 3)]
    mesh = PlainMesh{eltype(VT), FT}(vertices=vs, faces=fs)
    @test convert(GLNormalMesh, mesh) == GLNormalMesh(vs, fs)
end

end


using GeometryTypes
attributes = Dict{Symbol, Any}()
attributes[:faces] = GLTriangle[(1,2,3), (3, 2, 1)]
attributes[:vertices] = rand(Point3f0, 3)
attributes[:normals] = rand(Normal{3, Float32}, 3)
@which HomogenousMesh(attributes)
# M = HomogenousMesh
# attribs = attributes
# newfields = map(fieldnames(HomogenousMesh)) do field
#     target_type = fieldtype(M, field)
#     default = fieldtype(HomogenousMesh, field) <: Vector ? Void[] : nothing
#     get(attribs, field, default)
# end

x = GeometryTypes.homogenousmesh(attributes)
GLNormalMesh(x)
