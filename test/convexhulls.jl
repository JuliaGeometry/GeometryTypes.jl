import GeometryTypes: numtype
context("Convex Hulls") do
    T = Float64
    V = Vec{2, T}
    s = Simplex((Vec(0, 0.), Vec(0,1.), Vec(1.,0)))
    fs = FlexibleSimplex([Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)])
    fh = FlexibleConvexHull([Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)])
    types = (Simplex, FlexibleSimplex, FlexibleConvexHull)
    objects = (s,fs,fh)

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

    context("Rects") do
        c = HyperCube(Vec(1.,2), 1.)
        r = HyperRectangle(Vec(1.,2), Vec(1.,1))
        fh = FlexibleConvexHull([ Vec(0.5,1.5), Vec(0.5,2.5), Vec(1.5,1.5), Vec(1.5,2.5)])
        objects = (c,r,fh)

        @fact (@inferred convert(HyperRectangle, c)) --> r
        fh2 = (@inferred convert(FlexibleConvexHull, c))
        @fact vertices(fh2) --> vertices(fh)
        for x in objects, y in objects
            @fact isapprox(x, y) --> true
        end
        for x in objects
            @fact nvertices(c) --> 4
            @fact spacedim(c) --> 2
            @fact numtype(c) --> Float64
        end
    end
end
