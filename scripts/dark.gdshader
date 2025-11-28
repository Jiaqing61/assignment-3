shader_type canvas_item;

uniform sampler2D mask_tex : hint_default_black;

uniform float darkness_strength : hint_range(0.0, 1.0) = 0.85;
uniform float ambient_light     : hint_range(0.0, 1.0) = 0.10;
uniform float brightness_curve  : hint_range(0.5, 3.0) = 1.4;

uniform float darkness_amount   : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float m = texture(mask_tex, SCREEN_UV).r;
    m = pow(m, brightness_curve);

    float strength = darkness_strength * darkness_amount;
    float darkness = strength * (1.0 - clamp(m, 0.0, 1.0));

    float a = mix(ambient_light, 1.0, darkness);
    COLOR = vec4(vec3(0.0), a);
}
