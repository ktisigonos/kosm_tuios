//! A tuios theme: the terminal's colors and the window manager's chrome, generated whole as a
//! theme of its own, which the app also selects in tuios' config. Field names are tuios'.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");

/// The theme file kosm owns, in tuios' themes directory; `{name}` is filled as `files` says.
/// Default: `~/.config/tuios/themes/{name}.json`.
file: []const u8 = "~/.config/tuios/themes/{name}.json",
/// How `{name}` in `file` is filled: `kosm`, or the kosmos' name. Default: the theme's `files`.
files: kosm.Theme.Files = .shared,
/// tuios' config, where the app sets `appearance.theme` to `id`; the key must be there already.
/// null: the config is not touched, and you select the theme yourself.
/// Default: `~/.config/tuios/config.toml`.
config: ?[]const u8 = "~/.config/tuios/config.toml",
/// The theme's name, as `appearance.theme` and `tuios --theme` take it. null (default): the
/// theme file's name without `.json` (`kosm`).
id: ?[]const u8 = null,
/// The name tuios shows for the theme. null (default): the theme's `name`, or the name kosm
/// applies the kosmos under.
display_name: ?[]const u8 = null,
/// The terminal's colors.
colors: Colors = .{},
/// The window manager's own colors.
chrome: Chrome = .{},

/// A theme's terminal colors. null: tuios' default.
pub const Colors = struct {
    /// Text in the default color.
    fg: ?kosm.Color = null,
    /// The default background.
    bg: ?kosm.Color = null,
    /// The cursor.
    cursor: ?kosm.Color = null,
    /// The selection's background.
    selection_bg: ?kosm.Color = null,
    /// ANSI black.
    black: ?kosm.Color = null,
    /// ANSI red.
    red: ?kosm.Color = null,
    /// ANSI green.
    green: ?kosm.Color = null,
    /// ANSI yellow.
    yellow: ?kosm.Color = null,
    /// ANSI blue.
    blue: ?kosm.Color = null,
    /// ANSI magenta.
    purple: ?kosm.Color = null,
    /// ANSI cyan.
    cyan: ?kosm.Color = null,
    /// ANSI white.
    white: ?kosm.Color = null,
    /// Bright black.
    bright_black: ?kosm.Color = null,
    /// Bright red.
    bright_red: ?kosm.Color = null,
    /// Bright green.
    bright_green: ?kosm.Color = null,
    /// Bright yellow.
    bright_yellow: ?kosm.Color = null,
    /// Bright blue.
    bright_blue: ?kosm.Color = null,
    /// Bright magenta.
    bright_purple: ?kosm.Color = null,
    /// Bright cyan.
    bright_cyan: ?kosm.Color = null,
    /// Bright white.
    bright_white: ?kosm.Color = null,
};

/// The window manager's colors. null: derived by tuios from the terminal colors.
pub const Chrome = struct {
    /// Focus, highlights and the active parts of tuios' own interface.
    accent: ?kosm.Color = null,
    /// Things that went well.
    success: ?kosm.Color = null,
    /// Warnings.
    warning: ?kosm.Color = null,
    /// Errors.
    @"error": ?kosm.Color = null,
    /// Informational text.
    info: ?kosm.Color = null,
    /// Panels and dialogs behind tuios' own interface.
    surface: ?kosm.Color = null,
};

/// Colors from the theme: foreground and background from their roles, the 8 ANSI colors from
/// the wheel and the bright ones a `lightness.bright` step brighter; the chrome's accent and
/// states from the accent, success, warning and error roles.
pub fn from(theme: kosm.Theme) App {
    const palette = theme.palette;
    const variations = theme.variations;
    const foreground = theme.roles.foreground;
    const background = theme.roles.background;
    var colors: Colors = .{
        .fg = foreground,
        .bg = background,
        .cursor = foreground,
        .selection_bg = variations.state.selected.apply(background),
        .black = palette.black,
        .red = palette.red,
        .green = palette.green,
        .yellow = palette.yellow,
        .blue = palette.blue,
        .purple = palette.magenta,
        .cyan = palette.cyan,
        .white = palette.white,
    };
    inline for (.{ "black", "red", "green", "yellow", "blue", "purple", "cyan", "white" }) |name| {
        @field(colors, "bright_" ++ name) = variations.lightness.bright.apply(@field(colors, name).?);
    }
    return .{
        .files = theme.files,
        .display_name = theme.name,
        .colors = colors,
        .chrome = .{
            .accent = theme.roles.accent,
            .success = theme.roles.success,
            .warning = theme.roles.warning,
            .@"error" = theme.roles.@"error",
            .info = foreground,
            .surface = background,
        },
    };
}

/// Writes the theme whole, and sets `appearance.theme` in `config` unless it is null.
pub fn apply(self: App, output: *kosm.Output) !void {
    const file = try output.namedFile(self.file, self.files);
    const id = self.id orelse std.Io.Dir.path.stem(file);
    if (id.len == 0) return output.fail(file, "'id' is empty; tuios selects a theme by it", .{});
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    try entries.appendSlice(output.allocator, &.{
        .{ .key = "id", .value = .{ .string = id } },
        .{ .key = "display_name", .value = .{ .string = try output.displayName(file, self.display_name) } },
    });
    try appendColors(output.allocator, &entries, self.colors);
    var chrome: std.ArrayList(kosm.Value.Entry) = .empty;
    try appendColors(output.allocator, &chrome, self.chrome);
    if (chrome.items.len != 0) try entries.append(output.allocator, .{ .key = "chrome", .value = .{ .table = chrome.items } });
    try output.generate(.{ .file = file, .lang = "json" }, kosm.Value{ .table = entries.items });
    const config = self.config orelse return;
    var settings = try output.edit(.{ .files = config, .lang = "toml" });
    try settings.set("appearance.theme", id);
}

