-- hyprland.lua — meloworld
-- Translated from MangoWM config for Hyprland 0.55+
-- Ref: https://wiki.hypr.land/Configuring/Start/

-- ─── MONITORS ────────────────────────────────────────────────────────────────
hl.monitor({
  output = "",
  mode = "preferred", -- fixed typo
  position = "auto",
  scale = "1",
})

-- ─── ENVIRONMENT VARIABLES ───────────────────────────────────────────────────
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "22")
hl.env("HYPRCURSOR_SIZE", "22")

-- ─── AUTOSTART ───────────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("quickshell")
  hl.exec_cmd("wl-paste --type text  --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/nightlight.sh")
  hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/chime.sh")
  hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/usb-sound.sh")
  hl.exec_cmd("hypridle")
end)

-- ─── LOOK AND FEEL ───────────────────────────────────────────────────────────
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 4,

    col = {
      active_border   = { colors = { "rgba(80cbc4ff)" }, angle = 0 },
      inactive_border = "rgba(37474fff)",
    },

    layout = "master",
    resize_on_border = true,
    allow_tearing = false,
  },

  decoration = {
    rounding = 8,
    rounding_power = 2,

    active_opacity = 1.0,
    inactive_opacity = 1.0,

    dim_inactive = false,

    shadow = {
      enabled = false,
      range = 10,
      render_power = 3,
      color = "rgba(000000ff)",
    },

    blur = {
      enabled = true,
      size = 8,
      passes = 4,
      noise = 0.02,
      brightness = 0.9,
      contrast = 0.9,
      vibrancy = 0.0,
      new_optimizations = true,
    },
  },

  animations = {
    enabled = true,
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    focus_on_activate = true,
  },
})

-- ─── LAYOUTS ─────────────────────────────────────────────────────────────────
hl.config({
  master = {
    new_status = "master",
    mfact = 0.5,
  },

  dwindle = {
    preserve_split = true,
    force_split = 0,
  },
})

-- ─── INPUT ───────────────────────────────────────────────────────────────────
hl.config({
  input = {
    kb_layout = "tr",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    repeat_rate = 25,
    repeat_delay = 600,

    numlock_by_default = true,

    follow_mouse = 1,
    mouse_refocus = true,

    sensitivity = -0.2,
    accel_profile = "flat",
    natural_scroll = false,

    touchpad = {
      natural_scroll = true,
      disable_while_typing = true,
      tap_to_click = true,
      drag_lock = true,
      clickfinger_behavior = false,
      middle_button_emulation = false,
    },
  },
})

-- ─── BEZIER CURVES ───────────────────────────────────────────────────────────
-- Same motion language, but front-loaded — covers distance fast, settles briefly.
-- The "weight" now comes from the landing, not the overall duration.

-- Open: rockets in immediately, very short soft landing at the end
hl.curve("meloOpen", { type = "bezier", points = { { 0.0, 0.85 }, { 0.0, 1.0 } } })

-- Close: instant acceleration out — gone before you think about it
hl.curve("meloClose", { type = "bezier", points = { { 0.55, 0.0 }, { 1.0, 1.0 } } })

-- Move: pure ease-out, very responsive
hl.curve("meloMove", { type = "bezier", points = { { 0.0, 0.0 }, { 0.1, 1.0 } } })

-- Fade: slightly asymmetric — fades in quick, out a touch slower
hl.curve("meloFade", { type = "bezier", points = { { 0.3, 0.0 }, { 0.5, 1.0 } } })

-- Workspace: aggressive ease-out — snaps across, firm landing
hl.curve("meloWorkspace", { type = "bezier", points = { { 0.0, 0.9 }, { 0.1, 1.0 } } })

-- ─── ANIMATIONS ──────────────────────────────────────────────────────────────

-- Windows open: gnomed style — slides in from the top edge of the window origin,
-- then settles. Weighted, not bouncy. Matches the "dropping onto the canvas" feel.
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.8, bezier = "meloOpen", style = "gnomed" })

