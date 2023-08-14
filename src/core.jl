"""
    UpdateCamera(camera::RayCamera3D)

Return new camera with updated parameter.
"""
function Binding.UpdateCamera(camera::RayCamera3D)
    new_camera_ref = Ref(camera)
    UpdateCamera(new_camera_ref)

    return new_camera_ref[]
end

"""
    UpdateCamera!(camera::RayCamera3D)

Update camera position for selected mode
"""
function UpdateCamera!(camera::RayCamera3D)
    camera_ptr = convert(Ptr{RayCamera3D}, pointer_from_objref(camera))
    UpdateCamera(camera_ptr)
    return camera
end

"""
    GetDroppedFiles()

Return a list of dropped file paths.
"""
function Binding.GetDroppedFiles()
    count = Ref{Cint}(0)
    fptrs = GetDroppedFiles(count)
    fcstr = Base.unsafe_wrap(Vector{Cstring}, fptrs, count[])
    return map(Base.unsafe_string, fcstr)
end

"""
    RayFileData(filename::AbstractString)

Read the file data. It will be auto-unloaded when being garbage collected.
"""
struct RayFileData
    data::Vector{UInt8}

    function RayFileData(filename::AbstractString)
        bytes = Ref{Cuint}(0)
        dptr = LoadFileData(filename, bytes)
        fdata = Base.unsafe_wrap(Vector{UInt8}, dptr, bytes[])
        finalizer(fdata) do x
            ptr = pointer(x)
            UnloadFileData(ptr)
        end

        return new(fdata)
    end
end

Base.length(fdata::RayFileData) = length(fdata.data)
Base.pointer(fdata::RayFileData) = pointer(fdata.data)

#Convert KeyPressed Enums to Int
for func in :(
    IsKeyDown, IsKeyPressed, IsKeyReleased, IsKeyUp
).args
    @eval Binding.$func(k::KeyboardKey) = $func(convert(Integer, k))
end

#Convert MouseButton Enums to Int
for func in :(
    IsMouseButtonDown, IsMouseButtonPressed, IsMouseButtonReleased, IsMouseButtonUp
).args
    @eval Binding.$func(m::MouseButton) = $func(convert(Integer, m))
end

#Convert MouseCursor Enums to Int
for func in :(
    SetMouseCursor,
).args
    @eval Binding.$func(c::MouseCursor) = $func(convert(Integer, c))
end
