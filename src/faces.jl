"""
Given an Array, `a`, and a face, `f`, return a tuple of numbers
interpreting the values and offset of the face as indices into `A`.

Note: This is not bounds checked. It is recommended that you use
`checkbounds` to confirm the indices are safe for loops.
Also be aware when writing generic code that faces may be of more than
3 vertices.
"""
@generated function Base.getindex{T,N,FD,FT,Offset}(a::Array{T,N},
                                               f::Face{FD, FT, Offset})
    v = Expr(:tuple)
    for i = 1:FD
        push!(v.args, Expr(:call, Base.unsafe_getindex, :a, :(Int(f[$i])-Int(Offset))))
    end
    :($(v)::NTuple{FD,T})
end

function setindex!{T,N,FD,FT,Offset}(a::Array{T,N}, b::Array{T,N}, f::Face{FD, FT, Offset})
	for i=1:FD
    	a[onebased(f,i)] = b[i]
    end
end

convert{T1<:Face}(::Type{T1}, f::T1) = f
convert{T1<:Face, T2<:Face}(::Type{T1}, f::T2) = T1(f)

# Silly duplication, but call(::FixedVector, ::Any) = convert is overloaded in FixedSizeArrays
call{F<:Face}(::Type{F}, f::F) = f

function call{T, T2, O, N}(::Type{Face{N, T, O}}, f::Face{N, T2, O})
    Face{N, T, O}(convert(NTuple{N, T}, getfield(f, 1)))
end
immutable IndexConvertFunc{T1, T2}
	f::T2
end
function call{N,T1,T2,O1,O2}(ifunc::IndexConvertFunc{Face{N,T1,O1}, Face{N,T2,O2}}, i)
	Int(ifunc.f[i])+Int(O1)-Int(O2)
end
function call{N, T1, O1, F<:Face}(T::Type{Face{N, T1, O1}}, f::F)
	map(IndexConvertFunc{T,F}(f), T)
end

function Face{T<:Number}(vals::T...)
    Face{length(vals), T, 0}(vals...)
end
onebased{N,T,Offset}(face::Face{N,T,Offset}, i) = T(Int(face[i]) - Int(Offset))
zerobased{N,T,Offset}(face::Face{N,T,Offset}, i) = T(Int(face[i]) - Int(Offset) - 1)
offsetbased{N,T,Offset}(face::Face{N,T,Offset}, i, offset) = T(Int(face[i]) - Int(Offset) + Int(offset))

export onebased, zerobased
