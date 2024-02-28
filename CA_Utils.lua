local app_name, app = ...

app.DEFAULT_SETTINGS = {
    ['class_filter_enabled'] = true,
}

function app.GetCategoryInfo(category_id)
    local category_info = app.DB.CATEGORIES[category_id]
    if category_info then
        return unpack(category_info)
    else
        return
    end
end

function app.GetSlotForCategory(category_id)
    if 13 <= category_id and category_id <= 28 then
        return "MAINHANDSLOT"
    elseif category_id == 29 or category_id == 30 then
        return "SECONDARYHANDSLOT"
    else
        return app.DB.SLOTS[category_id]
    end
end

function app.GetCategoryID(category)
    for index, slot in pairs(app.DB.SLOTS) do
        if slot == category then
            return index
        end
    end
end

function app.GetPossibleWeaponCategories()
    local _, _, class_id = UnitClass("player")
    if app.GetSettings('class_filter_enabled') == false then
        class_id = 0
    end
    local _, possible_mainhand, possible_secondaryhand = unpack(app.DB.CLASS_PROFICIENCY[class_id])
    return possible_mainhand, possible_secondaryhand
end

function app.GetAppearanceCameraID(appearance_id, category_id)
    local camera_set

    -- If Weapons then return universal camera ID
    if category_id >= 13 then
        return app.DB.CAMERA.SETS[category_id]
    -- If Chest then check item type: robes have their own separate camera set
    elseif category_id == 4 then
        local item_id = app.GetItemForModel(appearance_id)
        local _, _, _, inv_type = GetItemInfoInstant(item_id)
        if inv_type == 'INVTYPE_ROBE' then
            camera_set = app.DB.CAMERA.SETS[5]
        else
            camera_set = app.DB.CAMERA.SETS[4]
        end
    -- For other types of armor use specific camera set
    else
        camera_set = app.DB.CAMERA.SETS[category_id]
    end

    local sex = UnitSex("player") -- Returns 1, 2 (male), 3 (female)
    local _, _, race_id = UnitRace("player") -- Order: Human, Orc, Dwarf, NightElf, Undead, Tauren, Gnome, Troll, BloodElf, Draenei

    -- HACK for Blood Elfs and Draeneis (to skip Goblins (9))
    if race_id == 10 or race_id == 11 then
        race_id = race_id - 1
    end
    return camera_set[race_id][sex - 1]
end


function app.Model_ApplyUICamera(self, uiCameraID)
    local cameraInfo = app.DB.CAMERA.PARAMETERS[uiCameraID]
    if not cameraInfo then
        print('DEBUG camera_info not found for camera_id:', uiCameraID)
        return
    end
    local posX, posY, posZ, yaw, pitch, roll, animId, animVariation, animFrame, centerModel = unpack(cameraInfo)

	if posX and posY and posZ and yaw and pitch and roll then
		self:MakeCurrentCameraCustom();

		self:SetPosition(posX, posY, posZ);
		self:SetFacing(yaw);
		self:SetPitch(pitch);
		self:SetRoll(roll);
		self:UseModelCenterToTransform(centerModel);

		local cameraX, cameraY, cameraZ = self:TransformCameraSpaceToModelSpace(MODELFRAME_UI_CAMERA_POSITION):GetXYZ();
		local targetX, targetY, targetZ = self:TransformCameraSpaceToModelSpace(MODELFRAME_UI_CAMERA_TARGET):GetXYZ();

		self:SetCameraPosition(cameraX, cameraY, cameraZ);
		self:SetCameraTarget(targetX, targetY, targetZ);
	end
	if( animId and animFrame ~= -1 and animId ~= -1 ) then
		self:FreezeAnimation(animId, animVariation, animFrame);
	else
		self:SetAnimation(0, 0);
	end
end


local function get_keys(t)
	local keys = {}
	for key, _ in pairs(t) do
		tinsert(keys, key)
	end
	return keys
end
local function is_in_array(i, t)
    for _, value in pairs(t) do
        if value == i then
            return true
        end
    end
    return false
