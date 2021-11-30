using StaticArrays

import Base: propertynames, getproperty, setproperty!

struct RayVector2 <: FieldVector{2, Cfloat}
    x::Cfloat
    y::Cfloat
end

struct RayVector3 <: FieldVector{3, Cfloat}
    x::Cfloat
    y::Cfloat
    z::Cfloat
end

struct RayVector4 <: FieldVector{4, Cfloat}
    x::Cfloat
    y::Cfloat
    z::Cfloat
    w::Cfloat
end

const RayQuaternion = RayVector4

rayvector(v::Vararg{<:Real, 2}) = RayVector2(v)
rayvector(v::Vararg{<:Real, 3}) = RayVector3(v)
rayvector(v::Vararg{<:Real, 4}) = RayVector4(v)

const RayMatrix = SMatrix{4, 4, Cfloat, 16}
const RayMatrix2x2 = SMatrix{2, 2, Cfloat, 4}

mutable struct RayCamera3D
    #position::RayVector3  # Camera position
    position_x::Cfloat
    position_y::Cfloat
    position_z::Cfloat

    # target::RayVector3    # Camera target it looks-at
    target_x::Cfloat
    target_y::Cfloat
    target_z::Cfloat

    # up::RayVector3        # Camera up vector (rotation over its axis)
    up_x::Cfloat
    up_y::Cfloat
    up_z::Cfloat

    fovy::Cfloat          # Camera field-of-view apperture in Y (degrees) in perspective,
                          #   used as near plane width in orthographic
    projection::Cint      # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
end

const RayCamera = RayCamera3D

RayCamera3D(position::RayVector3, target::RayVector3, up::RayVector3, fovy, projection) =
    RayCamera3D(position..., target..., up..., fovy, projection)

RayCamera3D(position, target, up, fovy, projection) =
    RayCamera3D(RayVector3(position), RayVector3(target), RayVector3(up), fovy, projection)

@inline function propertynames(x::RayCamera3D, private::Bool=false)
    if private
        return fieldnames(RayCamera3D)
    else
        return (:position, :target, :up, :fovy, :projection)
    end
end

@inline function getproperty(x::RayCamera3D, name::Symbol)
    if name == :position
        return rayvector(
            getfield(x, :position_x),
            getfield(x, :position_y),
            getfield(x, :position_z),
        )
    elseif name == :target
        return rayvector(
            getfield(x, :target_x),
            getfield(x, :target_y),
            getfield(x, :target_z),
        )
    elseif name == :up
        return rayvector(
            getfield(x, :up_x),
            getfield(x, :up_y),
            getfield(x, :up_z),
        )
    else
        return getfield(x, name)
    end
end

@inline function setproperty!(x::RayCamera3D, name::Symbol, v)
    if name == :position
        vv = RayVector3(v)
        setfield!(x, :position_x, vv.x)
        setfield!(x, :position_y, vv.y)
        setfield!(x, :position_z, vv.z)
        return vv
    elseif name == :target
        vv = RayVector3(v)
        setfield!(x, :target_x, vv.x)
        setfield!(x, :target_y, vv.y)
        setfield!(x, :target_z, vv.z)
        return vv
    elseif name == :up
        vv = RayVector3(v)
        setfield!(x, :up_x, vv.x)
        setfield!(x, :up_y, vv.y)
        setfield!(x, :up_z, vv.z)
        return vv
    else
        return setfield!(x, name, convert(fieldtype(RayCamera3D, name), v))
    end
end


mutable struct RayCamera2D
    # offset::RayVector2  # Camera offset (displacement from target)
    offset_x::Cfloat
    offset_y::Cfloat

    # target::RayVector2  # Camera target (rotation and zoom origin)
    target_x::Cfloat
    target_y::Cfloat

    rotation::Cfloat    # Camera rotation in degrees
    zoom::Cfloat        # Camera zoom (scaling), should be 1.0f by default
end

RayCamera2D(offset::RayVector2, target::RayVector2, rotation, zoom) = RayCamera2D(offset..., target..., rotation, zoom)

RayCamera2D(offset, target, rotation, zoom) = RayCamera2D(RayVector2(offset), RayVector2(target), rotation, zoom)

@inline function propertynames(x::RayCamera2D, private::Bool=false)
    if private
        return fieldnames(RayCamera2D)
    else
        return (:offset, :target, :rotation, :zoom)
    end
end


@inline function getproperty(x::RayCamera2D, name::Symbol)
    if name == :offset
        return rayvector(
            getfield(x, :offset_x),
            getfield(x, :offset_y),
        )
    elseif name == :target
        return rayvector(
            getfield(x, :target_x),
            getfield(x, :target_y),
        )
    else
        return getfield(x, name)
    end
end

@inline function setproperty!(x::RayCamera2D, name::Symbol, v)
    if name == :offset
        vv = RayVector2(v)
        setfield!(x, :offset_x, vv.x)
        setfield!(x, :offset_y, vv.y)
        return vv
    elseif name == :target
        vv = RayVector2(v)
        setfield!(x, :target_x, vv.x)
        setfield!(x, :target_y, vv.y)
        return vv
    else
        return setfield!(x, name, convert(fieldtype(RayCamera2D, name), v))
    end
end
