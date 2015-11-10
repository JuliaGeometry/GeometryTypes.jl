Base.@deprecate triangulate{F<:Face}(t::Type{F}, f::Face) decompose(t, f)
