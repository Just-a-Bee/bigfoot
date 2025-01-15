shader_type sky;
uniform vec3 col1 : source_color;
uniform vec3 col2 : source_color;
uniform vec3 col3 : source_color;
uniform vec3 sundir;
uniform sampler2D dither_texture;

uniform float exposure;
uniform float lightness;


float dither(vec2 coord, float scale) {
	ivec2 px = ivec2((1.0/scale)*coord);
	ivec2 dithertex_dim = textureSize(dither_texture,0);
	vec2 dthr_scaling = 1.0/vec2(dithertex_dim);

	return(texture(dither_texture,
	(mod(vec2(px)+vec2(.5,.5),vec2(dithertex_dim))*dthr_scaling)  ).r);
}

void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.

	    if (AT_CUBEMAP_PASS) {
        COLOR = vec3(0,0,0);
    } else {
		float lum = dot(EYEDIR,normalize(sundir))*exposure;
		lum += lightness;
		float dthr = dither(FRAGCOORD.xy, 1);
		bool choice1 = lum-dthr>.45;
		bool choice2 = lum-dthr>1.0;


		COLOR = col1;
		if(choice1)
		COLOR = col2;
		if(choice2)
		COLOR = col3;


    }

	//COLOR = vec3(1,1,1);
}
