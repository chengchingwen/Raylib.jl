using Raylib

const screenWidth = 800
const screenHeight = 450

function main()
    Raylib.InitWindow(
        screenWidth, screenHeight,
        "raylib [core] example - 3d camera free"
    )

    # Define the camera to look into our 3d world
    camera = Raylib.RayCamera3D(
        Raylib.rayvector(0, 10, 10),   # Camera position
        Raylib.rayvector(0, 0, 0), # Camera looking at point
        Raylib.rayvector(0, 1, 0), # Camera up vector (rotation towards target)
        45, # Camera field-of-view Y
        Int(Raylib.CAMERA_PERSPECTIVE), # Camera mode type
    )

    cubePosition = Raylib.rayvector(0, 0, 0)

    Raylib.SetCameraMode(camera, Int(Raylib.CAMERA_FREE))   # Set a free camera mode

    Raylib.SetTargetFPS(60)
    while !Raylib.WindowShouldClose()   # Detect window close button or ESC key
        # Update
        camera = Raylib.UpdateCamera(camera)    # Update camera
        Raylib.IsKeyDown(Int('Z')) && (camera = Raylib.RayCamera3D(
            camera.position,
            Raylib.rayvector(0, 0, 0),
            camera.up,
            camera.fovy,
            camera.projection
        ))

        # Draw
        Raylib.BeginDrawing()
        Raylib.ClearBackground(Raylib.RAYWHITE)

        Raylib.BeginMode3D(camera)
        Raylib.DrawCube(cubePosition, 2f0, 2f0, 2f0, Raylib.RED)

        Raylib.DrawCubeWires(cubePosition, 2f0, 2f0, 2f0, Raylib.MAROON)

        Raylib.DrawGrid(10, 1f0)

        Raylib.EndMode3D()

        Raylib.DrawRectangle(10, 10, 320, 133, Raylib.Fade(Raylib.SKYBLUE, 0.5))
        Raylib.DrawRectangleLines(10, 10, 320, 133, Raylib.BLUE)

        Raylib.DrawText("Free camera default controls:", 20, 20, 10, Raylib.BLACK)
        Raylib.DrawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, Raylib.DARKGRAY)
        Raylib.DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, Raylib.DARKGRAY)
        Raylib.DrawText("- Alt + Mouse Wheel Pressed to Rotate", 40, 80, 10, Raylib.DARKGRAY)
        Raylib.DrawText("- Alt + Ctrl + Mouse Wheel Pressed for Smooth Zoom", 40, 100, 10, Raylib.DARKGRAY)
        Raylib.DrawText("- Z to zoom to (0, 0, 0)", 40, 120, 10, Raylib.DARKGRAY)

        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()
end
