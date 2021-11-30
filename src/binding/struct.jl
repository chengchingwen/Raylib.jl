struct RayRectangle
    x::Cfloat        # Rectangle top-left corner position x
    y::Cfloat        # Rectangle top-left corner position y
    width::Cfloat    # Rectangle width
    height::Cfloat   # Rectangle height
end

struct RayImage
    data::Ptr{Cvoid}         # Image raw data
    width::Cint              # Image base width
    height::Cint             # Image base height
    mipmaps::Cint            # Mipmap levels, 1 by default
    format::Cint             # Data format (PixelFormat type)
end

struct RayTexture
    id::Cuint        # OpenGL texture id
    width::Cint      # Texture base width
    height::Cint     # Texture base height
    mipmaps::Cint    # Mipmap levels, 1 by default
    format::Cint     # Data format (PixelFormat type)
end

const RayTexture2D = RayTexture
const RayTextureCubemap = RayTexture

struct RayRenderTexture
    id::Cuint                # OpenGL framebuffer object id
    texture::RayTexture      # Color buffer attachment texture
    depth::RayTexture        # Depth buffer attachment texture
end

const RayRenderTexture2D = RayRenderTexture

struct RayNPatchInfo
    source::RayRectangle     # Texture source rectangle
    left::Cint               # Left border offset
    top::Cint                # Top border offset
    right::Cint              # Right border offset
    bottom::Cint             # Bottom border offset
    layout::Cint             # Layout of the n-patch: 3x3, 1x3 or 3x1
end

struct RayGlyphInfo
   value::Cint              # Character value (Unicode)
   offsetX::Cint            # Character offset X when drawing
   offsetY::Cint            # Character offset Y when drawing
   advanceX::Cint           # Character advance position X
   image::RayImage          # Character image data
end

struct RayFont
    baseSize::Cint                 # Base size (default chars height)
    glyphCount::Cint               # Number of glyph characters
    glyphPadding::Cint             # Padding around the glyph characters
    texture::RayTexture            # Texture atlas containing the glyphs
    recs::Ptr{RayRectangle}        # Rectangles in texture for the glyphs
    glyphs::Ptr{RayGlyphInfo}      # Glyphs info data
end

struct RayMesh
    vertexCount::Cint        # Number of vertices stored in arrays
    triangleCount::Cint      # Number of triangles stored (indexed or not)

    # Vertex attributes data
    vertices::Ptr{Cfloat}        # Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords::Ptr{Cfloat}       # Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    texcoords2::Ptr{Cfloat}      # Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
    normals::Ptr{Cfloat}         # Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    tangents::Ptr{Cfloat}        # Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    colors::Ptr{Cuchar}          # Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices::Ptr{Cuchar}         # Vertex indices (in case vertex data comes indexed)

    # Animation vertex data
    animVertices::Ptr{Cfloat}    # Animated vertex positions (after bones transformations)
    animNormals::Ptr{Cfloat}     # Animated normals (after bones transformations)
    boneIds::Ptr{Cuchar}         # Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning)
    boneWeights::Ptr{Cfloat}     # Vertex bone weight, up to 4 bones influence by vertex (skinning)

    # OpenGL identifiers
    vaoId::Cuint                 # OpenGL Vertex Array Object id
    vboId::Ptr{Cuint}            # OpenGL Vertex Buffer Objects id (default vertex data)
end

struct RayShader
    id::Cuint                    # Shader program id
    locs::Ptr{Cint}              # Shader locations array (RL_MAX_SHADER_LOCATIONS)
end

struct RayMaterialMap
    texture::RayTexture        # Material map texture
    color::RayColor            # Material map color
    value::Cfloat              # Material map value
end

struct RayMaterial
    shader::RayShader                # Material shader
    maps::Ptr{RayMaterialMap}        # Material maps array (MAX_MATERIAL_MAPS)
    params::NTuple{4, Cfloat}        # Material generic parameters (if required)
end

struct RayTransform
    translation::RayVector3     # Translation
    rotation::RayQuaternion     # Rotation
    scale::RayVector3           # Scale
end

struct RayBoneInfo
    name::NTuple{32, Cchar}          # Bone name
    parent::Cint                     # Bone parent
end

struct RayModel
    transform::RayMatrix              # Local transform matrix

    meshCount::Cint                   # Number of meshes
    materialCount::Cint               # Number of materials
    meshes::Ptr{RayMesh}              # Meshes array
    materials::Ptr{RayMaterial}       # Materials array
    meshMaterial::Ptr{Cint}           # Mesh material number

    # Animation data
    boneCount::Cint                   # Number of bones
    bones::Ptr{RayBoneInfo}           # Bones information (skeleton)
    bindPose::Ptr{RayTransform}       # Bones base transformation (pose)
end

struct RayModelAnimation
    boneCount::Cint                # Number of bones
    frameCount::Cint               # Number of animation frames
    bones::Ptr{RayBoneInfo}        # Bones information (skeleton)
    # Transform **framePoses        # Poses array by frame
    framePoses::Ptr{Ptr{RayTransform}}        # Poses array by frame
end

struct Ray
    position::RayVector3        # Ray position (origin)
    direction::RayVector3       # Ray direction
end

struct RayCollision
    hit::Bool                  # Did the ray hit something?
    distance::Cfloat           # Distance to nearest hit
    point::RayVector3          # Point of nearest hit
    normal::RayVector3         # Surface normal of hit
end

struct RayBoundingBox
    min::RayVector3     # Minimum vertex box-corner
    max::RayVector3     # Maximum vertex box-corner
