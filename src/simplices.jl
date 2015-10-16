#
# We need this constructor to route around the FixedSizeArray `call` and 
# so Simplex(Pt, Pt...) works.
#
function call{T<:Simplex,F<:FixedVector}(::Type{T}, f::F...)
    Simplex{length(f),F}(f)
end
