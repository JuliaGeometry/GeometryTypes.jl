import Base: +, -, abs, *, /, div, convert, ==, <=, >=, show

function show{O, T}(io::IO, oi::OffsetInteger{O, T})
    i = T(oi)
    print(io, "|$(i)-$(O)|")
end

# constructors and conversion

(::Type{T}){T <: OffsetInteger}(x::T) = x

function (::Type{OffsetInteger{O}}){O, T <: Integer}(x::T)
    OffsetInteger{O, T}(x)
end

function (::Type{OffsetInteger{O, T}}){O, T}(x::OffsetInteger)
    OffsetInteger{O, T}(T(x))
end
function (::Type{OffsetInteger{O1}}){O1, O2, T}(x::OffsetInteger{O2, T})
    OffsetInteger{O1}(T(x))
end

convert{T <: Integer, O, T2}(::Type{T}, x::OffsetInteger{O, T2}) = T(x.i + O)
convert{O, T}(::Type{OffsetInteger{O, T}}, x::Int) = OffsetInteger{O, T}(T(x))
convert{O, T <: Integer}(::Type{OffsetInteger{O, T}}, x::T) = OffsetInteger{O, T}(x)


# basic operators
for op in (:(-), :abs)
    @eval $(op){T <: OffsetInteger}(x::T) = T($(op)(x.i))
end
for op in (:(+), :(-), :(*), :(/), :div)
    @eval begin
        @inline function $(op){O}(x::OffsetInteger{O}, y::OffsetInteger{O})
            OffsetInteger{O}($op(x.i, y.i))
        end
    end
end
for op in (:(==), :(>=), :(<=))
    @eval begin
        @inline function $(op){O}(x::OffsetInteger{O}, y::OffsetInteger{O})
            $op(x.i, y.i)
        end
    end
end


function Base.promote_type{T <: Int, OI <: OffsetInteger}(::Type{T}, ::Type{OI})
    T
end
function Base.promote_type{T <: Int, OI <: OffsetInteger}(::Type{OI}, ::Type{T})
    T
end


@generated function Base.getindex{N}(
        A::AbstractArray, f::Face{N}
    )
    v = Expr(:tuple)
    for i = 1:N
        push!(v.args, :(A[f[$i]]))
    end
    :($(v))
end

function setindex!{N}(a::AbstractArray, b::AbstractArray, f::Face{N})
    for i = 1:N
        a[f[i]] = b[i]
    end
    b
end
