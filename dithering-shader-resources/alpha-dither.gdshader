shader_type spatial;
render_mode unshaded;

uniform sampler2D dither_texture;
uniform float col_dither_scale : hint_range(1.0, 15.0, 1.0);
uniform float alpha_dither_scale : hint_range(1.0, 15.0, 1.0);

uniform sampler2D alpha_map;
uniform sampler2D col_map;
uniform sampler2D normal_map;

uniform vec3 shadow_col : source_color;
uniform vec3 base_col : source_color;
uniform vec3 highlight_col : source_color;

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


	//float weight = float( (px.x%2 * px.y%2) + ((px.x+1)%2 * (px.y+1)%2) );

	//vec2 pre  = .25*mod(vec2(px),4)-mod(vec2(px)+vec2(2,2),4);
	//vec2 pre2 = mod(vec2(px),2)-mod(vec2(px)+vec2(1,1),2);

	//float weight = float (pre2.x * pre2.y) - (.5*(pre.x * pre.y));
	//weight = .5*(pre2.x*pre2.y) + .5*(pre.x * pre.y);
	//weight *= 1.0;


	//COLOR.a -= .2 * weight;
	//COLOR.a = float(COLOR.a > .5);
	//COLOR.a = step(COLOR.a,weight);

	float alpha_weight = dither(FRAGCOORD.xy, alpha_dither_scale);
	if((texture(alpha_map,UV).x-alpha_weight)<0.0) discard;

	float col_weight = dither(FRAGCOORD.xy, col_dither_scale);



	float lum = .5*(1.0+dot(NORMAL, normalize(light_dir)));
	lum -= col_weight;



	if (lum < shadow_thresh) ALBEDO = shadow_col;
	//else if (lum > highlight_thresh) ALBEDO = highlight_col;
	else ALBEDO = base_col;


	//ALBEDO = vec3(alpha_weight,alpha_weight,alpha_weight);
	//ALBEDO = vec3(lum,lum,lum);

	//COLOR.a = weight;
	//COLOR.xy = ;

	//float n = dither(FRAGCOORD.xy,2);

	//ALBEDO = vec3(n,n,n);


}
