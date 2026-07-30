-- Migrated from hyprland.conf + binds.conf (native Lua, Hyprland 0.55+)
-- hyprland.conf is kept as a fallback until this is confirmed working.

----------------------------------------------------------------------
-- PROGRAMS
----------------------------------------------------------------------
local mod     = "SUPER"
local term    = "uwsm app -- kitty"
local files   = "thunar"
local menu    = 'uwsm app -- fuzzel --no-exit-on-keyboard-focus-loss --launch-prefix="uwsm app -- "'
local browser = "uwsm app -- librewolf"
local discord = "uwsm app -- vesktop -enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland"

----------------------------------------------------------------------
-- MONITORS
----------------------------------------------------------------------
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "1920x0", scale = "auto" })
hl.monitor({ output = "DVI-D-1",  mode = "preferred", position = "0x0",    scale = "auto" })

for i = 1, 5 do
  hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", default = (i == 1) })
end
for i = 6, 10 do
  hl.workspace_rule({ workspace = tostring(i), monitor = "DVI-D-1", default = (i == 6) })
end

----------------------------------------------------------------------
-- LOOK AND FEEL
----------------------------------------------------------------------
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
    allow_tearing = false,
    layout = "master",
  },

  decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  master = { new_status = "slave" },

  misc = { force_default_wallpaper = 0 },

  cursor = { no_hardware_cursors = true },

  input = {
    numlock_by_default = true,
    kb_layout  = "us, hu",
    kb_variant = "colemak, colemak",
    kb_options = "grp:win_space_toggle,altwin:swap_alt_win",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = { natural_scroll = false },
  },

  opengl = { nvidia_anti_flicker = false },
  render = { new_render_scheduling = true },
  animations = { enabled = true },
})

-- Animations
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })

-- Per-device
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

----------------------------------------------------------------------
-- WINDOW RULES
----------------------------------------------------------------------
-- Fix some dragging issues with XWayland
hl.window_rule({
  name = "fix-xwayland-drags",
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  no_focus = true,
})
-- Center the ssh/FIDO askpass prompt instead of tiling it
hl.window_rule({
  name = "float-askpass",
  match = { class = "^(lxqt-openssh-askpass)$" },
  float = true,
  center = true,
})

----------------------------------------------------------------------
-- AUTOSTART
----------------------------------------------------------------------
hl.on("hyprland.start", function()
  hl.exec_cmd(term)
  hl.exec_cmd("hyprctl output create headless") -- virtual output for Moonlight streaming
  hl.exec_cmd("uwsm app -- waybar")
  hl.exec_cmd("uwsm app -- hyprpaper")
  hl.exec_cmd("uwsm app -- /usr/lib/polkit-kde-authentication-agent-1")
  hl.exec_cmd("uwsm app -- nm-applet")
  hl.exec_cmd("uwsm app -- dunst")
  hl.exec_cmd("uwsm app -- wl-gammarelay-rs")
  hl.exec_cmd("uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("uwsm app -- rm ~/.cache/cliphist/db")
  hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
  hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
  hl.exec_cmd("sleep 5 && uwsm app -- keepassxc", { workspace = "6 silent" })
end)

----------------------------------------------------------------------
-- KEYBINDINGS
----------------------------------------------------------------------
hl.bind(mod .. " + T", hl.dsp.exec_cmd(term))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + M", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mod .. " + F", hl.dsp.exec_cmd(files))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F11", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + Tab", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(discord))
hl.bind(mod .. " + P", hl.dsp.exec_cmd("uwsm app -- keepassxc"))
hl.bind(mod .. " + Y", hl.dsp.exec_cmd("uwsm app -- deezer-desktop"))
hl.bind(mod .. " + U", hl.dsp.exec_cmd("uwsm app -- tutanota-desktop --ozone-platform=wayland"))
hl.bind(mod .. " + S", hl.dsp.exec_cmd("uwsm app -- steam"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("uwsm app -- bash -c '/home/dibbli/Documents/scripts/misc/steam-status.sh'"))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only --freeze --silent"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screengif.sh"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only --silent"))

hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | uwsm app -- fuzzel -d | cliphist decode | wl-copy"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("uwsm app -- rm ~/.cache/cliphist/db"))
hl.bind(mod .. " + Period", hl.dsp.exec_cmd("uwsm app -- bemoji -n"))
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- Gamma / color temperature
hl.bind(mod .. " + Page_Up",   hl.dsp.exec_cmd("busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -500"))
hl.bind(mod .. " + Page_Down", hl.dsp.exec_cmd("busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +500"))
hl.bind(mod .. " + Home",      hl.dsp.exec_cmd("busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 6500"))

-- Special workspace (magic)
hl.bind(mod .. " + G", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + G", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move focus
hl.bind(mod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Workspaces (number row): 1-9, 0 -> 10
for i = 1, 10 do
  local key = tostring(i % 10) -- 10 -> "0"
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i), follow = true }))
end

-- Workspaces (numpad): keypad key -> workspace number
local kp = {
  KP_End = 1, KP_Down = 2, KP_Next = 3, KP_Left = 4, KP_Begin = 5,
  KP_Right = 6, KP_Home = 7, KP_Up = 8, KP_Prior = 9, KP_Insert = 10,
}
for key, ws in pairs(kp) do
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = tostring(ws) }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(ws), follow = true }))
end

-- Master layout
hl.bind(mod .. " + O", hl.dsp.layout("swapwithmaster"))
hl.bind(mod .. " + R", hl.dsp.layout("orientationcycle left top"))

-- Scroll through workspaces
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys (repeat + work while locked/inhibited)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
hl.bind(mod .. " + Delete", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { repeating = true, locked = true })

-- Media control (work while locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
