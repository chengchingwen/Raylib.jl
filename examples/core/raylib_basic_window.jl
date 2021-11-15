using Raylib

function main()

    screenWidth = 800
    screenHeight = 450

    Raylib.InitWindow(screenWidth, screenHeight,
                         "raylib [core] example - basic window")

    Raylib.SetTargetFPS(60)

    while !Raylib.WindowShouldClose()
        Raylib.BeginDrawing()
        Raylib.ClearBackground(Raylib.RAYWHITE)
        Raylib.DrawText("Congrats! You created your first window!",
                           190, 200, 20, Raylib.LIGHTGRAY)
        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()
end
