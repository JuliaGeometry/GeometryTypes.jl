using Base.Test

@testset "algorithms.jl" begin
pSphere = parseGtsFile( "/Users/christ/.julia/v0.6/GeometryTypes/test/data/sphere5.gts" )
sphere = ( nodes = pSphere[1], faces = pSphere[4] )

@test area( reinterpret(Point{3,Float64},sphere.nodes), reinterpret(Point{3,Int},sphere.faces) ) ≈ 12.413436704726122
end
