// based on github.com/nektro/zig-ansi
//
const std = @import("std");


pub const Csi = struct {

    pub fn cursorUp(comptime n: i32) []const u8 {
        return _make_csi_seq("A", .{n});
    }
    pub fn cursorDown(comptime n: i32) []const u8 {
        return _make_csi_seq("B", .{n});
    }
    pub fn cursorRight(comptime n: i32) []const u8 {
        return _make_csi_seq("C", .{n});
    }
    pub fn cursorLeft(comptime n: i32) []const u8 {
        return _make_csi_seq("D", .{n});
    }
    pub fn cursorLineDown(comptime n: i32) []const u8 {
        return _make_csi_seq("E", .{n});
    }
    pub fn cursorLineUp(comptime n: i32) []const u8 {
        return _make_csi_seq("F", .{n});
    }
    pub fn cursorPositionLine(comptime n: i32) []const u8 {
        return _make_csi_seq("G", .{n});
    }
    pub fn cursorSet(comptime n: i32, m: i32) []const u8 {
        return _make_csi_seq("H", .{ n, m });
    }
    pub fn clearDisplay(comptime n: i32) []const u8 {
        return _make_csi_seq("J", .{n});
    }
    pub fn clearLine(comptime n: i32) []const u8 {
        return _make_csi_seq("K", .{n});
    }
    pub fn scrollUp(comptime n: i32) []const u8 {
        return _make_csi_seq("S", .{n});
    }
    pub fn scrollDown(comptime n: i32) []const u8 {
        return _make_csi_seq("T", .{n});
    }
    pub fn cursorPosition(comptime n: i32, m: i32) []const u8 {
        return _make_csi_seq("f", .{ n, m });
    }
    pub fn sgr(comptime ns: anytype) []const u8 {
        return _make_csi_seq("m", ns);
    }
};

pub const Escape = struct {
    pub const ss2 = ascii.ESC.s() ++ "N";
    pub const ss3 = ascii.ESC.s() ++ "O";
    pub const dcs = ascii.ESC.s() ++ "P";
    pub const csi = ascii.ESC.s() ++ "[";
    pub const st = ascii.ESC.s() ++ "\\";
    pub const osc = ascii.ESC.s() ++ "]";
    pub const sos = ascii.ESC.s() ++ "X";
    pub const pm = ascii.ESC.s() ++ "^";
    pub const apc = ascii.ESC.s() ++ "_";
    pub const ris = ascii.ESC.s() ++ "c";
};

pub const ascii = enum(u8) {
    NUL, SOH, STX, ETX, EOT, ENQ, ACK, BEL,
    BS, TAB, LF, VT, FF, CR, SO, SI, DLE, DC1,
    DC2, DC3, DC4, NAK, SYN, ETB, CAN, EM,
    SUB, ESC, FS, GS, RS, US,

    pub fn s(self: ascii) []const u8 {
        return &[_]u8{@enumToInt(self)};
    }
};

