"""
Allow to call decompose with unspecified vector type and infer types from
primitive.
"""
function decompose(::Type{SV},
        r::AbstractGeometry{N, T}, args...
    ) where {SV <: StaticVector, N, T}
    sz = size_or(SV, (N,))
    vectype = similar_type(SV, eltype_or(SV, T), Size{sz}())
    # since we have not triangular dispatch, we can't define a function with the
    # signature for a fully specified Vector type. But we need to check for it
    # as it means that decompose is not implemented for that version
    if SV == vectype
        throw(ArgumentError(
            "Decompose not implemented for decompose(::Type{$SV}, ::$(typeof(r)))"
        ))
    end
    decompose(vectype, r, args...)
end

"""
Tests if a geometric primitive is decomposable for a certain type.
"""
isdecomposable(::Type{T1}, ::Type{T2}) where {T1, T2} = false

isdecomposable(::Type{T1}, ::T2) where {T1, T2} = isdecomposable(T1, T2)

isdecomposable(::Type{T}, ::Type{HR}) where {T<:Point, HR<:HyperRectangle} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:Face, HR<:HyperRectangle} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:UVW, HR<:HyperRectangle} = true

isdecomposable(::Type{T}, ::Type{HR}) where {T<:Point, HR<:Quad} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:Face, HR<:Quad} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:UVW, HR<:Quad} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:Normal, HR<:Quad} = true

isdecomposable(::Type{T}, ::Type{HR}) where {T<:Point, HR<:SimpleRectangle} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:Face, HR<:SimpleRectangle} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:TextureCoordinate, HR<:SimpleRectangle} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:Normal, HR<:SimpleRectangle} = true

isdecomposable(::Type{T}, ::Type{HR}) where {T<:Point, HR <: HyperSphere} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:Face, HR <: HyperSphere} = true
isdecomposable(::Type{T}, ::Type{HR}) where {T<:TextureCoordinate, HR <: HyperSphere} = true

"""
```
decompose{N, FT1, FT2, O1, O2}(::Type{Face{3, FT1, O1}},
                               f::Face{N, FT2, O2})
```
Triangulate an N-Face into a tuple of triangular faces.
"""
@generated function decompose(::Type{Face{3, FT1}},
                          f::Face{N, FT2}) where {N, FT1, FT2}
    3 <= N || error("decompose not implented for N <= 3 yet. N: $N")# other wise degenerate
    v = Expr(:tuple)
    for i = 3:N
        push!(v.args, :(Face{3, FT1}(f[1], f[$(i-1)], f[$i])))
    end
    v
end

"""
```
decompose{N, FT1, FT2, O1, O2}(::Type{Face{2, FT1, O1}},
                               f::Face{N, FT2, O2})
```

Extract all line segments in a Face.
"""
@generated function decompose(
        ::Type{Face{2, FT1}},
        f::Face{N, FT2}
    ) where {N, FT1, FT2}
    2 <= N || error("decompose not implented for N <= 2 yet. N: $N")# other wise degenerate

    v = Expr(:tuple)
    for i = 1:N-1
        push!(v.args, :(Face{2, $FT1}(f[$i], f[$(i+1)])))
    end
    # connect vertices N and 1
    push!(v.args, :(Face{2, $FT1}(f[$N], f[1])))
    v
end

"""
Decompose an N-Simplex into a tuple of `Simplex{3}`
"""
@generated function decompose(::Type{Simplex{3, T1}},
                            f::Simplex{N, T2}) where {N, T1, T2}
    3 <= N || error("decompose not implented for N <= 3 yet. N: $N")# other wise degenerate

    v = Expr(:tuple)
    append!(v.args, [
        :(Simplex{3,$T1}(
            f[1],
            f[$(i-1)],
            f[$i]
        )) for i = 3:N]
    )
    v
end

# less strict version of above that preserves types
decompose(::Type{Simplex{3}}, f::Simplex{N, T}) where {N, T} = decompose(Simplex{3,T}, f)

"""
Decompose an N-Simplex into tuple of `Simplex{2}`
"""
@generated function decompose(::Type{Simplex{2, T1}},
                            f::Simplex{N, T2}) where {N, T1, T2}
    # other wise degenerate
    2 <= N || error("decompose not implented for N <= 2 yet. N: $N")

    v = Expr(:tuple)
    append!(v.args, [:(Simplex{2,$T1}(f[$(i)],
                                        f[$(i+1)])) for i = 1:N-1])
    # connect vertices N and 1
    push!(v.args, :(Simplex{2,$T1}(f[$(N)],
                                     f[$(1)])))
    v
