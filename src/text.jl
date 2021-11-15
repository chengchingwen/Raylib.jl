const text_api_file = joinpath(dirname(@__DIR__), "api_reference/text.txt")


for line in eachline(text_api_file)
    (startswith(strip(line), "//") || isempty(line)) && continue
    @eval @declaration_str $line
end
