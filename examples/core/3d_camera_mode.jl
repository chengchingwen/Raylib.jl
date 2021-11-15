using raylib_jll

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
    
    @ccall raylib.InitWindow(screenWidth::Cint, screenHeight::Cint,
                             "raylib [core] example - 3d camera mode"::Cstring)::Cvoid

    camera = RayCamera3D(
        RayVector3(0, 10, 10),
        RayVector3(0, 0, 0),
        RayVector3(0, 1, 0),
        45,
        0,
    )

    cubePosition = RayVector3(0, 0, 0)

    @ccall raylib.SetTargetFPS(60::Cint)::Cvoid

    while iszero(@ccall raylib.WindowShouldClose()::Cint)
        @ccall raylib.BeginDrawing()::Cvoid
        @ccall raylib.ClearBackground(RAYWHITE::RayColor)::Cvoid

        @ccall raylib.BeginMode3D(camera::RayCamera3D)::Cvoid
        @ccall raylib.DrawCube(cubePosition::RayVector3, 2f0::Cfloat, 2f0::Cfloat, 2f0::Cfloat,
                               RED::RayColor)::RayColor
        
        @ccall raylib.DrawCubeWires(cubePosition::RayVector3, 2f0::Cfloat, 2f0::Cfloat, 2f0::Cfloat,
                                    MAROON::RayColor)::Cvoid

        @ccall raylib.DrawGrid(10::Cint, 1f0::Cfloat)::Cvoid

        @ccall raylib.EndMode3D()::Cvoid
        @ccall raylib.DrawText("Welcome to the third dimension!"::Cstring,
                               10::Cint, 40::Cint, 20::Cint, DARKGRAY::RayColor)::Cvoid
        @ccall raylib.EndDrawing()::Cvoid
    end

    @ccall raylib.CloseWindow()::Cvoid

end
