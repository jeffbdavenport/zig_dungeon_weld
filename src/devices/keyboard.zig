const main = @import("../main.zig");
const SDL = main.SDL;
const std = main.std;

const display = main.display;
const devices = main.devices;

const p = main.p;

pub const Code = union(enum) {
    const Self = Code;
    key: SDL.Keycode,
    scan: SDL.Scancode,

    // Check if other Binding is the same as this one
    pub fn eq(self: Self, other: Code) bool {
        const Tag = @typeInfo(Code).Union.tag_type.?;

        inline for (@typeInfo(Tag).Enum.fields) |field| {
            if (field.value == @intFromEnum(self) and field.value == @intFromEnum(other)) {
                return @field(self, field.name) == @field(other, field.name);
            }
        }
        return false;
    }
};

pub fn Bindings(comptime T: type) type {
    return struct {
        down: std.EnumArray(T, bool),
        pressed: std.EnumArray(T, bool),
        bindings: std.EnumArray(T, Code),

        pub fn new(bindings_map: std.enums.EnumFieldStruct(T, Code, null)) @This() {
            return @This(){
                .down = std.EnumArray(T, bool).initFill(false),
                .pressed = std.EnumArray(T, bool).initFill(false),
                .bindings = std.EnumArray(T, Code).init(bindings_map),
            };
        }

        pub fn getAxis(self: *@This(), binding: T, other: T) f32 {
            return if (self.isDown(binding) and !self.isDown(other))
                -1
            else if (self.isDown(other) and !self.isDown(binding))
                1
            else
                0;
        }

        pub fn isDown(self: *@This(), binding: T) bool {
            return self.down.get(binding);
        }

        pub fn isPressed(self: *@This(), binding: T) bool {
            const pressed = self.pressed.get(binding);
            self.pressed.set(binding, false);
            return pressed;
        }

        pub fn processKey(self: *@This(), key: SDL.KeyboardEvent) !void {
            var binding = self.getKey(.{ .scan = key.scancode });
            if (binding == null) {
                binding = self.getKey(.{ .key = key.keycode });
            }
            if (binding) |b| {
                if (key.key_state == .pressed) {
                    self.down.set(b, true);

                    // Do not record repeated keys in pressed state
                    if (!key.is_repeat) {
                        self.pressed.set(b, true);
                        p("{s} pressed {any}", .{ @tagName(b), self.down.values });
                    }
                }
                if (key.key_state == .released) {
                    self.down.set(b, false);
                }
            }

            // p("Down keys: {}", .{self.down});
            // p("Pressed key: {}, event: {}", .{ key.scancode });
        }

        fn getKey(self: *@This(), code: Code) ?T {
            for (self.bindings.values, 0..) |v, i| {
                if (v.eq(code)) {
                    return std.enums.EnumIndexer(T).keyForIndex(i);
                }
            }
            return null;
        }
    };
}
