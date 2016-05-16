for s in enumerate((:vertextype, :facetype, :normaltype,
                       :texturecoordinatetype, :colortype))
    @eval begin
        $(s[2]){T<:HomogenousMesh}(t::Type{T}) = t.parameters[$(s[1])]
        $(s[2])(mesh::HomogenousMesh) = $(s[2])(typeof(mesh))
    end
end

hasvertices(msh) = vertextype(msh) != Void
hasfaces(msh) = facetype(msh) != Void
hasnormals(msh) = normaltype(msh) != Void
hastexturecoordinates(msh) = texturecoordinatetype(msh) != Void
hascolors(msh) = colortype(msh) != Void



vertices(msh) = msh.vertices
faces(msh) = msh.faces
normals(msh) = msh.normals
texturecoordinates(msh) = msh.texturecoordinates
colors(msh) = msh.color


# Bad, bad name! But it's a little tricky to filter out faces and verts from the attributes, after get_attribute
function attributes_noVF{T<:AbstractMesh}(m::T)
    fielddict = Dict{Symbol, Any}(map(fieldnames(T)[3:end]) do field
        field => getfield(m, field)
    end)
    return filter(fielddict) do key,val
        val != nothing && val != Void[]
    end
end
#Gets all non Void attributes from a mesh in form of a Dict fieldname => value
function attributes(m::AbstractMesh)
    filter((key,val) -> (val != nothing && val != Void[]), all_attributes(m))
end
#Gets all non Void attributes types from a mesh type fieldname => ValueType
function attributes{M <: HMesh}(m::Type{M})
    filter((key,val) -> (val != Void && val != Vector{Void}), all_attributes(M))
end

function all_attributes{M <: HMesh}(m::Type{M})
    Dict{Symbol, Any}(map(field -> (field => fieldtype(M, field)), fieldnames(M)))
end
function all_attributes{M <: HMesh}(m::M)
    Dict{Symbol, Any}(map(field -> (field => getfield(m, field)),  fieldnames(M)))
end

# Needed to not get into an stack overflow
convert{M <: AbstractMesh}(::Type{M}, mesh::AbstractGeometry) = M(mesh)
call{HM1 <: AbstractMesh}(::Type{HM1}, mesh::HM1) = mesh

"""
Uses decompose to get all the converted attributes from the meshtype and
creates a new mesh with the desired attributes from the converted attributs
Getindex can be defined for any arbitrary geometric type or exotic mesh type.
This way, we can make sure, that you can convert most of the meshes from one type to the other
with minimal code.
"""
function call{HM1 <: AbstractMesh}(::Type{HM1}, primitive::Union{AbstractMesh, GeometryPrimitive})
    result = Dict{Symbol, Any}()
    for (field, target_type) in zip(fieldnames(HM1), HM1.parameters)
        if target_type != Void
            if field == :attribute_id
                if !isa(primitive, HomogenousMesh)
                    error("Primitive $primitive doesn't hold attribute indexes")
                end
                result[field] = primitive.attribute_id
            else
                result[field] = decompose(target_type, primitive)
            end
        end
    end
    HM1(result)
end

isvoid{T}(::Type{T}) = false
isvoid(::Type{Void}) = true
isvoid{T}(::Type{Vector{T}}) = isvoid(T)
function call{HM1 <: HomogenousMesh}(::Type{HM1}, primitive::HomogenousMesh)
    fnames = fieldnames(HM1)
    args = ntuple(nfields(HM1)) do i
        field, target_type = fnames[i], fieldtype(HM1, i)
        soure_type = fieldtype(typeof(primitive), i)
        isa(HM1.parameters[i], TypeVar) && return getfield(primitive, field) # target is not defined
        if !isvoid(target_type) && isvoid(soure_type) # target not there yet, maybe we can decompose though (e.g. normals)
            return decompose(HM1.parameters[i], primitive)
        else
            return convert(target_type, getfield(primitive, field))
        end
    end
    HM1(args...)
end


#Should be:
#function call{M <: HMesh, VT <: Point, FT <: Face}(::Type{M}, vertices::Vector{VT}, faces::Vector{FT})
# Haven't gotten around to implement the types correctly with abstract types in FixedSizeArrays
function call{M <: HMesh, VT, FT <: Face}(::Type{M}, vertices::Vector{Point{3, VT}}, faces::Vector{FT})
    msh = PlainMesh{VT, FT}(vertices=vertices, faces=faces)
    convert(M, msh)
