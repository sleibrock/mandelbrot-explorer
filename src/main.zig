const std = @import("std");
const alloc = std.heap.page_allocator;
const complex = @import("complex.zig");


const Complex64 = complex.makeComplex(f64);
//const Complex128 = complex.makeComplex(f128);

const WIDTH: u32 = 640;
const HEIGHT: u32 = 480;

const BUFSIZE: u32 = WIDTH * HEIGHT * 4;

const ByteList = std.ArrayList(u8);
var video_buffer: ByteList = ByteList.init(alloc);

const Zone = struct {
    x1: f64,
    y1: f64,
    x2: f64,
    y2: f64,

    pub fn init(x1: f64, y1: f64, x2: f64, y2: f64) Zone {
        return .{ .x1 = x1, .y1 = y1, .x2 = x2, .y2 = y2 };
    }
};


fn mandelbrot(comptime T: anytype, Z: *T, C: *T) u8 {
    // Z(n+1) = Z*Z + C
    var iter: u8 = 0;
    while ((iter < 255) and (Z.square() < 4.0)) : (iter += 1){
        Z.mul(Z);
        Z.add(C);
    } 
    return iter;
}

pub fn setPixel(x: u32, y: u32, f: u8) void {
    const pos = ((y * WIDTH) + x) * 4;
    video_buffer.items[pos] = f;
    video_buffer.items[pos + 1] = f;
    video_buffer.items[pos + 2] = f;
    return;
}


fn render(comptime T: anytype) void {
    // render the whole picture
    // render from (-2 ... 0.47), (-1.12 ... 1.12)
    var x_bump: T = T.init(0.0038, 0);
    var y_bump: T = T.init(0, 0.0046);
    var x: u32 = 0;
    var y: u32 = 0;

    var Z: T = T.init(0, 0);
    var C: T = T.init(-2, 1.12); // fill with values

    var iters: u8 = 0;
    iters = 0;

    while (y < HEIGHT) : (y += 1) {
        x = 0;
        while (x < WIDTH) : (x += 1) {
            Z.real = 0;
            Z.imag = 0;
            iters = mandelbrot(Complex64, &Z, &C);
            setPixel(x, y, iters);
            C.add(&x_bump);
        }
        // typewriter sling the C.real value back to it's initial left side
        C.real = -2;
        // then bump the C.imag value down by it's bump value
        C.sub(&y_bump);
    }
    return;
}


export fn init(w: u32, h: u32) u32 {
    // reserve memory for the output picture
    var size = w * h * 4;
    video_buffer.resize(size) catch |err| {
        switch (err) {
            else => { return 0; },
        }
    };
    var index: usize = 0;
    while (index < size) {
        video_buffer.items[index] = 0;
        video_buffer.items[index + 1] = 0;
        video_buffer.items[index + 2] = 0;
        video_buffer.items[index + 3] = 255;
        index += 4;
    }
    render(Complex64);
    return size;
}

export fn getWidth() u32 { return WIDTH; }
export fn getHeight() u32 { return HEIGHT; }
export fn getSize() u32 { return BUFSIZE; }
export fn startAddr() *u8 { return &video_buffer.items[0]; }


export fn handle_onresize() void {}
export fn update() void {}
export fn handle_onclick(x: i32, y: i32) void { _ = x; _ = y;}
export fn handle_onrelease(x: i32, y: i32) void { _ = x; _ = y;}


test "Does Mandelbrot() actually work?" {
    const C64 = complex.makeComplex(f64);
    var Z = C64.init(0, 0);
    var C = C64.init(-1, 1);
    var res = mandelbrot(C64, &Z, &C);
    try std.testing.expect(res == 3);

    var Z2 = C64.init(0, 0);
    var C2 = C64.init(-0.1, 0.01);
    var res2 = mandelbrot(C64, &Z2, &C2);
    try std.testing.expect(res2 == 255);
}

// end main.zig
