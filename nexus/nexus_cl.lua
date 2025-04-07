-- [NEXUS v3.0 Client]

NEXUS = NEXUS or {}
NEXUS.Commands = NEXUS.Commands or {}

-- Function to create input fields based on parameter type
local function CreateInput(parent, param)
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, 5)
    panel:SetTall(25)

    local label = vgui.Create("DLabel", panel)
    label:SetText(param.Name .. ":")
    label:Dock(LEFT)
    label:SetWide(75)

    if param.Type == "vector2" or param.Type == "vector3" then
        local inputs = {}
        for _, subName in ipairs(param.SubParams) do
            local entry = vgui.Create("DTextEntry", panel)
            entry:Dock(LEFT)
            entry:DockMargin(0, 0, 5, 0)
            entry:SetWide(50)
            entry:SetPlaceholderText(subName)
            table.insert(inputs, entry)
        end
        panel.GetValue = function()
            local values = {}
            for _, input in ipairs(inputs) do
                table.insert(values, tonumber(input:GetValue()) or 0)
            end
            return values
        end
    else
        local entry = vgui.Create("DTextEntry", panel)
        entry:Dock(FILL)
        entry:SetPlaceholderText(param.Name)
        panel.GetValue = function()
            return entry:GetValue()
        end
    end

    return panel
end

-- Open Nexus GUI
net.Receive("nexus_open_gui", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Nexus Command Menu")
    frame:SetSize(600, 400)
    frame:Center()
    frame:MakePopup()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

    for cmd, data in pairs(NEXUS.Commands) do
        local cmdPanel = vgui.Create("DPanel", scroll)
        cmdPanel:Dock(TOP)
        cmdPanel:DockMargin(0, 0, 0, 10)
        cmdPanel:SetTall(100)

        local title = vgui.Create("DLabel", cmdPanel)
        title:SetText(cmd)
        title:SetFont("DermaLarge")
        title:Dock(TOP)

        local help = vgui.Create("DLabel", cmdPanel)
        help:SetText(data.Help)
        help:Dock(TOP)

        local inputPanels = {}
        for _, param in ipairs(data.Params) do
            local input = CreateInput(cmdPanel, param)
            table.insert(inputPanels, input)
        end

        local runBtn = vgui.Create("DButton", cmdPanel)
        runBtn:SetText("Run Command")
        runBtn:Dock(BOTTOM)
        runBtn.DoClick = function()
            local args = {}
            for _, input in ipairs(inputPanels) do
                table.insert(args, input:GetValue())
            end
            net.Start("nexus_cmd_run")
            net.WriteString(cmd)
            net.WriteTable(args)
            net.SendToServer()
        end
    end
end)

-- Sync commands from server
net.Receive("nexus_plugins_sync", function()
    NEXUS.Commands = net.ReadTable()
end)
