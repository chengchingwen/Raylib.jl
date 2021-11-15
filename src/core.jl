const core_api_file = joinpath(dirname(@__DIR__), "api_reference/core.txt")


for line in eachline(core_api_file)
    (startswith(strip(line), "//") || isempty(line)) && continue
    @eval @declaration_str $line
end

function UpdateCamera(camera::RayCamera3D)
    new_camera_ref = Ref(camera)
    Raylib.UpdateCamera(new_camera_ref)

    return new_camera_ref[]
end

function GetDroppedFiles()
    count = Ref{Cint}(0)
    fptrs = GetDroppedFiles(count)
    return Base.unsafe_wrap(Vector{String}, fptrs, count[])
end