end

# less strict version of above that preserves types
decompose(::Type{Simplex{2}}, f::Simplex{N, T}) where {N, T} =
    decompose(Simplex{2,T}, f)

"""
Decompose an N-Simplex into a tuple of `Simplex{1}`
"""
@generated function decompose(::Type{Simplex{1, T1}},
                            f::Simplex{N, T2}) where {N, T1, T2}
    v = Expr(:tuple)
    append!(v.args, [:(Simplex{1,$T1}(f[$i])) for i = 1:N])
    v
end
# less strict version of above
decompose(::Type{Simplex{1}}, f::Simplex{N, T}) where {N, T} = decompose(Simplex{1,T}, f)

"""
Get decompose a `HyperRectangle` into points.
"""
function decompose(
        PT::Type{Point{N, T1}}, rect::HyperRectangle{N, T2}
    ) where {N, T1, T2}
    # The general strategy is that since there are a deterministic number of
    # points, we can generate all points by looking at the binary increments.
    w = widths(rect)
    o = origin(rect)
    points = T1[o[j]+((i>>(j-1))&1)*w[j] for j=1:N, i=0:(2^N-1)]
    reshape(reinterpret(PT, points), (2^N,))
end
"""
Get decompose a `HyperRectangle` into Texture Coordinates.
"""
function decompose(
        UVWT::Type{UVW{T1}}, rect::HyperRectangle{N, T2}
    ) where {N, T1, T2}
    # The general strategy is that since there are a deterministic number of
    # points, we can generate all points by looking at the binary increments.
    w = Vec{3,T1}(1)
    o = Vec{3,T1}(0)
    points = T1[((i>>(j-1))&1) for j=1:N, i=0:(2^N-1)]
    reshape(reinterpret(UVWT, points), (8,))
end
decompose(::Type{FT}, faces::Vector{FT}) where {FT<:Face} = faces
function decompose(::Type{FT1}, faces::Vector{FT2}) where {FT1<:Face, FT2<:Face}
    isempty(faces) && return FT1[]
    N1,N2 = length(FT1), length(FT2)

    n = length(decompose(FT1, first(faces)))
    outfaces = Vector{FT1}(undef, length(faces)*n)
    i = 1
    for face in faces
        for outface in decompose(FT1, face)
            outfaces[i] = outface
            i += 1
        end
    end
    outfaces
end


"""
Get decompose a `HyperRectangle` into faces.
"""
function decompose(
        FT::Type{Face{N, T}}, rect::HyperRectangle{3, T2}
    ) where {N, T, T2}
    faces = Face{4, Int}[
        (1,2,4,3),
        (2,4,8,6),
        (4,3,7,8),
        (1,3,7,5),
        (1,5,6,2),
        (5,6,8,7),
    ]
    decompose(FT, faces)
end

function decompose(P::Type{Point{2, PT}}, r::SimpleRectangle, resolution=(2,2)) where PT
    w, h = resolution
    vec(P[(x,y) for x=range(r.x, stop=r.x+r.w, length=w), y=range(r.y, stop=r.y+r.h, length=h)])
end
function decompose(P::Type{Point{3, PT}}, r::SimpleRectangle, resolution=(2,2)) where PT
    w, h = resolution
    vec(P[(x, y, 0) for x = range(r.x, stop=r.x+r.w, length=w), y = range(r.y, stop=r.y+r.h, length=h)])
end
function decompose(T::Type{UV{UVT}}, r::SimpleRectangle, resolution=(2,2)) where UVT
    w,h = resolution
    vec(T[(x, y) for x = range(0, stop=1, length=w), y = range(1, stop=0, length=h)])
end
function decompose(::Type{T}, r::SimpleRectangle, resolution=(2,2)) where T<:Normal
    fill(T(0,0,1), prod(resolution))
end
function decompose(::Type{T}, r::SimpleRectangle, resolution=(2,2)) where T<:Face
    w,h = resolution
    Idx = LinearIndices(resolution)
    faces = vec([Face{4, Int}(
            Idx[i, j], Idx[i+1, j],
            Idx[i+1, j+1], Idx[i, j+1]
        ) for i=1:(w-1), j=1:(h-1)]
    )
    decompose(T, faces)
