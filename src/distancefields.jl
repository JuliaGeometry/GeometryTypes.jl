@inline size(s::SignedDistanceField) = size(s.data)
@inline size(s::SignedDistanceField, i...) = size(s.data, i...)
@inline getindex(s::SignedDistanceField, i) = getindex(s.data,i)
@inline getindex(s::SignedDistanceField, i, j) = getindex(s.data,i, j)
@inline getindex(s::SignedDistanceField, i, j, k) = getindex(s.data,i, j,k)
@inline getindex(s::SignedDistanceField, i...) = getindex(s.data,i...)

@inline HyperRectangle(s::SignedDistanceField) = s.bounds

"""
Construct a `SignedDistanceField` by sampling a function over the `bounds`
at the specified `resolution` (default = 0.1). Note that the sampling grid
must be regular,
so a new HyperRectangle will be generated for the SignedDistanceField that
may have larger maximum bounds than the input HyperRectangle. The default
Field type is Float64, but this can be changed with the `fieldT` argument.
"""
function SignedDistanceField(f::Function,
                             bounds::HyperRectangle{3, T},
                             resolution=0.1,
                             fieldT=Float64) where T
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

    nb_min = minimum(bounds)
    SignedDistanceField{3,T,fieldT}(HyperRectangle{3, T}(nb_min, nb_max-nb_min), vol)
end

function SignedDistanceField(f::Function,
                             bounds::HyperRectangle{2,T},
                             resolution=0.1,
                             fieldT=Float64) where T
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

    nb_min = minimum(bounds)
    SignedDistanceField{2,T,fieldT}(HyperRectangle{2, T}(nb_min, nb_max-nb_min), vol)
end