end
local function merge_tables(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end
local function clear_duplicates(t)
    local temp_t = {}
    for i=1, #t do
        temp_t[t[i]] = true
    end
    return get_keys(temp_t)
end
function app.GetVisualsList(category_id)
	local _, _, class_id = UnitClass("player")
    if app.GetSettings('class_filter_enabled') == false then
        class_id = 0
    end
	local armor_types = unpack(app.DB.CLASS_PROFICIENCY[class_id])
    local visuals_list = {}
    local sorted_visuals_list = {}

    -- For Cloaks, Shirts, Tabards and Weapons return universal appearances list
    if category_id == 3 or category_id == 6 or category_id == 7 or category_id >= 13 then
        visuals_list = clear_duplicates(get_keys(app.DB.APPEARANCES[category_id]))
    else
        for i=1, #armor_types do
            local armor_type = armor_types[i]

            -- For Chest add Robe appearances
            if category_id == 4 then
                local chest_appearances = get_keys(app.DB.APPEARANCES[4][armor_type])
                local robe_appearances = get_keys(app.DB.APPEARANCES[5][armor_type])
                local combined_chests = merge_tables(chest_appearances, robe_appearances)
                visuals_list = clear_duplicates(merge_tables(visuals_list, combined_chests))
            -- For other armor return type specific appearances list (NEEDS REWORK - handle unfiltered)
            else
                visuals_list = clear_duplicates(merge_tables(visuals_list, get_keys(app.DB.APPEARANCES[category_id][armor_type])))
            end
        end
    end

    local collected_visuals_table = {}
    for i=1, #visuals_list do
        local appearance_id = visuals_list[i]
        local is_collected, char = app.GetIsCollected(appearance_id)
        if is_collected then
            collected_visuals_table[appearance_id] = char
            visuals_list[i] = nil
        end
    end
    sorted_visuals_list = get_keys(collected_visuals_table)
    local collected_count = #sorted_visuals_list
    table.sort(sorted_visuals_list)

    local temp_unsorted_visuals_list = {}
    for i=1, #visuals_list do
        if visuals_list[i] ~= nil then
            tinsert(temp_unsorted_visuals_list, visuals_list[i])
        end
    end
    table.sort(temp_unsorted_visuals_list)
    sorted_visuals_list = merge_tables(sorted_visuals_list, temp_unsorted_visuals_list)
    return sorted_visuals_list, collected_count, collected_visuals_table
end

function app.GetItemForModel(appearance_id)
    local item_ids = app.DB.ITEM_IDS[appearance_id]
    if not item_ids then
        print("DEBUG: appearance not found:", appearance_id)
        return
    end
    for i=1, #item_ids do
        local item_id = item_ids[i]
        local item_exists = GetItemInfoInstant(item_id)
        if item_exists then
            return item_id
        end
    end
end

function app.GetAllItemIDsForAppearance(appearance_id)
    local item_ids = app.DB.ITEM_IDS[appearance_id]
    if not item_ids then
        return
    end
    return item_ids
end

function app.GetItemAppearanceIDAndExpansion(item_id)
    local item_info = app.DB.ITEM_EXPANSIONS_AND_APPEARANCES[item_id]
    if not item_info then
        print("DEBUG GetItemAppearanceIDAndExpansion - Item not found!", item_id)
    else
        local expansion, appearance_id = unpack(item_info)
        if expansion ~= "DoesNotExist" then
            local expansion_text = app.DB.EXPANSIONS[expansion]
            return appearance_id, expansion_text
        else
            print("DEBUG Unknown expansion for item", item_id)
            return appearance_id, expansion
        end
    end
end

function app.ScanItems(container_type)
    if not CA_OwnedItems[app.player_full_name] then
        CA_OwnedItems[app.player_full_name] = {}
    end
    local cached_items = {}
    
    -- Scan mail
    if container_type == 1 then
        local messages_count = GetInboxNumItems()
        for message_index = 1, messages_count do
            for item_index = 1, ATTACHMENTS_MAX_RECEIVE do
                local _, item_id = GetInboxItem(message_index, item_index)
                if item_id then
                    tinsert(cached_items, item_id)
                end
            end
        end
    -- Scan bank
    elseif container_type == 2 then
        for slot = 1, C_Container.GetContainerNumSlots(BANK_CONTAINER) do
            local item_id = C_Container.GetContainerItemID(BANK_CONTAINER, slot)
            if item_id then
                tinsert(cached_items, item_id)
            end
        end
        for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local item_id = C_Container.GetContainerItemID(bag, slot)
                if item_id then
                    tinsert(cached_items, item_id)
                end
            end
        end
    -- Scan guild bank
    elseif container_type == 3 then
        for tab = 1, MAX_GUILDBANK_TABS do
            local _, _, viewable = GetGuildBankTabInfo(tab)
            if viewable then
                for item_index = 1, 98 do
                    local item_link = GetGuildBankItemLink(tab, item_index)
                    if item_link then
                        local item_id = GetItemInfoFromHyperlink(item_link)
                        if item_id then
                            tinsert(cached_items, item_id)
                        end
                    end
                end
            else
                break
            end
        end
    -- Scan bags and equipped items
    else
        local inventory_slots = {1, 3, 4, 5, 6, 7, 8, 9, 10, 15, 16, 17, 18, 19}
        for i=1, #inventory_slots do
            local slot_id = inventory_slots[i]
            local item_id = GetInventoryItemID("player", slot_id)
            if item_id then
                tinsert(cached_items, item_id)
            end
        end
        for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local item_id = C_Container.GetContainerItemID(bag, slot)
                if item_id then
                    tinsert(cached_items, item_id)
                end
            end
        end
    end

    -- Filter out cached items without models, find model and save
    for i = 1, #cached_items do
        local item_id = cached_items[i]
        local _, _, _, inv_type, _, item_class, item_subclass = GetItemInfoInstant(item_id)
        if (item_class == 2 or (item_class == 4 and 1 <= item_subclass and item_subclass <= 6)
                            or inv_type == 'INVTYPE_HOLDABLE'
                            or inv_type == 'INVTYPE_TABARD'
                            or inv_type == 'INVTYPE_BODY'
                            or inv_type == 'INVTYPE_HEAD') then
            --[[ local appearance_id = app.GetItemAppearanceIDAndExpansion(item_id)
            if appearance_id then
                CA_OwnedItems[app.player_full_name][appearance_id] = true
            end ]]
            CA_OwnedItems[app.player_full_name][item_id] = true
        end
    end
end

function app.GetIsCollected(appearance_id)
    local item_ids = app.GetAllItemIDsForAppearance(appearance_id)
    for _, item_id in pairs(item_ids) do
        for char, collected_item_ids in pairs(CA_OwnedItems) do
            if collected_item_ids[item_id] then
                return true, char
            end
        end
    end
    return false
end

function app.GetItemOwner(item_id)
    for char, collected_item_ids in pairs(CA_OwnedItems) do
        if collected_item_ids[item_id] then
            return char
        end
    end
    return
end

function app.GetSettings(setting_tag)
    local parameter = CA_SettingsPerCharacter[setting_tag]
    if parameter ~= nil then
        return parameter
    end
    return app.DEFAULT_SETTINGS[setting_tag]
end

function app.SetSettings(setting_tag, value)
    CA_SettingsPerCharacter[setting_tag] = value
end