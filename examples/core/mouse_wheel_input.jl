using Raylib

const screenWidth = 800
const screenHeight = 450

function main()
    Raylib.InitWindow(
        screenWidth, screenHeight,
        "raylib [core] example - input mouse wheel"
    )

    boxPositionY = floor(Int, screenHeight/2) - 40
    scrollSpeed = 4 # Scrolling speed in pixels

    Raylib.SetTargetFPS(60)
    while !Raylib.WindowShouldClose()    # Detect window close button or ESC key
        # Update
        boxPositionY -= Int(Raylib.GetMouseWheelMove() * scrollSpeed)

        # Draw
        Raylib.BeginDrawing()
        Raylib.ClearBackground(Raylib.RAYWHITE);
        Raylib.DrawRectangle(floor(Int, screenWidth/2) - 40, boxPositionY, 80, 80, Raylib.MAROON)
        Raylib.DrawText("Use mouse wheel to move the cube up and down!", 10, 10, 20, Raylib.GRAY)
        Raylib.DrawText("Box position Y: $boxPositionY", 10, 40, 20, Raylib.LIGHTGRAY)
        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()
end
