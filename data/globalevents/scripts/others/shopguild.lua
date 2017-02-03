-- ### CONFIG ###
-- time (in seconds) between connections to SQL database by shop script
SQL_interval = 30
-- ### END OF CONFIG ###
function onThink(interval, lastExecution)
    local result_plr = db.storeQuery("SELECT * FROM z_ots_comunication")
    if result_plr ~= false then
        repeat
            local id = tonumber(result.getDataInt(result_plr, "id"))
            local action = tostring(result.getDataString(result_plr, "action"))
            local delete = tonumber(result.getDataInt(result_plr, "delete_it"))
            local player = Player(tostring(result.getDataString(result_plr, "name")))
            if player then
                local itemtogive_id = tonumber(result.getDataInt(result_plr, "param1"))
                local itemtogive_count = tonumber(result.getDataInt(result_plr, "param2"))
                local container_id = tonumber(result.getDataInt(result_plr, "param3"))
                local container_count = tonumber(result.getDataInt(result_plr, "param4"))
                local add_item_type = tostring(result.getDataString(result_plr, "param5"))
                local add_item_name = tostring(result.getDataString(result_plr, "param6"))
                local received_item = 0
                local full_weight = 0
		local itemType = ItemType(itemtogive_id)
                if add_item_type == 'container' then
                    if itemType:isRune() then
                        items_weight = container_count * itemType:getWeight()
                    else
                        items_weight = container_count * itemType:getWeight(itemtogive_count)
                    end
                    full_weight = items_weight + ItemType(container_id):getWeight()
                else
                    if itemType:isRune() then
                        full_weight = itemType:getWeight()
                    else
                        full_weight = itemType:getWeight(itemtogive_count)
                    end
                end
                local free_cap = player:getFreeCapacity()
                if full_weight <= free_cap then
                    if add_item_type == 'container' then
                        local new_container = Game.createItem(container_id, 1)
                        local iter = 0
                        while iter ~= container_count do
                            new_container:addItem(itemtogive_id, itemtogive_count)
                            iter = iter + 1
                        end
                        received_item = player:addItemEx(new_container)
                    else
                        local new_item = Game.createItem(itemtogive_id, itemtogive_count)
                        received_item = player:addItemEx(new_item)
                    end
                    if type(received_item) == 'number' and received_item == RETURNVALUE_NOERROR then
                        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'You received >> '.. add_item_name ..' << from OTS shop.')
                        db.query("DELETE FROM `z_ots_comunication` WHERE `id` = " .. id .. ";")
                        db.query("UPDATE `z_shop_history_item` SET `trans_state`='realized', `trans_real`=" .. os.time() .. " WHERE id = " .. id .. ";")
                    else
                        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, '>> '.. add_item_name ..' << from OTS shop is waiting for you. Please make place for this item in your backpack/hands and wait about '.. SQL_interval ..' seconds to get it.')
                    end
                else
                    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, '>> '.. add_item_name ..' << from OTS shop is waiting for you. It weight is '.. full_weight ..' oz., you have only '.. free_cap ..' oz. free capacity. Put some items in depot and wait about '.. SQL_interval ..' seconds to get it.')
                end
            end
        until not result.next(result_plr)
        result.free(result_plr)
    end
    return true
end