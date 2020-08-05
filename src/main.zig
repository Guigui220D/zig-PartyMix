const std = @import("std");
const prtmx = @import("numark_partymix.zig").NumarkPartyMix;

pub fn main() !void {
    var partymix = prtmx.create();
    try partymix.initMidiInput();

    while (true) {
        while (partymix.pollEvents()) {}
        if (prtmx.wasPressed(&partymix.load1)) {
            std.debug.print("BOB\n", .{});
        }
    }
}