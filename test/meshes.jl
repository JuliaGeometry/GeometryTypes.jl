context("Mesh Types") do

context("Merging Mesh") do
    baselen = 0.4f0
    dirlen = 2f0
    a = [
        (Cube{Float32}(Vec3f0(baselen), Vec3f0(dirlen, baselen, baselen)), RGBA(1f0,0f0,0f0,1f0)),
        (Cube{Float32}(Vec3f0(baselen), Vec3f0(baselen, dirlen, baselen)), RGBA(0f0,1f0,0f0,1f0)),
        (Cube{Float32}(Vec3f0(baselen), Vec3f0(baselen, baselen, dirlen)), RGBA(0f0,0f0,1f0,1f0))
    ]
    am = map(GLNormalMesh, a)
    axis = merge(am)
    axis2 = merge(am)
    @fact axis --> axis2 # test ==
    @fact typeof(am[1]) --> GLNormalColorMesh

    @fact typeof(axis) --> GLNormalAttributeMesh

    @fact vertextype(axis) --> Point{3, Float32}
    @fact normaltype(axis) --> Normal{3, Float32}
    @fact facetype(axis) --> Face{3, Cuint, -1}
    @fact hasvertices(axis) --> true
    @fact hasfaces(axis) --> true
    @fact hasnormals(axis) --> true
    @fact hascolors(axis) --> false
    end

context("Show") do
    baselen = 0.4f0
    dirlen = 2f0
    m = GLNormalMesh(Cube{Float32}(Vec3f0(baselen),
                     Vec3f0(dirlen, baselen, baselen)))
    io = IOBuffer()
    show(io,m)
    seekstart(io)
    s =  "HomogenousMesh(\n    normals: 24xGeometryTypes.Normal{3,Float32},     vertices: 24xFixedSizeArrays.Point{3,Float32},     faces: 12xGeometryTypes.Face{3,UInt32,-1}, )\n"
    @fact readall(io) --> s
end

context("Primitives") do
    # issue #16
    #m = HomogenousMesh{Point{3,Float64},Face{3,Int,0}}(Sphere(Point(0,0,0), 1))
    #@fact length(vertices(m)) --> 145
    #@fact length(faces(m)) --> 288
end


context("Slice") do
    test_mesh = HomogenousMesh(Point{3,Float64}[
     Point{3,Float64}(0.0,0.0,10.0),
     Point{3,Float64}(0.0,10.0,10.0),
     Point{3,Float64}(0.0,0.0,0.0),
     Point{3,Float64}(0.0,10.0,0.0),
     Point{3,Float64}(10.0,0.0,10.0),
     Point{3,Float64}(10.0,10.0,10.0),
     Point{3,Float64}(10.0,0.0,0.0),
     Point{3,Float64}(10.0,10.0,0.0),
    ],Face{3,Int,0}[
     Face{3,Int,0}(3,7,5)
     Face{3,Int,0}(1,3,5)
     Face{3,Int,0}(1,2,3)
     Face{3,Int,0}(2,4,3)
     Face{3,Int,0}(1,5,6)
     Face{3,Int,0}(2,1,6)
     Face{3,Int,0}(4,8,3)
     Face{3,Int,0}(3,8,7)
     Face{3,Int,0}(7,8,6)
     Face{3,Int,0}(7,6,5)
     Face{3,Int,0}(2,6,4)
     Face{3,Int,0}(4,6,8)]
    )
    s1 = slice(test_mesh, 1.0)
    s2 = slice(test_mesh, 2.0)
    s3 = slice(test_mesh, 0.0)

    @fact length(s1) --> 8
    @fact length(s1) --> length(s2)
    @fact length(s3) --> 0
    exp1 = [([0.0,1.0],[0.0,0.0]),([0.0,0.0],[1.0,0.0]),
                      ([1.0,0.0],[10.0,0.0]),([10.0,0.0],[10.0,1.0]),
                      ([10.0,1.0],[10.0,10.0]),([10.0,10.0],[1.0,10.0]),
                      ([1.0,10.0],[0.0,10.0]),([0.0,10.0],[0.0,1.0])]
    exp2 = [([0.0,2.0],[0.0,0.0]),([0.0,0.0],[2.0,0.0]),
                      ([2.0,0.0],[10.0,0.0]),([10.0,0.0],[10.0,2.0]),
                      ([10.0,2.0],[10.0,10.0]),([10.0,10.0],[2.0,10.0]),
                      ([2.0,10.0],[0.0,10.0]),([0.0,10.0],[0.0,2.0])]
    @fact length(s1) --> length(exp1)
    @fact length(s2) --> length(exp2)
end

context("checkbounds") do
    m1 = HomogenousMesh([Point{3,Float64}(0.0,0.0,10.0),
                         Point{3,Float64}(0.0,10.0,10.0),
                         Point{3,Float64}(0.0,0.0,0.0)],
                        [Face{3,Int,0}(1,2,3)])
    @fact checkbounds(m1) --> true
    m2 = HomogenousMesh([Point{3,Float64}(0.0,0.0,10.0),
                         Point{3,Float64}(0.0,10.0,10.0),
                         Point{3,Float64}(0.0,0.0,0.0)],
                        [Face{3,Int,-1}(1,2,3)])
    @fact checkbounds(m2) --> false
    # empty case
    m3 = HomogenousMesh([Point{3,Float64}(0.0,0.0,10.0),
                         Point{3,Float64}(0.0,10.0,10.0),
                         Point{3,Float64}(0.0,0.0,0.0)],
                        Face{3,Int,-1}[])
    @fact checkbounds(m3) --> true
end

context("vertex normals") do
    test_mesh = HomogenousMesh(Point{3,Float64}[Point{3,Float64}(0.0,0.0,10.0),
     Point{3,Float64}(0.0,10.0,10.0),
     Point{3,Float64}(0.0,0.0,0.0),
     Point{3,Float64}(0.0,10.0,0.0),
     Point{3,Float64}(10.0,0.0,10.0),
     Point{3,Float64}(10.0,10.0,10.0),
     Point{3,Float64}(10.0,0.0,0.0),
     Point{3,Float64}(10.0,10.0,0.0),
    ],Face{3,Int,0}[
     Face{3,Int,0}(3,7,5)
     Face{3,Int,0}(1,3,5)
     Face{3,Int,0}(1,2,3)
     Face{3,Int,0}(3,2,4)
     Face{3,Int,0}(1,5,6)
     Face{3,Int,0}(2,1,6)
     Face{3,Int,0}(4,8,3)
     Face{3,Int,0}(3,8,7)
     Face{3,Int,0}(7,8,6)
     Face{3,Int,0}(5,7,6)
     Face{3,Int,0}(2,6,4)
     Face{3,Int,0}(4,6,8)]
    )
    ns = normals(test_mesh.vertices, test_mesh.faces)
    @fact length(ns) --> length(test_mesh.vertices)
    expect = [Normal(-0.408248290463863,-0.408248290463863,0.816496580927726),
              Normal(-0.816496580927726,0.408248290463863,0.408248290463863),
              Normal(-0.5773502691896257,-0.5773502691896257,-0.5773502691896257),
              Normal(-0.408248290463863,0.816496580927726,-0.408248290463863),
              Normal(0.408248290463863,-0.816496580927726,0.408248290463863),
              Normal(0.5773502691896257,0.5773502691896257,0.5773502691896257),
              Normal(0.816496580927726,-0.408248290463863,-0.408248290463863),
              Normal(0.408248290463863,0.408248290463863,-0.816496580927726)]
    @fact ns --> expect
end

end
