@group(0) @binding(0) var<uniform> size : u32;
@group(0) @binding(1) var<uniform> sample_window : u32;
@group(0) @binding(2) var<uniform> output_size : u32;
@group(0) @binding(3) var<storage, read> u : array<vec2f>;
@group(0) @binding(4) var<storage, read_write> u_sample : array<vec2f>;

override blockSize = 8;

@compute @workgroup_size(blockSize, blockSize)
fn downsample(@builtin(global_invocation_id) grid : vec3u) {
    let x = grid.x;
    let y = grid.y;

    if (x >= output_size || y >= output_size) {
        return;
    }

    let start_x = x * sample_window;
    let start_y = y * sample_window;

    let end_x = min(size, start_x + sample_window);
    let end_y = min(size, start_y + sample_window);

    var sum = vec2f(0);

    for (var r : u32 = start_y; r < end_y; r++) {
        for (var c : u32 = start_x; c < end_x; c++) {
            sum += u[r * size + c];
        }
    }

    u_sample[y * output_size + x] = sum / f32(sample_window * sample_window);
}
