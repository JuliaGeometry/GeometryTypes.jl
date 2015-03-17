@gen_fixed_sizea_array("Vector", 	[:x,:y,:z,:w],              2:4)
@gen_fixed_sizea_array("Point",  	[:x,:y,:z,:w], 				2:4)
@gen_fixed_sizea_array("Normal",  	[:x,:y,:z,:w], 				2:4)
@gen_fixed_sizea_array("UV",		[:u,:v], 					2:2)
@gen_fixed_sizea_array("UVW",  		[:u,:v,:w], 				3:3)
@gen_fixed_sizea_array("Face",   	[:a,:b,:c,:d,:e,:f,:g,:h], 	3:8)




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