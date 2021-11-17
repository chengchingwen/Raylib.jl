function test_camera(camera::Raylib.RayCamera2D, ans::Vector)
    return all([
        camera.offset == ans[1],
        camera.target == ans[2],
        camera.rotation == ans[3],
        camera.zoom == ans[4]
    ])
end

function test_camera(camera::Raylib.RayCamera3D, ans::Vector)
    return all([
        camera.position == ans[1],
        camera.target == ans[2],
        camera.up == ans[3],
        camera.fovy == ans[4],
        camera.projection == ans[5]
    ])
end

@testset "set camera properties" begin
    camera = Raylib.RayCamera2D(
        Raylib.rayvector(1, 2), # camera offset
        Raylib.rayvector(3, 4), # camera target
        0, # camera rotation
        1, # camera zoom
    )
    @test test_camera(camera, [
        Raylib.rayvector(1, 2),
        Raylib.rayvector(3, 4),
        0,
        1
    ])

    camera.offset += Raylib.rayvector(5, 6)
    camera.target += Raylib.rayvector(7, 8)
    camera.rotation = 45
    camera.zoom = 3
    @test test_camera(camera, [
        Raylib.rayvector(1, 2) + Raylib.rayvector(5, 6),
        Raylib.rayvector(3, 4) + Raylib.rayvector(7, 8),
        45,
        3
    ])

    camera = Raylib.RayCamera3D(
        Raylib.rayvector(0, 10, 10), # camera position
        Raylib.rayvector(0, 0, 0), # camera looking at point
        Raylib.rayvector(0, 1, 0), # camera up vector (rotation towards target)
        45, # camera field-of-view Y
        Raylib.CAMERA_PERSPECTIVE, # camera mode type
    )
    @test test_camera(camera, [
        Raylib.rayvector(0, 10, 10),
        Raylib.rayvector(0, 0, 0),
        Raylib.rayvector(0, 1, 0),
        45,
        Raylib.CAMERA_PERSPECTIVE
    ])

    camera.position += Raylib.rayvector(1, 2, 3)
    camera.target += Raylib.rayvector(3, 2, 1)
    camera.up += Raylib.rayvector(4, 5, 6)
    camera.fovy = 60
    camera.projection = Raylib.CAMERA_ORTHOGRAPHIC
    @test test_camera(camera, [
        Raylib.rayvector(0, 10, 10) + Raylib.rayvector(1, 2, 3),
        Raylib.rayvector(0, 0, 0) + Raylib.rayvector(3, 2, 1),
        Raylib.rayvector(0, 1, 0) + Raylib.rayvector(4, 5, 6),
        60,
        Raylib.CAMERA_ORTHOGRAPHIC
    ])

    Raylib.SetCameraMode(camera, Int(Raylib.CAMERA_FIRST_PERSON))
    Raylib.UpdateCamera!(camera)
    @test !test_camera(camera, [
        Raylib.rayvector(0, 10, 10) + Raylib.rayvector(1, 2, 3),
        Raylib.rayvector(0, 0, 0) + Raylib.rayvector(3, 2, 1),
        Raylib.rayvector(0, 1, 0) + Raylib.rayvector(4, 5, 6),
        60,
        Raylib.CAMERA_ORTHOGRAPHIC
    ])

    Raylib.SetCameraMode(camera, Int(Raylib.CAMERA_CUSTOM))
    Raylib.UpdateCamera!(camera)
    camera.position = Raylib.rayvector(1, 2, 3)
    camera.target = Raylib.rayvector(3, 2, 1)
    camera.up = Raylib.rayvector(4, 5, 6)
    camera.fovy = 60
    camera.projection = Raylib.CAMERA_ORTHOGRAPHIC
    @test test_camera(camera, [
        Raylib.rayvector(1, 2, 3),
        Raylib.rayvector(3, 2, 1),
        Raylib.rayvector(4, 5, 6),
        60,
        Raylib.CAMERA_ORTHOGRAPHIC
    ])
end
