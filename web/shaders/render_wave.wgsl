struct Out {
  @builtin(position) pos: vec4f,
  @location(0) density: f32,
}

@binding(0) @group(0) var<uniform> size: vec2u;

@vertex
fn vert_main(@builtin(instance_index) i: u32, @location(0) u: vec2f, @location(1) pos: vec2u) -> Out {
    let w = size.x;
    let h = size.y;

    let side = f32(max(w, h));
    let bw = 2 / f32(w);
    let bh = 2 / f32(h);

    let qx = i % w;
    let qy = i / h;

    let l = f32(qx) * bw;
    let vx = (f32(pos.x) - 0.5) * 0.7 + 0.5;

    let t = f32(qy) * bh;
    let vy = (f32(pos.y) - 0.5) * 0.7 + 0.5;

    let x = (l + bw * vx + bw * u.x - 1) * f32(w) / side;
    let y = (t + bh * vy + bh * u.y - 1) * f32(h) / side;

    return Out(vec4f(x, y, 0., 1), 1.0);
}

@fragment
fn frag_main(@location(0) density: f32) -> @location(0) vec4f {
    return vec4f(density, 0, 0, 1.);
}

