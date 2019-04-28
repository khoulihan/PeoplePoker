shader_type canvas_item;

uniform int skin_type : hint_range(0, 2);

uniform vec4 main_color_0 : hint_color;
uniform vec4 main_color_1 : hint_color;
uniform vec4 main_color_2 : hint_color;

uniform vec4 shadow_color_0 : hint_color;
uniform vec4 shadow_color_1 : hint_color;
uniform vec4 shadow_color_2 : hint_color;

uniform vec4 dark_shadow_color_0 : hint_color;
uniform vec4 dark_shadow_color_1 : hint_color;
uniform vec4 dark_shadow_color_2 : hint_color;

uniform vec4 highlight_color_0 : hint_color;
uniform vec4 highlight_color_1 : hint_color;
uniform vec4 highlight_color_2 : hint_color;

uniform float threshold : hint_range(0.0, 1.0) = 0.01;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (skin_type != 0) {
		if (length(tex.rgb - main_color_0.rgb) < threshold) {
			if (skin_type == 1) {
				tex.rgb = main_color_1.rgb;
			} else {
				tex.rgb = main_color_2.rgb;
			}
		} else if (length(tex.rgb - shadow_color_0.rgb) < threshold) {
			if (skin_type == 1) {
				tex.rgb = shadow_color_1.rgb;
			} else {
				tex.rgb = shadow_color_2.rgb;
			}
		} else if (length(tex.rgb - dark_shadow_color_0.rgb) < threshold) {
			if (skin_type == 1) {
				tex.rgb = dark_shadow_color_1.rgb;
			} else {
				tex.rgb = dark_shadow_color_2.rgb;
			}
		} else if (length(tex.rgb - highlight_color_0.rgb) < threshold) {
			if (skin_type == 1) {
				tex.rgb = highlight_color_1.rgb;
			} else {
				tex.rgb = highlight_color_2.rgb;
			}
		}
	}
	COLOR = tex;
}