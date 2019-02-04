_eltype(::Type{T}) where {T <: AbstractArray} = eltype(T)
_eltype(::Type{T}) where {T} = T
for (i, field) in enumerate((:vertextype, :facetype, :normaltype,
                       :texturecoordinatetype, :colortype))
    @eval begin
        $field(t::Type{T}) where {T <: HomogenousMesh} = _eltype(fieldtype(t, $i))
        $field(mesh::HomogenousMesh) = $field(typeof(mesh))
    end
end

hasvertices(msh) = vertextype(msh) != Nothing
hasfaces(msh) = facetype(msh) != Nothing
hasnormals(msh) = normaltype(msh) != Nothing
hastexturecoordinates(msh) = texturecoordinatetype(msh) != Nothing
hascolors(msh) = colortype(msh) != Nothing

vertices(msh) = msh.vertices
faces(msh) = msh.faces
normals(msh) = msh.normals
texturecoordinates(msh) = msh.texturecoordinates
colors(msh) = msh.color


# Bad, bad name! But it's a little tricky to filter out faces and verts from the attributes, after get_attribute
function attributes_noVF(m::T) where T <: AbstractMesh
    fielddict = Dict{Symbol, Any}(map(fieldnames(T)[3:end]) do field
        field => getfield(m, field)
    end)
    return filter(fielddict) do (key, val)
        val != nothing && val != Nothing[]
    end
end
#Gets all non Nothing attributes from a mesh in form of a Dict fieldname => value
function attributes(m::AbstractMesh)
    filter(((key,val),) -> (val != nothing && val != Nothing[]), all_attributes(m))
end
#Gets all non Nothing attributes types from a mesh type fieldname => ValueType
function attributes(m::Type{M}) where M <: HMesh
    filter(((key,val),) -> (val != Nothing && val != Vector{Nothing}), all_attributes(M))
end

function all_attributes(m::Type{M}) where M <: HMesh
    Dict{Symbol, Any}(map(field -> (field => fieldtype(M, field)), fieldnames(M)))
end
function all_attributes(m::M) where M <: HMesh
    Dict{Symbol, Any}(map(field -> (field => getfield(m, field)),  fieldnames(M)))
end

# Needed to not get into an stack overflow
convert(::Type{M}, mesh::Union{AbstractGeometry, AbstractMesh}) where {M <: AbstractMesh} = M(mesh)
convert(::Type{T}, mesh::T) where T <: AbstractMesh = mesh
# (::Type{HM1}){HM1 <: AbstractMesh}(mesh::HM1) = mesh


isvoid(::Type{T}) where {T} = false
isvoid(::Type{Nothing}) = true
isvoid(::Type{Vector{T}}) where {T} = isvoid(T)

@generated function (::Type{HM1})(primitive::HM2) where {HM1 <: HomogenousMesh, HM2 <: HomogenousMesh}
    fnames = fieldnames(HM1)
    expr = Expr(:call, HM1)
    for i in 1:fieldcount(HM1)
        field = fnames[i]
        target_type = fieldtype(HM1, i)
        source_type = fieldtype(HM2, i)
        if !isconcretetype(fieldtype(HM1, i))  # target is not defined
            push!(expr.args, :(getfield(primitive, $(QuoteNode(field)))))
        elseif !isvoid(target_type) && isvoid(source_type) # target not there yet, maybe we can decompose though (e.g. normals)
            push!(expr.args, :(decompose($(HM1.parameters[i]), primitive)))
        elseif isvoid(target_type)
            push!(expr.args, :($(target_type())))
        else
            push!(expr.args, :(convert($target_type, getfield(primitive, $(QuoteNode(field))))))
        end
    end
    expr
end

#Should be:
#function call{M <: HMesh, VT <: Point, FT <: Face}(::Type{M}, vertices::Vector{VT}, faces::Vector{FT})
# Haven't gotten around to implement the types correctly with abstract types in FixedSizeArrays
function (::Type{M})(
        vertices::AbstractVector{Point{3, VT}}, faces::AbstractVector{FT}
    ) where {M <: HMesh, VT, FT <: Face}
    msh = PlainMesh{VT, FT}(vertices = vertices, faces = faces)
    convert(M, msh)