end

struct RayWave
    frameCount::Cuint      # Total number of frames (considering channels)
    sampleRate::Cuint      # Frequency (samples per second)
    sampleSize::Cuint      # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels::Cuint        # Number of channels (1-mono, 2-stereo, ...)
    data::Ptr{Cvoid}       # Buffer data pointer
end

struct RayAudioStream
    # rAudioBuffer *buffer;       // Pointer to internal data used by the audio system
    buffer::Ptr{Cvoid}

    sampleRate::Cuint    # Frequency (samples per second)
    sampleSize::Cuint    # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels::Cuint      # Number of channels (1-mono, 2-stereo, ...)
end

struct RaySound
    stream::RayAudioStream         # Audio stream
    frameCount::Cuint              # Total number of frames (considering channels)
end

struct RayMusic
    stream::RayAudioStream        # Audio stream
    frameCount::Cuint             # Total number of frames (considering channels)
    looping::Bool                 # Music looping enable

    ctxType::Cint                 # Type of music context (audio filetype)
    ctxData::Ptr{Cvoid}           # Audio context data, depends on type
end

struct RayVrDeviceInfo
    hResolution::Cint                        # Horizontal resolution in pixels
    vResolution::Cint                        # Vertical resolution in pixels
    hScreenSize::Cfloat                      # Horizontal size in meters
    vScreenSize::Cfloat                      # Vertical size in meters
    vScreenCenter::Cfloat                    # Screen center in meters
    eyeToScreenDistance::Cfloat              # Distance between eye and display in meters
    lensSeparationDistance::Cfloat           # Lens separation distance in meters
    interpupillaryDistance::Cfloat           # IPD (distance between pupils) in meters
    lensDistortionValues::NTuple{4, Cfloat}  # Lens distortion constant parameters
    chromaAbCorrection::NTuple{4, Cfloat}    # Chromatic aberration correction parameters
end

struct RayVrStereoConfig
    projection::NTuple{2, RayMatrix}           # VR projection matrices (per eye)
    viewOffset::NTuple{2, RayMatrix}           # VR view offset matrices (per eye)
    leftLensCenter::NTuple{2, Cfloat}          # VR left lens center
    rightLensCenter::NTuple{2, Cfloat}         # VR right lens center
    leftScreenCenter::NTuple{2, Cfloat}        # VR left screen center
    rightScreenCenter::NTuple{2, Cfloat}       # VR right screen center
    scale::NTuple{2, Cfloat}                   # VR distortion scale
    scaleIn::NTuple{2, Cfloat}                 # VR distortion scale in
end

struct RayGuiStyleProp
    controlId::Cushort
    propertyId::Cushort
    propertyValue::Cint
end

const PHYSAC_MAX_VERTICES = 24

struct RayPhysicsVertexData
    vertexCount::Cuint                                 # Vertex count (positions and normals)
    positions::NTuple{PHYSAC_MAX_VERTICES, RayVector2} # Vertex positions vectors
    normals::NTuple{PHYSAC_MAX_VERTICES, RayVector2}   # Vertex normals vectors
end

struct RayPhysicsShape
    type::PhysicsShapeType                      # Shape type (circle or polygon)
    # body::Ptr{RayPhysicsBodyData}
    body::Ptr{Cvoid}                            # Shape physics body data pointer
    vertexData::RayPhysicsVertexData            # Shape vertices data (used for polygon shapes)
    radius::Cfloat                              # Shape radius (used for circle shapes)
    transform::RayMatrix2x2                     # Vertices transform matrix 2x2
end

struct RayPhysicsBodyData
    id::Cuint                            # Unique identifier
    enabled::Bool                        # Enabled dynamics state (collisions are calculated anyway)
    position::RayVector2                 # Physics body shape pivot
    velocity::RayVector2                 # Current linear velocity applied to position
    force::RayVector2                    # Current linear force (reset to 0 every step)
    angularVelocity::Cfloat              # Current angular velocity applied to orient
    torque::Cfloat                       # Current angular force (reset to 0 every step)
    orient::Cfloat                       # Rotation in radians
    inertia::Cfloat                      # Moment of inertia
    inverseInertia::Cfloat               # Inverse value of inertia
    mass::Cfloat                         # Physics body mass
    inverseMass::Cfloat                  # Inverse value of mass
    staticFriction::Cfloat               # Friction when the body has not movement (0 to 1)
    dynamicFriction::Cfloat              # Friction when the body has movement (0 to 1)
    restitution::Cfloat                  # Restitution coefficient of the body (0 to 1)
    useGravity::Bool                     # Apply gravity force to dynamics
    isGrounded::Bool                     # Physics grounded on other body state
    freezeOrient::Bool                   # Physics rotation constraint
    shape::RayPhysicsShape               # Physics body shape information (type, radius, vertices, transform)
end

struct RayPhysicsManifoldData
    id::Cuint                            # Unique identifier
    bodyA::Ptr{RayPhysicsBodyData}       # Manifold first physics body reference
    bodyB::Ptr{RayPhysicsBodyData}       # Manifold second physics body reference
    penetration::Cfloat                  # Depth of penetration from collision
    normal::RayVector2                   # Normal direction vector from 'a' to 'b'
    contacts::NTuple{2, RayVector2}      # Points of contact during collision
    contactsCount::Cuint                 # Current collision number of contacts
    restitution::Cfloat                  # Mixed restitution during collision
    dynamicFriction::Cfloat              # Mixed dynamic friction during collision
    staticFriction::Cfloat               # Mixed static friction during collision
end
