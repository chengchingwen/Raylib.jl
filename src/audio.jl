const audio_api_file = joinpath(dirname(@__DIR__), "api_reference/audio.txt")


for line in eachline(audio_api_file)
    (startswith(strip(line), "//") || isempty(line)) && continue
    @eval @declaration_str $line
end
