#version 150

#moj_import <light.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;

// This calculates the exact light values for block sides, like in minecraft.
// Dividing Color by this gets rid of block light, leaving out only the AO part (+ other stuff, like color)
vec4 getMCBlockLighting() {
	// Same as in minecraft, excluding the AO. Deduces from normal and minecraft hardcoded values.
	vec4 myVertexColor = vec4(1.0);
	vec3 absNormal = abs(Normal.xyz);

	// Optimization to this could be done, but idk man. We can consider these as 4 bits, and use a LUT or something. LUT would give us index in another LUT and this index will point to light intensity. Or, first LUT could point straight to the color. Why use two luts? So, 4 bits is 2^4 = 16 possible variations, however, we only use 1, 2, 4, and 8 numbers. So, in reality we use only 4 possible variations.

	// We can ignore the top side.
	/*
	// Top
	if (Normal.y > Normal.z && Normal.y > Normal.x) {
		myVertexColor.xyz = vec3(1.0);
	}
	*/

	// Bottom
	if (Normal.y < Normal.z && Normal.y < Normal.x) {
		myVertexColor.xyz = vec3(127.0 / 255.0);
	}

	// East-west
	if (absNormal.x > absNormal.z && absNormal.x > absNormal.y) {
		myVertexColor.xyz = vec3(153.0 / 255.0);
	}

	// North-south
	if (absNormal.z > absNormal.x && absNormal.z > absNormal.y) {
		myVertexColor.xyz = vec3(204.0 / 255.0);
	}

	//vec4 onlyAOVertexColor = vertexColor / myVertexColor; // So, basically, this gets rid of hardcoded "direct lighting", leaving out only the AO part.
	return myVertexColor;
}


void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position + ChunkOffset, 1.0);

    vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2) / getMCBlockLighting();
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
