---@module 'hl'

local mainMod = "CAPS"

local ipc="noctalia msg "

local launcher="flatpak run io.github.flattool.Warehouse"

hl.config({
    animations = {
        enabled = false,
    },
})

hl.bind(mainMod .. " + " .. "down", hl.dsp.window.close())

hl.bind(mainMod .. " + " .. "left", hl.dsp.window.cycle_next({next=false}))

hl.bind(mainMod .. " + " .. "right", hl.dsp.window.cycle_next({next=true}))

hl.bind(mainMod .. " + " .. "up", hl.dsp.window.fullscreen({mode="maximized"}))

hl.bind(mainMod .. " + " .. "Return", hl.dsp.exec_cmd("pkill wvkbd || wvkbd-mobintl"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer --allow-boost -i 10"))

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer --allow-boost -d 10"))

hl.bind(mainMod.." + XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc.."brightness-down"))

hl.bind(mainMod.." + XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc.."brightness-up"))

hl.config({
    general={
        border_size=0,
        gaps_in=0,
        gaps_out=0,
    },
})

hl.config({
    input = {
        kb_options = "caps:swapescape",
        touchdevice={transform=3},
    },
})

hl.monitor({
    output   = "eDP-1",
    mode     = "800x1280@60",
    position = "0x0",
    scale    = 1,
    transform=3,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
    mirror="eDP-1",
})

hl.window_rule({
    name="maximize",
    match={
        class=".*",
    },
    maximize=true,
})

hl.on("window.destroy",function()
    local clients = hl.get_windows()
    if #clients == 0 then
        hl.dispatch(hl.dsp.exec_cmd(launcher))
    end
end)

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd(launcher)
    hl.exec_cmd("noctalia")
    hl.exec_cmd("pamixer --allow-boost --set-volume 150")
    hl.exec_cmd(ipc.."brightness-set 30%")
end)

