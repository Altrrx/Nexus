-- [NEXUS v3.0 Server]

util.AddNetworkString("nexus_open_gui")
util.AddNetworkString("nexus_cmd_run")
util.AddNetworkString("nexus_plugins_sync")

NEXUS = NEXUS or {}
NEXUS.Commands = NEXUS.Commands or {}

-- Function to register a command
function NEXUS:RegisterCommand(name, command)
    self.Commands[name] = command
end

-- Load server-side plugins
local function LoadPlugins()
    local pluginFolder = "plugins/"
    local _, dirs = file.Find(pluginFolder .. "*", "LUA")

    for _, dir in ipairs(dirs) do
        local svFile = pluginFolder .. dir .. "/plugin_sv.lua"
        if file.Exists(svFile, "LUA") then
            include(svFile)
            AddCSLuaFile(pluginFolder .. dir .. "/plugin_cl.lua")
        end
    end
end

-- Handle command execution
net.Receive("nexus_cmd_run", function(len, ply)
    local cmd = net.ReadString()
    local args = net.ReadTable()

    local command = NEXUS.Commands[cmd]
    if command and (not IsValid(ply) or ply:IsAdmin()) then
        command.Run(ply, args)
    end
end)

-- Open GUI command
concommand.Add("nexus_menu", function(ply)
    net.Start("nexus_open_gui")
    net.Send(ply)
end)

-- Send plugin data to clients
hook.Add("PlayerInitialSpawn", "nexus_send_plugins", function(ply)
    net.Start("nexus_plugins_sync")
    net.WriteTable(NEXUS.Commands)
    net.Send(ply)
end)

-- Initialize plugins
LoadPlugins()
