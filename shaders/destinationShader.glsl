extern vec2 position;
extern number maxDistance;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    if(screen_coords.y > position.y) {
        return color;
    }

    vec4 texColor = Texel(tex, texture_coords);
    float dist = position.y - screen_coords.y;
    float fade = clamp(1 - dist/maxDistance, 0, 1);
    return vec4(color.rgb, color.a*fade);
}