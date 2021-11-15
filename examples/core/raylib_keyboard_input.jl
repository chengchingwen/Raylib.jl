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
    while iszero(Raylib.WindowShouldClose())    # Detect window close button or ESC key
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

#=
/*******************************************************************************************
*
*   raylib [core] example - Keyboard input
*
*   This example has been created using raylib 1.0 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Copyright (c) 2014 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

#include "raylib.h"

int main(void)
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard input");

    Vector2 ballPosition = { (float)screenWidth/2, (float)screenHeight/2 };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(KEY_RIGHT)) ballPosition.x += 2.0f;
        if (IsKeyDown(KEY_LEFT)) ballPosition.x -= 2.0f;
        if (IsKeyDown(KEY_UP)) ballPosition.y -= 2.0f;
        if (IsKeyDown(KEY_DOWN)) ballPosition.y += 2.0f;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText("move the ball with arrow keys", 10, 10, 20, DARKGRAY);

            DrawCircleV(ballPosition, 50, MAROON);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    return 0;
}
=#
