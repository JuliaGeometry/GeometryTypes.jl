context("Mesh Types") do

context("Merging Mesh") do
	baselen = 0.4f0
	dirlen  = 2f0
	axis    = [
		(Cube{Float32}(Vec3f0(baselen), Vec3f0(dirlen, baselen, baselen)), RGBA(1f0,0f0,0f0,1f0)),
		(Cube{Float32}(Vec3f0(baselen), Vec3f0(baselen, dirlen, baselen)), RGBA(0f0,1f0,0f0,1f0)),
		(Cube{Float32}(Vec3f0(baselen), Vec3f0(baselen, baselen, dirlen)), RGBA(0f0,0f0,1f0,1f0))
	]
	axis = map(GLNormalMesh, axis)
	@fact typeof(axis[1]) --> GLNormalColorMesh

	axis = merge(axis)
	@fact typeof(axis) --> GLNormalAttributeMesh

	@fact vertextype(axis) --> Point{3, Float32}
	@fact normaltype(axis) --> Normal{3, Float32}
	@fact facetype(axis) --> Face{3, Cuint, -1}
	@fact has_vertices(axis) --> true
	@fact has_faces(axis) --> true
	@fact has_normals(axis) --> true
end


end
