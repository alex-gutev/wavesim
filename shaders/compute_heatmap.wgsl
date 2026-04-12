@group(0) @binding(0) var<uniform> size : u32;
@group(0) @binding(1) var<uniform> window : u32;
@group(0) @binding(2) var<uniform> heatmap_size : u32;
@group(0) @binding(3) var<storage, read> u : array<vec2f>;
@group(0) @binding(4) var<storage, read_write> heatmap: array<atomic<u32>>;
@group(0) @binding(5) var<storage, read_write> maxHeat: atomic<u32>;

override blockSize = 8;

@compute @workgroup_size(blockSize, blockSize)
fn compute_density(@builtin(global_invocation_id) grid : vec3u) {
    let x = grid.x;
    let y = grid.y;

    if (x >= size || y >= size) {
        return;
    }

    let displacement = u[y * size + x];

    let window_size = vec2f(f32(window), f32(window));

    let position = vec2u((vec2f(f32(x), f32(y)) + displacement) / window_size);

    if ((position.x >= 0 && position.x < heatmap_size) &&
        (position.y >= 0 && position.y < heatmap_size)) {

        let index = position.y * heatmap_size + position.x;
        let heat = atomicAdd(&heatmap[index], 1) + 1;

        atomicMax(&maxHeat, heat);
    }
}