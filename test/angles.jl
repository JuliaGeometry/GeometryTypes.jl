context("angle") do

context("two points") do
    @fact angle(Point(1,0.), Point(sqrt(2), sqrt(2))) --> pi/4
    @fact angle(Point(sqrt(2), sqrt(2)), Point(5,0.)) --> -pi/4
end

context("Simplex") do

end
end
