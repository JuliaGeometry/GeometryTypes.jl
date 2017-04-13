"""
Allow to call decompose with unspecified vector type and infer types from
primitive.
"""
function decompose{FSV <: FixedVector, N, T}(::Type{FSV},
        r::AbstractGeometry{N, T}, args...
    )
    vectype = similar_type(FSV, eltype_or(FSV, T), size_or(FSV, (N,)))
    # since we have not triangular dispatch, we can't define a function with the
    # signature for a fully specified Vector type. But we need to check for it
    # as it means that decompose is not implemented for that version
    if FSV == vectype
        throw(ArgumentError(
            "Decompose not implemented for decompose(::Type{$FSV}, ::$(typeof(r)))"
        ))
    end
    decompose(vectype, r, args...)
end

"""
Tests if a geometric primitive is decomposable for a certain type.
"""
isdecomposable{T1, T2}(::Type{T1}, ::Type{T2}) = false

isdecomposable{T1, T2}(::Type{T1}, ::T2) = isdecomposable(T1, T2)

isdecomposable{T<:Point, HR<:HyperRectangle}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:Face, HR<:HyperRectangle}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:UVW, HR<:HyperRectangle}(::Type{T}, ::Type{HR}) = true

isdecomposable{T<:Point, HR<:Quad}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:Face, HR<:Quad}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:UVW, HR<:Quad}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:Normal, HR<:Quad}(::Type{T}, ::Type{HR}) = true

isdecomposable{T<:Point, HR<:SimpleRectangle}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:Face, HR<:SimpleRectangle}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:TextureCoordinate, HR<:SimpleRectangle}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:Normal, HR<:SimpleRectangle}(::Type{T}, ::Type{HR}) = true

isdecomposable{T<:Point, HR<:HyperSphere}(::Type{T}, ::Type{HR}) = true
isdecomposable{T<:Face, HR<:HyperSphere}(::Type{T}, ::Type{HR}) = true

"""
```
decompose{N, FT1, FT2, O1, O2}(::Type{Face{3, FT1, O1}},
                               f::Face{N, FT2, O2})
```
Triangulate an N-Face into a tuple of triangular faces.
"""
@generated function decompose{N, FT1, FT2, O1, O2}(::Type{Face{3, FT1, O1}},
                                       f::Face{N, FT2, O2})
    3 <= N || error("decompose not implented for N <= 3 yet. N: $N")# other wise degenerate

    v = Expr(:tuple)
    append!(v.args, [
        :(Face{3,FT1,O1}(
            offsetbased(f,1, O1),
            offsetbased(f,$(i-1), O1),
            offsetbased(f,$i, O1)
        )) for i = 3:N]
    )
    v
end

"""
```
decompose{N, FT1, FT2, O1, O2}(::Type{Face{2, FT1, O1}},
                               f::Face{N, FT2, O2})
```

Extract all line segments in a Face.
"""
@generated function decompose{N, FT1, FT2, O1, O2}(::Type{Face{2, FT1, O1}},
                                       f::Face{N, FT2, O2})
    2 <= N || error("decompose not implented for N <= 2 yet. N: $N")# other wise degenerate

    v = Expr(:tuple)
    append!(v.args, [
        :(Face{2,$FT1,$O1}(
            offsetbased(f, $i    , O1),
            offsetbased(f, $(i+1), O1),
        )) for i = 1:N-1]
    )
    # connect vertices N and 1
    push!(v.args,
        :(Face{2,$FT1,$O1}(
            offsetbased(f, N, O1),
            offsetbased(f, 1, O1)
        ))
    )
    v
end

"""
Decompose an N-Simplex into a tuple of Simplex{3}
"""
@generated function decompose{N, T1, T2}(::Type{Simplex{3, T1}},
                                       f::Simplex{N, T2})
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
function decompose{N, T1, T2}(
        PT::Type{Point{N, T1}}, rect::HyperRectangle{N, T2}
    )
    # The general strategy is that since there are a deterministic number of
    # points, we can generate all points by looking at the binary increments.
    w = widths(rect)
    o = origin(rect)
    points = T1[o[j]+((i>>(j-1))&1)*w[j] for j=1:N, i=0:(2^N-1)]
    reinterpret(PT, points, (2^N,))
end
"""
Get decompose a `HyperRectangle` into Texture Coordinates.
"""
function decompose{N, T1, T2}(
        UVWT::Type{UVW{T1}}, rect::HyperRectangle{N, T2}
    )
    # The general strategy is that since there are a deterministic number of
    # points, we can generate all points by looking at the binary increments.
    w = Vec{3,T1}(1)
    o = Vec{3,T1}(0)
    points = T1[((i>>(j-1))&1) for j=1:N, i=0:(2^N-1)]
    reinterpret(UVWT, points, (8,))
