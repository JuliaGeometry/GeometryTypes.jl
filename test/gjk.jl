import GeometryTypes: ⊖, support_vector_max
import GeometryTypes: gjk0
import GeometryTypes: type_immutable, with_immutable, make_immutable

@testset "gjk" begin

    @testset "gjk examples" begin
        @testset "two simplices" begin
            c1 = Simplex(Vec(-1.))
            c2 = Simplex(Vec(4.))
            @test gjk(c1,c2) ≈5
            @test min_euclidean(c1,c2) ≈5

            c1 = Simplex(Vec(-1.,0,0))
            c2 = Simplex(Vec(4.,0,0))
            @test gjk(c1,c2) ≈5
            @test min_euclidean(c1,c2) ≈5

            c1 = FlexibleConvexHull([Vec(0.,0), Vec(0.,1), Vec(1.,0),Vec(1.,1)])
            c2 = Simplex(Vec(4.,0.5))
            @test gjk(c1, c2) ≈3
            @test min_euclidean(c1,c2) ≈3

            pt1 = Vec(1,2,3.)
            pt2 = Vec(3,4,5.)
            @test gjk(pt1, pt2) ≈norm(pt1-pt2)
            @test min_euclidean(pt1, pt2) ≈norm(pt1-pt2)
        end

        @testset "gjk intersecting lines" begin
            c1 = Simplex(Vec(1,1.), Vec(1, 2.))
            @test gjk(c1, c1) == 0.
            @test min_euclidean(c1,c1) == 0.

            c2 = Simplex(Vec(1,1.), Vec(10, 2.))
            @test gjk(c1, c2) == 0.
            @test min_euclidean(c1,c2) == 0.

            c3 = Simplex(Vec(0, 1.), Vec(2,2.))
            md = vertices(c1 ⊖ c3)
            @test md == [Vec(1.0,0.0),Vec(-1.0,-1.0),Vec(1.0,1.0),Vec(-1.0,0.0)]
            @test gjk0(FlexibleConvexHull(md)) == (Vec(0, 0.), 0.)
            @test gjk(c1, c3) == 0.
            @test min_euclidean(c1,c3) == 0.

        end

        @testset "Cube" begin
            c = HyperCube(Vec(0.5,0.5,0.5), 1.)
            @test min_euclidean(Vec(2,2,2.), c) ≈ gjk(Vec(2,2,2.), c) ≈ √(3/4)

            s = Simplex(Vec(1, 0.5, 0.5), Vec(1,2,3.))
            @test 0 <= min_euclidean(s, c) <= 1e-14
            @test 0 <= gjk(s, c) <= 1e-14

            s = Simplex(Vec(2,2,2.), Vec(2,3,2.), Vec(2,2,7.), Vec(3,4,5.))
            @test min_euclidean(s,c) ≈ gjk(s, c) ≈ √(3/4)
        end

    end

    @testset "support_vector_max" begin
        r = HyperRectangle(Vec(-0.5, -1.), Vec(1., 2.))
        @test support_vector_max(r, Vec(1,0.)) == (Vec(0.5,-1.), 0.5)
        @test support_vector_max(r, Vec(2,0.)) == (Vec(0.5,-1.), 1.)
        @test support_vector_max(r, Vec(-1,0.)) == (Vec(-0.5,-1.), 0.5)
        @test support_vector_max(r, Vec(0, 1.)) == (Vec(-0.5,1.), 1.)
        @test support_vector_max(r, Vec(1, 1.)) == (Vec(0.5,1.), 1.5)
        @test support_vector_max(FlexibleConvexHull(r), Vec(1, 1.)) == (Vec(0.5,1.), 1.5)

        c1 = Simplex(Vec(1,1.), Vec(1, 2.))
        c3 = Simplex(Vec(0, 1.), Vec(2,2.))
        md = c1 ⊖ c3
        fh = FlexibleConvexHull(md)
        for v in [Vec(1,0.), Vec(12,-10.), Vec(0,-1.), Vec(1,1.)]
            v_md, s_md = support_vector_max(md, v)
            v_fh, s_fh = support_vector_max(fh, v)
            @test s_md ≈ s_fh
            @test v_md ≈ v_fh
        end
    end


    @testset "make immutable" begin
        T = Vec{2, Float64}
        n = 3
        S = Simplex{n, T}
        FS = FlexibleSimplex{T}
        fs = FS([Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)])
        s = S((Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)))
        @test (@inferred type_immutable(FS, Val{3})) == S
        @test type_immutable(fs) == S
        @test (@inferred type_immutable(fs, Val{3})) == S
        @test make_immutable(fs) == s
        @test (@inferred make_immutable(fs, Val{3})) == s
        @test with_immutable(identity, fs) == s
    end

end