pub const Style = struct {

    pub const reset = Csi.sgr(.{0});
    pub const bold = Csi.sgr(.{1});
    pub const dim = Csi.sgr(.{2});
    pub const italic = Csi.sgr(.{3});
    pub const underline = Csi.sgr(.{4});
    pub const blinkSlow = Csi.sgr(.{5});
    pub const blinkFast = Csi.sgr(.{6});

    pub const resetFont = Csi.sgr(.{10});
    pub const font1 = Csi.sgr(.{11});
    pub const font2 = Csi.sgr(.{12});
    pub const font3 = Csi.sgr(.{13});
    pub const font4 = Csi.sgr(.{14});
    pub const font5 = Csi.sgr(.{15});
    pub const font6 = Csi.sgr(.{16});
    pub const font7 = Csi.sgr(.{17});
    pub const font8 = Csi.sgr(.{18});
    pub const font9 = Csi.sgr(.{19});

    pub const underlineDouble = Csi.sgr(.{21});
    pub const resetIntensity = Csi.sgr(.{22});
    pub const resetItalic = Csi.sgr(.{23});
    pub const resetunderline = Csi.sgr(.{24});
    pub const resetBlink = Csi.sgr(.{25});

    pub const fgBlack = Csi.sgr(.{30});
    pub const fgRed = Csi.sgr(.{31});
    pub const fgGreen = Csi.sgr(.{32});
    pub const fgYellow = Csi.sgr(.{33});
    pub const fgBlue = Csi.sgr(.{34});
    pub const fgMagenta = Csi.sgr(.{35});
    pub const fgCyan = Csi.sgr(.{36});
    pub const fgWhite = Csi.sgr(.{37});
    // Fg8bit       = func(n int) string { return Csi.sgr(38, 5, n) }
    // Fg24bit      = func(r, g, b int) string { return Csi.sgr(38, 2, r, g, b) }
    pub const resetFgColor = Csi.sgr(.{39});

    pub const bgBlack = Csi.sgr(.{40});
    pub const bgRed = Csi.sgr(.{41});
    pub const bgGreen = Csi.sgr(.{42});
    pub const bgYellow = Csi.sgr(.{43});
    pub const bgBlue = Csi.sgr(.{44});
    pub const bgMagenta = Csi.sgr(.{45});
    pub const bgCyan = Csi.sgr(.{46});
    pub const bgWhite = Csi.sgr(.{47});
    // Bg8bit       = func(n int) string { return Csi.sgr(48, 5, n) }
    // Bg24bit      = func(r, g, b int) string { return Csi.sgr(48, 2, r, g, b) }
    pub const resetBgColor = Csi.sgr(.{49});

    pub const framed = Csi.sgr(.{51});
    pub const encircled = Csi.sgr(.{52});
    pub const overlined = Csi.sgr(.{53});
    pub const resetFrameEnci = Csi.sgr(.{54});
    pub const resetOverlined = Csi.sgr(.{55});
};

/// Terminal color interface for export. For using to print to stdout:
/// ```zig
/// std.debug.print("{s}\n", .{comptime Color.fg(.green, "Your text here")});
/// // or
/// std.debug.print("{s}\n", .{comptime Color.green.fg("your text here")});
/// // or
/// Color.printFg(.green, "Your text here\n");
/// ```
/// For multiple styles:
/// ```zig
/// std.debug.print("{s}\n", .{comptime Color.bold(Color.green.fg("Bold and green"))});
/// // or
/// Color.printBold(comptime Color.green.fg("Bold and green"));
/// ```
pub const Color = enum(u8) {
    black, red, green, yellow, blue, magenta, cyan, white,

    pub fn fg(s: Color, comptime m: []const u8) []const u8 {
        return Csi.sgr(.{30 + @enumToInt(s)}) ++ m ++ Style.resetFgColor;
    }

    pub fn bg(s: Color, comptime m: []const u8) []const u8 {
        return Csi.sgr(.{40 + @enumToInt(s)}) ++ m ++ Style.resetBgColor;
    }

    pub fn bold(comptime m: []const u8) []const u8 {
        return Style.bold ++ m ++ Style.resetIntensity;
    }

    pub fn dim(comptime m: []const u8) []const u8 {
        return Style.dim ++ m ++ Style.resetIntensity;
    }

    pub fn italic(comptime m: []const u8) []const u8 {
        return Style.italic ++ m ++ Style.resetItalic;
    }

    pub fn underline(comptime m: []const u8) []const u8 {
        return Style.underline ++ m ++ Style.Resetunderline;
    }

    pub fn printFg(comptime color: Color, comptime m: []const u8) void {
        std.debug.print(comptime Color.fg(color, m), .{});
    }
};


pub fn printBold(comptime m: []const u8) void {
    std.debug.print(comptime Color.bold(m), .{});
}

pub fn fgBlue(comptime m: []const u8) []const u8 {
    return "hi";  
}

//
// private
//

fn _join(comptime delim: []const u8, comptime xs: [][]const u8) []const u8 {
    var buf: []const u8 = "";
    for (xs) |x, i| {
        buf = buf ++ x;
        if (i < xs.len - 1) buf = buf ++ delim;
    }
    return buf;
}

fn _arr_i_to_s(x: anytype) [][]const u8 {
    var res: [x.len][]const u8 = undefined;
    for (x) |item, i| {
        res[i] = std.fmt.comptimePrint("{}", .{item});
    }
    return &res;
}

fn _make_csi_seq(comptime c: []const u8, comptime x: anytype) []const u8 {
    return Escape.csi ++ _join(";", _arr_i_to_s(x)) ++ c;
}
