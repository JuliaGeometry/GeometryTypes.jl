#Create typealiases like Mat4f0, Point2, Point2f0
for i=1:4
	for T=[:Point, :Vec]
		name 	= symbol("$T$i")
		namef0 	= symbol("$T$(i)f0")
		@eval begin
			typealias $name $T{$i}
			typealias $namef0 $T{$i, Float32}
			export $name
			export $namef0
		end
	end
	name   = symbol("Mat$i")
	namef0 = symbol("Mat$(i)f0")
	@eval begin
		typealias $name $Mat{$i,$i}
		typealias $namef0 $Mat{$i,$i, Float32}
		export $name
		export $namef0
	end
end


