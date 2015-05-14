# generate immutable types
@gen_fixed_size_vector("Vector", 	[:x,:y,:z,:w],              1:4, false)
@gen_fixed_size_vector("Point",  	[:x,:y,:z,:w], 				1:4, false)
@gen_fixed_size_vector("Normal",  	[:x,:y,:z,:w], 				1:4, false)



# generate mutable variant (will be MVector, MPoint, etc...)
@gen_fixed_size_vector("Vector",    [:x,:y,:z,:w],              1:4, true)
@gen_fixed_size_vector("Point",     [:x,:y,:z,:w],              1:4, true)
@gen_fixed_size_vector("Normal",    [:x,:y,:z,:w],              1:4, true)
@gen_fixed_size_vector("UV",        [:u,:v],                    2:2, true)
@gen_fixed_size_vector("UVW",       [:u,:v,:w],                 3:3, true)

#generating matrixes (Matrix1x1, Matrix1x2, etc...)
gen_fixed_size_matrix(1:4, 1:4, false)
gen_fixed_size_matrix(1:4, 1:4, true)

abstract Face{Dim, T, IndexOffset} <: FixedVector{T, Dim}

immutable Face3{T, IndexOffset} <: Face{3, T, IndexOffset}
    a::T
    b::T
    c::T
end
immutable Face4{T, IndexOffset} <: Face{4, T, IndexOffset}
    a::T
    b::T
    c::T
    d::T
end
typealias Triangle{T} Face3{T, 0}
typealias GLFace{Dim} Face{Dim, Cuint, -1} #offset is relative to julia, so -1 is 0-indexed
typealias GLTriangle  Face3{Cuint, -1}
typealias GLQuad      Face4{Cuint, -1}

immutable UV{T} <: FixedVector{T, 2}
    u::T
    v::T
end
immutable UVW{T} <: FixedVector{T, 3}
    u::T
    v::T
    w::T
end
#Axis Aligned Bounding Box

immutable AABB{T}
  min::Vector3{T}
  max::Vector3{T}
end

immutable Cube{T}
  origin::Vector3{T}
  width::Vector3{T}
end
immutable Circle{T}
    center::Point2{T}
    r::T
end
immutable Sphere{T}
    center::Point3{T}
    r::T
end
immutable Rectangle{T}
    x::T
    y::T
    w::T
    h::T
end

immutable Quad{T}
  downleft::Vector3{T}
  width::Vector3{T}
  height::Vector3{T}
end

immutable Pyramid{T}
  middle::Point3{T}
  length::T
  width::T
end

type MCube{T}
  min::MVector3{T}
  max::MVector3{T}
end

type MCircle{T}
    center::MPoint2{T}
    r::T
end
type MSphere{T}
    center::MPoint3{T}
    r::T
end
type MRectangle{T}
    x::T
    y::T
    w::T
    h::T
end