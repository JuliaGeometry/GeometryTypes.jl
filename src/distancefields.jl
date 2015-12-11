@inline Base.size(s::SignedDistanceField) = size(s.data)

"""
Construct a `SignedDistanceField` by sampling a function over the `bounds`
at the specified `resolution` (default = 0.1). Note that the sampling grid
must be regular,
so a new HyperRectangle will be generated for the SignedDistanceField that
may have larger maximum bounds than the input HyperRectangle. The default
Field type is Float64, but this can be changed with the `fieldT` argument.
"""
function SignedDistanceField{T}(f::Function,
                                bounds::HyperRectangle{3,T},
                                resolution=0.1,
                                fieldT=Float64)
    x_min, y_min, z_min = minimum(bounds)
    x_max, y_max, z_max = maximum(bounds)

    x_rng, y_rng, z_rng = maximum(bounds) - minimum(bounds)

    nx = ceil(Int, x_rng/resolution)
    ny = ceil(Int, y_rng/resolution)
    nz = ceil(Int, z_rng/resolution)

    vol = Array{fieldT}(nx+1, ny+1, nz+1)

    nb_max = Vec(x_min + resolution*nx,
                 y_min + resolution*ny,
                 z_min + resolution*nz)

    for i = 0:nx, j = 0:ny, k = 0:nz
        x = x_min + resolution*i
        y = y_min + resolution*j
        z = z_min + resolution*k
        @inbounds vol[i+1,j+1,k+1] = f(Vec{3,fieldT}(x,y,z))
    end

    SignedDistanceField{3,T,fieldT}(HyperRectangle(minimum(bounds), nb_max), vol)
end

function SignedDistanceField{T}(f::Function,
                                bounds::HyperRectangle{2,T},
                                resolution=0.1,
                                fieldT=Float64)
    x_min, y_min = minimum(bounds)
    x_max, y_max = maximum(bounds)

    x_rng, y_rng = maximum(bounds) - minimum(bounds)

    nx = ceil(Int, x_rng/resolution)
    ny = ceil(Int, y_rng/resolution)

    vol = Array{fieldT}(nx+1, ny+1)

    nb_max = Vec(x_min + resolution*nx,
                 y_min + resolution*ny)

    for i = 0:nx, j = 0:ny
        x = x_min + resolution*i
        y = y_min + resolution*j
        @inbounds vol[i+1,j+1] = f(Vec{2,fieldT}(x,y))
    end

    SignedDistanceField{2,T,fieldT}(HyperRectangle(minimum(bounds), nb_max), vol)
end

#=
@generated function SignedDistanceField{N,T}(f::Function,
                                bounds::HyperRectangle{N,T},
                                resolution=0.1,
                                fieldT=Float64)

    # grab the bounds to easily reference later
    ib = minimum(bounds)
    sb = maximum(bounds)

    # compute the range
    rng = maximum(bounds) - minimum(bounds)

    # determine how many intervals cover the range
    ct = map(x->ceil(Int, x/resolution), rng)

    # adjust count for array since we have atleast two elements
    rct = map(x->x+1, ct)

    vol = Array{fieldT}(rct...)

    # compute the new max value
    nb_max = ib + ct*resolution

    for i = 0:nx, j = 0:ny
        x = x_min + resolution*i
        y = y_min + resolution*j
        @inbounds vol[i+1,j+1] = f(Vec{N,fieldT}(x,y))
    end

    SignedDistanceField{N,T,fieldT}(HyperRectangle(ib, nb_max), vol)
end
=#
