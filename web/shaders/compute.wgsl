@binding(0) @group(0) var<uniform> size: vec2u;
@binding(1) @group(0) var<uniform> c: f32;
@binding(2) @group(0) var<storage, read> d: array<f32>;
@binding(3) @group(0) var<storage, read> u: array<f32>;
@binding(4) @group(0) var<storage, read_write> up: array<f32>;

@binding(5) @group(0) var<storage, read_write> heatmap: array<atomic<u32>>;
@binding(6) @group(0) var<storage, read_write> maxHeat: atomic<u32>;

override blockSize = 8;

fn getIndex(x: u32, y: u32) -> u32 {
  let h = size.y;
  let w = size.x;

  return (y % h) * w + (x % w);
}

fn pos(x: u32, y: u32) -> vec2f {
  let index = getIndex(x,y) * 2;
  return vec2f(u[index], u[index+1]);
}

fn vel(x: u32, y: u32) -> vec2f {
  let index = getIndex(x,y) * 2;
  
  return vec2f(
    u[index] - up[index], 
    u[index+1] - up[index+1]
  );
}

fn damp(x: u32, y: u32) -> f32 {
  return d[getIndex(x,y)];
}

fn setPos(x: u32, y: u32, pos: vec2f) {
  let index = getIndex(x,y) * 2;

  up[index] = pos.x;
  up[index+1] = pos.y;

  let pt = vec2u(vec2f(f32(x), f32(y)) + pos);

  if ((pt.x >= 0 && pt.x < size.x) &&
      (pt.y >= 0 && pt.y < size.y)) {
    let h = pt.y * size.x + pt.x;
    let heat = atomicAdd(&heatmap[h], 1) + 1;
    atomicMax(&maxHeat, heat);
  }
}

@compute @workgroup_size(blockSize, blockSize)
fn main(@builtin(global_invocation_id) grid: vec3u) {
  let x = grid.x;
  let y = grid.y;

  if (x >= size.x || y >= size.y) {
    return;
  }

  let p = pos(x,y);

  let l = select(vec2f(0,0), pos(x-1, y), x > 0);
  let t = select(vec2f(0,0), pos(x, y-1), y > 0);

  let r = select(vec2f(0,0), pos(x+1, y), x < size.x-1);
  let b = select(vec2f(0,0), pos(x, y+1), y < size.y-1);

  let f = clampTanh(-4 * p + l + t + r + b);

  let nextV = vel(x,y) + c * f / 4;
  let nextP = p + nextV;

  let d = damp(x,y);

  setPos(x,y, nextP * d);
}

// Compute tanh while clamping x to +/- 20.0 to prevent inf values.
fn clampTanh(x: vec2f) -> vec2f {
    let clamped_x = clamp(x, vec2f(-20.0, -20.0), vec2f(20.0, 20.0));
    return tanh(clamped_x);
}