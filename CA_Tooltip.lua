local app_name, app = ...

local KNOWN_SYMBOL = "\124T".."Interface\\AddOns\\ClassicAppearances\\Assets\\known"..":0\124t"
local KNOWN_CIRCLE_SYMBOL = "\124T".."Interface\\AddOns\\ClassicAppearances\\Assets\\known_circle"..":0\124t"
local UNKNOWN_SYMBOL = "\124T".."Interface\\AddOns\\ClassicAppearances\\Assets\\unknown"..":0\124t"

local ITEMS_CACHE = {}
function app.AddOwnershipInfo(self)
    local _, link = self:GetItem()
    local text = ""
    if ITEMS_CACHE[link] then
        text = ITEMS_CACHE[link]
    else
        local item_id = GetItemInfoFromHyperlink(link)
        local _, _, _, inv_type, _, item_class, item_subclass = GetItemInfoInstant(item_id)
        if (item_class == 2 or (item_class == 4 and 1 <= item_subclass and item_subclass <= 6)
                            or inv_type == 'INVTYPE_HOLDABLE'
                            or inv_type == 'INVTYPE_HEAD'
                            or inv_type == 'INVTYPE_SHOULDER'
                            or inv_type == 'INVTYPE_BODY'
                            or inv_type == 'INVTYPE_ROBE'
                            or inv_type == 'INVTYPE_TABARD'
                            or inv_type == 'INVTYPE_WAIST'
                            or inv_type == 'INVTYPE_FEET') then
            local appearance_id = app.GetItemAppearanceIDAndExpansion(item_id)
            if not appearance_id then
                return
            end
            local is_collected = app.GetIsCollected(appearance_id)

            text = UNKNOWN_SYMBOL.." Not Collected"
            local color = "ffff9333"
            if is_collected then
                text = KNOWN_CIRCLE_SYMBOL.." Collected"
                color = "ff15abff"
            end
            text = WrapTextInColorCode(text, color)

            local owner = app.GetItemOwner(item_id)
            if owner == app.player_full_name then
                text = WrapTextInColorCode(KNOWN_SYMBOL.." Collected", "ff15abff")
            end

            ITEMS_CACHE[link] = text
        else
            return
        end
    end

    self:AddDoubleLine(" ", text)
    self:Show()
end

GameTooltip:HookScript("OnTooltipSetItem", app.AddOwnershipInfo)
GameTooltip:HookScript("OnHide", function() ITEMS_CACHE = {} end)
