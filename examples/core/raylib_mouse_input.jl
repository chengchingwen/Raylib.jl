using Raylib

const screenWidth = 800
const screenHeight = 450

function main()
    Raylib.InitWindow(
        screenWidth, screenHeight,
        "raylib [core] example - keyboard input"
    )

    ballColor = Raylib.DARKBLUE

    Raylib.SetTargetFPS(60)
    while !Raylib.WindowShouldClose()    # Detect window close button or ESC key
        ballPosition = Raylib.GetMousePosition()

        # update
        if Raylib.IsMouseButtonPressed(Int(Raylib.MOUSE_BUTTON_LEFT))
            ballColor = Raylib.MAROON
        elseif Raylib.IsMouseButtonPressed(Int(Raylib.MOUSE_BUTTON_MIDDLE))
            ballColor = Raylib.LIME
        elseif Raylib.IsMouseButtonPressed(Int(Raylib.MOUSE_BUTTON_RIGHT))
            ballColor = Raylib.DARKBLUE
        elseif Raylib.IsMouseButtonPressed(Int(Raylib.MOUSE_BUTTON_SIDE))
            ballColor = Raylib.PURPLE
        elseif Raylib.IsMouseButtonPressed(Int(Raylib.MOUSE_BUTTON_EXTRA))
            ballColor = Raylib.YELLOW
        elseif Raylib.IsMouseButtonPressed(Int(Raylib.MOUSE_BUTTON_FORWARD))
            ballColor = Raylib.ORANGE
        elseif Raylib.IsMouseButtonPressed(Int(Raylib.MOUSE_BUTTON_BACK))
            ballColor = Raylib.BEIGE
        end

        # draw
        Raylib.BeginDrawing()
        Raylib.ClearBackground(Raylib.RAYWHITE)
        Raylib.DrawText("move the ball with arrow keys", 10, 10, 20, Raylib.DARKGRAY)
        Raylib.DrawCircleV(ballPosition, 50, ballColor)
        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()
end
