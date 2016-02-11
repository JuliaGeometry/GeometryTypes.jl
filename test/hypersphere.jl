context("HyperSphere") do
    @fact Sphere(Point(0,0,0), 4) --> HyperSphere{3,Int}(Point{3,Int}((0,0,0)),4)
    c = Circle(Point(0,0), 1)
    @fact c --> HyperSphere(Point(0,0), 1)
    @fact origin(c) --> Point(0,0)
    @fact isinside(c, 1, 2) --> false
    @fact isinside(c, 0.5, 0.5) --> true

    centered_rect = centered(HyperSphere)
    @fact centered_rect --> HyperSphere{3,Float32}(Point3f0(0), 0.5f0)
    centered_rect = centered(HyperSphere{2})
    @fact centered_rect --> HyperSphere{2,Float32}(Point2f0(0),0.5f0)

    centered_rect = centered(HyperSphere{2, Float64})
    @fact centered_rect --> HyperSphere{2,Float64}(Point(0.,0.), 0.5)

    centered_rect = centered(HyperSphere{3, Float32})
    @fact centered_rect --> HyperSphere{3,Float32}(Point3f0(0), 0.5f0)

    @fact widths(centered_rect) --> Vec3f0(1)
    @fact radius(centered_rect) --> 0.5f0
    @fact maximum(centered_rect) --> Vec3f0(0.5f0)
    @fact minimum(centered_rect) --> Vec3f0(-0.5f0)
end
