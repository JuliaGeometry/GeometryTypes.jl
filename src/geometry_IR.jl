abstract PropertyFields{T}


abstract VertexFields{T} <: PropertyFields{T}

immutable PositionField{T} <: PropertyFields{T}  end
immutable NormalField{T} <: PropertyFields{T} end
immutable TextureCoordinateField{T} <: PropertyFields{T} end

get(v::Vertex, ::Val{:Position}) = ...
get(v::Vertex, ::Type{PositionField}, default) = ...
get(functionv::Vertex, ::Type{PositionField}, default) = ...

VertexTypes = Union{
    Tuple{Point},
    Tuple{Point, Normal},
    Tuple{Point, Normal},
    Tuple{Point}
}

x = StructOfArray{Property{Vertex, Material}}(
    rand(Vec3f0),
    rand(Vec3f0),
    RGBA(0,0,0,1),
)

View(x, RedField)

function boundingbox{T<:Property}(AbstractArray{T})
    for elem in array
        p = get(elem, PositionField)
    end

end
Vertex(Vec3f0(0), Vec3f0(0))
Vertex{Tuple{Vec3, Vec3}, Tuple{PositionField, NormalField}}

immutable Vertex{Fields, T}
    vertex::T
end
# always has vertices
hasvertex{V<:Vertex}(::Type{V}) = true

hasnormal{V<:Vertex}(::Type{V}) = false
hasnormal{T, X<:Normal}(::Type{Vertex{Tuple{T, X}}}) = true
hasnormal{T, X<:Normal}(::Type{Vertex{Tuple{T, X}}}) = true
hasnormal{T, X<:Normal, Y}(::Type{Vertex{Tuple{T, X, Y}}}) = true

get_vertex(v::Vertex, default) = v.vertex[1]
get_normal(v::Vertex{T}, default) = ifelse(hasnormal, v.vertex[2], default)


MaterialTypes = Union{
    Tuple{Color},
    Tuple{Color, Shininess},
    Tuple{Color, Normal, TextureCoordinate},
    Tuple{Color, TextureCoordinate}
}

immutable Material{T<:MaterialTypes}
    material::T
end
