const RayVector2 = NTuple{2, Cfloat}
const RayVector3 = NTuple{3, Cfloat}
const RayVector4 = NTuple{4, Cfloat}

rayvector(v::Vararg{<:Real, 2}) = RayVector2(v)
rayvector(v::Vararg{<:Real, 3}) = RayVector3(v)
rayvector(v::Vararg{<:Real, 4}) = RayVector4(v)

struct RayCamera3D
    position::RayVector3
    target::RayVector3
    up::RayVector3
    fovy::Cfloat
    projection::Cint
end

struct RayCamera2D
    offset::RayVector2
    target::RayVector2
    rotation::Cfloat
    zoom::Cfloat
end
