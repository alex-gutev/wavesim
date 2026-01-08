struct Out {
    @builtin(position) pos: vec4f,
    @location(0) heatmapPos: vec2f
}

@binding(0) @group(0) var<uniform> size: vec2u;
@binding(1) @group(0) var<storage, read> heatmap: array<u32>;
@binding(2) @group(0) var<storage, read> maxHeat: u32;

@vertex
fn vertMain(@builtin(instance_index) i: u32, @location(0) pos: vec2f, @location(1) hPos: vec2u) -> Out {
    return Out(vec4f(f32(pos.x), f32(pos.y), 0, 1), vec2f(hPos));
}

@fragment
fn fragMain(@location(0) hPos: vec2f) -> @location(0) vec4f {
    let hIndex = u32(hPos.y) * size.x + u32(hPos.x);
    let heat = f32(heatmap[hIndex]) / 5;

    return heatmapColor(heat);
}

fn heatmapColor(t: f32) -> vec4f {
    let blue = vec4f(0.0, 0.0, 1.0, 1.0);
    let cyan = vec4f(0.0, 1.0, 1.0, 1.0);
    let yellow = vec4f(1.0, 1.0, 0.0, 1.0);
    let red = vec4f(1.0, 0.0, 0.0, 1.0);

    if (t < 0.33) { 
        return mix(blue, cyan, t / 0.33); 
    }
    if (t < 0.66) { 
        return mix(cyan, yellow, (t - 0.33) / 0.33); 
    }

    return mix(yellow, red, (t - 0.66) / 0.34);
}