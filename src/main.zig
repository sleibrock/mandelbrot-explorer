const std = @import("std");
const math = std.math;
const alloc = std.heap.page_allocator;
const complex = @import("complex.zig");
const canvas = @import("canvas.zig");


const Complex64 = complex.makeComplex(f64);
//const Complex128 = complex.makeComplex(f128);


const CanvasT = canvas.makeVCanvas(alloc);
var cnv = CanvasT.init();

fn abs64(x: f64) f64 {
    if (x < 0) {
        return x * -1;
    }
    return x;
}




const Domain = struct {
    x1: f64,
    y1: f64,
    x2: f64,
    y2: f64,

    pub fn init(x1: f64, y1: f64, x2: f64, y2: f64) Domain {
        return .{ .x1 = x1, .y1 = y1, .x2 = x2, .y2 = y2 };
    }
};

var domain = Domain.init(-2.0, 1.12, 0.47, 1.12);


fn mandelbrot(comptime T: anytype, Z: *T, C: *T) u8 {
    // Z(n+1) = Z*Z + C
    var iter: u8 = 0;
    while ((iter < 255) and (Z.square() < 4.0)) : (iter += 1){
        Z.mul(Z);
        Z.add(C);
    } 
    return iter;
}


fn render64(dom: *Domain) void {
    // render the whole picture
    // render from (-2 ... 0.47), (-1.12 ... 1.12)
    const x_inc = abs64(dom.x1) + abs64(dom.x2) / @intToFloat(f64, cnv.width);
    const y_inc = abs64(dom.y1) + abs64(dom.y2) / @intToFloat(f64, cnv.height);
    var x_bump = Complex64.init(x_inc, 0);
    var y_bump = Complex64.init(0, y_inc);
    var x: u32 = 0;
    var y: u32 = 0;

    var Z = Complex64.init(0, 0);
    var C = Complex64.init(dom.x1, dom.y1);

    var iters: u8 = 0;
    iters = 0;

    while (y < cnv.height) : (y += 1) {
        x = 0;
        while (x < cnv.width) : (x += 1) {
            Z.real = 0;
            Z.imag = 0;
            iters = mandelbrot(Complex64, &Z, &C);
            cnv.setPixel(x, y, iters, iters, iters);
            C.add(&x_bump);
        }
        // sling the C.real value back to it's initial left side
        C.real = dom.x1;
        // then bump the C.imag value down by it's bump value
        C.sub(&y_bump);
    }
    return;
}


export fn init(w: u32, h: u32) u64 {
    // reserve memory for the output picture
    var size = cnv.resize(w, h);
    if (size == 0) {
        return 0;
    }
    cnv.fillBuffer(255);
    render64(&domain);
    return size;
}

export fn getWidth() usize { return cnv.width; }
export fn getHeight() usize { return cnv.height; }
export fn getSize() usize { return cnv.buffer_size; }
export fn startAddr() *u8 { return &cnv.buffer.items[0]; }


export fn handle_onresize() void {}
export fn update() void {}
export fn handle_onclick(x: i32, y: i32) void { _ = x; _ = y;}
export fn handle_onrelease(x: i32, y: i32) void { _ = x; _ = y;}


test "Does abs work?" {
    var x: f64 = -1;
    var y: f64 = abs64(x);
    try std.testing.expect(y == 1.0);
}

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
