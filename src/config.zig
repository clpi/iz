const std = @import("std");
const User = @import("./types/user.zig").User;
const fs = std.fs;

pub const log_level: std.log.Level = @intToEnum(std.log.Level, Config.log_level);
pub const log_level_: std.log.Level = if (true) .debug else .info;

pub const Config = struct {
    user: User,
    api_key: []const u8,
    directory: []const u8,
    data_dir: []const u8 = "~/.local/lib/iz",
    log_level: i32 = 7, // Max log level (emergency = 0, debug = 7)
    simul: Simul,
    host: Host,
    debug: bool,

    pub const Simul = struct {
        seed: u64 = 0,
        tick_ms: u32 = 10,
        ticks_max: u32 = 100_000_000,
        epoch_max_ms: u32 = 60_000,
        sync_window_max_ms: u32 = 20_000,
        sync_window_min_ms: u32 = 2_000,

        pub fn init() !Simul {
            const rand_seed = std.crypto.random.int(u64);
            const prng = std.rand.DefaultPrng.init(rand_seed);
            const rand = &prng.random;
            return Simul {

            };
        }
    };

    pub const Host = struct {
        name: ?[]const u8 = null,
        address: []const u8 = "127.0.0.1",
        port: u64 = 4001,
    };

    /// Initialize config with default parameters, and save to data dir
    pub fn init() !Config {
        return Config{ 
            .user = User{ .id = 0, .display = "d", .email = "e", .name = "n"},
            .debug = false,
            .host = Host {},
            .simul = Simul {},
            .directory = "",
            .api_key = ""
        };
    }

    pub fn defaultPath() []const u8 {
        return std.process.getCwd();
    }
};