fn appendColors(allocator: std.mem.Allocator, entries: *std.ArrayList(kosm.Value.Entry), colors: anytype) !void {
    inline for (@typeInfo(@TypeOf(colors)).@"struct".field_names) |name| {
        if (@field(colors, name)) |color| try entries.append(allocator, .{ .key = name, .value = .{ .color = color } });
    }
}

const testing = std.testing;
const root = @import("root.zig");

const Fixture = struct {
    tmp: testing.TmpDir,
    arena: std.heap.ArenaAllocator,
    plan: kosm.Plan,
    diagnostics: kosm.Diagnostics = .{},
    warnings: kosm.Warnings = undefined,
    home_buffer: [std.Io.Dir.max_path_bytes]u8 = undefined,
    output: kosm.Output = undefined,

    fn init(fixture: *Fixture, config: ?[]const u8) !void {
        fixture.* = .{ .tmp = testing.tmpDir(.{}), .arena = .init(testing.allocator), .plan = .init(testing.allocator, testing.io) };
        if (config) |text| {
            try fixture.tmp.dir.createDirPath(testing.io, ".config/tuios");
            try fixture.tmp.dir.writeFile(testing.io, .{ .sub_path = ".config/tuios/config.toml", .data = text });
        }
        fixture.warnings = .init(fixture.arena.allocator());
        const length = try fixture.tmp.dir.realPath(testing.io, &fixture.home_buffer);
        fixture.output = .{
            .allocator = fixture.arena.allocator(),
            .home = fixture.home_buffer[0..length],
            .adapters = &.{ root.json_adapter, root.toml_adapter },
            .plan = &fixture.plan,
            .diagnostics = &fixture.diagnostics,
            .warnings = &fixture.warnings,
            .app = "tuios",
            .kosmos = "krystallos.dark",
        };
    }

    fn deinit(fixture: *Fixture) void {
        fixture.plan.deinit();
        fixture.arena.deinit();
        fixture.tmp.cleanup();
    }

    fn planned(fixture: *Fixture, display_path: []const u8) []const u8 {
        for (fixture.plan.files.items) |file| {
            if (std.mem.eql(u8, file.display_path, display_path)) return file.new;
        }
        return "(not planned)";
    }
};

const test_theme = kosm.Theme.from(.{ .palette = .{ .black = kosm.hex("041c26"), .white = kosm.hex("a3c5cc"), .cyan = kosm.hex("2d8699") }, .mode = .dark });

test "the theme is written whole and selected in the config, which keeps its other bytes" {
    var fixture: Fixture = undefined;
    try fixture.init("[appearance]\nanimation_speed = 200\ntheme = \"ricer\" # picked by hand\n");
    defer fixture.deinit();
    try from(test_theme).apply(&fixture.output);

    const written = fixture.planned("~/.config/tuios/themes/kosm.json");
    try testing.expect(std.mem.startsWith(u8, written,
        \\{
        \\  "id": "kosm",
        \\  "display_name": "krystallos.dark",
        \\  "fg": "#a3c5cc",
        \\  "bg": "#041c26",
        \\
    ));
    try testing.expect(std.mem.indexOf(u8, written, "  \"chrome\": {\n    \"accent\": \"#2d8699\",\n") != null);
    try testing.expectEqualStrings("[appearance]\nanimation_speed = 200\ntheme = \"kosm\" # picked by hand\n", fixture.planned("~/.config/tuios/config.toml"));
}

test "a config without the theme key fails, and a null config is left alone" {
    var fixture: Fixture = undefined;
    try fixture.init("[appearance]\nanimation_speed = 200\n");
    defer fixture.deinit();
    try testing.expectError(error.NoMatch, from(test_theme).apply(&fixture.output));
    try testing.expectEqualStrings("~/.config/tuios/config.toml", fixture.diagnostics.file);

    var other: Fixture = undefined;
    try other.init(null);
    defer other.deinit();
    const app: App = .{ .config = null, .id = "mine" };
    try app.apply(&other.output);
    try testing.expectEqualStrings("{\n  \"id\": \"mine\",\n  \"display_name\": \"krystallos.dark\"\n}\n", other.planned("~/.config/tuios/themes/kosm.json"));
}

test "per kosmos, the theme is named and selected after the kosmos and shows the theme's name" {
    var fixture: Fixture = undefined;
    try fixture.init("[appearance]\ntheme = \"kosm\"\n");
    defer fixture.deinit();
    var theme = test_theme;
    theme.name = "Krystallos";
    theme.files = .per_kosmos;
    try from(theme).apply(&fixture.output);

    const written = fixture.planned("~/.config/tuios/themes/krystallos.dark.json");
    try testing.expect(std.mem.startsWith(u8, written, "{\n  \"id\": \"krystallos.dark\",\n  \"display_name\": \"Krystallos\",\n"));
    try testing.expectEqualStrings("[appearance]\ntheme = \"krystallos.dark\"\n", fixture.planned("~/.config/tuios/config.toml"));
}
