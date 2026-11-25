shader_type canvas_item;

uniform float corner_radius : hint_range(0.0, 0.5) = 0.12;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    vec2 size = vec2(0.5) - vec2(corner_radius);
    vec2 d = abs(uv) - size;
    float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - corner_radius;
    
    vec4 tex_color = texture(TEXTURE, UV);
    float alpha = 1.0 - smoothstep(-0.005, 0.005, dist);
    COLOR = vec4(tex_color.rgb, tex_color.a * alpha);
}