"""
Triangulate an N-Face into a tuple of triangular faces.
"""
@generated function decompose{N, FT1, FT2, O1, O2}(::Type{Face{3, FT1, O1}},
                                       f::Face{N, FT2, O2})
    @assert 3 <= N # other wise degenerate

    v = Expr(:tuple)
    append!(v.args, [:(Face{3,$FT1,$O1}(f[1]+$(-O2+O1),
                                        f[$(i-1)]+$(-O2+O1),
                                        f[$(i)]+$(-O2+O1))) for i = 3:N])
    v
end

"""
Extract all line segments in a Face.
"""
@generated function decompose{N, FT1, FT2, O1, O2}(::Type{Face{2, FT1, O1}},
                                       f::Face{N, FT2, O2})
    @assert 2 <= N # other wise degenerate

    v = Expr(:tuple)
    append!(v.args, [:(Face{2,$FT1,$O1}(f[$(i)]+$(-O2+O1),
                                        f[$(i+1)]+$(-O2+O1))) for i = 1:N-1])
    # connect vertices N and 1
    push!(v.args, :(Face{2,$FT1,$O1}(f[$(N)]+$(-O2+O1),
                                     f[$(1)]+$(-O2+O1))))
    v
end