-- Windows close: popin to 95% — shrinks away quickly and cleanly.
-- 95% means barely any scale change, so it reads as "pulling back" not "shrinking"
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.0, bezier = "meloClose", style = "popin 95%" })

-- Parent fallback
hl.animation({ leaf = "windows", enabled = true, speed = 2.8, bezier = "meloOpen" })

-- Move/resize: snappy, grounded
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.2, bezier = "meloMove" })

-- Fades: all soft, all consistent
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.8, bezier = "meloFade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.0, bezier = "meloFade" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 2.0, bezier = "meloFade" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 2.0, bezier = "meloFade" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2.5, bezier = "meloFade" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "meloFade" })

-- Layers (bar, launcher, quickshell panels): slide from edge, land firmly
hl.animation({ leaf = "layersIn", enabled = true, speed = 2.5, bezier = "meloOpen", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.8, bezier = "meloClose", style = "slide" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2.5, bezier = "meloFade" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.8, bezier = "meloFade" })
hl.animation({ leaf = "layers", enabled = true, speed = 2.5, bezier = "meloOpen" })

-- Workspaces: slidefade with low percentage = mostly slide, hint of fade
-- The heavy curve makes it feel like turning a thick page
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 3.2, bezier = "meloWorkspace", style = "slidefade 10%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 3.2, bezier = "meloWorkspace", style = "slidefade 10%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.2, bezier = "meloWorkspace", style = "slidefade 10%" })

-- Border: subtle, slow fade on focus change
hl.animation({ leaf = "border", enabled = true, speed = 2.0, bezier = "meloFade" })

-- Zoom: kept modest
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 3.0, bezier = "meloOpen" })

-- ─── LAYER RULES ─────────────────────────────────────────────────────────────
hl.layer_rule({
  match = { namespace = "selection" },
  blur = false,
  no_anim = true,
})

hl.layer_rule({
  match = { namespace = "polkit-dialog" },
  blur = false,
})

-- ─── WINDOW RULES ────────────────────────────────────────────────────────────
hl.window_rule({
  match = { title = "nmtui" },
  float = true,
  size = { 600, 400 },
})

hl.window_rule({
  match = { class = "com.mitchellh.ghostty" },
  float = true,
  size = { 860, 600 },
})

hl.window_rule({
  match = { class = "Spotify" },
  float = true,
  size = { 1600, 900 },
})

hl.window_rule({
  match = { class = "org.gnome.Nautilus" },
  float = true,
  size = { 900, 600 },
})

hl.window_rule({
  match = { title = "Vesktop" },
  float = true,
  size = { 1400, 860 },
})

