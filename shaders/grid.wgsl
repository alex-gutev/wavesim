struct Out {
  @builtin(position) pos: vec4f,
  @location(0) density: f32,
}

@group(0) @binding(0) var<uniform> size : vec2u;
@group(0) @binding(1) var<storage, read> data : array<vec2f>;

@vertex
fn vert_main(@location(0) index: vec2u) -> Out {
    let w = size.x;
    let h = size.y;

    let side = f32(max(w, h));
    let bw = 2 / f32(w);
    let bh = 2 / f32(h);

    let left = f32(index.x) * bw;
    let top = f32(index.y) * bh;

    let offset = data[index.y * w + index.x];

    let x = (left + bw / 2 + bw * offset.x - 1) * f32(w) / side;
    let y = (top + bh / 2 + bh * offset.y - 1) * f32(h) / side;

    return Out(vec4f(x, y, 0., 1), 1.0);
}

@fragment
fn frag_main(@location(0) density: f32) -> @location(0) vec4f {
    return vec4f(0, 0, density, 1.0);
}

