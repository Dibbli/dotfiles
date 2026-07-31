------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1.0 })
hl.monitor({ output = "",      mode = "preferred",    position = "auto",  scale = 1.0 })

for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1", persistent = true })
end
for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", persistent = true })
end

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- waybar")
    hl.exec_cmd("uwsm app -- hyprpaper")
    hl.exec_cmd("uwsm app -- /usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("uwsm app -- nm-applet")
    hl.exec_cmd("uwsm app -- dunst")
    hl.exec_cmd("uwsm app -- wl-gammarelay-rs")
    hl.exec_cmd("uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("rm ~/.cache/cliphist/db")
    hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
    hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
    hl.exec_cmd("sleep 5 && uwsm app -- keepassxc", { workspace = "1 silent" })
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 3,
        gaps_out = 6,

        border_size = 1,

        col = {
            active_border   = { colors = { "rgba(D79921ee)", "rgba(fabd2fee)" }, angle = 45 },
            inactive_border = "rgba(665c54ee)",
        },

        resize_on_border = true,
        allow_tearing    = false,

        layout = "master",
    },

    decoration = {
        rounding = 10,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    master = {
        new_status = "slave",
    },

    misc = {
        force_default_wallpaper = 0,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })

---------------
---- INPUT ----
---------------

-- Built-in keyboard runs Colemak DH; the flashed Keychron does its own layout in firmware.
hl.config({
    input = {
        numlock_by_default = true,

        kb_layout  = "us,us,hu",
        kb_variant = "colemak,,",
        kb_options = "ctrl:nocaps,grp:win_space_toggle",

        follow_mouse = 1,
        sensitivity  = 0,

        accel_profile = "flat", -- fixes Sober/Roblox unlocked-cursor accel

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.device({
    name       = "keychron-keychron-q10-max-keyboard",
    kb_layout  = "us",
    kb_variant = "",
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

---------------------
---- KEYBINDINGS ----
---------------------

require("binds")
