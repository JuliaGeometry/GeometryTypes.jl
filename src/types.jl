macro fixed_vector(name, parent)
    esc(quote
        immutable $(name){S, T} <: $(parent){T}
            data::NTuple{S, T}

            function $(name)(x::NTuple{S,T})
                new(x)
            end
            function $(name)(x::NTuple{S})
                new(StaticArrays.convert_ntuple(T, x))
            end
        end
        @inline function (::Type{$(name){S, T}}){S, T}(x)
            $(name){S, T}(ntuple(i-> T(x), Val{S}))
        end
        @inline function (::Type{$(name){S}}){S, T}(x::T)
            $(name){S, T}(ntuple(i-> x, Val{S}))
        end
        @inline function (::Type{$(name){1, T}}){T}(x::T)
            $(name){1, T}((x,))
        end
        @inline (::Type{$(name)}){S}(x::NTuple{S}) = $(name){S}(x)
        @inline function (::Type{$(name){S}}){S, T <: Tuple}(x::T)
            $(name){S, StaticArrays.promote_tuple_eltype(T)}(x)
        end
        @generated function (::Type{SV}){SV <: $(name)}(x::StaticVector)
            len = size_or(SV, size(x))[1]
            if length(x) == len
                :(SV(Tuple(x)))
            elseif length(x) > len
                elems = [:(x[$i]) for i = 1:len]
                :(SV($(Expr(:tuple, elems...))))
            else
                error("Static Vector too short: $x, target type: $SV")
            end
        end

        Base.@pure Base.size{S}(::Union{$(name){S}, Type{$(name){S}}}) = (S, )
        Base.@pure Base.size{S,T}(::Type{$(name){S, T}}) = (S,)

        Base.@propagate_inbounds function Base.getindex(v::$(name), i::Integer)
            v.data[i]
        end
        @inline Base.Tuple(v::$(name)) = v.data
        @inline Base.convert{S, T}(::Type{$(name){S, T}}, x::NTuple{S, T}) = $(name){S, T}(x)
        @inline Base.convert{SV <: $(name)}(::Type{SV}, x::StaticVector) = SV(x)
        @inline function Base.convert{S, T}(::Type{$(name){S, T}}, x::Tuple)
            $(name){S, T}(convert(NTuple{S, T}, x))
        end
        # StaticArrays.similar_type{SV <: $(name)}(::Union{SV, Type{SV}}) = $(name)
        # function StaticArrays.similar_type{SV <: $(name), T}(::Union{SV, Type{SV}}, ::Type{T})
        #     $(name){length(SV), T}
        # end
        # function StaticArrays.similar_type{SV <: $(name)}(::Union{SV, Type{SV}}, s::Tuple{Int})
        #     $(name){s[1], eltype(SV)}
        # end
        function StaticArrays.similar_type{SV <: $(name), T}(::Union{SV, Type{SV}}, ::Type{T}, s::Tuple{Int})
            $(name){s[1], T}
        end
        function StaticArrays.similar_type{SV <: $(name)}(::Union{SV, Type{SV}}, s::Tuple{Int})
            $(name){s[1], eltype(SV)}
        end
        eltype_or(::Type{$(name)}, or) = or
        eltype_or{T}(::Type{$(name){TypeVar(:S), T}}, or) = T
        eltype_or{S}(::Type{$(name){S, TypeVar(:T)}}, or) = or
        eltype_or{S, T}(::Type{$(name){S, T}}, or) = T

        size_or(::Type{$(name)}, or) = or
        size_or{T}(::Type{$(name){TypeVar(:S), T}}, or) = or
        size_or{S}(::Type{$(name){S, TypeVar(:T)}}, or) = (S,)
        size_or{S, T}(::Type{$(name){S, T}}, or) = (S,)
    end)
end


abstract AbstractDistanceField
abstract AbstractUnsignedDistanceField <: AbstractDistanceField
abstract AbstractSignedDistanceField <: AbstractDistanceField
"""
Abstract to categorize geometry primitives of dimensionality `N` and
the numeric element type `T`.
"""
abstract AbstractGeometry{N, T}
abstract AbstractMesh{VertT, FaceT} <: AbstractGeometry
abstract GeometryPrimitive{N, T} <: AbstractGeometry{N, T}


"""
Abstract to classify Simplices. The convention for N starts at 1, which means
a Simplex has 1 point. A 2-simplex has 2 points, and so forth. This convention
is not the same as most mathematical texts.
"""
abstract AbstractSimplex{T} <: StaticVector{T}



"""
A `Simplex` is a generalization of an N-dimensional tetrahedra and can be thought
of as a minimal convex set containing the specified points.

* A 0-simplex is a point.
* A 1-simplex is a line segment.
* A 2-simplex is a triangle.
* A 3-simplex is a tetrahedron.

Note that this datatype is offset by one compared to the traditional
mathematical terminology. So a one-simplex is represented as `Simplex{2,T}`.
This is for a simpler implementation.

It applies to infinite dimensions. The structure of this type is designed
to allow embedding in higher-order spaces by parameterizing on `T`.
"""
immutable Simplex{S, T} <: AbstractSimplex{T}
    data::NTuple{S, T}
    function Simplex(x::NTuple{S, T})
        new(x)
    end
    function Simplex(x::NTuple{S})
        new(StaticArrays.convert_ntuple(T, x))
    end
