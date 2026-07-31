local terminal    = "uwsm app -- kitty"
local fileManager = "thunar"
local menu        = "uwsm app -- fuzzel --no-exit-on-keyboard-focus-loss --launch-prefix=\"uwsm app -- \""
local browser     = "uwsm app -- librewolf"
local discord     = "uwsm app -- vesktop -enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland"
local mainMod     = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F11", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(discord))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("uwsm app -- keepassxc"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("uwsm app -- deezer-desktop"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("uwsm app -- tutanota-desktop --ozone-platform=wayland"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("uwsm app -- steam"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("uwsm app -- bash -c '/home/dibbli/Documents/scripts/misc/steam-status.sh'"))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only --freeze --silent"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screengif.sh"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only --silent"))

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | uwsm app -- fuzzel -d | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("uwsm app -- rm ~/.cache/cliphist/db"))
hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd("uwsm app -- bemoji -n"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + page_up", hl.dsp.exec_cmd("busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -500"))
hl.bind(mainMod .. " + page_down", hl.dsp.exec_cmd("busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +500"))
hl.bind(mainMod .. " + home", hl.dsp.exec_cmd("busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 6500"))

hl.bind(mainMod .. " + G", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move focus
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Workspaces on the number row, and mirrored on the numpad
local numpadKeys = { "KP_End", "KP_Down", "KP_Next", "KP_Left", "KP_Begin",
                     "KP_Right", "KP_Home", "KP_Up", "KP_Prior", "KP_Insert" }

for i = 1, 10 do
    local ws  = tostring(i)
    local row = tostring(i % 10) -- workspace 10 sits on key 0
    local pad = numpadKeys[i]

    hl.bind(mainMod .. " + " .. row, hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. row, hl.dsp.window.move({ workspace = ws, follow = true }))
    hl.bind(mainMod .. " + " .. pad, hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. pad, hl.dsp.window.move({ workspace = ws, follow = true }))
end

hl.bind(mainMod .. " + O", hl.dsp.layout("swapwithmaster"))
hl.bind(mainMod .. " + R", hl.dsp.layout("orientationcycle left top"))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind(mainMod .. " + delete", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
