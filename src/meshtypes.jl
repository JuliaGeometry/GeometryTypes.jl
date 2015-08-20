abstract Mesh

# all vectors must have the same length or must be empty, besides the face vector
# Type can be void or a value, this way we can create many combinations from this one mesh type.
# This is not perfect, but helps to reduce a type explosion (imagine defining every attribute combination as a new type).
# It's still experimental, but this design has been working well for me so far.
# This type is also heavily linked to GLVisualize, which means if you can transform another meshtype to this type
# chances are high that GLVisualize can display them.
immutable HomogenousMesh{VertT, FaceT, NormalT, TexCoordT, ColorT, AttribT, AttribIDT} <: Mesh
    vertices            ::Vector{VertT}
    faces               ::Vector{FaceT}
    normals             ::Vector{NormalT}
    texturecoordinates  ::Vector{TexCoordT}
    color               ::ColorT
    attributes          ::AttribT
    attribute_id        ::Vector{AttribIDT}
end

# Creates a mesh from a file
# This function should really be defined in FileIO, but can't as it's ambigous with every damn constructor...
# Its nice, as you can simply do something like GLNormalMesh(file"mesh.obj")

typealias HMesh HomogenousMesh
vertextype{_VertT,    _1, _2, _3, _4, _5, _6}(::Type{HomogenousMesh{_VertT,    _1, _2, _3, _4, _5, _6}})            = _VertT
facetype{_1, FaceT,     _2, _3, _4, _5, _6}(::Type{HomogenousMesh{_1, FaceT,     _2, _3, _4, _5, _6}})              = FaceT
normaltype{_1, _2, NormalT,   _3, _4, _5, _6}(::Type{HomogenousMesh{_1, _2, NormalT,   _3, _4, _5, _6}})            = NormalT
texturecoordinatetype{_1, _2, _3, TexCoordT, _4, _5, _6}(::Type{HomogenousMesh{_1, _2, _3, TexCoordT, _4, _5, _6}}) = TexCoordT
colortype{_1, _2, _3, _4, ColorT,    _5, _6}(::Type{HomogenousMesh{_1, _2, _3, _4, ColorT,    _5, _6}})             = ColorT

# Bad, bad name! But it's a little tricky to filter out faces and verts from the attributes, after get_attribute
attributes_noVF(m::Mesh) = filter((key,val) -> (val != nothing && val != Void[]), Dict{Symbol, Any}(map(field->(field => m.(field)), fieldnames(typeof(m))[3:end])))
#Gets all non Void attributes from a mesh in form of a Dict fieldname => value
attributes(m::Mesh) = filter((key,val) -> (val != nothing && val != Void[]), all_attributes(m))
#Gets all non Void attributes types from a mesh type fieldname => ValueType
attributes{M <: HMesh}(m::Type{M}) = filter((key,val) -> (val != Void && val != Vector{Void}), all_attributes(M))

all_attributes{M <: HMesh}(m::Type{M}) = Dict{Symbol, Any}(map(field -> (field => fieldtype(M, field)), fieldnames(M)))
all_attributes{M <: HMesh}(m::M)       = Dict{Symbol, Any}(map(field -> (field => getfield(m, field)),  fieldnames(M)))

#Some Aliases
typealias HMesh HomogenousMesh



typealias UV{T} TextureCoordinate{2, T}
typealias UVW{T} TextureCoordinate{3, T}

typealias PlainMesh{VT, FT} HMesh{Point{3, VT}, FT, Void, Void, Void, Void, Void}
typealias GLPlainMesh PlainMesh{Float32, GLTriangle}

typealias Mesh2D{VT, FT} HMesh{Point{2, VT}, FT, Void, Void, Void, Void, Void}
typealias GLMesh2D Mesh2D{Float32, GLTriangle}

typealias UVMesh{VT, FT, UVT} HMesh{Point{3, VT}, FT, Void, UV{UVT}, Void, Void, Void}
typealias GLUVMesh UVMesh{Float32, GLTriangle, Float32}

typealias UVWMesh{VT, FT, UVT} HMesh{Point{3, VT}, FT, Void, UVW{UVT}, Void, Void, Void}
typealias GLUVWMesh UVWMesh{Float32, GLTriangle, Float32}

typealias NormalMesh{VT, FT, NT} HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, Void, Void, Void}
typealias GLNormalMesh NormalMesh{Float32, GLTriangle, Float32}

typealias UVMesh2D{VT, FT, UVT} HMesh{Point{2, VT}, FT, Void, UV{UVT}, Void, Void, Void}
typealias GLUVMesh2D UVMesh2D{Float32, GLTriangle, Float32}

typealias NormalColorMesh{VT, FT, NT, CT} HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, CT, Void, Void}
typealias GLNormalColorMesh NormalColorMesh{Float32, GLTriangle, Float32, RGBA{Float32}}


typealias NormalAttributeMesh{VT, FT, NT, AT, A_ID_T} HMesh{Point{3, VT}, FT, Normal{3, NT}, Void, Void, AT, A_ID_T}
typealias GLNormalAttributeMesh NormalAttributeMesh{Float32, GLTriangle, Float32, Vector{RGBA{U8}}, Float32}

