context("Distance Fields") do

context("SignedDistanceField") do
    s1 = SignedDistanceField(HyperRectangle(Vec(1,2),Vec(3,4)), [1 2;3 4])
    @fact typeof(s1) --> GeometryTypes.SignedDistanceField{2,Int,Int}
    s1 = SignedDistanceField(HyperRectangle(Vec(1,2),Vec(3,4)), [1. 2.;3. 4.])
    @fact typeof(s1) --> GeometryTypes.SignedDistanceField{2,Int,Float64}


    # functional
    s2 = SignedDistanceField(HyperRectangle(Vec(0,0,0.),Vec(1,1,1.))) do v
        sqrt(sum(v.*v)) - 1 # sphere
    end
    @fact size(s2) --> (11, 11, 11)
    # functional
    s2 = SignedDistanceField(HyperRectangle(Vec(-1,-1.),Vec(2,2.))) do v
        sqrt(sum(v.*v)) - 1 # circle
    end
    @fact size(s2) --> (21, 21)

    @fact HyperRectangle(s2) --> HyperRectangle(Vec(-1,-1.),Vec(2,2.))
end

context("getindex") do
    sdf = SignedDistanceField(HyperRectangle(Vec(-1,-1.),Vec(2,2.))) do v
        sqrt(sum(v.*v)) - 1 # circle
    end

    @fact sdf[1,1] --> sdf[21*21] # by circle symmetry
    @fact_throws BoundsError sdf[21*21+1]
end

end
