function call{T <: HMesh,HT}(meshtype::Type{T}, c::HyperRectangle{3,HT})
    ET = Float32
    xdir = Vec{3, ET}(c.widths[1],0f0,0f0)
    ydir = Vec{3, ET}(0f0,c.widths[2],0f0)
    zdir = Vec{3, ET}(0f0,0f0,c.widths[3])
    quads = [
        Quad(c.origin + zdir,   xdir, ydir), # Top
        Quad(c.origin,          ydir, xdir), # Bottom
        Quad(c.origin + xdir,   ydir, zdir), # Right
        Quad(c.origin,          zdir, ydir), # Left
        Quad(c.origin,          xdir, zdir), # Back
        Quad(c.origin + ydir,   zdir, xdir) #Front
    ]
    merge(map(meshtype, quads))
end

function call{T <: HMesh,HT}(meshtype::Type{T}, c::HyperCube{3,HT})
    ET = Float32
    xdir = Vec{3, ET}(c.width,0f0,0f0)
    ydir = Vec{3, ET}(0f0,c.width,0f0)
    zdir = Vec{3, ET}(0f0,0f0,c.width)
    quads = [
        Quad(c.origin + zdir,   xdir, ydir), # Top
        Quad(c.origin,          ydir, xdir), # Bottom
        Quad(c.origin + xdir,   ydir, zdir), # Right
        Quad(c.origin,          zdir, ydir), # Left
        Quad(c.origin,          xdir, zdir), # Back
        Quad(c.origin + ydir,   zdir, xdir) #Front
    ]
    merge(map(meshtype, quads))
end

call{T <: HMesh}(meshtype::Type{T}, c::Pyramid) = T(decompose(vertextype(T), c), decompose(facetype(T), c))

spherical{T}(theta::T, phi::T) = Point{3, T}(
    sin(theta)*cos(phi),
    sin(theta)*sin(phi),
    cos(theta)
)

function call{MT <: AbstractMesh}(::Type{MT}, s::Sphere, facets=12)
    PT, FT = vertextype(MT), facetype(MT)
    FTE    = eltype(FT)
    PTE    = eltype(PT)

    vertices      = Array(PT, facets*facets+1)
    vertices[end] = PT(0, 0, -1) #Create a vertex for last triangle fan
    for j=1:facets
        theta = PTE((pi*(j-1))/facets)
        for i=1:facets
            position           = sub2ind((facets,), j, i)
            phi                = PTE((2*pi*(i-1))/facets)
            vertices[position] = (spherical(theta, phi)*PTE(s.r))+PT(s.center)
        end
    end
    indexes          = Array(FT, facets*facets*2)
    psydo_triangle_i = length(vertices)
    index            = 1
    for j=1:facets
        for i=1:facets
            next_index = mod1(i+1, facets)
            i1 = sub2ind((facets,), j, i)
            i2 = sub2ind((facets,), j, next_index)
            i3 = (j != facets) ? sub2ind((facets,), j+1, i)          : psydo_triangle_i
            i6 = (j != facets) ? sub2ind((facets,), j+1, next_index) : psydo_triangle_i
            indexes[index]   = FT(Triangle{FTE}(i1,i2,i3)) # convert to required Face index offset
            indexes[index+1] = FT(Triangle{FTE}(i3,i2,i6))
            index += 2
        end
    end
    MT(vertices, indexes)
end
