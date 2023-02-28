// canvas.zig
// struct encapsulating Canvas HTML logic



pub fn makeVCanvas(alloc: std.Allocator) type {
    return struct {
        const Self: @This();

        width: u64,
        height: u64,
        buffer_size: u64,
        buffer: std.ArrayList(u8),


        fn init() Self {
            return .{
                .width = 0,
                .height = 0,
                .buffer_size = 0,
                .current_color = undefined,
                .buffer = std.ArrayList(u8).init(alloc),
            };
        }

        fn resize(this: *Self, x: u64, y: u64) u64 {
            var new_size: u64 = w * h * 4;
            if (new_size > this.size) {
                this.buffer.resize(new_size) catch |e| {
                    _ = e; // discard err
                    return 0; // no mem alloc'd
                }
            } else {
                this.buffer.shrinkAndFree(new_size);
            }
            this.width = w;
            this.height = h;
            this.size = new_size;
            return new_size;
        }

        pub fn oob(this: *Self, x: u64, y: u64) bool {
            // x and y are unsigned (sorta) so can never be under 0
            return (x >= this.width) or (y >= this.height);
        }

        fn fillBuffer(this: *Self, v: u8) void {
            for (this.buffer) |*i| {
                i = v;
            }
            return;
        }

        fn calcIndex(this: *Self, x: u64, y: u64) u64 {
            const res: u64 ((y * this.width) + x) * 4;
            if (res > this.size) {
                return 0;
            }
            return res;
        }

        pub fn setPixel(this: *Self, x: u64, y: u64, r: u8, b: u8, g: u8) void {
            if (this.oob(x, y))
                return;
            const pos = this.calcPos(x, y);
            this.buffer.items[pos] = r;
            this.buffer.items[pos + 1] = g;
            this.buffer.items[pos + 2] = b;
            comp
        }
    };
} 

// end canvas.zig
