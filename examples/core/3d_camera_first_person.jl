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
const BLUE = RayColor(0, 121, 241, 255 )
const LIME = RayColor(0, 158, 47, 255)
const GOLD = RayColor(255, 203, 0, 255)
const SKYBLUE = RayColor(102, 191, 255, 255)
const BLACK = RayColor(0, 0, 0, 255)


struct RayVector3
    x::Cfloat
    y::Cfloat
    z::Cfloat
end

struct RayVector2
    x::Cfloat
    y::Cfloat
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
                             "raylib [core] example - 3d camera first person"::Cstring)::Cvoid

    camera = Ref(RayCamera3D(
        RayVector3(4, 2, 4),
        RayVector3(0, 1.8, 0),
        RayVector3(0, 1, 0),
        60,
        0,
    ))

    heights = Vector{Cfloat}(undef, 20)
    positions = Vector{RayVector3}(undef, 20)
    colors = Vector{RayColor}(undef, 20)

    for i = 1:20
        heights[i] = @ccall raylib.GetRandomValue(1::Cint, 12::Cint)::Cint
        positions[i] = RayVector3(
            @ccall(raylib.GetRandomValue((-15)::Cint, 15::Cint)::Cint),
            heights[i] / 2,
            @ccall(raylib.GetRandomValue((-15)::Cint, 15::Cint)::Cint),
        )
        colors[i] = RayColor(
            @ccall( raylib.GetRandomValue(20::Cint, 255::Cint)::Cint),
            @ccall( raylib.GetRandomValue(10::Cint, 55::Cint)::Cint),
            30,
            255,
        )
    end

    @ccall raylib.SetCameraMode(camera[]::RayCamera3D, 3::Cint)::Cvoid
    @ccall raylib.SetTargetFPS(60::Cint)::Cvoid

    while iszero(@ccall raylib.WindowShouldClose()::Cint)
        @ccall raylib.UpdateCamera(camera::Ref{RayCamera3D})::Cvoid

        @ccall raylib.BeginDrawing()::Cvoid
        @ccall raylib.ClearBackground(RAYWHITE::RayColor)::Cvoid

        @ccall raylib.BeginMode3D(camera[]::RayCamera3D)::Cvoid

        @ccall raylib.DrawPlane(
            RayVector3(0,0,0)::RayVector3,
            RayVector2(32, 32)::RayVector2,
            LIGHTGRAY::RayColor)::Cvoid

        @ccall raylib.DrawCube(
            RayVector3(-16, 2.5, 0)::RayVector3, 1f0::Cfloat, 5f0::Cfloat, 32f0::Cfloat,
            BLUE::RayColor)::Cvoid
        @ccall raylib.DrawCube(
            RayVector3(16, 2.5, 0)::RayVector3, 1f0::Cfloat, 5f0::Cfloat, 32f0::Cfloat,
            LIME::RayColor)::Cvoid
        @ccall raylib.DrawCube(
            RayVector3(0, 2.5, 16)::RayVector3, 32f0::Cfloat, 5f0::Cfloat, 1f0::Cfloat,
            GOLD::RayColor)::Cvoid


        for i = 1:20
            @ccall raylib.DrawCube(
                positions[i]::RayVector3, 2f0::Cfloat, heights[i]::Cfloat, 2f0::Cfloat,
                colors[i]::RayColor)::Cvoid
            @ccall raylib.DrawCubeWires(positions[i]::RayVector3, 2f0::Cfloat, heights[i]::Cfloat, 2f0::Cfloat,
                                        MAROON::RayColor)::Cvoid

        end

        @ccall raylib.EndMode3D()::Cvoid

        @ccall raylib.DrawRectangle(10::Cint, 10::Cint, 220::Cint, 70::Cint,
                                    @ccall( raylib.Fade(SKYBLUE::RayColor, 0.5::Cfloat)::RayColor )::RayColor)::Cvoid
        @ccall raylib.DrawRectangleLines(10::Cint, 10::Cint, 220::Cint, 70::Cint, BLUE::RayColor)::Cvoid

        @ccall raylib.DrawText("First person camera default controls:"::Cstring,
                               20::Cint, 20::Cint, 10::Cint, BLACK::RayColor)::Cvoid
        @ccall raylib.DrawText("- Move with keys: W, A, S, D"::Cstring,
                               40::Cint, 40::Cint, 10::Cint, DARKGRAY::RayColor)::Cvoid
        @ccall raylib.DrawText("- Mouse move to look around"::Cstring,
                               40::Cint, 60::Cint, 10::Cint, DARKGRAY::RayColor)::Cvoid

        @ccall raylib.EndDrawing()::Cvoid
    end

    @ccall raylib.CloseWindow()::Cvoid

end
