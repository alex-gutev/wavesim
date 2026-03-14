struct Out {
    @builtin(position) pos: vec4f,
    @location(0) dataPos: vec2f
}

@group(0) @binding(0) var<uniform> size : vec2u;
@group(0) @binding(1) var<uniform> component : u32;
@group(0) @binding(2) var<uniform> loColor : vec4f;
@group(0) @binding(3) var<uniform> hiColor : vec4f;
@group(0) @binding(4) var<storage, read> data : array<vec2f>;

@vertex
fn vertMain(@builtin(instance_index) i: u32, @location(0) pos: vec2f, @location(1) dataPos: vec2u) -> Out {
    return Out(vec4f(f32(pos.x), f32(pos.y), 0, 1), vec2f(dataPos));
}

@fragment
fn fragMain(@location(0) dataPos: vec2f) -> @location(0) vec4f {
    let index = u32(dataPos.y) * size.x + u32(dataPos.x);
    let coeff = (1 + clamp(-1, 1, data[index][component])) / 2;

    return mix(loColor, hiColor, coeff);
}

