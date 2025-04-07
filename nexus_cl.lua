-- [ Full clientside Nexus script ]
-- handles voting UI, spook effect, and chat command help
net.Receive("nexus_vote_open", function()
    local maps = net.ReadTable()
    local title = net.ReadString()

    local frame = vgui.Create("DFrame")
    frame:SetTitle(title)
    frame:SetSize(400, 300)
    frame:Center()
    frame:MakePopup()

    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:AddColumn("Map Name")

    for _, map in ipairs(maps) do
        list:AddLine(map)
    end

    list.OnRowSelected = function(_, id, line)
        local selected = line:GetColumnText(1)
        net.Start("nexus_vote_choice")
        net.WriteString(selected)
        net.SendToServer()
        frame:Close()
    end
end)

net.Receive("nexus_spook", function()
    local texture = net.ReadString()
    local duration = net.ReadFloat()

    local overlay = vgui.Create("DHTML")
    overlay:Dock(FILL)
    overlay:SetHTML([[
        <html><body style="margin:0;padding:0;overflow:hidden;background:black;">
        <img src="]] .. texture .. [[" style="width:100%;height:100%;object-fit:cover;">
        </body></html>
    ]])
    overlay:SetMouseInputEnabled(false)

    timer.Simple(duration, function()
        if IsValid(overlay) then overlay:Remove() end
    end)
end)

concommand.Add("spookpreview", function(_, _, args)
    local texture = args[1] or ""
    local duration = tonumber(args[2]) or 5
    local sound = args[3] or ""

    net.Start("nexus_spook_preview")
    net.WriteString(texture)
    net.WriteFloat(duration)
    net.WriteString(sound)
    net.SendToServer()
end)

hook.Add("OnPlayerChat", "NexusMenuCommand", function(ply, text)
    if ply ~= LocalPlayer() then return end
    if string.lower(text) == "!nexusmenu" then
        RunConsoleCommand("nexus_help")
        return true
    end
end)

concommand.Add("nexus_help", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Nexus Help Menu")
    frame:SetSize(400, 300)
    frame:Center()
    frame:MakePopup()

    local label = vgui.Create("DLabel", frame)
    label:SetText("Available Nexus Commands:\n- votemap <time> <title> <nothanks 0/1> <sound>\n- spook <img> <target> <time> <sound>\n- !nexusmenu - opens this help\n- !bot (max 5 bots)\n- !kickbots\n")
    label:SetWrap(true)
    label:SetSize(380, 260)
    label:SetPos(10, 30)
end)
