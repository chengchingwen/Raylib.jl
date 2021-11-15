const shapes_api_file = joinpath(dirname(@__DIR__), "api_reference/shapes.txt")


for line in eachline(shapes_api_file)
    (startswith(strip(line), "//") || isempty(line)) && continue
    @eval @declaration_str $line
end
