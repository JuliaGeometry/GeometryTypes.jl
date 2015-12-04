"""
Given an Array, `a`, and a face, `f`, return a tuple of numbers
interpreting the values and offset of the face as indices into `A`.

Note: This is not bounds checked. It is recommended that you use
`checkbounds` to confirm the indices are safe for loops.
"""
@generated function Base.getindex{T,N,FD,FT,Offset}(a::Array{T,N},
                                               f::Face{FD, FT, Offset})
    v = Expr(:tuple)
    for i = 1:FD
        push!(v.args, Expr(:call, Base.unsafe_getindex, :a, :(f[$i]-Offset)))
    end
    Expr(:(::), v, :(NTuple{FD,T}))
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


getindex{T}(a::Array{T,2}, rect::SimpleRectangle)                 = a[rect.x+1:rect.w, rect.y+1:rect.h]
setindex!{T}(a::Array{T,2}, b::Array{T,2}, rect::SimpleRectangle) = (a[rect.x+1:rect.w, rect.y+1:rect.h] = b)
