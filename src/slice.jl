# TODO Return type channges based on pair value
"""
Slice an AbstractMesh at the specified Z axis values.
Returns a Vector of Vectors
containing LineSegments generated at the specified heights.
"""
function Base.slice{VT<:Point{3,Float64},FT<:Face{3,Int,0}}(mesh::AbstractMesh{VT,FT}, heights::Vector{Float64}, pair=true; eps=0.00001, autoeps=true)

    height_ct = length(heights)
    # intialize the LineSegment arrays
    slices = [LineSegment{Point{2,Float64}}[] for i = 1:height_ct]

    for face in mesh.faces
        v1 = mesh.vertices[face[1]]
        v2 = mesh.vertices[face[2]]
        v3 = mesh.vertices[face[3]]
        zmax = max(v1[3], v2[3], v3[3])
        zmin = min(v1[3], v2[3], v3[3])
        for i = 1:height_ct
            height = heights[i]
            if height > zmax
                break
            elseif zmin <= height
                if v1[3] < height && v2[3] >= height && v3[3] >= height
                    p1 = v1
                    p2 = v3
                    p3 = v2
                elseif v1[3] > height && v2[3] < height && v3[3] < height
                    p1 = v1
                    p2 = v2
                    p3 = v3
                elseif v2[3] < height && v1[3] >= height && v3[3] >= height
                    p1 = v2
                    p2 = v1
                    p3 = v3
                elseif v2[3] > height && v1[3] < height && v3[3] < height
                    p1 = v2
                    p2 = v3
                    p3 = v1
                elseif v3[3] < height && v2[3] >= height && v1[3] >= height
                    p1 = v3
                    p2 = v2
                    p3 = v1
                elseif v3[3] > height && v2[3] < height && v1[3] < height
                    p1 = v3
                    p2 = v1
                    p3 = v2
                else
                    continue
                end

                start = Point{2,Float64}(p1[1] + (p2[1] - p1[1]) * (height - p1[3]) / (p2[3] - p1[3]),
                p1[2] + (p2[2] - p1[2]) * (height - p1[3]) / (p2[3] - p1[3]))
                finish = Point{2,Float64}(p1[1] + (p3[1] - p1[1]) * (height - p1[3]) / (p3[3] - p1[3]),
                p1[2] + (p3[2] - p1[2]) * (height - p1[3]) / (p3[3] - p1[3]))

                push!(slices[i], LineSegment(start, finish))
            end
        end
    end

    if !pair
        return slices
    end

    paired_slices = [Vector{LineSegment{Point{2,Float64}}}[] for i = 1:height_ct]

    for slice_num = 1:height_ct
        lines = slices[slice_num]
        line_ct = length(lines)
        if line_ct == 0
            continue
        end
        polys = Vector{LineSegment{Point{2,Float64}}}[]
        paired = fill(false, line_ct)
        start = 1
        seg = 1
        paired[seg] = true

        if autoeps
            for segment in lines
                eps = min(eps, norm(segment[1]-segment[2])/2)
            end
        end

        @inbounds while true
            #Start new polygon with seg
            poly = LineSegment{Point{2,Float64}}[]
            push!(poly, lines[seg])

            #Pair slice until we get to start point
            lastseg = seg
            while norm(lines[start][1] - lines[seg][2]) >= eps
                lastseg = seg

                for i = 1:line_ct
                    if !paired[i]
                        if norm(lines[seg][2] - lines[i][1]) <= eps
                            push!(poly, lines[i])
                            paired[i] = true
                            seg = i
                        end
                    end
                end

                if (seg == start #We couldn't pair the segment
                    || seg == lastseg) #The polygon can't be closed
                    break
                end
            end

            if length(poly) > 2
                closed = true
                if poly[1][1] != poly[end][2]
                    closed = false
                end
                for i = 1:length(poly)-2
                    if closed
                        break
                    end
                    for j = i+2:length(poly)
                        if poly[i][1] == poly[j][2]
                            poly = poly[i:j]
                            closed = true
                            break
                        end
                    end
                end
                push!(polys,poly)
            end
            finished_pairing = false
            #start new polygon
            for i = 1:length(lines)
                if !paired[i] #Find next unpaired seg
                    start = i
                    paired[i] = true
                    seg = start
                    break
                elseif i == length(lines) #we have paired each segment
                    finished_pairing = true
                    break
                end
            end
            if finished_pairing
                paired_slices[slice_num] = polys
                break # move to next layer
            end
        end
    end
    paired_slices
end
