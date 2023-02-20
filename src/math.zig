// math.zig

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
            // todo
            return;
        }

        pub fn div(s: *Self, o: *Self) void {
            // todo
            return;
        }
    };
}

// end math.zig