-- Suppress maximize requests globally
hl.window_rule({
  name = "suppress-maximize",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix XWayland floating drag issues
hl.window_rule({
  name = "fix-xwayland-drags",
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

-- ─── KEY BINDINGS ─────────────────────────────────────────────────────────────
local M = "SUPER"

-- ─── Session ─────────────────────────────────────────────────────────────────
hl.bind(M .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(M .. " + SHIFT + Escape", hl.dsp.exit())
hl.bind(M .. " + SHIFT + L", hl.dsp.exec_cmd("quickshell -c " .. os.getenv("HOME") .. "/.config/quickshell/lockscreen"))

-- ─── Launch ──────────────────────────────────────────────────────────────────
hl.bind("ALT + space", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(M .. " + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind(M .. " + E", hl.dsp.exec_cmd("qs ipc call launcher openEmoji"))
hl.bind(M .. " + V", hl.dsp.exec_cmd("qs ipc call launcher openClipboard"))
hl.bind(M .. " + W", hl.dsp.exec_cmd("qs ipc call launcher openWallpaper"))
hl.bind(M .. " + N", hl.dsp.exec_cmd("nautilus"))

-- ─── Window: Lifecycle ───────────────────────────────────────────────────────
hl.bind(M .. " + Q", hl.dsp.window.close())

-- ─── Window: Focus (vi-style hjkl) ───────────────────────────────────────────
hl.bind(M .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(M .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(M .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(M .. " + J", hl.dsp.focus({ direction = "d" }))

-- ─── Window: Overview & Cycle stack ──────────────────────────────────────────
hl.bind(M .. " + Tab", hl.dsp.workspace.toggle_special("overview"))
hl.bind(M .. " + SHIFT + Tab", hl.dsp.layout("cyclenext"))

-- ─── Window: Swap ────────────────────────────────────────────────────────────
hl.bind(M .. " + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
hl.bind(M .. " + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))
hl.bind(M .. " + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))

-- ─── Window: State ───────────────────────────────────────────────────────────
hl.bind(M .. " + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(M .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(M .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(M .. " + comma", hl.dsp.window.move({ workspace = "special:minimized" }))
hl.bind(M .. " + SHIFT + comma", hl.dsp.workspace.toggle_special("minimized"))
hl.bind(M .. " + grave", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(M .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- ─── Layout ──────────────────────────────────────────────────────────────────
do
  local layouts = { "master", "dwindle" }
  local idx = 1
  hl.bind(M .. " + ALT + space", function()
    idx = (idx % #layouts) + 1
    hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword general:layout " .. layouts[idx]))
  end)
end

-- ─── Gaps ────────────────────────────────────────────────────────────────────
hl.bind(M .. " + ALT + equal", function()
  local g = hl.get_config("general.gaps_in") + 1
  hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword general:gaps_in " .. g))
  hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword general:gaps_out " .. (g * 2)))
end)
hl.bind(M .. " + ALT + minus", function()
  local g = math.max(0, hl.get_config("general.gaps_in") - 1)
  hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword general:gaps_in " .. g))
  hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword general:gaps_out " .. (g * 2)))
end)
hl.bind(M .. " + ALT + G", function()
  local g = hl.get_config("general.gaps_in")
  if g > 0 then
    hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword general:gaps_in 0"))
    hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword general:gaps_out 0"))
  else
    hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword general:gaps_in 5"))
    hl.dispatch(hl.dsp.exec_cmd("hyprctl keyword general:gaps_out 10"))
  end
end)

-- ─── Workspaces: Switch ──────────────────────────────────────────────────────
hl.bind(M .. " + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(M .. " + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + CTRL + left", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(M .. " + CTRL + right", hl.dsp.window.move({ workspace = "e+1" }))

for i = 1, 9 do
  hl.bind(M .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(M .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- ─── Monitor: Focus / Move ───────────────────────────────────────────────────
hl.bind("ALT + SHIFT + left", hl.dsp.focus({ monitor = "l" }))
hl.bind("ALT + SHIFT + right", hl.dsp.focus({ monitor = "r" }))
hl.bind(M .. " + ALT + left", hl.dsp.window.move({ monitor = "l" }))
hl.bind(M .. " + ALT + right", hl.dsp.window.move({ monitor = "r" }))

-- ─── Window: Move (Floating) ─────────────────────────────────────────────────
hl.bind("CTRL + SHIFT + up", hl.dsp.window.move({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind("CTRL + SHIFT + down", hl.dsp.window.move({ x = 0, y = 20, relative = true }), { repeating = true })
hl.bind("CTRL + SHIFT + left", hl.dsp.window.move({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind("CTRL + SHIFT + right", hl.dsp.window.move({ x = 20, y = 0, relative = true }), { repeating = true })

-- ─── Window: Resize ──────────────────────────────────────────────────────────
hl.bind("CTRL + ALT + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind("CTRL + ALT + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
hl.bind("CTRL + ALT + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind("CTRL + ALT + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })

-- ─── Mouse: Move / Resize ────────────────────────────────────────────────────
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ─── Scroll: Workspace Navigation ────────────────────────────────────────────
hl.bind(M .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ─── Media & Hardware Keys ───────────────────────────────────────────────────
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- ─── Media Controls ──────────────────────────────────────────────────────────
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ─── Screenshot ──────────────────────────────────────────────────────────────
hl.bind(M .. " + SHIFT + S", hl.dsp.exec_cmd("sh -c 'grim /tmp/qs-master.png; qs ipc call screenshot capture'"))
