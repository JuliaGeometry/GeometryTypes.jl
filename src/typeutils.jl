@generated function eltype_or{T<:GeometryPrimitive}(::Type{T}, OR)
    ET = T.parameters[2]
    if isa(ET, TypeVar)
        return :(OR)
    else
        return :($ET)
    end
end
@generated function ndims_or{T<:GeometryPrimitive}(::Type{T}, OR)
    N = T.parameters[1]
    if isa(N, TypeVar)
        return :(OR)
    else
        return :($N)
    end
end
