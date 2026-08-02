-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

hl.monitor({
    output = "DP-4",
    mode = "1920x1080@165",
    position = "0x0",
    scale = 1,
})

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("xdg-desktop-portal-hyprland")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("quickshell")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT5_STYLE_OVERRIDE", "qt5ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-----------------------
---- LOOK AND FEEL ----
-----------------------

require("ui")

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        vrr = true,
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,

        -- Focus browsers when they request activation after a link is clicked.
        focus_on_activate = true,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity = -0.3,
        accel_profile = "flat",
    },
    cursor = {
        no_warps = true,
    },
})

---------------------
---- KEYBINDINGS ----
---------------------

require("keybindings")

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.layer_rule({
    name = "quickshell-blur",
    match = { namespace = "quickshell" },
    blur = true,
})

hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "xwayland-float-no-focus",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "floation-pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    size = "440 247",
    move = "10 10",
})

hl.window_rule({
    name = "ai-agent-cli-float",
    match = { class = "^(ai-agent-cli)$" },
    animation = "slide left",
    float = true,
    pin = true,
    opacity = "0.95",
})

-- Special workspaces.
hl.window_rule({
    name = "switch-to-browser",
    match = { class = "^([Zz]en.*)$" },
    workspace = 10,
})

hl.window_rule({
    name = "switch-to-music",
    match = { class = "^([Ss]potify.*)$" },
    workspace = 11,
})

hl.window_rule({
    name = "switch-to-steam",
    match = { title = "^(Steam)$" },
    workspace = 12,
})