end
get_default(x::Union{Type, TypeVar}) = nothing
get_default(x::Type{X}) where {X <: AbstractArray} = Nothing[]

"""
generic constructor for abstract HomogenousMesh, infering the types from the keywords (which have to match the field names)
some problems with the dispatch forced me to use this method name... need to further investigate this
"""
function homogenousmesh(attribs::Dict{Symbol, Any})
    newfields = map(fieldnames(HMesh)) do name
        get(attribs, name, get_default(fieldtype(HMesh, name)))
    end
    HomogenousMesh(newfields...)
end

"""
Creates a mesh from keyword arguments, which have to match the field types of the given concrete mesh
"""
(::Type{M})(; kw_args...) where {M <: HMesh} = M(Dict{Symbol, Any}(kw_args))

"""
Creates a new mesh from a dict of `fieldname => value` and converts the types to the given meshtype
"""
function (::Type{M})(attribs::Dict{Symbol, Any}) where M <: HMesh
    newfields = map(fieldnames(HomogenousMesh)) do field
        target_type = fieldtype(M, field)
        default = fieldtype(HomogenousMesh, field) <: AbstractVector ? Nothing[] : nothing
        get(attribs, field, default)
    end
    convert(M, HomogenousMesh(newfields...))
end

"""
Creates a new mesh from an old one, with changed attributes given by the keyword arguments
"""
function (::Type{M})(mesh::AbstractMesh, attributes::Dict{Symbol, Any}) where M <: HMesh
    newfields = map(fieldnames(HomogenousMesh)) do field
        get(attributes, field, getfield(mesh, field))
    end
    HomogenousMesh(newfields...)
end
"""
Creates a new mesh from an old one, with a new constant attribute (like a color)
"""
function (::Type{HM})(mesh::AbstractMesh, constattrib::ConstAttrib) where {HM <: HMesh, ConstAttrib}
    result = Dict{Symbol, Any}()
    for (field, target_type) in zip(fieldnames(HM), HM.parameters)
        if target_type <: ConstAttrib
            result[field] = constattrib
        elseif target_type != Nothing
            result[field] = decompose(target_type, mesh)
        end
    end
    HM(result)
end
function add_attribute(m::AbstractMesh, attribute)
    attribs = attributes(m) # get all attribute values as a Dict fieldname => value
    attribs[:color] = attribute # color will probably be renamed to attribute. not sure yet...
    homogenousmesh(attribs)
end

"""
Creates a new mesh from a tuple of a geometry type and a constant attribute
"""
function (::Type{HM})(x::Tuple{P, ConstAttrib}) where {HM <: HMesh, ConstAttrib, P<:AbstractGeometry}
    any, const_attribute = x
    add_attribute(HM(any), const_attribute)
end


merge(m::AbstractVector{M}) where {M <: AbstractMesh} = merge(m...)

"""
Merges an arbitrary mesh. This function probably doesn't work for all types of meshes
parameters:
`m1` first mesh
`meshes...` other meshes
"""
function merge(m1::M, meshes::M...) where M <: AbstractMesh
    v = copy(m1.vertices)
    f = copy(m1.faces)
    attribs = deepcopy(attributes_noVF(m1))
    for mesh in meshes
        append!(f, mesh.faces .+ length(v))
        append!(v, mesh.vertices)
        for (v1, v2) in zip(values(attribs), values(attributes_noVF(mesh)))
            append!(v1, v2)
        end
    end
    attribs[:vertices]  = v
    attribs[:faces]     = f
    return M(attribs)
end

