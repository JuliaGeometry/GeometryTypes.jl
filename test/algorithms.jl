using Test, GeometryTypes

@testset "algorithms.jl" begin
    cube = HyperRectangle(Vec3f0(-0.5), Vec3f0(1))
    cube_faces = decompose(Face{3,Int}, Face{4, Int}[
        (1,3,4,2),
        (2,4,8,6),
        (4,3,7,8),
        (1,5,7,3),
        (1,2,6,5),
        (5,6,8,7),
    ])
    cube_vertices = decompose(Point{3,Float32}, cube) |> Array
    @test area( cube_vertices, cube_faces ) == 6
    @test volume( cube_vertices, cube_faces ) ≈ 1
end
