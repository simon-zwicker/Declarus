-- Shared compatibility boundary for current official Blizzard clients only.
local Declarus = _G.Declarus

---@class DeclarusClientInfo
---@field flavor string
---@field version string
---@field build string
---@field interface number
---@field projectID? number

---@class DeclarusClient
local Client = {}

-- Identity is informational. Rendering must use shared APIs/capabilities rather
-- than assuming a Classic-looking game necessarily uses Classic's API family.
---@return DeclarusClientInfo
function Client.GetInfo()
    local version, build, _, interface = GetBuildInfo()
    local flavor = "Unknown"
    if interface >= 16000 and interface < 17000 then
        flavor = "Forever"
    elseif interface >= 100000 then
        flavor = "Retail"
    elseif interface >= 11500 and interface < 11600 then
        flavor = "Classic Era"
    elseif interface >= 20500 and interface < 20600 then
        flavor = "Burning Crusade Classic"
    elseif interface >= 38000 and interface < 38100 then
        flavor = "Titan Reforged"
    elseif interface >= 50500 and interface < 50600 then
        flavor = "Mists Classic"
    end
    return {
        flavor = flavor,
        version = version,
        build = build,
        interface = interface,
        projectID = _G.WOW_PROJECT_ID,
    }
end

---Respect the client/locale's font, including non-Latin client fonts.
---@return string
function Client.GetDefaultFont()
    return _G.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
end

---Internal boundary: use the shared modern API, never infer it from a project ID.
---@param texture Texture
---@param orientation DeclarusGradientOrientation
---@param fromColor DeclarusColor
---@param toColor DeclarusColor
function Client._ApplyGradient(texture, orientation, fromColor, toColor)
    assert(type(texture.SetGradient) == "function" and type(CreateColor) == "function",
        "Declarus gradient requires Texture:SetGradient and CreateColor from the official client")
    texture:SetGradient(orientation,
        CreateColor(fromColor[1], fromColor[2], fromColor[3], fromColor[4]),
        CreateColor(toColor[1], toColor[2], toColor[3], toColor[4]))
end

Declarus.Client = Client
