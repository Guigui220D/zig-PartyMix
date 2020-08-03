const std = @import("std");
const w = @import("win32").c;

pub const NumarkPartyMix = struct {
    const Self = @This();

    const Slider = u7;
    const Knob = u7;
    const Button = bool;
    const ToggleButton = bool;
    const Turntable = i16;
    const RKnob = i16;

    pub const Half = struct {
        speed: Slider,
        volume: Slider,

        gain: Knob,
        treble: Knob,
        bass: Knob,

        turntable: Turntable,

        headset: ToggleButton,
        scratch: Button,

        pad1: Button,
        pad2: Button,
        pad3: Button,
        pad4: Button,

        sync: Button,
        cue: Button,
        play: Button
    };

    pub fn create() Self {
        var new: Self = undefined;
        @memset(@ptrCast([*]u8, &new), 0, @sizeOf(Self));
        return new;
    }

    pub fn wasPressed(button: Button) bool {
        var b = button;
        button = false;
        return b;
    }

    pub fn getTurntableDelta(turntable: Turntable) i16 {
        var b = turntable;
        turntable = 0;
        return b;
    }

    pub fn getRKnobDelta(knob: RKnob) u16 {
        var b = turntable;
        turntable = 0;
        return b;
    }

    pub fn handleMidiMsg(self: *Self, message: w.DWORD) void {
        var control_id: u8 = @truncate(u8,(message & 0xff00) >> 8);
        var control_value: u7 = @truncate(u7, (message & 0xff0000) >> 16);

        if (message & 0xf == 0xf) { //Center controls
            switch (control_id) {
                0x00 => {
                    if (message & 0xf0 == 0xb0) {
                        if (control_value == 0x01)
                            self.browse +%= 1;
                        if (control_value == 0x7f)
                            self.browse -%= 1;
                    } else
                        self.browse_select = true;
                },
                0x02 => {
                    self.load1 = true;
                },
                0x03 => {
                    self.load2 = true;
                },
                0x08 => {
                    self.balance = control_value;
                },
                0x0a => {
                    self.master_gain = control_value;
                },
                0x0c => {
                    self.cue_mix = control_value;
                },
                0x0d => {
                    self.cue_gain = control_value;
                },
                else => {
                    std.debug.print("Unknown message : {x:0<8}\n", .{message});
                }
            }
        } else {
            var half: *Half = if (message & 1 == 0) &self.left else &self.right;
            
            if (message & 0xf0 == 0xb0) {
                switch (control_id) {
                    0x06 => {
                        if (control_value == 0x01)
                            half.turntable +%= 1;
                        if (control_value == 0x7f)
                            half.turntable -%= 1;
                    }, 
                    0x09 => {
                        half.speed = control_value;
                    }, 
                    0x17 => {
                        half.gain = control_value;
                    }, 
                    0x18 => {
                        half.treble = control_value;
                    }, 
                    0x19 => {
                        half.bass = control_value;
                    },
                    0x1c => {
                        half.volume = control_value;
                    }, 
                    else => {
                        std.debug.print("Unknown message : {x:0<8}\n", .{message});
                    }
                }
            } else {
                switch (control_id) {
                    0x00 => {
                        half.play = true;
                    }, 
                    0x01 => {
                        half.cue = true;
                    }, 
                    0x02 => {
                        half.sync = true;
                    }, 
                    0x07 => {
                        half.scratch = true;
                    }, 
                    0x14 => {
                        half.pad1 = true;
                    }, 
                    0x15 => {
                        half.pad2 = true;
                    }, 
                    0x16 => {
                        half.pad3 = true;
                    },
                    0x17 => {
                        half.pad4 = true;
                    },
                    0x1b => {
                        half.headset = control_value != 0;
                    },
                    else => {
                        std.debug.print("Unknown message : {x:0<8}\n", .{message});
                    }
                }
            }
        } 
    }

    left: Half,
    right: Half,

    browse: RKnob,
    browse_select: Button,

    load1: Button,
    load2: Button,

    master_gain: Knob,
    cue_mix: Knob,
    cue_gain: Knob,

    balance: Slider
};
