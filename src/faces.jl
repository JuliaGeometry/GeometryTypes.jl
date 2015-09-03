# triangulate a quad. Could be written more generic
export triangulate
triangulate{FT1, FT2, Offset1, Offset2}(::Type{Face{3, FT1, Offset1}}, f::Face{4, FT2, Offset2}) =
	(Face{3, FT1, Offset1}(Face{3, FT2, Offset2}(f[1:3])), Face{3, FT1, Offset1}(Face{3, FT2, Offset2}(f[(3, 4, 1)])))

#=
# need to spend more time on this generic conversion algorithm
function convert{FT1, FT2, N, Offset1, Offset2}(::Type{Vector{Face{3, FT1, Offset1}}}, f::Vector{Face{N, FT2, Offset2}})
	fsn = fill(Face{3, FT1, Offset1}, N-2)
	for i=1:2:length(fsn)
		a, b 	 = triangulate(Face{3, FT1, Offset1}, fs[div(i,2)])
		fsn[i] 	 = a
		fsn[i+1] = b
	end
	return fsn
end
=#
# This needs to be defined here, but should ultimately done by fixedsizearrays. Right now it would lead to ambiguities though.
#call{T, Offset, S <: AbstractString}(::Type{Face{3, T, Offset}}, x::Union(Vector{S}, Tuple{S})) = Face3{T, Offset}(parse(T, x[1]), parse(T, x[2]), parse(T, x[3]))
#call{T, Offset, S <: AbstractString}(::Type{Face{4, T, Offset}}, x::Union(Vector{S}, Tuple{S})) = Face4{T, Offset}(parse(T, x[1]), parse(T, x[2]), parse(T, x[3]), parse(T, x[4]))

getindex{T,N,FD,FT,Offset}(a::Array{T,N}, i::Face{FD, FT, Offset})                 = a[[(i-Offset)...]]
setindex!{T,N,FD,FT,Offset}(a::Array{T,N}, b::Array{T,N}, i::Face{FD, FT, Offset}) = (a[[(i-Offset)...]] = b)

convert{T, IndexOffset1, N}(::Type{Face{N, T, IndexOffset1}}, f::Face{N, T, IndexOffset1}) = f
convert{T, T2, IndexOffset1, N}(::Type{Face{N, T, IndexOffset1}}, f::Face{N, T2, IndexOffset1}) = Face{N, T, IndexOffset1}(convert(NTuple{N, T}, f.(1)))
convert{T1, T2, IndexOffset1, IndexOffset2, N}(t::Type{Face{N, T1, IndexOffset1}}, f::Face{N, T2, IndexOffset2}) = t((f+IndexOffset1-IndexOffset2)...)

# Silly duplication, but call(::FixedVector, ::Any) = convert is overloaded in FixedSizeArrays
call{T, IndexOffset1, N}(::Type{Face{N, T, IndexOffset1}}, f::Face{N, T, IndexOffset1}) = f
call{T, T2, IndexOffset1, N}(::Type{Face{N, T, IndexOffset1}}, f::Face{N, T2, IndexOffset1}) = Face{N, T, IndexOffset1}(convert(NTuple{N, T}, f.(1)))
call{T1, T2, IndexOffset1, IndexOffset2, N}(t::Type{Face{N, T1, IndexOffset1}}, f::Face{N, T2, IndexOffset2}) = t((f+IndexOffset1-IndexOffset2)...)


getindex{T}(a::Array{T,2}, rect::Rectangle)                 = a[rect.x+1:rect.w, rect.y+1:rect.h]
setindex!{T}(a::Array{T,2}, b::Array{T,2}, rect::Rectangle) = (a[rect.x+1:rect.w, rect.y+1:rect.h] = b)
