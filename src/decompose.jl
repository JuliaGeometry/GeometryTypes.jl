"""
Allow to call decompose with unspecified vector type and infer types from
primitive.
"""
decompose{FSV <: FixedVector, N, T}(::Type{FSV}, r::GeometryPrimitive{N, T}) =
    decompose(similar(FSV, eltype_or(FSV, T), size_or(FSV, (N,))[1]), r)

"""
Triangulate an N-Face into a tuple of triangular faces.
"""
@generated function decompose{N, FT1, FT2, O1, O2}(::Type{Face{3, FT1, O1}},
                                       f::Face{N, FT2, O2})
    3 <= N || error("decompose not implented for N <= 3 yet. N: $N")# other wise degenerate

    v = Expr(:tuple)
    append!(v.args, [:(Face{3,$FT1,$O1}(f[1]+$(-O2+O1),
                                        f[$(i-1)]+$(-O2+O1),
                                        f[$(i)]+$(-O2+O1))) for i = 3:N])
    v
end

"""
Extract all line segments in a Face.
"""
@generated function decompose{N, FT1, FT2, O1, O2}(::Type{Face{2, FT1, O1}},
                                       f::Face{N, FT2, O2})
    2 <= N || error("decompose not implented for N <= 2 yet. N: $N")# other wise degenerate

    v = Expr(:tuple)
    append!(v.args, [:(Face{2,$FT1,$O1}(f[$(i)]+$(-O2+O1),
                                        f[$(i+1)]+$(-O2+O1))) for i = 1:N-1])
    # connect vertices N and 1
    push!(v.args, :(Face{2,$FT1,$O1}(f[$(N)]+$(-O2+O1),
                                     f[$(1)]+$(-O2+O1)))) # not enough dollars
    v
end

"""
Decompose an N-Simplex into a tuple of Simplex{3}
"""
@generated function decompose{N, T1, T2}(::Type{Simplex{3, T1}},
                                       f::Simplex{N, T2})
    3 <= N || error("decompose not implented for N <= 3 yet. N: $N")# other wise degenerate

    v = Expr(:tuple)
    append!(v.args, [:(Simplex{3,$T1}(f[1],
                                        f[$(i-1)],
                                        f[$i])) for i = 3:N])
    v
end

# less strict version of above that preserves types
decompose{N, T}(::Type{Simplex{3}}, f::Simplex{N, T}) = decompose(Simplex{3,T}, f)

"""
Decompose an N-Simplex into tuple of Simplex{2}
"""
@generated function decompose{N, T1, T2}(::Type{Simplex{2, T1}},
                                       f::Simplex{N, T2})
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
decompose{N, T}(::Type{Simplex{2}}, f::Simplex{N, T}) =
    decompose(Simplex{2,T}, f)

"""
Decompose an N-Simplex into a tuple of Simplex{1}
"""
@generated function decompose{N, T1, T2}(::Type{Simplex{1, T1}},
                                       f::Simplex{N, T2})
    v = Expr(:tuple)
    append!(v.args, [:(Simplex{1,$T1}(f[$i])) for i = 1:N])
    v
end
# less strict version of above
decompose{N, T}(::Type{Simplex{1}}, f::Simplex{N, T}) = decompose(Simplex{1,T}, f)

"""
Get decompose a `HyperRectangle` into points.
"""
@generated function decompose{N, T1<:FixedVector, T2}(::Type{T1},
                                 rect::HyperRectangle{N, T2})
    # The general strategy is that since there are a deterministic number of
    # points, we can generate all points by looking at the binary increments.
    v = Expr(:tuple)
    for i = 0:(2^N-1)
        ex = Expr(:call, T1)
        for j = 0:(N-1)
            n = 2^j
            push!(ex.args, :(origin(rect)[$(j+1)]+$((i>>j)&1)*widths(rect)[$(j+1)]))
        end
        push!(v.args, ex)
    end
    v
end



function decompose{PT}(P::Type{Point{2, PT}}, r::SimpleRectangle)
   P[P(r.x, r.y),
    P(r.x, r.y + r.h),
    P(r.x + r.w, r.y + r.h),
    P(r.x + r.w, r.y)]
