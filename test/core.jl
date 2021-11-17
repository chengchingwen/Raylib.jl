function test_camera(camera::Raylib.RayCamera2D, ans::Vector)
    @test all([
        camera.offset == ans[1],
        camera.target == ans[2],
        camera.rotation == ans[3],
        camera.zoom == ans[4]
    ])
end

function test_camera(camera::Raylib.RayCamera3D, ans::Vector)
    @test all([
        camera.position == ans[1],
        camera.target == ans[2],
        camera.up == ans[3],
        camera.fovy == ans[4],
        camera.projection == ans[5]
    ])
end

@testset "core" begin
    camera = Raylib.RayCamera2D(
        Raylib.rayvector(1, 2), # camera offset
        Raylib.rayvector(3, 4), # camera position
        0, # camera rotation
        1, # camera zoom
    )
    test_camera(camera, [Raylib.rayvector(1, 2), Raylib.rayvector(3, 4), 0, 1])

    camera = Raylib.RayCamera3D(
        Raylib.rayvector(0, 10, 10), # camera position
        Raylib.rayvector(0, 0, 0), # camera looking at point
        Raylib.rayvector(0, 1, 0), # camera up vector (rotation towards target)
        45, # camera field-of-view Y
        Int(Raylib.CAMERA_PERSPECTIVE), # camera mode type
    )
    test_camera(camera, [
        Raylib.rayvector(0, 10, 10),
        Raylib.rayvector(0, 0, 0),
        Raylib.rayvector(0, 1, 0),
        45,
        Int(Raylib.CAMERA_PERSPECTIVE)
    ])

end