"""
A mesh with one constant attribute can be merged as an attribute mesh.
Possible attributes are FSArrays
"""
function merge(
        m1::HMesh{_1, _2, _3, _4, ConstAttrib, _5, _6},
        meshes::HMesh{_1, _2, _3, _4, ConstAttrib, _5, _6}...
    ) where {_1, _2, _3, _4, ConstAttrib <: Colorant, _5, _6}
    vertices     = copy(m1.vertices)
    faces        = copy(m1.faces)
    attribs      = Dict{Symbol, Any}(filter(((k,v),) -> k != :color, attributes_noVF(m1)))
    attribs      = Dict{Symbol, Any}([(k, copy(v)) for (k,v) in attribs])
    color_attrib = RGBA{N0f8}[RGBA{N0f8}(m1.color)]
    index        = Float32[length(color_attrib)-1 for i=1:length(m1.vertices)]
    for mesh in meshes
        append!(faces, mesh.faces .+ length(vertices))
        append!(vertices, mesh.vertices)
        attribsb = attributes_noVF(mesh)
        for (k,v) in attribsb
            k != :color && append!(attribs[k], copy(v))
        end
        push!(color_attrib, mesh.color)
        append!(index, Float32[length(color_attrib)-1 for i=1:length(mesh.vertices)])
    end
    delete!(attribs, :color)
    attribs[:vertices]      = vertices
    attribs[:faces]         = faces
    attribs[:attributes]    = color_attrib
    attribs[:attribute_id]  = index
    return HMesh{_1, _2, _3, _4, Nothing, typeof(color_attrib), eltype(index)}(attribs)
end

# Fast but slightly ugly way to implement mesh multiplication
# This should probably go into FixedSizeArrays.jl, Vector{FSA} * FSA
struct MeshMulFunctor{T}
    matrix::Mat{4,4,T}
end
(m::MeshMulFunctor{T})(vert) where {T} = Vec{3, T}(m.matrix*Vec{4, T}(vert..., 1))
function *(m::Mat{4,4,T}, mesh::AbstractMesh) where T
    msh = deepcopy(mesh)
    map!(MeshMulFunctor(m), msh.vertices, msh.vertices)
    msh
end




"""
```
normals{VT,FD,FT,FO}(vertices::Vector{Point{3, VT}},
                     faces::Vector{Face{FD,FT,FO}},
                     NT = Normal{3, VT})
```

Compute all vertex normals.
"""
function normals(
        vertices::AbstractVector{Point{3, VT}},
        faces::AbstractVector{F},
        NT = Normal{3, VT}
    ) where {VT, F <: Face}
    normals_result = zeros(Point{3, VT}, length(vertices)) # initilize with same type as verts but with 0
    for face in faces
        v = vertices[face]
        # we can get away with two edges since faces are planar.
        a = v[2] - v[1]
        b = v[3] - v[1]
        n = cross(a, b)
        for i =1:length(F)
            fi = face[i]
            normals_result[fi] = normals_result[fi] + n
        end
    end
    normals_result .= NT.(normalize.(normals_result))
    normals_result
end


"""
Slice an AbstractMesh at the specified Z axis value.
Returns a Vector of LineSegments generated from the faces at the specified
heights. Note: This will not slice in-plane faces.
"""
function slice(mesh::AbstractMesh{Point{3,VT}, Face{3, FT}}, height::Number) where {VT<:AbstractFloat,FT<:Integer}

    height_ct = length(height)
    # intialize the LineSegment array
    slice = Simplex{2,Point{2,VT}}[]

    for face in mesh.faces
        v1,v2,v3 = mesh.vertices[face]
        zmax = max(v1[3], v2[3], v3[3])
        zmin = min(v1[3], v2[3], v3[3])
        if height > zmax
            continue
        elseif zmin <= height
            if v1[3] < height && v2[3] >= height && v3[3] >= height
                p1 = v1
                p2 = v3
                p3 = v2
            elseif v1[3] > height && v2[3] < height && v3[3] < height
                p1 = v1
                p2 = v2
                p3 = v3
            elseif v2[3] < height && v1[3] >= height && v3[3] >= height
                p1 = v2
                p2 = v1
                p3 = v3
            elseif v2[3] > height && v1[3] < height && v3[3] < height
                p1 = v2
                p2 = v3
                p3 = v1
            elseif v3[3] < height && v2[3] >= height && v1[3] >= height
                p1 = v3
                p2 = v2
                p3 = v1
            elseif v3[3] > height && v2[3] < height && v1[3] < height
                p1 = v3
                p2 = v1
                p3 = v2
            else
                continue
            end

            start = Point{2,VT}(p1[1] + (p2[1] - p1[1]) * (height - p1[3]) / (p2[3] - p1[3]),
                                p1[2] + (p2[2] - p1[2]) * (height - p1[3]) / (p2[3] - p1[3]))
            finish = Point{2,VT}(p1[1] + (p3[1] - p1[1]) * (height - p1[3]) / (p3[3] - p1[3]),
                                 p1[2] + (p3[2] - p1[2]) * (height - p1[3]) / (p3[3] - p1[3]))

            push!(slice, Simplex{2,Point{2, VT}}(start, finish))
        end
    end

    return slice
