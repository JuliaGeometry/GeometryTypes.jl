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
                                     f[$(1)]+$(-O2+O1)))) # not enough dollars
    v
end

function decompose{T}(::Type{Point{3,T}}, rect::HyperRectangle{3, T})
       (Point{3, T}(rect.minimum[1],rect.minimum[2],rect.minimum[3]),
        Point{3, T}(rect.minimum[1],rect.minimum[2],rect.maximum[3]),
        Point{3, T}(rect.minimum[1],rect.maximum[2],rect.minimum[3]),
        Point{3, T}(rect.minimum[1],rect.maximum[2],rect.maximum[3]),
        Point{3, T}(rect.maximum[1],rect.minimum[2],rect.minimum[3]),
        Point{3, T}(rect.maximum[1],rect.minimum[2],rect.maximum[3]),
        Point{3, T}(rect.maximum[1],rect.maximum[2],rect.minimum[3]),
        Point{3, T}(rect.maximum[1],rect.maximum[2],rect.maximum[3]))
end

function decompose{T}(::Type{Point{2,T}}, rect::HyperRectangle{2, T})
       (Point{2,T}(rect.minimum[1], rect.minimum[2]),
        Point{2, T}(rect.minimum[1], rect.maximum[2]),
        Point{2, T}(rect.maximum[1], rect.minimum[2]),
        Point{2,T}(rect.maximum[1], rect.maximum[2]))
end

function decompose{PT}(T::Type{Point{2, PT}},r::Rectangle)
   T[T(r.x, r.y),
    T(r.x, r.y + r.h),
    T(r.x + r.w, r.y + r.h),
    T(r.x + r.w, r.y)]
end

function decompose{PT}(T::Type{Point{3, PT}},p::Pyramid)
    leftup   = T(-p.width , p.width, PT(0)) / 2f0
    leftdown = T(-p.width, -p.width, PT(0)) / 2f0
    tip = T(p.middle + T(PT(0),PT(0),p.length))
    lu  = T(p.middle + leftup)
    ld  = T(p.middle + leftdown)
    ru  = T(p.middle - leftdown)
    rd  = T(p.middle - leftup)
    T[tip, rd, ru,
        tip, ru, lu,
        tip, lu, ld,
        tip, ld, rd,
        rd,  ru, lu,
        lu,  ld, rd]
end

function decompose{ET}(T::Type{Point{3, ET}}, q::Quad)
   T[q.downleft,
    q.downleft + q.height,
    q.downleft + q.width + q.height,
    q.downleft + q.width]
end
