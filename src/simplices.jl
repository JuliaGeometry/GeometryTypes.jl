#
# We need this constructor to route around the FixedSizeArray `call` and 
# so Simplex(Pt, Pt...) works. Hopefully these ambiguities will be fixed in
# forthcoming Julia versions.
@compat function (::Type{T}){T<:Simplex,F<:FixedVector}(f::F...)
    Simplex{length(f),F}(f)
end

# FSA doesn't handle symbols for length 1 well.
@compat function (::Type{T}){T<:Simplex}(f::Symbol)
    Simplex{1,Symbol}((f,))
end
