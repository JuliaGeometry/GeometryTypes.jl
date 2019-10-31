import Base: +, -, abs, *, /, div, convert, ==, <=, >=, <, >, show, to_index, sub_with_overflow

function show(io::IO, oi::OffsetInteger{O, T}) where {O, T}
    print(io, "|$(raw(oi)) (indexes as $(value(oi))|")
end

Base.eltype(::Type{OffsetInteger{O, T}}) where {O, T} = T
Base.eltype(oi::OffsetInteger) = eltype(typeof(oi))

# constructors and conversion
OffsetInteger{O1, T1}(x::OffsetInteger{O2, T2}) where {O1, O2, T1 <: Integer, T2 <: Integer} = OffsetInteger{O1, T1}(T2(x))

OffsetInteger{O}(x::Integer) where {O} = OffsetInteger{O, eltype(x)}(x)
OffsetInteger{O}(x::OffsetInteger) where {O} = OffsetInteger{O, eltype(x)}(x)
(::Type{IT})(x::OffsetInteger{O, T}) where {IT <: Integer, O, T <: Integer} = IT(value(x))

Base.@pure pure_max(x1, x2) = x1 > x2 ? x1 : x2
Base.promote_rule(::Type{T1}, ::Type{OffsetInteger{O, T2}}) where {T1 <: Integer, O, T2} = T1
Base.promote_rule(::Type{OffsetInteger{O1, T1}}, ::Type{OffsetInteger{O2, T2}}) where {O1, O2, T1, T2} = OffsetInteger{pure_max(O1, O2), promote_type(T1, T2)}

to_index(I::AbstractArray{<:Face}) = I
to_index(I::OffsetInteger) = raw(OneIndex(I))
to_index(I::OffsetInteger{0}) = raw(I)

# basic operators
for op in (:(-), :abs)
    @eval $(op)(x::T) where {T <: OffsetInteger} = T($(op)(value(x)))
end
for op in (:(+), :(-), :(*), :(/), :div)
    @eval begin
        @inline function $(op)(x::OffsetInteger{O}, y::OffsetInteger{O}) where O
            OffsetInteger{O}($op(value(x), value(y)))
        end
    end
end
for op in (:(==), :(>=), :(<=), :(<) , :(>), :sub_with_overflow)
    @eval begin
        @inline function $(op)(x::OffsetInteger{O}, y::OffsetInteger{O}) where O
            $op(x.i, y.i)
        end
    end
end

@generated function Base.getindex(
        A::AbstractArray, f::Face{N}
    ) where N
    v = Expr(:tuple)
    for i = 1:N
        push!(v.args, :(A[f[$i]]))
    end
    :($(v))
end
