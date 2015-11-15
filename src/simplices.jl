#
# We need this constructor to route around the FixedSizeArray `call` and 
# so Simplex(Pt, Pt...) works. Hopefully these ambiguities will be fixed in
# forthcoming Julia versions.
function call{T<:Simplex,F<:FixedVector}(::Type{T}, f::F...)
    Simplex{length(f),F}(f)
end

# FSA doesn't handle symbols for length 1 well.
function call{T<:Simplex}(::Type{T}, f::Symbol)
    Simplex{1,Symbol}((f,))
end
