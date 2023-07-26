const main = @import("../main.zig");
const std = main.std;
const p = main.p;

const c = @cImport(@cInclude("/opt/dqlite/src/client/protocol.h"));

pub fn sqlStatement() !void {
    // try DW.Game.init("Ultra Jetpack", render_size, render_size, buildGame, client, server);
    // https://dqlite.io/docs/reference/wire-protocol
    const address = std.net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, 9001);
    var stream = try std.net.tcpConnectToAddress(address);
    const writer = stream.writer();

    // Tell version
    // var ret = writer.writeIntLittle(u64, 1) catch unreachable;
    var ret = c.ClientInit();
    p("write size:{!}:", .{ret});
    var buf: [256]u8 = undefined;

    // Register client
    var header = "\x01\x00\x00\x00\x01\x00\x00\x00";
    var write_size = writer.write(header) catch unreachable;
    p("write size:{!}:", .{write_size});
    var msg1 = "\x00\x00\x00\x00\x00\x00\x00\x00";
    write_size = writer.write(msg1) catch unreachable;
    p("write size:{!}:", .{write_size});
    p("Before Read 0", .{});
    var size = try stream.read(&buf);
    p("Output :{!}:{s}:", .{ size, buf[0..size] });

    // Open Database
    header = "\x04\x00\x00\x00\x03\x00\x00\x00";
    write_size = writer.write(header) catch unreachable;
    p("write size:{!}:", .{write_size});
    // size = try stream.read(&buf);
    // p("Output :{!}:{s}", .{ size, buf[0..size] });

    var msg = "demo\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00volatile\x00\x00\x00\x00\x00\x00\x00\x00";
    write_size = writer.write(msg) catch unreachable;
    p("write size:{!}:", .{write_size});
    p("Before Read 1", .{});
    size = try stream.read(&buf);
    p("Output :{!}:{s}:", .{ size, buf[0..size] });

    // Execute SQL Text yielding  rows
    header = "\x08\x00\x00\x00\x09\x00\x00\x00";
    write_size = try writer.write(header);
    p("write size:{!}:", .{write_size});
    // const msg2 = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00SELECT value from model where key='my-key';\x00\x00\x00\x00\x00";
    const msg2 = "\x00\x00\x00\x00\x00\x00\x00\x00SELECT value FROM model WHERE key = ?\x00\x00\x00\x01\x03, valumy-key\x00\x00";
    write_size = writer.write(msg2) catch unreachable;

    p("write size:{!}:", .{write_size});
    p("Before Read 2", .{});
    size = try stream.read(&buf);
    p("Output :{!}:{s}:", .{ size, buf[0..size] });
}
