shader_type canvas_item;
uniform sampler2D mask_tex : hint_default_black;
uniform float darkness_amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float m = texture(mask_tex, SCREEN_UV).r;
    float a = 1.0 - clamp(m, 0.0, 1.0);
    a *= darkness_amount;
    COLOR = vec4(0.0, 0.0, 0.0, a);
}
