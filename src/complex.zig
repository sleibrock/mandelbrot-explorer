// math.zig

const std = @import("std");
const math = std.math;
const testing = std.testing;

pub fn makeComplex(comptime T: anytype) type {
    return struct {
        const Self = @This();
        real: T,
        imag: T,

        pub fn init(r: T, i: T) Self {
            return .{ .real = r, .imag = i };
        }

        pub fn add(s: *Self, o: *Self) void {
            s.real += o.real;
            s.imag += o.imag;
            return;
        }

        pub fn sub(s: *Self, o: *Self) void {
            s.real -= o.real;
            s.imag -= o.imag;
            return;
        }

        pub fn mul(s: *Self, o: *Self) void {
            // wikipedia math
            // (x+yi)(u+vi) = (xu-yv)+(xv+yu)i``
            const xu = s.real * o.real;
            const yv = s.imag * o.imag;
            const xv = s.real * o.imag;
            const yu = s.imag * o.real;
            s.real = xu - yv;
            s.imag = xv + yu;
            return;
        }

        pub fn div(s: *Self, o: *Self) void {
            // more wikipedia math 
            const d = (o.real*o.real) + (o.imag*o.imag);
            const r = ((s.real*o.real)+(s.imag*o.imag)) / d;
            s.imag = ((s.imag*o.real)-(s.real*o.imag)) / d;
            s.real = r;
            return;
        }

        pub fn square(s: *Self) T {
            return (s.real*s.real)+(s.imag*s.imag);
        }

        pub fn magnitude(s: *Self) T {
            // sqrt(a**2 + b**2) is the absolute value/magnitude of C
            return math.sqrt((s.real*s.real) + (s.imag*s.imag));
        }

        pub fn eq(s: *Self, o: *Self) bool {
            // f64/f128 equality is sketchy and may not always yield
            // correctness when facing weird values
            // use eq_margin() instead to supply a closeness value
            return s.real == o.real and s.imag == o.imag;
        }

        pub fn conjugate(s: *Self) void {
            // reflect across the imaginary axis
            s.imag = -s.imag;
            return;
        }
    };
}


// testing
test "Complex addition f64 test" {
    const C64 = makeComplex(f64);
    var a = C64.init(5, 3);
    var b = C64.init(7, 4);
    var c = C64.init(12, 7);
    a.add(&b);
    try testing.expect(a.eq(&c));
}

test "Complex subtraction f64 test" {
    const C64 = makeComplex(f64);
    var a = C64.init(5, 3);
    var b = C64.init(7, 4);
    var c = C64.init(-2, -1);
    a.sub(&b);
    try testing.expect(a.eq(&c));
}

test "Complex multiplication f64 test" {
    const C64 = makeComplex(f64);
    var a = C64.init(5, 3);
    var b = C64.init(7, 4);
    var c = C64.init(23, 41);
    a.mul(&b);
    try testing.expect(a.eq(&c));
}

test "Complex division f64 test" {
    const C64 = makeComplex(f64);
    var a = C64.init(1, 1);
    var b = C64.init(2, 2);
    var c = C64.init(0.5, 0);
    a.div(&b);
    try testing.expect(a.eq(&c));
}

test "Complex addition f128 test?" {
    const C64 = makeComplex(f128);
    var a = C64.init(5, 3);
    var b = C64.init(7, 4);
    var c = C64.init(12, 7);
    a.add(&b);
    try testing.expect(a.eq(&c));
}

// end math.zig
