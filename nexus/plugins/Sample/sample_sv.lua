-- [SamplePlugin Server]
IF SERVER
local command = {}
command.Help = "Usage: ColorPrint [Message], ( [R] [G] [B] )"
command.Params = {
    { Type = "string", Name = "Message" },
    { Type = "vector3", Name = "Color", SubParams = { "R", "G", "B" } }
}
command.Run = function(ply, args)
    local msg = args[1] or "Default Message"
    local colorArgs = args[2] or {255, 255, 255}
    local color = Color(colorArgs[1], colorArgs[2], colorArgs[3])
    ply:ChatPrint(msg)
end

NEXUS:RegisterCommand("ColorPrint", command)
