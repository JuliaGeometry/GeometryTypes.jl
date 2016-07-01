context("eltype") do
    @fact eltype_or(HyperCube, nothing) --> nothing
    @fact eltype_or(HyperCube{2}, nothing) --> nothing
    @fact eltype_or(HyperCube{2, Float32}, nothing) --> Float32
    @fact eltype_or(SimpleRectangle, Int) --> Int
    @fact eltype_or(SimpleRectangle{Float32}, Int) --> Float32

    @fact eltype(SimpleRectangle(0,0,1,1)) --> Int
    @fact eltype(SimpleRectangle) --> Any
    @fact eltype(HyperCube{2}) --> Any
    @fact eltype(HyperCube{2, Float32}) --> Float32
    @fact eltype(SimpleRectangle{Float32}) --> Float32
end
context("ndims") do
    @fact ndims_or(HyperCube, nothing) --> nothing
    @fact ndims_or(HyperCube{2}, nothing) --> 2
    @fact ndims_or(HyperCube{2, Float32}, nothing) --> 2
    @fact ndims_or(SimpleRectangle, 0) --> 2

    @fact ndims(SimpleRectangle(0,0,1,1)) --> 2
    @fact ndims(SimpleRectangle) --> 2
    @fact ndims(HyperCube{2}) --> 2
    @fact ndims(HyperCube{2, Float32}) --> 2
    @fact_throws ndims(HyperCube)
end

context("Convex Hulls") do
    T = Float64
    V = Vec{2, T}
    s = Simplex((Vec(0, 0.), Vec(0,1.), Vec(1.,0)))
    fs = FlexibleSimplex([Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)])
    fh = FlexibleConvexHull([Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)])
    objects = (s,fs,fh)
    types = (Simplex, FlexibleSimplex, FlexibleConvexHull)

    context("conversions") do
            @fact typeof(@inferred FlexibleSimplex(s)) --> FlexibleSimplex{V}
            @fact typeof(@inferred FlexibleConvexHull(s)) --> FlexibleConvexHull{V}
            @fact typeof(@inferred FlexibleConvexHull(fs)) --> FlexibleConvexHull{V}
        for i1 in objects, i2 in objects
            @fact isapprox(FlexibleConvexHull(i1), i2) --> true
        end
    end

    context("Utility functions") do

        v_matrix = [0. 0 1; 0 1 0]
        v_mat = Mat(v_matrix)
        for shape in objects
            @fact (@inferred eltype(shape)) --> V
            @fact (@inferred spacedim(shape)) --> 2
            @fact nvertices(shape) --> 3

            @fact (@inferred vertexmatrix(shape)) --> v_matrix
            @fact vertexmat(shape) --> v_mat

        end
        @fact (@inferred vertexmat(s)) --> v_mat
        @fact (@inferred nvertices(s)) --> 3
    end

    context("isapprox") do
        s2 = rand(Simplex{3, Vec{2,Float64}})

        @fact isapprox(s, s2) --> false
        @fact isapprox(s, s2, atol=100.) --> true
    end

end
