const textures_api_file = joinpath(dirname(@__DIR__), "api_reference/textures.txt")


for line in eachline(textures_api_file)
    (startswith(strip(line), "//") || isempty(line)) && continue
    @eval @declaration_str $line
end
