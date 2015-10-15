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
    @fact triangulate(GLTriangle, Face{4, Int, 0}(1,2,3,4)) --> (Face{3,UInt32,-1}((0x00000000,0x00000001,0x00000002)), Face{3,UInt32,-1}((0x00000002,0x00000003,0x00000000)))
end

context("Primitives") do
    #@show HomogenousMesh(Sphere(Point(0,0,0), 1))
end

end
