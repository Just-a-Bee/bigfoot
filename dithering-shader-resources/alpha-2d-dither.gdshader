shader_type canvas_item;

uniform sampler2D dither_texture;

float dither(vec2 coord, float scale) {
	ivec2 px = ivec2((1.0/scale)*coord);
	ivec2 dithertex_dim = textureSize(dither_texture,0);
	vec2 dthr_scaling = 1.0/vec2(dithertex_dim);

	return(texture(dither_texture,
	(mod(vec2(px)+vec2(.5,.5),vec2(dithertex_dim))*dthr_scaling)  ).r);

}
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {

	float weight = dither(FRAGCOORD.xy, 1);
	if (!(weight > COLOR.r+.5))
		discard;

	COLOR = vec4(0,0,0,1.0);

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
