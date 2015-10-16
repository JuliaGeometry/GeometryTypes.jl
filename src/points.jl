function call{T}(::Type{Vector{Point{3,T}}}, rect::HyperRectangle{3, T})
    Point{3, T}[
        Point{3, T}(rect.minimum[1],rect.minimum[2],rect.minimum[3]),
        Point{3, T}(rect.minimum[1],rect.minimum[2],rect.maximum[3]),
        Point{3, T}(rect.minimum[1],rect.maximum[2],rect.minimum[3]),
        Point{3, T}(rect.minimum[1],rect.maximum[2],rect.maximum[3]),
        Point{3, T}(rect.maximum[1],rect.minimum[2],rect.minimum[3]),
        Point{3, T}(rect.maximum[1],rect.minimum[2],rect.maximum[3]),
        Point{3, T}(rect.maximum[1],rect.maximum[2],rect.minimum[3]),
        Point{3, T}(rect.maximum[1],rect.maximum[2],rect.maximum[3])]
end

function call{T}(::Type{Vector{Point{2,T}}}, rect::HyperRectangle{2, T})
    Point{2, T}[
        Point{2,T}(rect.minimum[1], rect.minimum[2]),
        Point{2, T}(rect.minimum[1], rect.maximum[2]),
        Point{2, T}(rect.maximum[1], rect.minimum[2]),
        Point{2,T}(rect.maximum[1], rect.maximum[2])]
end

getindex{PT}(r::Rectangle, T::Type{Point{2, PT}}) = T[
    T(r.x, r.y),
    T(r.x, r.y + r.h),
    T(r.x + r.w, r.y + r.h),
    T(r.x + r.w, r.y)
]

function getindex{PT}(p::Pyramid, T::Type{Point{3, PT}})
    leftup   = T(-p.width , p.width, PT(0)) / 2f0
    leftdown = T(-p.width, -p.width, PT(0)) / 2f0
    tip = T(p.middle + T(PT(0),PT(0),p.length))
    lu  = T(p.middle + leftup)
    ld  = T(p.middle + leftdown)
    ru  = T(p.middle - leftdown)
    rd  = T(p.middle - leftup)
    T[
        tip, rd, ru,
        tip, ru, lu,
        tip, lu, ld,
        tip, ld, rd,
        rd,  ru, lu,
        lu,  ld, rd
    ]
end

getindex{ET}(q::Quad, T::Type{Point{3, ET}}) = T[
    q.downleft,
    q.downleft + q.height,
    q.downleft + q.width + q.height,
    q.downleft + q.width
]
