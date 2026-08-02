return function()
    local active = hl.get_active_window()

    if active and active.class == "steam" then
        hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
    else
        hl.exec_cmd("steam")
    end
end