end

function decompose(T::Type{Point{3, PT}}, p::Pyramid) where PT
    leftup   = T(-p.width , p.width, PT(0)) / PT(2)
    leftdown = T(-p.width, -p.width, PT(0)) / PT(2)
    tip = T(p.middle + T(PT(0), PT(0), p.length))
    lu  = T(p.middle + leftup)
    ld  = T(p.middle + leftdown)
    ru  = T(p.middle - leftdown)
    rd  = T(p.middle - leftup)
    T[
        tip, rd, ru,
        tip, ru, lu,
        tip, lu, ld,
        tip, ld, rd,
        rd,  ru, lu,
        lu,  ld, rd
    ]
end

function decompose(T::Type{Point{3, ET}}, q::Quad) where ET
   T[q.downleft,
    q.downleft + q.height,
    q.downleft + q.width + q.height,
    q.downleft + q.width]
end


function decompose(T::Type{Normal{3, NT}}, q::Quad) where NT
    normal = T(normalize(cross(q.width, q.height)))
    T[normal for i=1:4]
end

decompose(T::Type{Face{3, FT}}, q::Quad) where {FT} = T[
    Face{3, FT}(1,2,3), Face{3, FT}(3,4,1)
]
decompose(T::Type{Face{4, FT}}, q::Quad) where {FT} = T[
    Face{4, FT}(1, 2, 3, 4)
]
decompose( T::Type{UV{ET}}, q::Quad) where {ET} = T[
    T(0,0), T(0,1), T(1,1), T(1,0)
]

decompose(T::Type{UVW{ET}}, q::Quad) where {ET} = T[
    q.downleft,
    q.downleft + q.height,
    q.downleft + q.width + q.height,
    q.downleft + q.width
]

function decompose(T::Type{Face{3, FT}}, r::Pyramid) where FT
    reinterpret(T, map(FT, collect(1:18)))
end




# Getindex methods, for converted indexing into the mesh
# Define decompose for your own meshtype, to easily convert it to Homogenous attributes

#Gets the normal attribute to a mesh
function decompose(T::Type{Point{3, VT}}, mesh::AbstractMesh) where VT
    vts = mesh.vertices
    eltype(vts) == T && return vts
    eltype(vts) <: Point && return map(T, vts)
end

# gets the wanted face type
function decompose(T::Type{Face{N, FT}}, mesh::AbstractMesh) where {N, FT}
    fs = faces(mesh)
    eltype(fs) == T && return fs
    return decompose(T, fs)
end

#Gets the normal attribute to a mesh
function decompose(T::Type{Normal{3, NT}}, mesh::AbstractMesh) where NT
    n = mesh.normals
    eltype(n) == T && return n
    eltype(n) <: Normal{3} && return map(T, n)
    (n == Nothing[] || isempty(n)) && return normals(vertices(mesh), faces(mesh), T)
end

#Gets the uv attribute to a mesh, or creates it, or converts it
function decompose(::Type{UV{UVT}}, mesh::AbstractMesh) where UVT
    uv = mesh.texturecoordinates
    eltype(uv) == UV{UVT} && return uv
    (eltype(uv) <: UV || eltype(uv) <: UVW) && return map(UV{UVT}, uv)
    eltype(uv) == Nothing && return zeros(UV{UVT}, length(vertices(mesh)))
end


#Gets the uv attribute to a mesh
function decompose(::Type{UVW{UVWT}}, mesh::AbstractMesh) where UVWT
    uvw = mesh.texturecoordinates
    typeof(uvw) == UVW{UVWT} && return uvw
    (isa(uvw, UV) || isa(uvw, UVW)) && return map(UVW{UVWT}, uvw)
    uvw == nothing && return zeros(UVW{UVWT}, length(mesh.vertices))
end
const DefaultColor = RGBA(0.2, 0.2, 0.2, 1.0)

#Gets the color attribute from a mesh
function decompose(::Type{Vector{T}}, mesh::AbstractMesh) where T <: Colorant
    colors = mesh.attributes
    typeof(colors) == Vector{T} && return colors
    colors == nothing && return fill(DefaultColor, length(mesh.attribute_id))
    map(T, colors)
end