end


# TODO this should be checkbounds(Bool, ...)
"""
```
checkbounds{VT,FT,FD,FO}(m::AbstractMesh{VT,Face{FD,FT,FO}})
```

Check the `Face` indices to ensure they are in the bounds of the vertex
array of the `AbstractMesh`.
"""
function Base.checkbounds(m::AbstractMesh{VT, Face{FD, FT}}) where {VT, FD, FT}
    isempty(faces(m)) && return true # nothing to worry about I guess
    flat_inds = reinterpret(FT, faces(m))
    checkbounds(Bool, vertices(m), flat_inds)
end



function unique_verts!(verts::AbstractVector{T}) where T
    table = Dict{T, Int}()
    new_idx = 0
    for (i, v) in enumerate(verts)
        if !haskey(table, v)
            new_idx += 1
            table[v] = new_idx
            # if index has moved, inplace rewrite verts
            new_idx != i && (verts[new_idx] = v)
        end
    end
    if new_idx != length(verts)
        resize!(verts, new_idx)
    end
    table
end

function reface!(point2idx, verts, uverts, faces)
    map!(faces, faces) do face
        map(face) do i
            point2idx[verts[i]]
        end
    end
end

"""
    remove_overlap!(mesh::AbstractMesh)

removes non unique vertices from a mesh, and relinks the faces to point to only shared vertices.
"""
function remove_overlap!(mesh::AbstractMesh)
    verts = vertices(mesh)
    orig_verts = copy(verts)
    table = unique_verts!(verts)
    reface!(table, orig_verts, verts, faces(mesh))
    return
end

# functions related to displaying types

function show(io::IO, m::M) where M <: HMesh
    println(io, "HomogenousMesh(")
    for (key,val) in attributes(m)
        print(io, "    ", key, ": ", length(val), "x", eltype(val), ", ")
    end
    println(io, ")")
end



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
    T(newattribs)
end

function to_pointn(::Type{Point{N, T}}, p::StaticVector{N2}, d = T(0)) where {T, N, N2}
    Point(ntuple(i-> i <= N2 ? p[i] : d, Val{N}))
end

function (::Type{T})(c::Circle, n = 32) where T <: AbstractMesh
    newattribs = Dict{Symbol, Any}()
    VT = vertextype(T)
    verts = decompose(VT, c)
    N = length(verts)
    push!(verts, to_pointn(VT, origin(c))) # middle point
    middle_idx = length(verts)
    FT = facetype(T)
    faces = map(1:N) do i
        FT(i, middle_idx, i + 1)
    end
    T(vertices = verts, faces = faces)
end

function (meshtype::Type{T})(
        c::Union{HyperCube{3,T}, HyperRectangle{3,HT}}
    ) where {T <: HMesh,HT}
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

==(a::AbstractMesh, b::AbstractMesh) = false
function ==(a::M, b::M) where M <: AbstractMesh
    for ((ka, va), (kb, vb)) in zip(all_attributes(a), all_attributes(b))
        va != vb && return false
    end
    true
end