typealias NormalUVWMesh{VT, FT, NT, UVT} HMesh{Point{3, VT}, FT, Normal{3, NT}, UVW{UVT}, Void, Void, Void}
typealias GLNormalUVWMesh NormalUVWMesh{Float32, GLTriangle, Float32, Float32}

# Needed to not get into an stack overflow
convert{HM1 <: HMesh}(::Type{HM1}, mesh::HM1) = mesh

# Uses getindex to get all the converted attributes from the meshtype and
# creates a new mesh with the desired attributes from the converted attributs
# Getindex can be defined for any arbitrary geometric type or exotic mesh type.
# This way, we can make sure, that you can convert most of the meshes from one type to the other
# with minimal code.
function convert{HM1 <: HMesh}(::Type{HM1}, any::Union(Mesh, GeometryPrimitive))
    result = Dict{Symbol, Any}()
    for (field, target_type) in zip(fieldnames(HM1), HM1.parameters)
        if target_type != Void
            result[field] = any[target_type]
        end
    end
    HM1(result)
end


#Should be:
#function call{M <: HMesh, VT <: Point, FT <: Face}(::Type{M}, vertices::Vector{VT}, faces::Vector{FT})
# Haven't gotten around to implement the types correctly with abstract types in FixedSizeArrays
function call{M <: HMesh, VT, FT <: Face}(::Type{M}, vertices::Vector{Point{3, VT}}, faces::Vector{FT})
    msh = PlainMesh{VT, FT}(vertices=vertices, faces=faces)
    convert(M, msh)
end
get_default(x::Union(Type, TypeVar)) = nothing
get_default{X <: Array}(x::Type{X}) = Void[]

# generic constructor for abstract HomogenousMesh, infering the types from the keywords (which have to match the field names)
# some problems with the dispatch forced me to use this method name... need to further investigate this
function homogenousmesh(attribs::Dict{Symbol, Any})
    newfields = []
    for name in fieldnames(HMesh)
        push!(newfields, get(attribs, name, get_default(fieldtype(HMesh, name))))
    end
    HomogenousMesh(newfields...)
end

# Creates a mesh from keyword arguments, which have to match the field types of the given concrete mesh
call{M <: HMesh}(::Type{M}; kw_args...) = M(Dict{Symbol, Any}(kw_args))

# Creates a new mesh from a dict of fieldname => value and converts the types to the given meshtype
function call{M <: HMesh}(::Type{M}, attribs::Dict{Symbol, Any})
    newfields = map(zip(fieldnames(HomogenousMesh), M.parameters)) do field_target_type
        field, target_type = field_target_type
        default = fieldtype(HomogenousMesh, field) <: Vector ? Array(target_type, 0) : target_type
        default = default == Void ? nothing : default
        get(attribs, field, default)
    end
    HomogenousMesh(newfields...)
end

#Creates a new mesh from an old one, with changed attributes given by the keyword arguments
function call{M <: HMesh}(::Type{M}, mesh::Mesh, attributes::Dict{Symbol, Any})
    newfields = map(fieldnames(HomogenousMesh)) do field
        get(attributes, field, mesh.(field))
    end
    HomogenousMesh(newfields...)
end

#Creates a new mesh from an old one, with a new constant attribute (like a color)
function call{HM <: HMesh, ConstAttrib}(::Type{HM}, mesh::Mesh, constattrib::ConstAttrib)
    result = Dict{Symbol, Any}()
    for (field, target_type) in zip(fieldnames(HM), HM.parameters)
        if target_type <: ConstAttrib
            result[field] = constattrib
        elseif target_type != Void
            result[field] = mesh[target_type]
        end
    end
    HM(result)
end
function add_attribute(m::Mesh, attribute)
    attribs = attributes(m) # get all attribute values as a Dict fieldname => value
    attribs[:color] = attribute # color will probably be renamed to attribute. not sure yet...
    homogenousmesh(attribs)
end

#Creates a new mesh from a pair of any and a const attribute
function call{HM <: HMesh, ConstAttrib}(::Type{HM}, x::Tuple{Any, ConstAttrib})
    any, const_attribute = x
    add_attribute(HM(any), const_attribute)
end
#=
function show{M <: HMesh}(io::IO, ::Type{M})
    print(io, "HomogenousMesh{")
    for (key,val) in attributes(M)
        print(io, key, ": ", eltype(val), ", ")
    end
    println(io, "}")
end
=#

function show{M <: HMesh}(io::IO, m::M)
    println(io, "HomogenousMesh(")
    for (key,val) in attributes(m)
        print(io, "    ", key, ": ", length(val), "x", eltype(val), ", ")
    end
    println(io, ")")
end
# Getindex methods, for converted indexing into the mesh
# Define getindex for your own meshtype, to easily convert it to Homogenous attributes

#Gets the normal attribute to a mesh
function getindex{VT}(mesh::HMesh, T::Type{Point{3, VT}})
    vts = mesh.vertices
    eltype(vts) == T       && return vts
    eltype(vts) <: Point   && return map(T, vts)
