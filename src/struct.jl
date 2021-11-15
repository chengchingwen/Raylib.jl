const RayVector2 = NTuple{2, Cfloat}
const RayVector3 = NTuple{3, Cfloat}
const RayVector4 = NTuple{4, Cfloat}
const RayQuaternion = RayVector4

rayvector(v::Vararg{<:Real, 2}) = RayVector2(v)
rayvector(v::Vararg{<:Real, 3}) = RayVector3(v)
rayvector(v::Vararg{<:Real, 4}) = RayVector4(v)

const RayMatrix = NTuple{16, Cfloat}

struct RayCamera3D
    position::RayVector3  # Camera position
    target::RayVector3    # Camera target it looks-at
    up::RayVector3        # Camera up vector (rotation over its axis)
    fovy::Cfloat          # Camera field-of-view apperture in Y (degrees) in perspective,
                          #   used as near plane width in orthographic
    projection::Cint      # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
end

struct RayCamera2D
    offset::RayVector2  # Camera offset (displacement from target)
    target::RayVector2  # Camera target (rotation and zoom origin)
    rotation::Cfloat    # Camera rotation in degrees
    zoom::Cfloat        # Camera zoom (scaling), should be 1.0f by default
end

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

struct RayRenderTexture
    id::Cuint                # OpenGL framebuffer object id
    texture::RayTexture      # Color buffer attachment texture
    depth::RayTexture        # Depth buffer attachment texture
end

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
