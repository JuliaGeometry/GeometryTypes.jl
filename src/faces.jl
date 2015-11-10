"""
Triangulate an N-Face into a tuple of triangular faces.
"""
@generated function triangulate{N, FT1, FT2, O1, O2}(::Type{Face{3, FT1, O1}},
                                       f::Face{N, FT2, O2})
    @assert 3 <= N # other wise degenerate

    v = Expr(:tuple)
    append!(v.args, [:(Face{3,$FT1,$O1}(f[1]+$(-O2+O1),
                                        f[$(i-1)]+$(-O2+O1),
                                        f[$(i)]+$(-O2+O1))) for i = 3:N])
    v
end

function getindex{T,N,FD,FT,Offset}(a::Array{T,N}, i::Face{FD, FT, Offset})
    a[[(map(Int,i)-Offset)...]]
end
function setindex!{T,N,FD,FT,Offset}(a::Array{T,N}, b::Array{T,N}, i::Face{FD, FT, Offset})
    a[[(map(Int,i)-Offset)...]] = b
end

convert{T, IndexOffset1, N}(::Type{Face{N, T, IndexOffset1}}, f::Face{N, T, IndexOffset1}) = f
convert{T, T2, IndexOffset1, N}(::Type{Face{N, T, IndexOffset1}}, f::Face{N, T2, IndexOffset1}) = Face{N, T, IndexOffset1}(convert(NTuple{N, T}, f.(1)))
convert{T1, T2, IndexOffset1, IndexOffset2, N}(t::Type{Face{N, T1, IndexOffset1}}, f::Face{N, T2, IndexOffset2}) = t((map(Int,f)+IndexOffset1-IndexOffset2)...)

# Silly duplication, but call(::FixedVector, ::Any) = convert is overloaded in FixedSizeArrays
call{T, IndexOffset1, N}(::Type{Face{N, T, IndexOffset1}}, f::Face{N, T, IndexOffset1}) = f
call{T, T2, IndexOffset1, N}(::Type{Face{N, T, IndexOffset1}}, f::Face{N, T2, IndexOffset1}) = Face{N, T, IndexOffset1}(convert(NTuple{N, T}, f.(1)))
call{T1, T2, IndexOffset1, IndexOffset2, N}(t::Type{Face{N, T1, IndexOffset1}}, f::Face{N, T2, IndexOffset2}) = t((map(Int,f)+IndexOffset1-IndexOffset2)...)


getindex{T}(a::Array{T,2}, rect::Rectangle)                 = a[rect.x+1:rect.w, rect.y+1:rect.h]
setindex!{T}(a::Array{T,2}, b::Array{T,2}, rect::Rectangle) = (a[rect.x+1:rect.w, rect.y+1:rect.h] = b)