end

@fixed_vector Vec StaticVector

@fixed_vector Point StaticVector

@fixed_vector Normal StaticVector

@fixed_vector TextureCoordinate StaticVector

@fixed_vector Face StaticVector

"""
A Face is typically used when constructing subtypes of `AbstractMesh` where
the `Face` should not reproduce the vertices, but rather index into them.
Face is parameterized by:

* `N` - The number of vertices in the face.
* `T` - The type of the indices in the face, a subtype of Integer.

"""
Face

"""
OffsetInteger type mainly for indexing.
* `O` - The offset relative to Julia arrays. This helps reduce copying when
communicating with 0-indexed systems such ad OpenGL.
"""
immutable OffsetInteger{O, T <: Integer} <: Integer
    i::T
    function OffsetInteger(x::T)
        new(x - O)
    end
end


raw(x::OffsetInteger) = x.i
raw(x::Integer) = x

"""
A `HyperRectangle` is a generalization of a rectangle into N-dimensions.
Formally it is the cartesian product of intervals, which is represented by the
`origin` and `width` fields, whose indices correspond to each of the `N` axes.
"""
immutable HyperRectangle{N, T} <: GeometryPrimitive{N, T}
    origin::Vec{N, T}
    widths::Vec{N, T}
end


immutable HyperCube{N, T} <: GeometryPrimitive{N, T}
    origin::Vec{N, T}
    width::T
end


"""
A `HyperSphere` is a generalization of a sphere into N-dimensions.
A `center` and radius, `r`, must be specified.
"""
immutable HyperSphere{N, T} <: GeometryPrimitive{N, T}
    center::Point{N, T}
    r::T
end

immutable SimpleRectangle{T} <: GeometryPrimitive{2, T}
    x::T
    y::T
    w::T
    h::T
end

# TODO remove before 0.2.0 tag
const Rectangle = SimpleRectangle

"""
A rectangle in 3D space.
"""
immutable Quad{T} <: GeometryPrimitive{3, T}
    downleft::Vec{3, T}
    width   ::Vec{3, T}
    height  ::Vec{3, T}
end

immutable Pyramid{T} <: GeometryPrimitive{3, T}
    middle::Point{3, T}
    length::T
    width ::T
end

immutable Particle{N, T} <: GeometryPrimitive{N, T}
    position::Point{N, T}
    velocity::Vec{N, T}
end

"""
A `SignedDistanceField` is a uniform sampling of an implicit function.
The `bounds` field corresponds to the sampling space intervals on each axis.
The `data` field represents the value at each point whose exact location
can be rationalized from `bounds`.
The type is parameterized by:

* `N` - The dimensionality of the sampling space.
* `SpaceT` - the type of the space where we will uniformly sample.
* `FieldT` - the type resulting from evaluation of the implicit function.

Note that decoupling the space and field types is useful since geometry can
be formulated with integers and distances can be measured with floating points.
"""
type SignedDistanceField{N,SpaceT,FieldT} <: AbstractSignedDistanceField
    bounds::HyperRectangle{N,SpaceT}
    data::Array{FieldT,N}
end

"""
The `HomogenousMesh` type describes a polygonal mesh that is useful for
computation on the CPU or on the GPU.
All vectors must have the same length or must be empty, besides the face vector
Type can be void or a value, this way we can create many combinations from this
one mesh type.
This is not perfect, but helps to reduce a type explosion (imagine defining
every attribute combination as a new type).
"""
immutable HomogenousMesh{VertT, FaceT, NormalT, TexCoordT, ColorT, AttribT, AttribIDT} <: AbstractMesh{VertT, FaceT}
    vertices            ::Vector{VertT}
    faces               ::Vector{FaceT}
    normals             ::Vector{NormalT}
    texturecoordinates  ::Vector{TexCoordT}
    color               ::ColorT
    attributes          ::AttribT
    attribute_id        ::Vector{AttribIDT}
end

"""
AbstractFlexibleGeometry{T}

AbstractFlexibleGeometry refers to shapes, which are somewhat mutable.
"""
abstract AbstractFlexibleGeometry{T}
typealias AFG AbstractFlexibleGeometry

"""
FlexibleConvexHull{T}

Represents the convex hull of finitely many points. The number of points is not fixed.
"""
immutable FlexibleConvexHull{T} <: AFG{T}
    _::Vector{T}
end

"""
FlexibleSimplex{T}

Represents a Simplex whos number of vertices is not fixed.
"""
immutable FlexibleSimplex{T} <: AFG{T}
    _::Vector{T}
end

"""
AbstractConvexHull

Groups all geometry types, that can be described as the convex hull of finitely
many points.
"""
typealias AbstractConvexHull Union{Simplex, FlexibleConvexHull, FlexibleSimplex,
HyperCube, HyperRectangle} # should we parametrize ACH by the type of points T?
