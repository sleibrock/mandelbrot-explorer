// canvas.zig
// struct encapsulating Canvas HTML logic

const std = @import("std");


pub fn makeVCanvas(comptime alloc: std.mem.Allocator) type {
    return struct {
        const Self = @This();

        width: u32,
        height: u32,
        buffer_size: usize,
        buffer: std.ArrayList(u8),

        pub fn init() Self {
            return .{
                .width = 0,
                .height = 0,
                .buffer_size = 0,
                .buffer = std.ArrayList(u8).init(alloc),
            };
        }

        pub fn resize(this: *Self, w: u32, h: u32) usize {
            const new_size = @as(usize, w * h * 4);
            if (new_size > this.buffer_size) {
                this.buffer.resize(new_size) catch |e| {
                    switch (e) {
                        else => { return 0; },
                    }
                };
            } else {
                this.buffer.shrinkAndFree(new_size);
            }
            this.width = w;
            this.height = h;
            this.buffer_size = new_size;
            return new_size;
        }

        pub fn oob(this: *Self, x: u32, y: u32) bool {
            // x and y are unsigned (sorta) so can never be under 0
            return (x >= this.width) or (y >= this.height);
        }

        pub fn fillBuffer(this: *Self, v: u8) void {
            for (this.buffer.items) |*i| {
                i.* = v;
            }
            return;
        }

        fn calcIndex(this: *Self, x: u32, y: u32) usize {
            const res: usize = ((y * this.width) + x) * 4;
            if (res > this.buffer_size) {
                return 0;
            }
            return res;
        }

        pub fn setPixel(this: *Self, x: u32, y: u32, r: u8, b: u8, g: u8) void {
            if (this.oob(x, y))
                return;
            const pos = this.calcIndex(x, y);
            this.buffer.items[pos] = r;
            this.buffer.items[pos + 1] = g;
            this.buffer.items[pos + 2] = b;
            return;
        }
    };
} 

// end canvas.zig