end

# gets the wanted face type
function getindex{FT, Offset}(mesh::HMesh, T::Type{Face{3, FT, Offset}})
    fs = mesh.faces
    eltype(fs) == T       && return fs
    eltype(fs) <: Face3   && return map(T, fs)
    if isa(fs, Face4)
        convert(Vector{Face{3, FT, Offset}}, fs)
    end
    error("can't get the wanted attribute $(T) from mesh:")
end

#Gets the normal attribute to a mesh
function getindex{NT}(mesh::HMesh, T::Type{Normal{3, NT}})
    n = mesh.normals
    eltype(n) == T       && return n
    eltype(n) <: Normal{3} && return map(T, n)
    n == Nothing[]       && return normals(mesh.vertices, mesh.faces, T)
end

#Gets the uv attribute to a mesh, or creates it, or converts it
function getindex{UVT}(mesh::HMesh, ::Type{UV{UVT}})
    uv = mesh.texturecoordinates
    eltype(uv) == UV{UVT}           && return uv
    (eltype(uv) <: UV || eltype(uv) <: UVW) && return map(UV{UVT}, uv)
    eltype(uv) == Nothing           && return zeros(UV{UVT}, length(mesh.vertices))
end


#Gets the uv attribute to a mesh
function getindex{UVWT}(mesh::HMesh, ::Type{UVW{UVWT}})
    uvw = mesh.texturecoordinates
    typeof(uvw) == UVW{UVT}     && return uvw
    (isa(uvw, UV) || isa(uv, UVW))  && return map(UVW{UVWT}, uvw)
    uvw == nothing          && return zeros(UVW{UVWT}, length(mesh.vertices))
end
const DefaultColor = RGBA(0.2, 0.2, 0.2, 1.0)

#Gets the color attribute from a mesh
function getindex{T <: Color}(mesh::HMesh, ::Type{Vector{T}})
    colors = mesh.attributes
    typeof(colors) == Vector{T} && return colors
    colors == nothing           && return fill(DefaultColor, length(mesh.attribute_id))
    map(T, colors)
end

#Gets the color attribute from a mesh
function getindex{T <: Color}(mesh::HMesh, ::Type{T})
    c = mesh.color
    typeof(c) == T    && return c
    c == nothing      && return DefaultColor
    convert(T, c)
end

merge{M <: Mesh}(m::Vector{M}) = merge(m...)

#Merges an arbitrary mesh. This function probably doesn't work for all types of meshes
function merge{M <: Mesh}(m1::M, meshes::M...)
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

# A mesh with one constant attribute can be merged as an attribute mesh. Possible attributes are FSArrays
function merge{_1, _2, _3, _4, ConstAttrib <: Color, _5, _6}(
        m1::HMesh{_1, _2, _3, _4, ConstAttrib, _5, _6},
        meshes::HMesh{_1, _2, _3, _4, ConstAttrib, _5, _6}...
    )
    vertices = m1.vertices
    faces    = m1.faces
    attribs         = attributes_noVF(m1)
    color_attrib    = RGBA{U8}[RGBA{U8}(m1.color)]
    index           = Float32[length(color_attrib)-1 for i=1:length(m1.vertices)]
    delete!(attribs, :color)
    for mesh in meshes
        append!(faces, mesh.faces + length(vertices))
        append!(vertices, mesh.vertices)
        attribsb = attributes_noVF(mesh)
        delete!(attribsb, :color)
        map(append!, values(attribs), values(attribsb))
        push!(color_attrib, mesh.color)
        append!(index, Float32[length(color_attrib)-1 for i=1:length(mesh.vertices)])
    end
    attribs[:vertices]      = vertices
    attribs[:faces]         = faces
    attribs[:attributes]    = color_attrib
    attribs[:attribute_id]  = index
    return HMesh{_1, _2, _3, _4, Void, _5, _6}(attribs)
end


function unique(m::Mesh)
    vts = vertices(m)
    fcs = faces(m)
    uvts = unique(vts)
    for i = 1:length(fcs)
        #repoint indices to unique vertices
        v1 = findfirst(uvts, vts[fcs[i].v1])
        v2 = findfirst(uvts, vts[fcs[i].v2])
        v3 = findfirst(uvts, vts[fcs[i].v3])
        fcs[i] = Face{3, Int}(v1,v2,v3)
    end
    m.vertices[:] = uvts
end


# Fast but slightly ugly way to implement mesh multiplication
# This should probably go into FixedSizeArrays.jl, Vector{FSA} * FSA
immutable MeshMulFunctor{T} <: Base.Func{2}
    matrix::Mat{4,4,T}
end
call{T}(m::MeshMulFunctor{T}, vert) = Vec{3, T}(m.matrix*Vec{4, T}(vert..., 1))
function *{T}(m::Mat{4,4,T}, mesh::Mesh)
    msh = deepcopy(mesh)
    map!(MeshMulFunctor(m), msh.vertices)
    msh
end
