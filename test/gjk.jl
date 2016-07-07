import GeometryTypes: ⊖, support_vector_max
import GeometryTypes: gjk0
import GeometryTypes: type_immutable, with_immutable, make_immutable

context("gjk") do

    context("gjk examples") do
        context("two simplices") do
            c1 = Simplex(Vec(-1.))
            c2 = Simplex(Vec(4.))
            @fact gjk(c1,c2) --> roughly(5)
            @fact min_euclidean(c1,c2) --> roughly(5)

            c1 = Simplex(Vec(-1.,0,0))
            c2 = Simplex(Vec(4.,0,0))
            @fact gjk(c1,c2) --> roughly(5)
            @fact min_euclidean(c1,c2) --> roughly(5)

            c1 = FlexibleConvexHull([Vec(0.,0), Vec(0.,1), Vec(1.,0),Vec(1.,1)])
            c2 = Simplex(Vec(4.,0.5))
            @fact gjk(c1, c2) --> roughly(3)
            @fact min_euclidean(c1,c2) --> roughly(3)

            pt1 = Vec(1,2,3.)
            pt2 = Vec(3,4,5.)
            @fact gjk(pt1, pt2) --> roughly(norm(pt1-pt2))
            @fact min_euclidean(pt1, pt2) --> roughly(norm(pt1-pt2))
        end

        context("gjk intersecting lines") do
            c1 = Simplex(Vec(1,1.), Vec(1, 2.))
            @fact gjk(c1, c1) --> 0.
            @fact min_euclidean(c1,c1) --> 0.

            c2 = Simplex(Vec(1,1.), Vec(10, 2.))
            @fact gjk(c1, c2) --> 0.
            @fact min_euclidean(c1,c2) --> 0.

            c3 = Simplex(Vec(0, 1.), Vec(2,2.))
            md = vertices(c1 ⊖ c3)
            @fact md --> [Vec(1.0,0.0),Vec(-1.0,-1.0),Vec(1.0,1.0),Vec(-1.0,0.0)]
            @fact gjk0(FlexibleConvexHull(md)) --> (Vec(0, 0.), 0.)
            @fact gjk(c1, c3) --> 0.
            @fact min_euclidean(c1,c3) --> 0.

        end

        context("Cube") do
            c = HyperCube(Vec(0.5,0.5,0.5), 1.)
            @fact min_euclidean(Vec(2,2,2.), c) ≈ gjk(Vec(2,2,2.), c) ≈ √(3/4) --> true

            s = Simplex(Vec(1, 0.5, 0.5), Vec(1,2,3.))
            @fact 0 <= min_euclidean(s, c) <= 1e-14 --> true
            @fact 0 <= gjk(s, c) <= 1e-14 --> true

            s = Simplex(Vec(2,2,2.), Vec(2,3,2.), Vec(2,2,7.), Vec(3,4,5.))
            @fact min_euclidean(s,c) ≈ gjk(s, c) ≈ √(3/4) --> true
        end

    end

    context("support_vector_max") do
        r = HyperRectangle(Vec(-0.5, -1.), Vec(1., 2.))
        @fact support_vector_max(r, Vec(1,0.)) --> (Vec(0.5,-1.), 0.5)
        @fact support_vector_max(r, Vec(2,0.)) --> (Vec(0.5,-1.), 1.)
        @fact support_vector_max(r, Vec(-1,0.)) --> (Vec(-0.5,-1.), 0.5)
        @fact support_vector_max(r, Vec(0, 1.)) --> (Vec(-0.5,1.), 1.)
        @fact support_vector_max(r, Vec(1, 1.)) --> (Vec(0.5,1.), 1.5)
        @fact support_vector_max(FlexibleConvexHull(r), Vec(1, 1.)) --> (Vec(0.5,1.), 1.5)

        c1 = Simplex(Vec(1,1.), Vec(1, 2.))
        c3 = Simplex(Vec(0, 1.), Vec(2,2.))
        md = c1 ⊖ c3
        fh = FlexibleConvexHull(md)
        for v in [Vec(1,0.), Vec(12,-10.), Vec(0,-1.), Vec(1,1.)]
            v_md, s_md = support_vector_max(md, v)
            v_fh, s_fh = support_vector_max(fh, v)
            @fact s_md ≈ s_fh --> true
            @fact v_md ≈ v_fh --> true
        end
    end


    context("make immutable") do
        T = FixedSizeArrays.Vec{2,Float64}
        n = 3
        S = Simplex{n, T}
        FS = FlexibleSimplex{T}
        fs = FS([Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)])
        s = S((Vec(0.0,0.0), Vec(0.0,1.0), Vec(1.0,0.0)))
        @fact (@inferred type_immutable(FS, Val{3})) --> S
        @fact type_immutable(fs) --> S
        @fact (@inferred type_immutable(fs, Val{3})) --> S
        @fact make_immutable(fs) --> s
        @fact (@inferred make_immutable(fs, Val{3})) --> s
        @fact with_immutable(identity, fs) --> s
    end

end
