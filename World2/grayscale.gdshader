shader_type canvas_item;

uniform float grayscale_strength : hint_range(0.0, 1.0) = 0.8;
uniform float contrast : hint_range(0.5, 2.0) = 1.1;
uniform float brightness : hint_range(-0.5, 0.5) = -0.1;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Calculate grayscale value
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

    // Mix between original color and grayscale
    vec3 mixed_color = mix(tex_color.rgb, vec3(gray), grayscale_strength);

    // Apply brightness adjustment
    mixed_color = mixed_color + vec3(brightness);

    // Apply contrast adjustment
    mixed_color = (mixed_color - 0.5) * contrast + 0.5;

    // Clamp values to valid range
    mixed_color = clamp(mixed_color, 0.0, 1.0);

    COLOR = vec4(mixed_color, tex_color.a);
}