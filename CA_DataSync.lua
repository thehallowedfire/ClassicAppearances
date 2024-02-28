local app_name, app = ...

LibStub("AceComm-3.0"):Embed(app)
LibStub("AceSerializer-3.0"):Embed(app)


local bn_listener = CreateFrame("Frame")
local message_cache = {}
local chunks_total = 0
local chunks_received = 0

local function HandleChunk(chunk_id, chunk)
    message_cache[chunk_id] = chunk

    if chunks_received == chunks_total then
        -- Check if message cache is correct (has all chunks)
        for i=1, chunks_total do
            if not message_cache[i] then
                print("DEBUG Sync failed")
                return
            end
        end
        local success, data = app.ConvertMessageToTable(message_cache)
        if success then
            app.SaveNewData(data)
        else
            print("DEBUG Sync failed - Deserialization failed")
        end
    end
end


bn_listener:RegisterEvent("BN_CHAT_MSG_ADDON")
bn_listener:SetScript("OnEvent", function(self, event, prefix, message, distribution, sender_id)
    if prefix ~= "CA_SYNC" then
        return
    end
    -- bnsync_send:chunks_total:current_chunk_id:chunk_data
    if message:sub(1, 11) == 'bnsync_send' then
        local batch = {}
        for batch_part in message:gmatch("[^:]+") do
            tinsert(batch, batch_part)
        end
        if chunks_total == 0 then
            chunks_total = tonumber(batch[2])
        end
        local chunk_id, chunk = tonumber(batch[3]), batch[4]
        chunks_received = chunks_received + 1
        HandleChunk(chunk_id, chunk)

        if chunks_received == chunks_total then
            CA_SYNC(true)
        end
    elseif message:sub(1, 14) == 'bnsync_receive' then
        local batch = {}
        for batch_part in message:gmatch("[^:]+") do
            tinsert(batch, batch_part)
        end
        if chunks_total == 0 then
            chunks_total = tonumber(batch[2])
        end
        local chunk_id, chunk = tonumber(batch[3]), batch[4]
        chunks_received = chunks_received + 1
        HandleChunk(chunk_id, chunk)
    end
end)

function app.GetCharacterData()
    local player_guid = UnitGUID("player")
    CA_CharactersData[app.player_full_name] = {}
    CA_CharactersData[app.player_full_name]["playerGuid"] = player_guid
end

function app:OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= "CA_SYNC" then
        return
    end

    if message:sub(1, 9) == "getguids:" then
        local requester_guid = message:sub(10, #message)
        local requester_info = C_BattleNet.GetGameAccountInfoByGUID(requester_guid)
        if requester_info.characterName == sender then
            app.SendLocalGuids(sender)
        end
    elseif message:sub(1, 6) == "guids:" then
        app.ReceiveGUIDs(message:sub(7, #message))
        app.SendLocalGuids(sender, true)
    elseif message:sub(1, 10) == "guids_end:" then
        app.ReceiveGUIDs(message:sub(11, #message))
    elseif message:sub(1, 9) == "sync_send" then
        local success, data = app.DeserializeItems(message:sub(11, #message))
        if success then
            app.SaveNewData(data)
            CA_SYNC(true)
        end
    elseif message:sub(1, 12) == "sync_receive" then
        local success, data = app.DeserializeItems(message:sub(14, #message))
        if success then
            app.SaveNewData(data)
        end
    end
end

function app.SendLocalGuids(target, the_end)
    local response = "guids:"
    if the_end then
        response = "guids_end:"
    end
    response = response..app:Serialize(CA_CharactersData)
    app:SendCommMessage("CA_SYNC", response, "WHISPER", target)
end

function app.ReceiveGUIDs(message)
    local success, characters_data = app:Deserialize(message)
    if success then
        for char_name, char_guid_data in pairs(characters_data) do
            CA_CharactersData[char_name] = char_guid_data
        end
    end
end

function app.SplitMessageIntoChunks(message, max_length)
    local length = message:len()
    if length > max_length then
        local chunks = {}
        for i=1, length, max_length do
            local chunk = message:sub(i, i + max_length - 1)
            tinsert(chunks, chunk)
        end
        return chunks
    end
    return {message}
end

function app.ConvertMessageToTable(message_cache)
    local message = ""
    for i=1, #message_cache do
        message = message..message_cache[i]
    end
    return app.DeserializeItems(message)
end

function app.SaveNewData(data)
    for char, item_ids in pairs(data) do
        if not CA_OwnedItems[char] then
            CA_OwnedItems[char] = {}
        end
        for item_id, _ in pairs(item_ids) do
            CA_OwnedItems[char][item_id] = true
        end
    end
    message_cache = {}
    chunks_total = 0
    chunks_received = 0
    print("DEBUG Successful sync!")
end

function app.SerializeItems(table)
    if not table then return end

    local data_string = ""
    -- Профессия-Пламегор@5419.42984.48687.15450,Яхтсмен-Пламегор@5419.42984.48687.15450,
    for char_name, collected_items in pairs(table) do
        if data_string == "" then
            data_string = char_name .. "@"
        else
            data_string = data_string .. "," .. char_name .. "@"
        end
        for item_id, _ in pairs(collected_items) do
            data_string = data_string .. item_id .. "."
        end
        -- Remove last dot
        data_string = data_string:sub(1, #data_string - 1)
    end
    return data_string
end

function app.DeserializeItems(serialized_string)
    if not serialized_string then return false end

    local deserialized_data = {}
    for character_serialized_data in serialized_string:gmatch("[^,]+") do
        local character_data = {}
        for part in character_serialized_data:gmatch("[^@]+") do
            tinsert(character_data, part)
        end
        local char_name = character_data[1]
        local serialized_item_ids = character_data[2]
        deserialized_data[char_name] = {}
        for item_id in serialized_item_ids:gmatch("[^.]+") do
            item_id = tonumber(item_id)
            deserialized_data[char_name][item_id] = true
        end
    end

    return true, deserialized_data
end


app:RegisterComm("CA_SYNC")




local function CheckOnline(player_guid)
    for char_name, char_data in pairs(CA_CharactersData) do
        local char_info = C_BattleNet.GetGameAccountInfoByGUID(char_data.playerGuid)
        if char_info and char_info.playerGuid ~= player_guid then
            return char_info
        end
    end
end
function CA_SYNC(is_response)
    local prefix = "send"
    if is_response then
        prefix = "receive"
    end
    local player_guid = UnitGUID("player")
    local player = C_BattleNet.GetGameAccountInfoByGUID(player_guid)
    local character = CheckOnline(player_guid)

    if character then
        local data = app.SerializeItems(CA_OwnedItems)
        --[[ if player.realmName == character.realmName and player.factionName == character.factionName then
            app:SendCommMessage("CA_SYNC", "sync_"..prefix..":"..data, "WHISPER", character.characterName)
        else ]]
        local chunks = app.SplitMessageIntoChunks(data, 4000)
        for i=1, #chunks do
            C_Timer.After(1, function()
                BNSendGameData(character.gameAccountID, "CA_SYNC", "bnsync_"..prefix..":"..#chunks..":"..i..":"..chunks[i])
            end)
        end
        --[[ end ]]
    end
end

function CA_ADD_CHAR(char_name)
    local player_guid = UnitGUID("player")
    local message = "getguids:"..player_guid
    app:SendCommMessage("CA_SYNC", message, "WHISPER", char_name)
end