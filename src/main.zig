const std = @import("std");
const w = @import("win32").c;

const midiError = error {
    noMidiDevice,
    otherError
};

pub fn main() !void {
    //Get MIDI devices count
    var dev_num = w.midiInGetNumDevs();

    std.debug.print("Found {} MIDI devices\n", .{dev_num});

    if (dev_num == 0)
        return midiError.noMidiDevice;

    var midi_dev: w.HMIDIIN = undefined;

    //Open first device
    var rv = w.midiInOpen(&midi_dev, 0, @ptrToInt(midiEventHandler), 0, w.CALLBACK_FUNCTION);

    //Start listening for events
    if (w.midiInStart(midi_dev) != 0)
        return midiError.otherError;

    while (true) {}
    
}

//Event handler for MIDI events
fn  midiEventHandler(midiin: w.HMIDIIN, msg: w.UINT, instance: w.DWORD, param1: w.DWORD, param2: w.DWORD) void {
    //std.debug.print("MIDI message : {x} {x}\n", .{param1, param2});

    switch (msg) {
        w.MIM_OPEN => {
            std.debug.print("MIDI: Device open!\n", .{});
        },
        w.MIM_CLOSE => {
            std.debug.print("MIDI: Device closed.\n", .{});
        },
        w.MIM_DATA => {
            std.debug.print("MIDI: Data : {x}, {x:0<8}, {x:0<8}.\n", .{instance, param1, param2});
        },
        w.MIM_LONGDATA => {
            std.debug.print("MIDI: Long data.\n", .{});
        },
        w.MIM_ERROR, w.MIM_LONGERROR => {
            std.debug.print("MIDI: Error.\n", .{});
        },
        w.MIM_MOREDATA => {
            std.debug.print("MIDI: More data message.\n", .{});
        },
        else => {
            std.debug.print("MIDI: Unknown message '{x}' : {x} {x}.\n", .{msg, param1, param2});
        }
    }
}