const std = @import("std");
const w = @import("win32").c;
const prtmx = @import("numark_partymix.zig");

const midiError = error {
    noMidiDevice,
    otherError
};

var midi_dev: w.HMIDIIN = undefined;

var val: u12 = 0;

var partymix: prtmx.NumarkPartyMix = undefined;

pub fn main() !void {
    partymix = prtmx.NumarkPartyMix.create();

    //Get MIDI devices count
    var idev_num = w.midiInGetNumDevs();

    std.debug.print("Found {} MIDI devices\n", .{idev_num});

    if (idev_num == 0)
        return midiError.noMidiDevice;

    

    //Open first device
    _ = w.midiInOpen(&midi_dev, 0, @ptrToInt(handler), 0, w.CALLBACK_FUNCTION);

    //Start listening for events
    if (w.midiInStart(midi_dev) != 0)
        return midiError.otherError;

    while (true) {
        
    }
}

fn handler(midiin: w.HMIDIIN, msg: w.UINT, instance: w.DWORD, param1: w.DWORD, param2: w.DWORD) void {
    if (msg == w.MIM_DATA)
        partymix.handleMidiMsg(param1);
}