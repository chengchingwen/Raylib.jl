const core_api_file = joinpath(dirname(@__DIR__), "api_reference/core.txt")

for line in eachline(core_api_file)
    (startswith(strip(line), "//") || isempty(line)) && continue
    @eval @declaration_str $line
end

"""
    UpdateCamera(camera::RayCamera3D)

Return new camera with updated parameter.
"""
function UpdateCamera(camera::RayCamera3D)
    new_camera_ref = Ref(camera)
    Raylib.UpdateCamera(new_camera_ref)

    return new_camera_ref[]
end

"""
    UpdateCamera!(camera::RayCamera3D)

Update camera position for selected mode
"""
function UpdateCamera!(camera::RayCamera3D)
    camera_ptr = convert(Ptr{RayCamera3D}, pointer_from_objref(camera))
    Raylib.UpdateCamera(camera_ptr)
    return camera
end

"""
    GetDroppedFiles()

Return a list of dropped file paths.
"""
function GetDroppedFiles()
    count = Ref{Cint}(0)
    fptrs = GetDroppedFiles(count)
    fcstr = Base.unsafe_wrap(Vector{Cstring}, fptrs, count[])
    return map(Base.unsafe_string, fcstr)
end

for func in :(
    IsKeyDown, IsKeyPressed, IsKeyReleased, IsKeyUp
).args
    @eval $func(k::KeyboardKey) = $func(convert(Integer, k))
end
