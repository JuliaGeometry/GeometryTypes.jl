abstract Mesh

function Base.show{M <: Mesh}(io::IO, ::Type{M})
end

println(methods(similar))