end
decompose{FT<:Face}(::Type{FT}, faces::Vector{FT}) = faces
function decompose{FT1<:Face, FT2<:Face}(::Type{FT1}, faces::Vector{FT2})
    isempty(faces) && return FT1[]
    N1,N2 = length(FT1), length(FT2)

    n = length(decompose(FT1, first(faces)))
    outfaces = Array(FT1, length(faces)*n)
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
function decompose{N, T, O, T2}(
        FT::Type{Face{N, T, O}}, rect::HyperRectangle{3, T2}
    )
    faces = Face{4, Int, 0}[
        (1,2,4,3),
        (2,4,8,6),
        (4,3,7,8),
        (1,3,7,5),
        (1,5,6,2),
        (5,6,8,7),
    ]
    decompose(FT, faces)
end

function decompose{PT}(P::Type{Point{2, PT}}, r::SimpleRectangle, resolution=(2,2))
    w,h = resolution
    vec(P[(x,y) for x=linspace(r.x, r.x+r.w, w), y=linspace(r.y, r.y+r.h, h)])
end
function decompose{PT}(P::Type{Point{3, PT}}, r::SimpleRectangle, resolution=(2,2))
    w,h = resolution
    vec(P[(x,y,0) for x=linspace(r.x, r.x+r.w, w), y=linspace(r.y, r.y+r.h, h)])
end
function decompose{UVT}(T::Type{UV{UVT}}, r::SimpleRectangle, resolution=(2,2))
    w,h = resolution
    vec(T[(x, y) for x = linspace(0, 1, w), y = linspace(1, 0, h)])
end
function decompose{T<:Normal}(::Type{T}, r::SimpleRectangle, resolution=(2,2))
    fill(T(0,0,1), prod(resolution))
end
function decompose{T<:Face}(::Type{T}, r::SimpleRectangle, resolution=(2,2))
    w,h = resolution
    faces = vec([Face{4, Int, 0}(
            sub2ind(resolution, i, j), sub2ind(resolution, i+1, j),
            sub2ind(resolution, i+1, j+1), sub2ind(resolution, i, j+1)
        ) for i=1:(w-1), j=1:(h-1)]
    )
    decompose(T, faces)
