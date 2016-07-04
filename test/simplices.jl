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
