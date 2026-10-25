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
    elseif interface >= 30400 and interface < 30500 then
        flavor = "Wrath Classic"
    elseif interface >= 38000 and interface < 38100 then
        flavor = "Titan Reforged"
    elseif interface >= 40400 and interface < 40500 then
        flavor = "Cataclysm Classic"
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

Declarus.Client = Client
