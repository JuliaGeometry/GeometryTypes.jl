@testset "Distance Fields" begin

@testset "SignedDistanceField" begin
    s1 = SignedDistanceField(HyperRectangle(Vec(1,2),Vec(3,4)), [1 2;3 4])
    @test typeof(s1) == GeometryTypes.SignedDistanceField{2,Int,Int}
    s1 = SignedDistanceField(HyperRectangle(Vec(1,2),Vec(3,4)), [1. 2.;3. 4.])
    @test typeof(s1) == GeometryTypes.SignedDistanceField{2,Int,Float64}


    # functional
    s2 = SignedDistanceField(HyperRectangle(Vec(0,0,0),Vec(1,1,1))) do v
        sqrt(sum(v.*v)) - 1 # sphere
    end
    @test size(s2) == (11, 11, 11)
    # functional
    s2 = SignedDistanceField(HyperRectangle(Vec(-1,-1),Vec(2,3))) do v
        sqrt(sum(v.*v)) - 1 # circle
    end
    @test size(s2) == (21, 31)
    @test size(s2, 1) == 21
    @test size(s2, 2) == 31

    @test HyperRectangle(s2) == HyperRectangle(Vec(-1,-1),Vec(2,3))
end

@testset "getindex" begin
    sdf = SignedDistanceField(HyperRectangle(Vec(-1,-1),Vec(2,2))) do v
        sqrt(sum(v.*v)) - 1 # circle
    end

    @test sdf[1,1] == sdf[21*21] # by circle symmetry
    @test_throws BoundsError sdf[21*21+1]
end

end
