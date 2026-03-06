struct Out {
  @builtin(position) pos: vec4f,
}

@binding(0) @group(0) var<uniform> size: vec2u;

@vertex
fn vert_main(@builtin(instance_index) i: u32, @location(0) u: vec2f, @location(1) vert: vec2f) -> Out {
    let w = size.x;
    let h = size.y;

    let side = f32(max(w, h));
    let bw = 2 / f32(w);
    let bh = 2 / f32(h);

    let qx = i % w;
    let qy = i / h;

    let l = f32(qx) * bw + bw/2;
    let t = f32(qy) * bh + bh/2;

    let magnitude = max(0.1, sqrt(u[0]*u[0] + u[1]*u[1]));
    let angle = atan2(u[1], u[0]) - radians(90);

    let scale = mat2x2(
        clampTanh(magnitude), 0,
        0, magnitude
    );

    let rotate = mat2x2(
        cos(angle), sin(angle),
        -sin(angle), cos(angle)
    );

    let transformed = rotate * scale * vert;

    return Out(
        vec4f(
            (l + transformed.x * bw/2 - 1) * f32(w) / side,
            (t + transformed.y * bh/2 - 1) * f32(h) / side,
            0,
            1
        )
    );
}

@fragment
fn frag_main() -> @location(0) vec4f {
    return vec4f(0, 0, 1, 1);
}

// Compute tanh while clamping x to +/- 20.0 to prevent inf values.
fn clampTanh(x: f32) -> f32 {
    let clamped = clamp(x, -20.0, 20.0);
    return tanh(clamped);
}
