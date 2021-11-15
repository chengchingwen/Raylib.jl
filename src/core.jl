const core_api_file = joinpath(dirname(@__DIR__), "api_reference/core.txt")


for line in eachline(core_api_file)
    (startswith(strip(line), "//") || isempty(line)) && continue
    @eval @declaration_str $line
end
