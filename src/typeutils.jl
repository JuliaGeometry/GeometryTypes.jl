using Compat.TypeUtils
"""
This is a terrible function. But is there any other way to reliable get the
abstract supertype of an arbitrary type hierarchy without loosing performance?
"""
@generated function go_abstract{T<:AbstractGeometry}(::Type{T})
    ff = T
    while ff.name.name != :AbstractGeometry
       ff = supertype(ff)
    end
    :($ff)
end

@generated function eltype_or{T<:GeometryPrimitive}(::Type{T}, OR)
    ET = go_abstract(T).parameters[2]
    if isa(ET, TypeVar)
        return :(OR)
    else
        return :($ET)
    end
end
@generated function ndims_or{T<:GeometryPrimitive}(::Type{T}, OR)
    N = go_abstract(T).parameters[1]
    if isa(N, TypeVar)
        return :(OR)
    else
        return :($N)
    end
end

function Base.eltype{T<:AbstractGeometry}(x::Type{T})
    eltype_or(T, Any)
end
@generated function Base.ndims{T<:AbstractGeometry}(x::Type{T})
    N = go_abstract(T).parameters[1]
    isa(N, TypeVar) && error("Ndims not given for type $T")
    :($N)
end

Base.eltype{N, T}(x::AbstractGeometry{N, T}) = T
Base.ndims{N, T}(x::AbstractGeometry{N, T}) = N

Base.eltype{T}(::Type{AFG{T}}) = T
Base.eltype{FG <: AFG}(::Type{FG}) = eltype(supertype(FG))
