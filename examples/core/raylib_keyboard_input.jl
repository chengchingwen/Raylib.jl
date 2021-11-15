using Raylib

const screenWidth = 800
const screenHeight = 450

function main()
    Raylib.InitWindow(
        screenWidth, screenHeight,
        "raylib [core] example - keyboard input"
    )

    ballPosition = Raylib.rayvector(screenWidth/2, screenHeight/2)

    Raylib.SetTargetFPS(60)
    while !Raylib.WindowShouldClose()    # Detect window close button or ESC key
        # update
        if Raylib.IsKeyDown(Int(Raylib.KEY_RIGHT))
            ballPosition = Raylib.rayvector(ballPosition[1]+2, ballPosition[2])
        elseif Raylib.IsKeyDown(Int(Raylib.KEY_LEFT))
            ballPosition = Raylib.rayvector(ballPosition[1]-2, ballPosition[2])
        elseif Raylib.IsKeyDown(Int(Raylib.KEY_UP))
            ballPosition = Raylib.rayvector(ballPosition[1], ballPosition[2]-2)
        elseif Raylib.IsKeyDown(Int(Raylib.KEY_DOWN))
            ballPosition = Raylib.rayvector(ballPosition[1], ballPosition[2]+2)
        end

        # draw
        Raylib.BeginDrawing()
        Raylib.ClearBackground(Raylib.RAYWHITE)
        Raylib.DrawText("move the ball with arrow keys", 10, 10, 20, Raylib.DARKGRAY)
        Raylib.DrawCircleV(ballPosition, 50, Raylib.MAROON)
        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()
end