end

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
decompose{FT, IO}(T::Type{Face{4, FT, IO}}, q::Quad) = T[
    Face{4, Int, 0}(1,2,3,4)
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

function decompose{FT, IO}(T::Type{Face{3, FT, IO}}, r::Pyramid)
    reinterpret(T, collect(map(FT, (1:18)+IO)))
end




# Getindex methods, for converted indexing into the mesh
# Define decompose for your own meshtype, to easily convert it to Homogenous attributes

#Gets the normal attribute to a mesh
function decompose{VT}(T::Type{Point{3, VT}}, mesh::AbstractMesh)
    vts = mesh.vertices
    eltype(vts) == T && return vts
    eltype(vts) <: Point && return map(T, vts)
end

# gets the wanted face type
function decompose{N, FT, Offset}(T::Type{Face{N, FT, Offset}}, mesh::AbstractMesh)
    fs = faces(mesh)
    eltype(fs) == T && return fs
    return decompose(T, fs)
end

#Gets the normal attribute to a mesh
function decompose{NT}(T::Type{Normal{3, NT}}, mesh::AbstractMesh)
    n = mesh.normals
    eltype(n) == T && return n
    eltype(n) <: Normal{3} && return map(T, n)
    (n == Void[] || isempty(n)) && return normals(vertices(mesh), faces(mesh), T)
end

#Gets the uv attribute to a mesh, or creates it, or converts it
function decompose{UVT}(::Type{UV{UVT}}, mesh::AbstractMesh)
    uv = mesh.texturecoordinates
    eltype(uv) == UV{UVT} && return uv
    (eltype(uv) <: UV || eltype(uv) <: UVW) && return map(UV{UVT}, uv)
    eltype(uv) == Void && return zeros(UV{UVT}, length(vertices(mesh)))
end


#Gets the uv attribute to a mesh
function decompose{UVWT}(::Type{UVW{UVWT}}, mesh::AbstractMesh)
    uvw = mesh.texturecoordinates
    typeof(uvw) == UVW{UVWT} && return uvw
    (isa(uvw, UV) || isa(uvw, UVW)) && return map(UVW{UVWT}, uvw)
    uvw == nothing && return zeros(UVW{UVWT}, length(mesh.vertices))
end
const DefaultColor = RGBA(0.2, 0.2, 0.2, 1.0)

#Gets the color attribute from a mesh
function decompose{T <: Colorant}(::Type{Vector{T}}, mesh::AbstractMesh)
    colors = mesh.attributes
    typeof(colors) == Vector{T} && return colors
    colors == nothing && return fill(DefaultColor, length(mesh.attribute_id))
    map(T, colors)
end

#Gets the color attribute from a mesh
function decompose{T <: Colorant}(::Type{T}, mesh::AbstractMesh)
    c = mesh.color
    typeof(c) == T && return c
    c == nothing && return DefaultColor
    convert(T, c)
end




spherical{T}(theta::T, phi::T) = Point{3, T}(
    sin(theta)*cos(phi),
    sin(theta)*sin(phi),
    cos(theta)
)

function decompose{T}(PT::Type{Point{2,T}}, s::Circle, n=32)
    rad = radius(s)
    map(linspace(T(0), T(2pi), n)) do fi
        PT(
            rad*sin(fi + pi),
            rad*cos(fi + pi)
        ) + origin(s)
    end
end

function decompose{N,T}(PT::Type{Point{N,T}}, s::Sphere, facets=12)
    vertices      = Array(PT, facets*facets+1)
    vertices[end] = PT(s.center) - PT(0,0,radius(s)) #Create a vertex for last triangle fan
    for j=1:facets
        theta = T((pi*(j-1))/facets)
        for i=1:facets
            position           = sub2ind((facets,), j, i)
            phi                = T((2*pi*(i-1))/facets)
            vertices[position] = (spherical(theta, phi)*T(s.r))+PT(s.center)
        end
    end
    vertices
end
function decompose{FT<:Face}(::Type{FT}, s::Sphere, facets=12)
    indexes          = Array(FT, facets*facets*2)
    FTE              = eltype(FT)
    psydo_triangle_i = facets*facets+1
    index            = 1
    for j=1:facets
        for i=1:facets
            next_index = mod1(i+1, facets)
            i1 = sub2ind((facets,), j, i)
            i2 = sub2ind((facets,), j, next_index)
            i3 = (j != facets) ? sub2ind((facets,), j+1, i)          : psydo_triangle_i
            i6 = (j != facets) ? sub2ind((facets,), j+1, next_index) : psydo_triangle_i
            indexes[index]   = FT(Triangle{FTE}(i1,i2,i3)) # convert to required Face index offset
            indexes[index+1] = FT(Triangle{FTE}(i3,i2,i6))
            index += 2
        end
    end
    indexes
end

isdecomposable{T<:Point, C<:Cylinder3}(::Type{T}, ::Type{C}) = true
isdecomposable{T<:Face, C<:Cylinder3}(::Type{T}, ::Type{C}) = true
isdecomposable{T<:Point, C<:Cylinder2}(::Type{T}, ::Type{C}) = true
isdecomposable{T<:Face, C<:Cylinder2}(::Type{T}, ::Type{C}) = true

# def of resolution + rotation
function decompose{T}(PT::Type{Point{3,T}},c::Cylinder{2,T},resolution=(2,2))
    r = SimpleRectangle{T}(c.origin[1]-c.r/2,c.origin[2],c.r,height(c))
    M = rotation(c); vertices = decompose(PT,r,resolution)
    vo = length(c.origin)==2 ? [c.origin...,0] : c.origin
    for i = 1:length(vertices)
        vertices[i] = PT(M*(vertices[i]-vo)+vo)
    end
    return vertices
end
function decompose{T}(PT::Type{Point{3,T}},c::Cylinder{3,T},resolution=5)
    isodd(resolution) ? resolution = 2*div(resolution,2) : nothing
    resolution<8 ? resolution = 8 : nothing; nbv = Int(resolution/2)
    M = rotation(c); h = height(c)
    position = 1; vertices = Array(PT,2*nbv)
    for j = 1:nbv
        phi = T((2*pi*(j-1))/nbv)
        vertices[position] = PT(M*[c.r*cos(phi);c.r*sin(phi);0])+PT(c.origin)
        vertices[position+1] = PT(M*[c.r*cos(phi);c.r*sin(phi);h])+PT(c.origin)
        position += 2
    end
    return vertices
end

function decompose{FT<:Face,T}(::Type{FT},c::Cylinder{2,T},resolution=(2,2))
    r = SimpleRectangle{T}(c.origin[1]-c.r/2,c.origin[2],c.r,height(c))
    return decompose(Face{3,Int,0},r,resolution)
end
function decompose{FT<:Face,T}(::Type{FT},c::Cylinder{3,T},facets=18)
    isodd(facets) ? facets = 2*div(facets,2) : nothing
    facets<8 ? facets = 8 : nothing; nbv = Int(facets/2)
    indexes = Array(Face{3,Int,0},facets); index = 1
    for j = 1:(nbv-1)
        indexes[index] = (index,index+1,index+2)
        indexes[index+1] = (index+2,index+1,index+3)
        index += 2
    end
    indexes[index] = (index,index+1,1)
    indexes[index+1] = (1,index+1,2)
    return indexes
end
