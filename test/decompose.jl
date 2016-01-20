context("decompose functions") do

context("HyperRectangles") do
    a = HyperRectangle(Vec(0,0),Vec(1,1))
    pt_expa = (Point(0,0), Point(1,0), Point(0,1), Point(1,1))
    @fact decompose(Point{2,Int},a) --> pt_expa
    b = HyperRectangle(Vec(1,1,1),Vec(1,1,1))
    pt_expb = (Point{3,Int64}((1,1,1)),Point{3,Int64}((2,1,1)),Point{3,Int64}((1,2,1)),Point{3,Int64}((2,2,1)),Point{3,Int64}((1,1,2)),Point{3,Int64}((2,1,2)),Point{3,Int64}((1,2,2)),Point{3,Int64}((2,2,2)))
    @fact decompose(Point{3,Int}, b) --> pt_expb
end

context("Faces") do
    @fact decompose(GLTriangle, Face{4, Int, 0}(1,2,3,4)) --> (Face{3,UInt32,-1}(0,1,2), Face{3,UInt32,-1}(0,2,3))
    @fact decompose(Face{3,Int,-1}, Face{4, Int, -1}(1,2,3,4)) --> (Face{3,Int,-1}(1,2,3),Face{3,Int,-1}(1,3,4))
    @fact decompose(Face{3,Int,2}, Face{4, Int, 1}(1,2,3,4)) --> (Face{3,Int,2}(2,3,4),Face{3,Int,2}(2,4,5))
    @fact decompose(Face{2,Int,0}, Face{4, Int, 0}(1,2,3,4)) --> (Face{2,Int,0}(1,2),
                                                                  Face{2,Int,0}(2,3),
                                                                  Face{2,Int,0}(3,4),
                                                                  Face{2,Int,0}(4,1))
end

context("Simplex") do
    s1 = Simplex(:x1,:x2,:x3)
    s2 = Simplex(:x1,:x2,:x3,:x4)
    @fact decompose(Simplex{1}, s1) --> (Simplex(:x1),Simplex(:x2),Simplex(:x3))
    @fact decompose(Simplex{2}, s1) --> (Simplex(:x1,:x2),Simplex(:x2,:x3),Simplex(:x3,:x1))
    @fact decompose(Simplex{2}, s2) --> (Simplex(:x1,:x2),Simplex(:x2,:x3),Simplex(:x3,:x4),Simplex(:x4,:x1))
    @fact decompose(Simplex{3}, s2) --> (Simplex(:x1,:x2,:x3),Simplex(:x1,:x3,:x4))
end

context("SimpleRectangle") do
    r = SimpleRectangle(0,0,1,1)
    pts = decompose(Point, r)
    @fact pts --> [Point(0,0),
                   Point(0,1),
                   Point(1,1),
                   Point(1,0)]
end


context("Normals") do
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
    @fact normals(vertices(r), faces(r), Normal{3, Float32}) --> n32
    @fact normals(vertices(r), faces(r), Normal{3, Float64}) --> n64

    r = PlainMesh{Float64, Face{3, UInt32, 0}}(centered(HyperRectangle))
    @fact normals(vertices(r), faces(r), Normal{3, Float32}) --> n32
    @fact normals(vertices(r), faces(r), Normal{3, Float64}) --> n64

    r = PlainMesh{Float16, Face{3, UInt64, -1}}(centered(HyperRectangle))
    @fact normals(vertices(r), faces(r), Normal{3, Float32}) --> n32
    @fact normals(vertices(r), faces(r), Normal{3, Float64}) --> n64

end



end
