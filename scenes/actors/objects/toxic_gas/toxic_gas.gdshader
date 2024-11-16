shader_type canvas_item;

uniform sampler2D base_texture : hint_albedo;
uniform sampler2D opacity_texture;
uniform sampler2D dissolve_texture;

// UV control for base texture
uniform vec2 base_uv_speed = vec2(0.0, 0.0);
uniform vec2 base_uv_scale = vec2(1.0, 1.0);

// UV control for opacity texture
uniform vec2 opacity_uv_speed = vec2(0.0, 0.0);
uniform vec2 opacity_uv_scale = vec2(1.0, 1.0);

// UV control for dissolve texture
uniform vec2 dissolve_uv_scale = vec2(1.0, 1.0);
uniform float dissolve_uv_speed = 0.5; // Controls radial speed

// Dissolve effect
uniform float dissolve_threshold = 0.5;
uniform float edge_threshold = 0.1; // Controls edge thickness

void fragment() {
    // Base texture UVs
    vec2 base_uv = UV * base_uv_scale + TIME * base_uv_speed;
    vec4 base_color = texture(base_texture, base_uv);

    // Opacity texture UVs
    vec2 opacity_uv = UV * opacity_uv_scale + TIME * opacity_uv_speed;
    float opacity_value = texture(opacity_texture, opacity_uv).r;

    // Edge detection using the alpha channel
    float alpha = base_color.a;
    float edge_mask = smoothstep(edge_threshold, 0.0, alpha) - smoothstep(1.0, 1.0 - edge_threshold, alpha);

    // Dissolve texture UVs (polar)
    vec2 polar_coords = UV - vec2(0.5); // Center UV
    float radius = length(polar_coords); // Polar radius
    float angle = atan(polar_coords.y, polar_coords.x); // Polar angle
    radius += TIME * dissolve_uv_speed; // Radial movement
    vec2 dissolve_uv = vec2(radius * dissolve_uv_scale.x, angle * dissolve_uv_scale.y);
    float dissolve_value = texture(dissolve_texture, dissolve_uv).r;

    // Apply dissolve effect to edges only
    float dissolve_mask = step(dissolve_threshold, dissolve_value) * edge_mask;

    // Final color
    vec4 final_color = base_color * opacity_value * dissolve_mask;

    COLOR = final_color;
}