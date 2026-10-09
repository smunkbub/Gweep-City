local overrides = {
    ["weapon_ags_30_handheld"] = {
        WepSelectIcon2 = Material("vgui/minigunexploderidk.png"),
        IconOverride   = "vgui/minigunexploderidk.png",
    },
    ["weapon_kar98"] = {
        WepSelectIcon2 = Material("vgui/kar98.png"),
        IconOverride   = "vgui/kar98.png",
    },
}

local function ApplyIconOverrides()
    for class, data in pairs(overrides) do
        local stored = weapons.GetStored(class)
        if stored then
            for key, value in pairs(data) do
                stored[key] = value
            end
        end
    end
end

hook.Add("InitPostEntity", "zcity_icon_overrides", ApplyIconOverrides)
hook.Add("OnReloaded", "zcity_icon_overrides", ApplyIconOverrides)

hook.Add("InitPostEntity", "physgun_icon_override", function()
    local stored = weapons.GetStored("weapon_physgun")
    if stored then
        stored.Icon = "vgui/physgun.png"
    end
end)