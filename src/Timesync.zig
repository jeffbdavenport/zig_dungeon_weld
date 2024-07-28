const main = @import("main.zig");
const std = main.std;
const nanotime = main.nanotime;

next_frame: u64,
frame_count: u32 = 0,
delay_ns: u64,

pub fn getFrames(self: *@This()) u32 {
    const frames = self.frame_count;
    self.frame_count = 0;
    return frames;
}

pub fn new(dealy_ns: u64) @This() {
    return @This(){ .next_frame = nanotime(), .delay_ns = dealy_ns };
}

// Sleep for elapsed_ns minus how long it has been since last call to sleepSync
pub fn sleepSync(self: *@This(), elapsed_ns: ?u64) void {
    const elapsed = if (elapsed_ns == null)
        nanotime()
    else
        elapsed_ns.?;

    if (elapsed < self.next_frame) {
        const delay = self.next_frame - elapsed;
        std.time.sleep(delay);
    }
    self.next_frame += self.delay_ns;
    self.frame_count += 1;
}

// Return true if it has been longer than elapsed_ns since last call to sync
pub fn sync(self: *@This(), elapsed_ns: ?u64) bool {
    const elapsed = if (elapsed_ns == null)
        nanotime()
    else
        elapsed_ns.?;

    if (elapsed >= self.next_frame) {
        self.next_frame += self.delay_ns;
        self.frame_count += 1;

        // We may have lost some frames
        if (elapsed >= self.next_frame) {
            self.next_frame = elapsed + self.delay_ns;
        }
        return true;
    }
    return false;
}
