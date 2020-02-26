
function (meshtype::Type{T})(c::Pyramid) where T <: AbstractMesh
    T(vertices = decompose(vertextype(T), c), faces = decompose(facetype(T), c))
end


"""
Standard way of creating a mesh from a primitive.
Just walk through all attributes of the mesh and try to decompose it.
If there are attributes missing, just hope it will get managed by the mesh constructor.
(E.g. normal calculation, which needs to have vertices and faces present)
"""
function (meshtype::Type{T})(c::GeometryPrimitive, args...) where T <: AbstractMesh
    attribs = attributes(T)
    newattribs = Dict{Symbol, Any}()
    for (fieldname, typ) in attribs
        if isdecomposable(eltype(typ), c)
            newattribs[fieldname] = decompose(eltype(typ), c, args...)
        end
    end
    return T(newattribs)
end

function to_pointn(::Type{Point{N, T}}, p::StaticVector{N2}, d = T(0)) where {T, N, N2}
    return Point{N, T}(ntuple(i-> i <= N2 ? T(p[i]) : T(d), N))
end

function (::Type{T})(c::Circle, n = 32) where T <: AbstractMesh
    newattribs = Dict{Symbol, Any}()
    VT = vertextype(T)
    verts = decompose(VT, c, n)
    N = length(verts)
    push!(verts, to_pointn(VT, origin(c))) # middle point
    middle_idx = length(verts)
    FT = facetype(T)
    faces = map(1:N) do i
        FT(i, middle_idx, i + 1)
    end
    return T(vertices = verts, faces = faces)
end

function (meshtype::Type{T})(
        c::Union{HyperCube{3,T}, HyperRectangle{3,HT}}
    ) where {T <: HMesh, HT}
    xdir = Vec{3, HT}(1, 0, 0)
    ydir = Vec{3, HT}(0, 1, 0)
    zdir = Vec{3, HT}(0, 0, 1)
    o0 = zero(Vec{3, HT})
    quads = [
        Quad(zdir, xdir, ydir), # Top
        Quad(o0,   ydir, xdir), # Bottom
        Quad(xdir, ydir, zdir), # Right
        Quad(o0,   zdir, ydir), # Left
        Quad(o0,   xdir, zdir), # Back
        Quad(ydir, zdir, xdir) #Front
    ]
    mesh = merge(map(meshtype, quads))
    v = vertices(mesh)
    w = widths(c)
    o = origin(c)
    map!(v, v) do v
        (v .* w) + o
    end
    return mesh
end
