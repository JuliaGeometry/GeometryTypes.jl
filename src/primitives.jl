
function (meshtype::Type{T}){T <: AbstractMesh}(c::Pyramid)
    T(decompose(vertextype(T), c), decompose(facetype(T), c))
end


"""
Standard way of creating a mesh from a primitive.
Just walk through all attributes of the mesh and try to decompose it.
If there are attributes missing, just hope it will get managed by the mesh constructor.
(E.g. normal calculation, which needs to have vertices and faces present)
"""
function (meshtype::Type{T}){T <: AbstractMesh}(c::GeometryPrimitive, args...)
    attribs = attributes(T)
    newattribs = Dict{Symbol, Any}()
    for (fieldname, typ) in attribs
        if isdecomposable(eltype(typ), c)
            newattribs[fieldname] = decompose(eltype(typ), c, args...)
        end
    end
    T(homogenousmesh(newattribs))
end


function (meshtype::Type{T}){T <: HMesh,HT}(
        c::Union{HyperCube{3,T}, HyperRectangle{3,HT}}

)    xdir = Vec{3, HT}(widths(c)[1],0f0,0f0)
    ydir = Vec{3, HT}(0f0,widths(c)[2],0f0)
    zdir = Vec{3, HT}(0f0,0f0,widths(c)[3])
    quads = [
        Quad(origin(c) + zdir,   xdir, ydir), # Top
        Quad(origin(c),          ydir, xdir), # Bottom
        Quad(origin(c) + xdir,   ydir, zdir), # Right
        Quad(origin(c),          zdir, ydir), # Left
        Quad(origin(c),          xdir, zdir), # Back
        Quad(origin(c) + ydir,   zdir, xdir) #Front
    ]
    merge(map(meshtype, quads))
end
