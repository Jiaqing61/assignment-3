shader_type canvas_item;
uniform sampler2D mask_tex : hint_default_black;
uniform float darkness_strength : hint_range(0.0, 1.0) = 0.99; 
uniform float ambient_light    : hint_range(0.0, 1.0) = 0.08; 

void fragment() {
    float m = texture(mask_tex, SCREEN_UV).r;
    m = pow(m, 1.4);

    float darkness = darkness_strength * (1.0 - clamp(m, 0.0, 1.0));

    float a = mix(ambient_light, 1.0, darkness);
    COLOR = vec4(vec3(0.0), a);
}
