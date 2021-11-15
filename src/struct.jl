const RayVector2 = NTuple{2, Cfloat}
const RayVector3 = NTuple{3, Cfloat}
const RayVector4 = NTuple{4, Cfloat}
const RayQuaternion = RayVector4

rayvector(v::Vararg{<:Real, 2}) = RayVector2(v)
rayvector(v::Vararg{<:Real, 3}) = RayVector3(v)
rayvector(v::Vararg{<:Real, 4}) = RayVector4(v)

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

# struct Mesh
#     vertexCount::Cint        # Number of vertices stored in arrays
#     triangleCount::Cint      # Number of triangles stored (indexed or not)

#     # Vertex attributes data
#     float *vertices;        # Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
#     float *texcoords;       # Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
#     float *texcoords2;      # Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
#     float *normals;         # Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
#     float *tangents;        # Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
#     unsigned char *colors;      # Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
#     unsigned short *indices;    # Vertex indices (in case vertex data comes indexed)

#     # Animation vertex data
#     float *animVertices;    # Animated vertex positions (after bones transformations)
#     float *animNormals;     # Animated normals (after bones transformations)
#     unsigned char *boneIds; # Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning)
#     float *boneWeights;     # Vertex bone weight, up to 4 bones influence by vertex (skinning)

#     # OpenGL identifiers
#     unsigned int vaoId;     # OpenGL Vertex Array Object id
#     unsigned int *vboId;    # OpenGL Vertex Buffer Objects id (default vertex data)
# end

# struct Shader
