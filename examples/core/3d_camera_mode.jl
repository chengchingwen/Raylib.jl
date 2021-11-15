using Raylib_jll

struct RayColor
    r::Cuchar
    g::Cuchar
    b::Cuchar
    a::Cuchar
end

const RAYWHITE = RayColor(245, 245, 245, 255)
const LIGHTGRAY = RayColor(200, 200, 200, 255)
const DARKGRAY = RayColor(80, 80, 80, 255)
const MAROON = RayColor(190, 33, 55, 255)
const RED = RayColor(230, 41, 55, 255)

struct RayVector3
    x::Cfloat
    y::Cfloat
    z::Cfloat
end

struct RayCamera3D
    position::RayVector3
    target::RayVector3
    up::RayVector3
    fovy::Cfloat
    projection::Cint
end

function main()
    screenWidth = 800
    screenHeight = 450
    
    @ccall libraylib.InitWindow(screenWidth::Cint, screenHeight::Cint,
                             "raylib [core] example - 3d camera mode"::Cstring)::Cvoid

    camera = RayCamera3D(
        RayVector3(0, 10, 10),
        RayVector3(0, 0, 0),
        RayVector3(0, 1, 0),
        45,
        0,
    )

    cubePosition = RayVector3(0, 0, 0)

    @ccall libraylib.SetTargetFPS(60::Cint)::Cvoid

    while iszero(@ccall libraylib.WindowShouldClose()::Cint)
        @ccall libraylib.BeginDrawing()::Cvoid
        @ccall libraylib.ClearBackground(RAYWHITE::RayColor)::Cvoid

        @ccall libraylib.BeginMode3D(camera::RayCamera3D)::Cvoid
        @ccall libraylib.DrawCube(cubePosition::RayVector3, 2f0::Cfloat, 2f0::Cfloat, 2f0::Cfloat,
                               RED::RayColor)::RayColor
        
        @ccall libraylib.DrawCubeWires(cubePosition::RayVector3, 2f0::Cfloat, 2f0::Cfloat, 2f0::Cfloat,
                                    MAROON::RayColor)::Cvoid

        @ccall libraylib.DrawGrid(10::Cint, 1f0::Cfloat)::Cvoid

        @ccall libraylib.EndMode3D()::Cvoid
        @ccall libraylib.DrawText("Welcome to the third dimension!"::Cstring,
                               10::Cint, 40::Cint, 20::Cint, DARKGRAY::RayColor)::Cvoid
        @ccall libraylib.EndDrawing()::Cvoid
    end

    @ccall libraylib.CloseWindow()::Cvoid

end
