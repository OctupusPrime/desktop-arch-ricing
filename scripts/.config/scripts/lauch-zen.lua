return function()
    local active = hl.get_active_window()

    if active and active.class == "zen" and active.initial_title == "Zen Browser" then
        hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
        return
    end

    for _, window in ipairs(hl.get_windows({ class = "zen" })) do
        if window.initial_title == "Zen Browser" then
            hl.dispatch(hl.dsp.focus({ window = window }))
            return
        end
    end

    hl.exec_cmd("zen-browser")
end