end
decompose{UVT}(T::Type{UV{UVT}}, r::SimpleRectangle) = T[
    T(0, 0),
    T(0, 1),
    T(1, 1),
    T(1, 0)
]
decompose{FT, IO}(T::Type{Face{3, FT, IO}}, r::SimpleRectangle) = T[
    Face{3, Int, 0}(1,2,3), Face{3, Int, 0}(3,4,1)
]

function decompose{PT}(T::Type{Point{3, PT}}, p::Pyramid)
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

function decompose{ET}(T::Type{Point{3, ET}}, q::Quad)
   T[q.downleft,
    q.downleft + q.height,
    q.downleft + q.width + q.height,
    q.downleft + q.width]
end


function decompose{NT}(T::Type{Normal{3, NT}}, q::Quad)
    normal = T(normalize(cross(q.width, q.height)))
    T[normal for i=1:4]
end

decompose{FT, IO}(T::Type{Face{3, FT, IO}}, q::Quad) = T[
    Face{3, Int, 0}(1,2,3), Face{3, Int, 0}(3,4,1)
]

decompose{ET}( T::Type{UV{ET}}, q::Quad) = T[
    T(0,0), T(0,1), T(1,1), T(1,0)
]

decompose{ET}(T::Type{UVW{ET}}, q::Quad) = T[
    q.downleft,
    q.downleft + q.height,
    q.downleft + q.width + q.height,
    q.downleft + q.width
]

decompose{FT, IO}(T::Type{Face{3, FT, IO}}, r::Pyramid) =
    reinterpret(T, collect(map(FT,(1:18)+IO)))

# Getindex methods, for converted indexing into the mesh
# Define decompose for your own meshtype, to easily convert it to Homogenous attributes

#Gets the normal attribute to a mesh
function decompose{VT}(T::Type{Point{3, VT}}, mesh::AbstractMesh)
    vts = mesh.vertices
    eltype(vts) == T && return vts
    eltype(vts) <: Point && return map(T, vts)
end

# gets the wanted face type
function decompose{FT, Offset}(T::Type{Face{3, FT, Offset}}, mesh::AbstractMesh)
    fs = faces(mesh)
    eltype(fs) == T && return fs
    eltype(fs) <: Face{3} && return map(T, fs)
    if eltype(fs) <:  Face{4}
        convert(Vector{Face{3, FT, Offset}}, fs)
    end
    error("can't get the wanted attribute $(T) from mesh:")
end

#Gets the normal attribute to a mesh
function decompose{NT}(T::Type{Normal{3, NT}}, mesh::AbstractMesh)
    n = mesh.normals
    eltype(n) == T && return n
    eltype(n) <: Normal{3} && return map(T, n)
    n == Void[] && return normals(mesh.vertices, mesh.faces, T)
end

#Gets the uv attribute to a mesh, or creates it, or converts it
function decompose{UVT}(::Type{UV{UVT}}, mesh::AbstractMesh)
    uv = mesh.texturecoordinates
    eltype(uv) == UV{UVT} && return uv
    (eltype(uv) <: UV || eltype(uv) <: UVW) && return map(UV{UVT}, uv)
    eltype(uv) == Void && return zeros(UV{UVT}, length(mesh.vertices))
end


#Gets the uv attribute to a mesh
function decompose{UVWT}(::Type{UVW{UVWT}}, mesh::AbstractMesh)
    uvw = mesh.texturecoordinates
    typeof(uvw) == UVW{UVT} && return uvw
    (isa(uvw, UV) || isa(uv, UVW)) && return map(UVW{UVWT}, uvw)
    uvw == nothing && return zeros(UVW{UVWT}, length(mesh.vertices))
end
const DefaultColor = RGBA(0.2, 0.2, 0.2, 1.0)

#Gets the color attribute from a mesh
function decompose{T <: Color}(::Type{Vector{T}}, mesh::AbstractMesh)
    colors = mesh.attributes
    typeof(colors) == Vector{T} && return colors
    colors == nothing && return fill(DefaultColor, length(mesh.attribute_id))
    map(T, colors)
end

#Gets the color attribute from a mesh
function decompose{T <: Color}(::Type{T}, mesh::AbstractMesh)
    c = mesh.color
    typeof(c) == T && return c
    c == nothing && return DefaultColor
    convert(T, c)
end
