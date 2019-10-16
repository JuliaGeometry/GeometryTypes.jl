using Test, GeometryTypes

@testset "algorithms.jl" begin
    cube = HyperRectangle(Vec3f0(-0.5), Vec3f0(1))
    cube_faces = decompose(Face{3,Int32}, cube)
    cube_vertices = decompose(Point{3,Float32}, cube) |> Array
    @test area( cube_vertices, cube_faces ) == 6
    @test_broken volume( cube_vertices, cube_faces ) == 6
end
