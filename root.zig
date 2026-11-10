//! tuios: a theme of its own for the terminal and the window manager's chrome.

const std = @import("std");

/// The tuios theme; build one with `from`.
pub const App = @import("App.zig");
/// Colors from the theme.
pub const from = App.from;
/// The adapter the app writes the theme with, so a config needs only this package.
pub const json_adapter = @import("kosm_json").adapter;
/// The adapter the app selects the theme in tuios' config with.
pub const toml_adapter = @import("kosm_toml").adapter;

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(App);
}
