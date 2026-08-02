return function()
    local active = hl.get_active_window()

    if active and active.class == "spotify" then
        hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
    else
        hl.exec_cmd("spotify-launcher")
    end
end
