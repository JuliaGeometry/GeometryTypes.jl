# generate immutable types
@gen_fixed_size_vector("Vector", 	[:x,:y,:z,:w],              1:4, false)
@gen_fixed_size_vector("Point",  	[:x,:y,:z,:w], 				1:4, false)
@gen_fixed_size_vector("Normal",  	[:x,:y,:z,:w], 				1:4, false)
@gen_fixed_size_vector("UV",		[:u,:v], 				    2:2, false)
@gen_fixed_size_vector("UVW",  		[:u,:v,:w], 				3:3, false)
@gen_fixed_size_vector("Face",   	[:a,:b,:c,:d,:e,:f,:g,:h], 	3:8, false)

# generate mutable variant (will be MVector, MPoint, etc...)
@gen_fixed_size_vector("Vector",    [:x,:y,:z,:w],              1:4, true)
@gen_fixed_size_vector("Point",     [:x,:y,:z,:w],              1:4, true)
@gen_fixed_size_vector("Normal",    [:x,:y,:z,:w],              1:4, true)
@gen_fixed_size_vector("UV",        [:u,:v],                    2:2, true)
@gen_fixed_size_vector("UVW",       [:u,:v,:w],                 3:3, true)
@gen_fixed_size_vector("Face",      [:a,:b,:c,:d,:e,:f,:g,:h],  3:8, true)

#generating matrixes (Matrix1x1, Matrix1x2, etc...)
gen_fixed_size_matrix(1:4, 1:4, false)
gen_fixed_size_matrix(1:4, 1:4, true)


#Axis Aligned Cube
immutable Cube{T}
  min::Vector3{T}
  max::Vector3{T}
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