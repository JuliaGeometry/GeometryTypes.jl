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
    @fact triangulate(GLTriangle, Face{4, Int, 0}(1,2,3,4)) --> (Face{3,UInt32,-1}(0,1,2), Face{3,UInt32,-1}(0,2,3))
    @fact triangulate(Face{3,Int,-1}, Face{4, Int, -1}(1,2,3,4)) --> (Face{3,Int,-1}(1,2,3),Face{3,Int,-1}(1,3,4))
    @fact triangulate(Face{3,Int,2}, Face{4, Int, 1}(1,2,3,4)) --> (Face{3,Int,2}(2,3,4),Face{3,Int,2}(2,4,5))
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

end
