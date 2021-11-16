using Raylib_jll

struct RayColor
    r::Cuchar
    g::Cuchar
    b::Cuchar
    a::Cuchar
end

const RAYWHITE = RayColor(245, 245, 245, 255)
const LIGHTGRAY = RayColor(200, 200, 200, 255)

function main()

    screenWidth = 800
    screenHeight = 450

    @ccall libraylib.InitWindow(screenWidth::Cint, screenHeight::Cint,
                             "raylib [core] example - basic window"::Cstring)::Cvoid

    @ccall libraylib.SetTargetFPS(60::Cint)::Cvoid

    while iszero(@ccall libraylib.WindowShouldClose()::Cint)
        @ccall libraylib.BeginDrawing()::Cvoid
        @ccall libraylib.ClearBackground(RAYWHITE::RayColor)::Cvoid
        @ccall libraylib.DrawText("Congrats! You created your first window!"::Cstring,
                               190::Cint, 200::Cint, 20::Cint, LIGHTGRAY::RayColor)::Cvoid
        @ccall libraylib.EndDrawing()::Cvoid
    end

    @ccall libraylib.CloseWindow()::Cvoid
end
