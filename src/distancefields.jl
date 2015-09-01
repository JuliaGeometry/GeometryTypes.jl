abstract AbstractDistanceField
abstract AbstractUnsignedDistanceField <: AbstractDistanceField
abstract AbstractSignedDistanceField <: AbstractDistanceField


"""
A DistanceField of dimensionality `N`, is parameterized by the Space and
Field types.
"""
type SignedDistanceField{N,SpaceT,FieldT} <: AbstractSignedDistanceField
    bounds::HyperRectangle{N,SpaceT}
    data::Array{FieldT,N}
end

@inline Base.size(s::SignedDistanceField) = size(s.data)

"""
Construct a `SignedDistanceField` by sampling a function over the `bounds`
at the specified `resolution`. Note that the sampling grid must be regular,
so a new HyperRectangle will be generated for the SignedDistanceField that
may have larger maximum bounds than the input HyperRectangle.
"""
function SignedDistanceField{T}(f::Function, bounds::HyperRectangle{3,T}, resolution=0.1)
    x_min, y_min, z_min = minimum(bounds)
    x_max, y_max, z_max = maximum(bounds)

    x_rng, y_rng, z_rng = maximum(bounds) - minimum(bounds)

    nx = ceil(Int, x_rng/resolution)
    ny = ceil(Int, y_rng/resolution)
    nz = ceil(Int, z_rng/resolution)

    vol = Array{Float64}(nx+1, ny+1, nz+1)

    nb_max = Vec(x_min + resolution*nx,
                 y_min + resolution*ny,
                 z_min + resolution*nz)

    for i = 0:nx, j = 0:ny, k = 0:nz
        x = x_min + resolution*i
        y = y_min + resolution*j
        z = z_min + resolution*k
        @inbounds vol[i+1,j+1,k+1] = f(Vec(x,y,z))
    end

    SignedDistanceField{3,T,Float64}(HyperRectangle(minimum(bounds), nb_max), vol)
end

function SignedDistanceField{T}(f::Function, bounds::HyperRectangle{2,T}, resolution=0.1)
    x_min, y_min = minimum(bounds)
    x_max, y_max = maximum(bounds)

    x_rng, y_rng = maximum(bounds) - minimum(bounds)

    nx = ceil(Int, x_rng/resolution)
    ny = ceil(Int, y_rng/resolution)

    vol = Array{Float64}(nx+1, ny+1)

    nb_max = Vec(x_min + resolution*nx,
                 y_min + resolution*ny)

    for i = 0:nx, j = 0:ny
        x = x_min + resolution*i
        y = y_min + resolution*j
        @inbounds vol[i+1,j+1] = f(Vec(x,y))
    end

    SignedDistanceField{2,T,Float64}(HyperRectangle(minimum(bounds), nb_max), vol)
end
