using raylib_jll

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

    @ccall raylib.InitWindow(screenWidth::Cint, screenHeight::Cint,
                             "raylib [core] example - basic window"::Cstring)::Cvoid

    @ccall raylib.SetTargetFPS(60::Cint)::Cvoid

    while iszero(@ccall raylib.WindowShouldClose()::Cint)
        @ccall raylib.BeginDrawing()::Cvoid
        @ccall raylib.ClearBackground(RAYWHITE::RayColor)::Cvoid
        @ccall raylib.DrawText("Congrats! You created your first window!"::Cstring,
                               190::Cint, 200::Cint, 20::Cint, LIGHTGRAY::RayColor)::Cvoid
        @ccall raylib.EndDrawing()::Cvoid
    end

    @ccall raylib.CloseWindow()::Cvoid
end
