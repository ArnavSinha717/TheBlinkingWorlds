shader_type canvas_item;

// Grayscale effect with customizable parameters
uniform float grayscale_amount : hint_range(0.0, 1.0) = 0.75;
uniform float saturation : hint_range(0.0, 2.0) = 0.25;
uniform float brightness : hint_range(-1.0, 1.0) = -0.05;
uniform float contrast : hint_range(0.0, 3.0) = 1.15;
uniform vec4 tint_color : source_color = vec4(0.9, 0.9, 1.0, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Convert to grayscale using luminance formula
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

    // Mix between original and grayscale based on grayscale_amount
    vec3 color = mix(tex.rgb, vec3(gray), grayscale_amount);

    // Apply saturation adjustment
    vec3 gray_vec = vec3(gray);
    color = mix(gray_vec, color, saturation);

    // Apply brightness
    color += brightness;

    // Apply contrast
    color = (color - 0.5) * contrast + 0.5;

    // Apply subtle tint
    color = mix(color, tint_color.rgb * gray, tint_strength);

    // Clamp to valid range
    color = clamp(color, 0.0, 1.0);

    COLOR = vec4(color, tex.a);
}