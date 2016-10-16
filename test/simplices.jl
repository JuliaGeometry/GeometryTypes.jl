@testset "example simplices" begin
    @testset "2d simplex in 2d" begin
        s = Simplex((Vec(1,0.), Vec(0,1.), Vec(0,0.)))
        @test (@inferred min_euclidean(Vec(0., 0.), s)) ≈0
        @test min_euclidean(Vec(0.5, 0.),s) ≈0
        @test min_euclidean(Vec(-1, -1.),s) ≈√(2)
        @test min_euclidean(Vec(-7, 0.5),s) ≈7
        @test min_euclidean(Vec(1., 1.), s) ≈√(0.5)
        @test (@inferred volume(s)) ≈1/2
        # containment
        @test contains(s, Vec(0.1, 0.))
        for v in vertices(s)
            @test contains(s, v)
        end
        @test !( contains(s, Vec(1,0.1)) )
        @test contains(s, Vec(1,0.1), atol=0.1)
    end

    @testset "counterexample" begin
        # There is a common false believe that in the proj_sqdist algorithm
        # one may throw away all negative weights. See for example
        # https://www.researchgate.net/publication/267801141_-_An_Algorithm_to_Compute_the_Distance_from_a_Point_to_a_Simplex
        # Here is a counterexample

        s = Simplex((Vec(-1,0.), Vec(0,0.), Vec(1,1.)))
        pt = Vec(2.,-1)
        @test min_euclidean(pt, s) ≈√(4.5)

        pt_proj, sqd = GeometryTypes.proj_sqdist(pt, s)
        @test pt_proj ≈ Vec(0.5, 0.5)
        @test !isapprox(pt_proj, Vec(0,0.), atol=1e-1)
        @test sqd ≈4.5

    end

    @testset "3d simplex in 3d" begin
        s = Simplex((Vec(1,0.,0), Vec(0,1.,0), Vec(0,0,1.), Vec(0,0.,0)))
        @test (@inferred min_euclidean(Vec(0., 0.,0), s)) ≈0
        @test min_euclidean(Vec(0.5, 0.,0),s) ≈0
        @test min_euclidean(Vec(-1, -1.,0),s) ≈√(2)
        @test min_euclidean(Vec(-7, 0.5,0),s) ≈7
        @test min_euclidean(Vec(1., 1.,0), s) ≈√(0.5)
        @test min_euclidean(Vec(1., 1.,1), s) ≈√(3)*(2/3)
        @test (@inferred volume(s)) ≈1/6
        @test !( contains(s, Vec(1,0,0.1)) )
        @test contains(s, Vec(0.1,0,0.1))
    end

    @testset "1d simplex in 2d" begin
        s = Simplex((Vec(-1, 1.), Vec(1,1.)))
        proj(pt) = GeometryTypes.proj_sqdist(pt, s)[1]
        @test proj(Vec( 0.,  2)) ≈ Vec( 0, 1.)
        @test proj(Vec( 0., -2)) ≈ Vec( 0, 1.)
        @test proj(Vec( 56., 2)) ≈ Vec( 1, 1.)
        @test proj(Vec(-56., 2)) ≈ Vec(-1, 1.)
    end

    @testset "1d simplex in 3d" begin
        s = Simplex((Vec(0,0.,0), Vec(1,1.,1)))
        @test (@inferred min_euclidean(Vec(0., 0.,0), s)) ≈0
        @test min_euclidean(Vec(.5, .5, .5), s) ≈0
        @test min_euclidean(Vec(-1,0,0.), s) ≈1
        @test min_euclidean(Vec(1,0,0.), s) ≈√(2/3)
        @test (@inferred volume(s)) ≈√(3)

        @test contains(s, Vec(0.2,0.2,0.2))
        @test !( contains(s, Vec(0.1,0.0999,0.1)) )
    end
end