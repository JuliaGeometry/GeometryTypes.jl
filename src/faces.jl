# triangulate a quad. Could be written more generic
function triangulate{FT1, FT2}(::Type{Face3{FT1}}, f::Face4{FT2})
  (Face3{FT1}(f[1], f[2], f[3]), Face3{FT1}(f[3], f[4], f[1]))
end

function Base.convert{FT1, FT2}(::Type{Vector{Face3{FT1}}}, f::Vector{Face4{FT2}})
  fsn = fill(Face3{FT}, length(fs)*2)
  for i=1:2:length(fs)
    a, b 	 = triangulate(Face3{FT}, fs[div(i,2)])
    fsn[i] 	 = a
    fsn[i+1] = b
  end
  return fsn
end
Iterable(T) = Union(Vector{T}, Tuple{T})
# This needs to be defined here, but should ultimately done by fixedsizearrays. Right now it would lead to ambiguities though.
Base.call{T, Offset, S <: AbstractString}(::Type{Face3{T, Offset}}, x::Iterable(S)) = Face3{T, Offset}(parse(T, x[1]), parse(T, x[2]), parse(T, x[3]))
Base.call{T, Offset, S <: AbstractString}(::Type{Face4{T, Offset}}, x::Iterable(S)) = Face4{T, Offset}(parse(T, x[1]), parse(T, x[2]), parse(T, x[3]), parse(T, x[4]))

Base.getindex{T,N,FD, FT, Offset}(a::Array{T,N}, i::Face{FD, FT, Offset})                 = a[[(i-Offset)...]]
Base.setindex!{T,N,FD, FT, Offset}(a::Array{T,N}, b::Array{T,N}, i::Face{FD, FT, Offset}) = (a[[(i-Offset)...]] = b)

Base.convert{T, IndexOffset1}(::Type{Face3{T, IndexOffset1}}, f::Face3{T, IndexOffset1}) = f
Base.convert{T, IndexOffset1, IndexOffset2}(t::Type{Face3{T, IndexOffset1}}, f::Face3{T, IndexOffset2}) = t((f+IndexOffset1-IndexOffset2)...)




Base.getindex{T}(a::Array{T,2}, rect::Rectangle)                 = a[rect.x+1:rect.w, rect.y+1:rect.h]
Base.setindex!{T}(a::Array{T,2}, b::Array{T,2}, rect::Rectangle) = (a[rect.x+1:rect.w, rect.y+1:rect.h] = b)
