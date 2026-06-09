---------------------
---- KEYBINDINGS ----
---------------------

local mainMod  = "SUPER"
local terminal = "kitty"

-- Apps
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("uwsm-app -- " .. terminal))

-- Window Management
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Logout
hl.bind(mainMod .. " + P",
  hl.dsp.exec_cmd("uwsm stop"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })


-- Launcher
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("qs ipc call launcher openEmoji"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("qs ipc call launcher openClipboard"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("qs ipc call launcher openWallpaper"))

-- ─── Window: Swap ────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "u" }))

-- Lockscreen
hl.bind(mainMod .. " + L",
  hl.dsp.exec_cmd("uwsm-app -- quickshell -c " .. os.getenv("HOME") .. "/.config/quickshell/lockscreen"))

-- Screenshot
hl.bind("SUPER + Print",
  hl.dsp.exec_cmd('uwsm-app -- grim -g "$(slurp -d)" - | tee ~/Pictures/Screenshots/$(date +"%s_grim.png") | wl-copy'))
hl.bind("Print", hl.dsp.exec_cmd("uwsm-app -- grim - | tee ~/Pictures/Screenshots/$(date +'%s_grim.png') | wl-copy"))

-- Toggle Gaps
hl.bind(mainMod .. " + SHIFT + G", function()
  local gapsInValueTable = hl.get_config("general.gaps_in")

  if gapsInValueTable.top == 5 then
    hl.config({
      general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
      },
      decoration = {
        rounding = 0
      }
    })
  else
    hl.config({
      general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 3
      },
      decoration = {
        rounding = 7
      }
    })
  end
end)

-- Cycle Layouts
hl.bind(mainMod .. " + tab", function()
  local layouts     = { "scrolling", "dwindle", "master", "monocle" }
  local workspace   = hl.get_active_workspace()
  local next_layout = "dwindle"

  if not workspace then
    return
  end

  for i = 1, #layouts do
    if layouts[i] == workspace.tiled_layout then
      local next_layout_idx = (i % #layouts) + 1
      next_layout = layouts[next_layout_idx]
      break
    end
  end

  hl.workspace_rule({ workspace = workspace.name, layout = next_layout })
end)

-- Color Picker
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("uwsm-app -- hyprpicker -a -n"))
