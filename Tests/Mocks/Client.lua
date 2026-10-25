-- Metadata fixtures, not emulations of the corresponding real WoW clients.
local profiles = {
    retail = {"12.1.5", "fixture", "2026-10-25", 120105},
    forever = {"1.60.1", "70338", "2026-10-25", 16001},
    era = {"1.15.9", "fixture", "2026-10-25", 11509},
    tbc = {"2.5.6", "fixture", "2026-10-25", 20506},
    wrath = {"3.4.5", "fixture", "2026-10-25", 30405},
    titan = {"3.80.2", "fixture", "2026-10-25", 38002},
    cata = {"4.4.2", "fixture", "2026-10-25", 40402},
    mists = {"5.5.4", "fixture", "2026-10-25", 50504},
}
local profile = profiles[arg[1] or "retail"]
assert(profile, "Unknown client fixture")

function GetBuildInfo() return unpack(profile) end
STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
SlashCmdList = {}
