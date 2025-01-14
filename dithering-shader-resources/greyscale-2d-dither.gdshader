shader_type canvas_item;

uniform sampler2D dither_texture;




uniform float col_dither_scale : hint_range(1.0, 15.0, 1.0);
uniform float alpha_dither_scale : hint_range(1.0, 15.0, 1.0);

uniform sampler2D alpha_map;
uniform sampler2D col_map;
uniform sampler2D normal_map;

uniform vec3 shadow_col : source_color;
uniform vec3 base_col : source_color;
uniform vec3 highlight_col : source_color;

uniform float exposure;
uniform float lighten;
uniform float alpha_thresh : hint_range(0.0, 1.0, 0.02);
uniform float shadow_thresh : hint_range(0.0, 1.0, 0.02);
uniform float highlight_thresh : hint_range(0.0, 1.0, 0.02);
uniform vec3 light_dir;


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
