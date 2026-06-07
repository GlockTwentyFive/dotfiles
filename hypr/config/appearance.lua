local currentLayout = "scrolling"

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  general = {
    snap             = {
      enabled = true,
    },

    gaps_in          = 5,
    gaps_out         = 10,

    border_size      = 4,

    col              = {
      active_border   = "rgba(80cbc4ff)",
      inactive_border = "rgba(37474fff)",
    },

    -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = true,

    -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
    allow_tearing    = true,

    layout           = currentLayout,
  },


  decoration = {
    rounding         = 7,
    rounding_power   = 3,

    -- Change transparency of focused and unfocused windows
    active_opacity   = 1.0,
    inactive_opacity = 1.0,

    shadow           = {
      enabled      = false,
      range        = 4,
      render_power = 3,
      color        = 0xee1a1a1a,
    },

    blur             = {
      enabled           = true,
      size              = 8,
      passes            = 4,
      noise             = 0.02,
      brightness        = 0.9,
      contrast          = 0.9,
      vibrancy          = 0.0,
      new_optimizations = true,
      xray              = true,
    },
  },

  animations = {
    enabled = true,
  },
})


-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
  dwindle = {
    preserve_split = true, -- You probably want this
    force_split = 0
  },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
  master = {
    new_status = "master",
  },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
  scrolling = {
    fullscreen_on_one_column = true,
    column_width = 0.98
  },
})
