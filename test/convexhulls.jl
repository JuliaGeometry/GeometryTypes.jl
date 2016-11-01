import GeometryTypes: numtype
@testset "Convex Hulls" begin
    T = Float64
    V = Vec{2, T}
    s = Simplex((Vec(0, 0.), Vec(0,1.), Vec(1.,0)))
    fs = FlexibleSimplex([Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)])
    fh = FlexibleConvexHull([Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)])
    types = (Simplex, FlexibleSimplex, FlexibleConvexHull)
    objects = (s,fs,fh)

    @testset "conversions" begin
        @test typeof(@inferred FlexibleSimplex(s)) == FlexibleSimplex{V}
        @test typeof(@inferred FlexibleConvexHull(s)) == FlexibleConvexHull{V}
        @test typeof(@inferred FlexibleConvexHull(fs)) == FlexibleConvexHull{V}
        for i1 in objects, i2 in objects
            @test isapprox(FlexibleConvexHull(i1), i2)
        end
    end

    @testset "Utility functions" begin

        v_matrix = [0. 0 1; 0 1 0]
        v_mat = Mat(v_matrix)
        for shape in objects
            @test (@inferred eltype(shape)) == V
            @test (@inferred spacedim(shape)) == 2
            @test nvertices(shape) == 3

            @test (@inferred vertexmatrix(shape)) == v_matrix
            @test vertexmat(shape) == v_mat

        end
        @test (@inferred vertexmat(s)) == v_mat
        @test (@inferred nvertices(s)) == 3
    end

    @testset "isapprox" begin
        s2 = rand(Simplex{3, Vec{2,Float64}})

        @test !( isapprox(s, s2) )
        @test isapprox(s, s2, atol=100.)
    end

    @testset "Rects" begin
        c = HyperCube(Vec(1.,2), 1.)
        r = HyperRectangle(Vec(1.,2), Vec(1.,1))
        fh = FlexibleConvexHull([ Vec(1,2.), Vec(1.,3.), Vec(2.,2.), Vec(2.,3.)])
        objects = (c,r,fh)

        @test (@inferred convert(HyperRectangle, c)) == r
        fh2 = (@inferred convert(FlexibleConvexHull, c))
        @test vertices(fh2) == vertices(fh)
        for x in objects, y in objects
            @test isapprox(x, y)
        end
        for x in objects
            @test nvertices(c) == 4
            @test spacedim(c) == 2
            @test numtype(c) == Float64
        end
    end
end