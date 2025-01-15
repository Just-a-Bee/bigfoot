shader_type canvas_item;

uniform sampler2D dither_texture;

void vertex() {
}


float dither(vec2 coord, float scale) {
	ivec2 px = ivec2((1.0/scale)*coord);
	ivec2 dithertex_dim = textureSize(dither_texture,0);
	vec2 dthr_scaling = 1.0/vec2(dithertex_dim);

	return(texture(dither_texture,
	(mod(vec2(px)+vec2(.5,.5),vec2(dithertex_dim))*dthr_scaling)  ).r);

}


void fragment() {

	float weight = dither(FRAGCOORD.xy, 1);
	float lum = 1.0;
	if (weight > COLOR.r)
		lum = 0.0;

	COLOR = vec4(lum,lum,lum,1.0);

}
