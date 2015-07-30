# triangulate a quad. Could be written more generic
triangulate{FT1, FT2}(::Type{Face{3, FT1}}, f::Face{4, FT2}) = 
	(Face3{FT1}(f[1], f[2], f[3]), Face3{FT1}(f[3], f[4], f[1]))

function convert{FT1, FT2}(::Type{Vector{Face{3, FT1}}}, f::Vector{Face{4, FT2}})
	fsn = fill(Face3{FT}, length(fs)*2)
	for i=1:2:length(fs)
		a, b 	 = triangulate(Face3{FT}, fs[div(i,2)])
		fsn[i] 	 = a
		fsn[i+1] = b
	end
	return fsn
end
# This needs to be defined here, but should ultimately done by fixedsizearrays. Right now it would lead to ambiguities though.
call{T, Offset, S <: AbstractString}(::Type{Face{3, T, Offset}}, x::Union(Vector{S}, Tuple{S})) = Face3{T, Offset}(parse(T, x[1]), parse(T, x[2]), parse(T, x[3]))
call{T, Offset, S <: AbstractString}(::Type{Face{4, T, Offset}}, x::Union(Vector{S}, Tuple{S})) = Face4{T, Offset}(parse(T, x[1]), parse(T, x[2]), parse(T, x[3]), parse(T, x[4]))

getindex{T,N,FD,FT,Offset}(a::Array{T,N}, i::Face{FD, FT, Offset})                 = a[[(i-Offset)...]]
setindex!{T,N,FD,FT,Offset}(a::Array{T,N}, b::Array{T,N}, i::Face{FD, FT, Offset}) = (a[[(i-Offset)...]] = b)

convert{T, IndexOffset1}(::Type{Face{3, T, IndexOffset1}}, f::Face{3, T, IndexOffset1}) = f
convert{T, IndexOffset1, IndexOffset2}(t::Type{Face{3, T, IndexOffset1}}, f::Face{3, T, IndexOffset2}) = t((f+IndexOffset1-IndexOffset2)...)

getindex{T}(a::Array{T,2}, rect::Rectangle)                 = a[rect.x+1:rect.w, rect.y+1:rect.h]
setindex!{T}(a::Array{T,2}, b::Array{T,2}, rect::Rectangle) = (a[rect.x+1:rect.w, rect.y+1:rect.h] = b)
