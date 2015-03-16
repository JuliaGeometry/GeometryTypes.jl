
gen_fixed_sizea_array("Vector", 	[:x,:y,:z,:w],              1:4)
gen_fixed_sizea_array("Point",  	[:x,:y,:z,:w], 				1:4)
gen_fixed_sizea_array("Normal",  	[:x,:y,:z,:w], 				1:4)
gen_fixed_sizea_array("UV",		    [:u,:v], 					2:2)
gen_fixed_sizea_array("UVW",  		[:u,:v,:w], 				3:3)
gen_fixed_sizea_array("Face",   	[:a,:b,:c,:d,:e,:f,:g,:h], 	3:8)


#Axis Aligned Bounding Box
immutable AABB{T}
  min::Vector3{T}
  max::Vector3{T}
end

immutable Circle{T <: Real}
    x::T
    y::T
    r::T
end

type Rectangle{T <: Real}
    x::T
    y::T
    w::T
    h::T
end