#Gets the color attribute from a mesh
function decompose(::Type{T}, mesh::AbstractMesh) where T <: Colorant
    c = mesh.color
    typeof(c) == T && return c
    c == nothing && return DefaultColor
    convert(T, c)
end




function spherical(theta::T, phi::T) where {T}
    Point{3, T}(
        sin(theta)*cos(phi),
        sin(theta)*sin(phi),
        cos(theta)
    )
end

function decompose(PT::Type{Point{3, T}}, s::Circle, n=64) where T
    points2d = decompose(Point{2, T}, s, n)
    map(x-> Point{3, T}(x[1], x[2], 0), points2d)
end

function decompose(PT::Type{Point{2,T}}, s::Circle, n=64) where T
    rad = radius(s)
    map(range(T(0), stop=T(2pi), length=n)) do fi
        PT(
            rad*sin(fi + pi),
            rad*cos(fi + pi)
        ) + origin(s)
    end
end

function decompose(PT::Type{Point{N,T}}, s::Sphere, n = 24) where {N,T}
    θ = LinRange(0, pi, n); φ = 2 .* θ
    vec(map((θ, φ) for θ in θ, φ in φ) do (θ, φ,)
        Point3f0(cos(φ)*sin(θ), sin(φ)*sin(θ), cos(θ))
    end)
end

function decompose(PT::Type{UV{T}}, s::Sphere, n = 24) where T
    ux = LinRange(0, 1, n)
    vec([UV{Float32}(φ, θ) for θ in reverse(ux), φ in ux])
end

function decompose(::Type{FT}, s::Sphere, n = 24) where FT <: Face
    decompose(FT, SimpleRectangle(0, 0, 1, 1), (n, n))
end

isdecomposable(::Type{T}, ::Type{C}) where {T <:Point, C <:Cylinder3} = true
isdecomposable(::Type{T}, ::Type{C}) where {T <:Face, C <:Cylinder3} = true
isdecomposable(::Type{T}, ::Type{C}) where {T <:Point, C <:Cylinder2} = true
isdecomposable(::Type{T}, ::Type{C}) where {T <:Face, C <:Cylinder2} = true

# def of resolution + rotation
function decompose(PT::Type{Point{3, T}}, c::Cylinder{2, T}, resolution = (2, 2)) where T
    r = SimpleRectangle{T}(c.origin[1] - c.r/2, c.origin[2], c.r, height(c))
    M = rotation(c); vertices = decompose(PT, r, resolution)
    vo = length(c.origin) == 2 ? Point{3, T}(c.origin[1], c.origin[2], 0) : c.origin
    for i = 1:length(vertices)
        vertices[i] = PT(M * (vertices[i] - vo) + vo)
    end
    return vertices
end
function decompose(PT::Type{Point{3,T}}, c::Cylinder{3, T}, resolution = 5) where T
    isodd(resolution) && (resolution = 2 * div(resolution, 2))
    resolution = max(8, resolution); nbv = div(resolution, 2)
    M = rotation(c); h = height(c)
    position = 1; vertices = Vector{PT}(undef, 2 * nbv)
    for j = 1:nbv
        phi = T((2π * (j - 1)) / nbv)
        vertices[position] = PT(M * Point{3, T}(c.r * cos(phi), c.r * sin(phi),0)) + PT(c.origin)
        vertices[position+1] = PT(M * Point{3, T}(c.r * cos(phi), c.r * sin(phi),h)) + PT(c.origin)
        position += 2
    end
    return vertices
end

function decompose(::Type{FT}, c::Cylinder{2, T}, resolution = (2, 2)) where {FT <: Face, T}
    r = SimpleRectangle{T}(c.origin[1] - c.r/2, c.origin[2], c.r, height(c))
    return decompose(FT, r, resolution)
end
function decompose(::Type{FT}, c::Cylinder{3, T}, facets = 18) where {FT <: Face, T}
    isodd(facets) ? facets = 2 * div(facets, 2) : nothing
    facets < 8 ? facets = 8 : nothing; nbv = Int(facets / 2)
    indexes = Vector{FT}(undef, facets); index = 1
    for j = 1:(nbv-1)
        indexes[index] = (index + 2, index + 1, index)
        indexes[index + 1] = ( index + 3, index + 1, index + 2)
        index += 2
    end
    indexes[index] = (1, index + 1, index)
    indexes[index + 1] = (2, index + 1, 1)
    return indexes
end
