context("example simplices") do
    context("2d simplex in 2d") do
        s = Simplex((Vec(1,0.), Vec(0,1.), Vec(0,0.)))
        @fact (@inferred min_euclidean(Vec(0., 0.), s)) --> roughly(0)
        @fact min_euclidean(Vec(0.5, 0.),s) --> roughly(0)
        @fact min_euclidean(Vec(-1, -1.),s) --> roughly(√(2))
        @fact min_euclidean(Vec(-7, 0.5),s) --> roughly(7)
        @fact min_euclidean(Vec(1., 1.), s) --> roughly(√(0.5))
        @fact (@inferred volume(s)) --> roughly(1/2)
        # containment
        @fact contains(s, Vec(0.1, 0.)) --> true
        for v in vertices(s)
            @fact contains(s, v) --> true
        end
        @fact contains(s, Vec(1,0.1)) --> false
        @fact contains(s, Vec(1,0.1), atol=0.1) --> true
    end

    context("counterexample") do
        # There is a common false believe that in the proj_sqdist algorithm
        # one may throw away all negative weights. See for example
        # https://www.researchgate.net/publication/267801141_-_An_Algorithm_to_Compute_the_Distance_from_a_Point_to_a_Simplex
        # Here is a counterexample

        s = Simplex((Vec(-1,0.), Vec(0,0.), Vec(1,1.)))
        pt = Vec(2.,-1)
        @fact min_euclidean(pt, s) --> roughly(√(4.5))

        pt_proj, sqd = GeometryTypes.proj_sqdist(pt, s)
        @fact pt_proj ≈ Vec(0.5, 0.5)--> true
        @fact !isapprox(pt_proj, Vec(0,0.), atol=1e-1) --> true
        @fact sqd --> roughly(4.5)

    end

    context("3d simplex in 3d") do
        s = Simplex((Vec(1,0.,0), Vec(0,1.,0), Vec(0,0,1.), Vec(0,0.,0)))
        @fact (@inferred min_euclidean(Vec(0., 0.,0), s)) --> roughly(0)
        @fact min_euclidean(Vec(0.5, 0.,0),s) --> roughly(0)
        @fact min_euclidean(Vec(-1, -1.,0),s) --> roughly(√(2))
        @fact min_euclidean(Vec(-7, 0.5,0),s) --> roughly(7)
        @fact min_euclidean(Vec(1., 1.,0), s) --> roughly(√(0.5))
        @fact min_euclidean(Vec(1., 1.,1), s) --> roughly(√(3)*(2/3))
        @fact (@inferred volume(s)) --> roughly(1/6)
        @fact contains(s, Vec(1,0,0.1)) --> false
        @fact contains(s, Vec(0.1,0,0.1)) --> true
    end

    context("1d simplex in 2d") do
        s = Simplex((Vec(-1, 1.), Vec(1,1.)))
        proj(pt) = GeometryTypes.proj_sqdist(pt, s)[1]
        @fact proj(Vec( 0.,  2)) ≈ Vec( 0, 1.) --> true
        @fact proj(Vec( 0., -2)) ≈ Vec( 0, 1.) --> true
        @fact proj(Vec( 56., 2)) ≈ Vec( 1, 1.) --> true
        @fact proj(Vec(-56., 2)) ≈ Vec(-1, 1.) --> true
    end

    context("1d simplex in 3d") do
        s = Simplex((Vec(0,0.,0), Vec(1,1.,1)))
        @fact (@inferred min_euclidean(Vec(0., 0.,0), s)) --> roughly(0)
        @fact min_euclidean(Vec(.5, .5, .5), s) --> roughly(0)
        @fact min_euclidean(Vec(-1,0,0.), s) --> roughly(1)
        @fact min_euclidean(Vec(1,0,0.), s) --> roughly(√(2/3))
        @fact (@inferred volume(s)) --> roughly(√(3))

        @fact contains(s, Vec(0.2,0.2,0.2)) --> true
        @fact contains(s, Vec(0.1,0.0999,0.1)) --> false
    end
end