end
get_default(x::Union{Type, TypeVar}) = nothing
get_default{X <: Array}(x::Type{X}) = Void[]

"""
generic constructor for abstract HomogenousMesh, infering the types from the keywords (which have to match the field names)
some problems with the dispatch forced me to use this method name... need to further investigate this
"""
function homogenousmesh(attribs::Dict{Symbol, Any})
    newfields = []
    for name in fieldnames(HMesh)
        push!(newfields, get(attribs, name, get_default(fieldtype(HMesh, name))))
    end
    HomogenousMesh(newfields...)
end

"""
Creates a mesh from keyword arguments, which have to match the field types of the given concrete mesh
"""
call{M <: HMesh}(::Type{M}; kw_args...) = M(Dict{Symbol, Any}(kw_args))

"""
Creates a new mesh from a dict of `fieldname => value` and converts the types to the given meshtype
"""
function call{M <: HMesh}(::Type{M}, attribs::Dict{Symbol, Any})
    newfields = map(zip(fieldnames(HomogenousMesh), M.parameters)) do field_target_type
        field, target_type = field_target_type
        default = fieldtype(HomogenousMesh, field) <: Vector ? Void[] : nothing
        get(attribs, field, default)
    end
    M(HomogenousMesh(newfields...))
end

"""
Creates a new mesh from an old one, with changed attributes given by the keyword arguments
"""
function call{M <: HMesh}(::Type{M}, mesh::AbstractMesh, attributes::Dict{Symbol, Any})
    newfields = map(fieldnames(HomogenousMesh)) do field
        get(attributes, field, getfield(mesh, field))
    end
    HomogenousMesh(newfields...)
end
"""
Creates a new mesh from an old one, with a new constant attribute (like a color)
"""
function call{HM <: HMesh, ConstAttrib}(::Type{HM}, mesh::AbstractMesh, constattrib::ConstAttrib)
    result = Dict{Symbol, Any}()
    for (field, target_type) in zip(fieldnames(HM), HM.parameters)
        if target_type <: ConstAttrib
            result[field] = constattrib
        elseif target_type != Void
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
function call{HM <: HMesh, ConstAttrib, P<:AbstractGeometry}(::Type{HM}, x::Tuple{P, ConstAttrib})
    any, const_attribute = x
    add_attribute(HM(any), const_attribute)
end


merge{M <: AbstractMesh}(m::Vector{M}) = merge(m...)

"""
Merges an arbitrary mesh. This function probably doesn't work for all types of meshes
parameters:
`m1` first mesh
`meshes...` other meshes
"""
function merge{M <: AbstractMesh}(m1::M, meshes::M...)
    v = m1.vertices
    f = m1.faces
    attribs = attributes_noVF(m1)
    for mesh in meshes
        append!(f, mesh.faces + length(v))
        append!(v, mesh.vertices)
        map(append!, values(attribs), values(attributes_noVF(mesh)))
    end
    attribs[:vertices]  = v
    attribs[:faces]     = f
    return M(attribs)
end

"""
A mesh with one constant attribute can be merged as an attribute mesh.
Possible attributes are FSArrays
"""
function merge{_1, _2, _3, _4, ConstAttrib <: Colorant, _5, _6}(
        m1::HMesh{_1, _2, _3, _4, ConstAttrib, _5, _6},
        meshes::HMesh{_1, _2, _3, _4, ConstAttrib, _5, _6}...
    )
    vertices     = copy(m1.vertices)
    faces        = copy(m1.faces)
    attribs      = filter((k,v) -> k != :color, attributes_noVF(m1))
    attribs      = [k=>copy(v) for (k,v) in attribs]
    color_attrib = RGBA{U8}[RGBA{U8}(m1.color)]
    index        = Float32[length(color_attrib)-1 for i=1:length(m1.vertices)]
    for mesh in meshes
        append!(faces, mesh.faces + length(vertices))
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
    return HMesh{_1, _2, _3, _4, Void, typeof(color_attrib), eltype(index)}(attribs)
end

# Fast but slightly ugly way to implement mesh multiplication
# This should probably go into FixedSizeArrays.jl, Vector{FSA} * FSA
immutable MeshMulFunctor{T}
    matrix::Mat{4,4,T}
end
call{T}(m::MeshMulFunctor{T}, vert) = Vec{3, T}(m.matrix*Vec{4, T}(vert..., 1))
function *{T}(m::Mat{4,4,T}, mesh::AbstractMesh)
    msh = deepcopy(mesh)
    map!(MeshMulFunctor(m), msh.vertices)
    msh
end
