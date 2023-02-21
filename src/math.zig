// math.zig

const std = @import("std");
const math = std.math;

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

        pub fn imag(s: *Self, o: *Self) void {
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
            // todo
            return;
        }

        pub fn magnitude(s: *Self) T {
            // sqrt(a**2 + b**2) is the absolute value/magnitude of C
            return 0;
        }

        pub fn eq(s: *Self, o: *Self) bool {
            // f64/f128 equality is sketchy and may not always yield
            // correctness when facing weird values
            // use eq_margin() instead to supply a closeness value
            return false;
        }

        pub fn lt(s: *Self, o: *Self) bool {
            return false;
        }

        pub fn gt(s: *Self, o: *Self) bool {
            return false;
        }

        pub fn conjugate(s: *Self) Self {
            return .{ .real = 0, .imag = 0 };
        }
    };
}


test "Complex addition f64 test" {}

test "Complex subtraction f64 test" {}

test "Complex multiplication f64 test" {}

test "Complex division f64 test" {}

test "Complex addition f128 test?" {}

// end math.zig
