local app_name, app = ...

app.non_filtered = true

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

function app.GetPossibleWeaponCategories(non_filtered)
    print("DEBUG: app.non_filtered", app.non_filtered)
    local _, _, class_id = UnitClass("player")
    if non_filtered == true then
        class_id = 0
    end
    print("DEBUG GetPossibleWeaponCategories for", class_id )
    local _, possible_mainhand, possible_secondaryhand = unpack(app.DB.CLASS_PROFICIENCY[class_id])
    return possible_mainhand, possible_secondaryhand
end


function app.GetAppearanceCameraID(appearance_id, category_id)
    local camera_set -- NEEDS REWORK: various types of weapons

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
function app.GetVisualsList(category_id)
	local _, _, class_id = UnitClass("player")
    if app.non_filtered then
        class_id = 0
    end
	local armor_types = unpack(app.DB.CLASS_PROFICIENCY[class_id])
    local visuals_list = {}

    -- For Cloaks, Shirts, Tabards and Weapons return universal appearances list
    if category_id == 3 or category_id == 6 or category_id == 7 or category_id >= 13 then
        return get_keys(app.DB.APPEARANCES[category_id])
    end
    for i=1, #armor_types do
        local armor_type = armor_types[i]

        -- For Chest add Robe appearances
        if category_id == 4 then
            local chest_appearances = get_keys(app.DB.APPEARANCES[4][armor_type])
            local robe_appearances = get_keys(app.DB.APPEARANCES[5][armor_type])
            local combined_chests = merge_tables(chest_appearances, robe_appearances)
            visuals_list = merge_tables(visuals_list, combined_chests)
        -- For other armor return type specific appearances list (NEEDS REWORK - handle unfiltered)
        else
            visuals_list = merge_tables(visuals_list, get_keys(app.DB.APPEARANCES[category_id][armor_type]))
        end
    end
    return visuals_list
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


function app.GetAllItemIDsForModel(model)
    local item_ids = app.DB.ITEM_IDS[model.appearance_id]
    if not item_ids then
        return
    end
    return item_ids
end


-- TODO
function app.GetCategoryCollectedCount(category)
    return 0
end


function app.GetItemExpansionAndAppearanceID(item_id)
    local item_info = app.DB.ITEM_EXPANSIONS_AND_APPEARANCES[item_id]
    if not item_info then
        print("DEBUG GetItemExpansionAndAppearanceID - Item not found!", item_id)
    else
        local expansion, appearance_id = unpack(item_info)
        if expansion ~= "DoesNotExist" then
            local expansion_text = app.DB.EXPANSIONS[expansion]
            return expansion_text, appearance_id
        else
            print("DEBUG Unknown expansion for item", item_id)
            return expansion, appearance_id
        end
    end
end
