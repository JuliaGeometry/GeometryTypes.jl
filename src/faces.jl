import Base: +, -, abs, *, /, div, convert, ==, <=, >=, show, to_index


to_index(I::AbstractArray{<:Face}) = I

function show{O, T}(io::IO, oi::OffsetInteger{O, T})
    i = T(oi)
    print(io, "|$(i)-$(O)|")
end

# constructors and conversion

(::Type{T}){T <: OffsetInteger}(x::T) = x

function (::Type{OffsetInteger{O1}}){O1, O2, T}(x::OffsetInteger{O2, T})
    OffsetInteger{O1}(T(x))
end
for IT in (Int64, Int32, UInt64, UInt32)
    @eval begin
        function (::Type{OffsetInteger{O}}){O}(x::$(IT))
            OffsetInteger{O, $(IT)}(x)
        end
        convert{O, T <: Integer}(::Type{$(IT)}, x::OffsetInteger{O, T}) = $(IT)(x.i + O)
        convert{O, T <: Integer}(::Type{OffsetInteger{O, T}}, x::$(IT)) = OffsetInteger{O, T}(T(x))
        function convert{O1, O2, T <: Integer}(::Type{OffsetInteger{O1, T}}, x::OffsetInteger{O2, $(IT)})
            OffsetInteger{O1, T}(T(x))
        end
    end
end
#convert{O, T <: Integer}(::Type{OffsetInteger{O, T}}, x::T) = OffsetInteger{O, T}(x)


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


Base.promote_rule{T <: Int, OI <: OffsetInteger}(::Type{T}, ::Type{OI}) = T


@generated function Base.getindex{N}(
        A::AbstractArray, f::Face{N}
    )
    v = Expr(:tuple)
    for i = 1:N
        push!(v.args, :(A[f[$i]]))
    end
    :($(v))
end

# function setindex!{N}(a::AbstractArray, b::AbstractArray, f::Face{N})
#     for i = 1:N
#         a[f[i]] = b[i]
#     end
#     b
# end
