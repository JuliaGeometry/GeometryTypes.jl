
@compat function (meshtype::Type{T}){T <: AbstractMesh}(c::Pyramid)
    T(decompose(vertextype(T), c), decompose(facetype(T), c))
end


"""
Standard way of creating a mesh from a primitive.
Just walk through all attributes of the mesh and try to decompose it.
If there are attributes missing, just hope it will get managed by the mesh constructor.
(E.g. normal calculation, which needs to have vertices and faces present)
"""
@compat function (meshtype::Type{T}){T <: AbstractMesh}(c::GeometryPrimitive, args...)
    attribs = attributes(T)
    newattribs = Dict{Symbol, Any}()
    for (fieldname, typ) in attribs
        if isdecomposable(eltype(typ), c)
            newattribs[fieldname] = decompose(eltype(typ), c, args...)
        end
    end
    T(homogenousmesh(newattribs))
end


@compat function (meshtype::Type{T}){T <: HMesh,HT}(
        c::Union{HyperCube{3,T}, HyperRectangle{3,HT}}
    )
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
    mesh
end
