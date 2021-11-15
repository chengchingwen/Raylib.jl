const models_api_file = joinpath(dirname(@__DIR__), "api_reference/models.txt")


for line in eachline(models_api_file)
    (startswith(strip(line), "//") || isempty(line)) && continue
    @eval @declaration_str $line
end
