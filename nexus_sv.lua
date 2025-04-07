-- [ Full serverside Nexus script ]
-- handles spooking, voting, and bot control
util.AddNetworkString("nexus_spook")
util.AddNetworkString("nexus_vote_open")
util.AddNetworkString("nexus_vote_choice")
util.AddNetworkString("nexus_spook_preview")

local voteActive = false
local mapChoices = {}
local votes = {}

local function getMaps()
    local maps = {}
    for _, file in ipairs(file.Find("maps/*.bsp", "GAME")) do
        table.insert(maps, string.StripExtension(file))
    end
    return maps
end

local function playSound(path, target)
    if not path or path == "" then return end
    if target then
        target:EmitSound(path)
    else
        for _, p in ipairs(player.GetAll()) do
            p:EmitSound(path)
        end
    end
end

local function startVote(duration, title, nothanks, sound)
    if voteActive then return end
    voteActive = true
    mapChoices = getMaps()
    if nothanks then table.insert(mapChoices, "no thanks") end
    votes = {}

    for _, ply in ipairs(player.GetAll()) do
        net.Start("nexus_vote_open")
        net.WriteTable(mapChoices)
        net.WriteString(title)
        net.Send(ply)
    end

    playSound(sound)

    timer.Create("nexus_vote_timer", duration, 1, function()
        voteActive = false
        local count = {}
        for _, v in pairs(votes) do
            count[v] = (count[v] or 0) + 1
        end
        local winner, max = nil, 0
        for k, v in pairs(count) do
            if v > max then winner, max = k, v end
        end
        if winner and winner ~= "no thanks" then
            PrintMessage(HUD_PRINTTALK, "[NEXUS] changing map to: " .. winner)
            timer.Simple(3, function() RunConsoleCommand("changelevel", winner) end)
        else
            PrintMessage(HUD_PRINTTALK, "[NEXUS] vote ended. no change.")
        end
    end)
end

net.Receive("nexus_vote_choice", function(_, ply)
    local map = net.ReadString()
    if table.HasValue(mapChoices, map) then
        votes[ply:SteamID()] = map
    end
end)

net.Receive("nexus_spook_preview", function(_, ply)
    local texture = net.ReadString()
    local duration = net.ReadFloat()
    local sound = net.ReadString()

    net.Start("nexus_spook")
    net.WriteString(texture)
    net.WriteFloat(duration)
    net.Send(ply)

    playSound(sound, ply)
end)

concommand.Add("votemap", function(ply, _, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    local time = tonumber(args[1]) or 30
    local title = table.concat(args, " ", 2, #args - 2)
    local nothanks = tonumber(args[#args - 1]) == 1
    local sound = args[#args]
    startVote(time, title, nothanks, sound)
end)

concommand.Add("spook", function(ply, _, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    local texture = args[1] or ""
    local target = args[2] or ""
    local duration = tonumber(args[3]) or 5
    local sound = args[4] or ""
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Nick()), string.lower(target)) then
            net.Start("nexus_spook")
            net.WriteString(texture)
            net.WriteFloat(duration)
            net.Send(p)
            playSound(sound, p)
        end
    end
end)

hook.Add("PlayerSay", "NexusBotCommand", function(ply, text)
    if string.lower(text) == "!bot" then
        ply.BotCount = ply.BotCount or 0
        if ply.BotCount < 5 then
            RunConsoleCommand("bot")
            ply.BotCount = ply.BotCount + 1
        end
        return ""
    elseif string.lower(text) == "!kickbots" then
        RunConsoleCommand("bot_kick")
        ply.BotCount = 0
        return ""
    end
end)
