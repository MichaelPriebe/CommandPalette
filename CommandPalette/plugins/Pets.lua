local _, addon = ...

local L = addon.L

EventRegistry:RegisterCallback("CommandPalette.UpdateActions", function()
    for i = 1, NUM_PET_ACTION_SLOTS, 1 do
        local petActionInfo = { GetPetActionInfo(i) }
        local name = petActionInfo[1]
        local texture = petActionInfo[2]
        if name ~= nil then
            local title = string.format(L["Call Pet: %s"], name)
            if CommandPalette:MatchesSearch(title) then
                CommandPalette:AddAction({
                    title = title,
                    icon = texture,
                    action = {
                        type = "pet",
                        action = i,
                    }
                })
            end
        end
    end
end)