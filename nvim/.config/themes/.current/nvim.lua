-- Feeds the active Omarchy colorscheme into config.nvim, and hot-reloads it
-- when the Omarchy theme changes.
--
-- lua/nurikjohn/plugins/color-scheme.lua dofiles this path when it exists and
-- falls back to the github-theme default when it does not.
--
-- Omarchy ships each theme as a LazyVim spec: the colorscheme plugin plus a
-- "LazyVim/LazyVim" entry carrying opts.colorscheme. config.nvim runs plain
-- lazy.nvim, so that entry is stripped and the colorscheme applied directly.
--
-- color-scheme.lua calls dofile unguarded, so a failure here would break
-- startup. Everything below is guarded and this file always returns a table.

local THEME_FILE = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
-- `omarchy theme set` does `rm -rf current/theme && mv current/next-theme
-- current/theme`, so the theme dir itself is destroyed and recreated. Watch the
-- parent, which is stable, and which also sees the final theme.name write.
local WATCH_DIR = vim.fn.expand("~/.config/omarchy/current")
local THEME_DIRS = {
  vim.fn.expand("~/.local/share/omarchy/themes"),
  vim.fn.expand("~/.config/omarchy/themes"),
}

local function fallback()
  local ok, spec = pcall(require, "nurikjohn.themes.default-theme")
  return ok and spec or {}
end

-- Split an Omarchy theme spec into its plugin entries and the colorscheme name.
local function parse(file)
  local ok, spec = pcall(dofile, file)
  if not ok or type(spec) ~= "table" then
    return nil, nil
  end

  local plugins, colorscheme = {}, nil
  for _, entry in ipairs(spec) do
    if type(entry) == "table" then
      if entry[1] == "LazyVim/LazyVim" then
        -- Only the colorscheme name is portable; the rest is LazyVim-specific.
        colorscheme = entry.opts and entry.opts.colorscheme
      elseif entry[1] then
        table.insert(plugins, entry)
      end
    end
  end
  return plugins, colorscheme
end

-- lazy.nvim registers plugins under their short name.
local function short_name(entry)
  return entry.name or entry[1]:match("[^/]+$")
end

local current, colorscheme = parse(THEME_FILE)
if not current or #current == 0 then
  return fallback()
end

local out, seen = {}, {}

-- The active theme loads at startup. opts is left intact so lazy.nvim still
-- runs setup(opts) for themes that need it, e.g. catppuccin's flavour.
for _, entry in ipairs(current) do
  entry.lazy = false
  entry.priority = entry.priority or 1000
  seen[entry[1]] = true
  table.insert(out, entry)
end

-- Every other Omarchy theme's plugin, cloned but not loaded. Without these a
-- switch to a theme whose plugin is missing would fail until :Lazy install.
for _, dir in ipairs(THEME_DIRS) do
  if vim.fn.isdirectory(dir) == 1 then
    for _, name in ipairs(vim.fn.readdir(dir)) do
      local file = dir .. "/" .. name .. "/neovim.lua"
      if vim.fn.filereadable(file) == 1 then
        local plugins = parse(file)
        for _, entry in ipairs(plugins or {}) do
          if not seen[entry[1]] then
            seen[entry[1]] = true
            table.insert(out, { entry[1], name = entry.name, lazy = true, priority = 1000 })
          end
        end
      end
    end
  end
end

local function apply(name)
  if name then
    pcall(vim.cmd.colorscheme, name)
  end
end

-- Re-read the theme and swap the colorscheme in a running session.
local function reload()
  local plugins, name = parse(THEME_FILE)
  if not plugins or not name then
    return
  end

  local names = {}
  for _, entry in ipairs(plugins) do
    table.insert(names, short_name(entry))
    -- The preloaded specs carry no opts, so re-run setup with the new theme's
    -- (catppuccin-latte's flavour, for instance) before switching.
    if entry.opts then
      local mod = short_name(entry):gsub("%.nvim$", "")
      pcall(function()
        require(mod).setup(entry.opts)
      end)
    end
  end

  pcall(function()
    require("lazy").load({ plugins = names })
  end)

  vim.schedule(function()
    apply(name)
    vim.cmd("redraw!")
  end)
end

table.insert(out, {
  dir = vim.fn.stdpath("config"),
  name = "omarchy-colorscheme",
  lazy = false,
  priority = 999,
  config = function()
    apply(colorscheme)

    local fs = vim.uv.new_fs_event()
    if not fs then
      return
    end

    -- A single theme change fires several events; coalesce them.
    local timer
    fs:start(WATCH_DIR, {}, function(err)
      if err then
        return
      end
      if timer then
        timer:stop()
        timer:close()
      end
      timer = vim.uv.new_timer()
      timer:start(
        300,
        0,
        vim.schedule_wrap(function()
          if timer then
            timer:stop()
            timer:close()
            timer = nil
          end
          reload()
        end)
      )
    end)

    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        pcall(function()
          fs:stop()
        end)
      end,
    })
  end,
})

return out
