-- Players cannot throw items on teleports if set to true
local blockTeleportTrashing = true

-- Internal Use
ITEM_STORE_INBOX = 26052

function Player:onBrowseField(position)
	return true
end

function Player:onLook(thing, position, distance)
	local description = 'You see '
	if thing:isItem() then
		if thing.actionid == 5640 then
			description = description .. 'a honeyflower patch.'
		elseif thing.actionid == 5641 then
			description = description .. 'a banana palm.'
		else
			description = description .. thing:getDescription(distance)
		end
	else
		description = description .. thing:getDescription(distance)
	end
	-- KD look 
	 if thing:isCreature() and thing:isPlayer() then
        description = string.format("%s\n [PVP Kills: %d] \n [PVP Deaths: %d] \n",
            description, math.max(0, thing:getStorageValue(167912)), math.max(0, thing:getStorageValue(167913)))
    end
	
	-- MARRY 
	if LOOK_MARRIAGE_DESCR and thing:isCreature() then
	if thing:isPlayer() then
	description = description .. self:getMarriageDescription(thing)
	end
end

	if self:getGroup():getAccess() then
		if thing:isItem() then
			description = string.format('%s\nItem ID: %d', description, thing.itemid)

			local actionId = thing.actionid
			if actionId ~= 0 then
				description = string.format('%s, Action ID: %d', description, actionId)
			end

			local uniqueId = thing:getAttribute(ITEM_ATTRIBUTE_UNIQUEID)
			if uniqueId > 0 and uniqueId < 65536 then
				description = string.format('%s, Unique ID: %d', description, uniqueId)
			end

			description = description .. '.'
			local itemType = thing:getType()

			local transformEquipId = itemType:getTransformEquipId()
			local transformDeEquipId = itemType:getTransformDeEquipId()
			if transformEquipId ~= 0 then
				description = string.format('%s\nTransforms to: %d (onEquip)', description, transformEquipId)
			elseif transformDeEquipId ~= 0 then
				description = string.format('%s\nTransforms to: %d (onDeEquip)', description, transformDeEquipId)
			end

			local decayId = itemType:getDecayId()
			if decayId ~= -1 then
				description = string.format('%s\nDecays to: %d', description, decayId)
			end
		elseif thing:isCreature() then
			local str = '%s\nHealth: %d / %d'
			if thing:getMaxMana() > 0 then
				str = string.format('%s, Mana: %d / %d', str, thing:getMana(), thing:getMaxMana())
			end
			description = string.format(str, description, thing:getHealth(), thing:getMaxHealth()) .. '.'
		end

		local position = thing:getPosition()
		description = string.format(
			'%s\nPosition: %d, %d, %d',
			description, position.x, position.y, position.z
		)

		if thing:isCreature() and thing:isPlayer() then
			description = string.format('%s\nIP: %s.', description, Game.convertIpToString(thing:getIp()))
		end
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInBattleList(creature, distance)
	local description = 'You see ' .. creature:getDescription(distance)
	if self:getGroup():getAccess() then
		local str = '%s\nHealth: %d / %d'
		if creature:getMaxMana() > 0 then
			str = string.format('%s, Mana: %d / %d', str, creature:getMana(), creature:getMaxMana())
		end
		description = string.format(str, description, creature:getHealth(), creature:getMaxHealth()) .. '.'

		
	
		local position = creature:getPosition()
		description = string.format(
			'%s\nPosition: %d, %d, %d',
			description, position.x, position.y, position.z
		)

		if creature:isPlayer() then
			description = string.format('%s\nIP: %s.', description, Game.convertIpToString(creature:getIp()))
		end
	end
	
	
	-- KD look 
	 if creature:isPlayer() and creature:isCreature() then
        description = string.format("%s\n [PVP Kills: %d] \n [PVP Deaths: %d] \n",
            description, math.max(0, creature:getStorageValue(167912)), math.max(0, creature:getStorageValue(167913)))
    end
	
	-- MARRY  
	if LOOK_MARRIAGE_DESCR and creature:isCreature() then
if creature:isPlayer() then
description = description .. self:getMarriageDescription(creature)
end
end

	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInTrade(partner, item, distance)
	self:sendTextMessage(MESSAGE_INFO_DESCR, 'You see ' .. item:getDescription(distance))
end

function Player:onLookInShop(itemType, count)
	return true
end

function Player:onMoveCreature(creature, fromPosition, toPosition)
	return true
end

function Player:onTurn(direction)
	return true
end

function Player:onTradeRequest(target, item)
	if isInArray({1738, 1740, 1747, 1748, 1749, 8766}, item.itemid) and item.actionid > 0 or item.actionid == 5640 then
		self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return false
	end
	return true
end

function Player:onTradeAccept(target, item, targetItem)
	return true
end

local soulCondition = Condition(CONDITION_SOUL, CONDITIONID_DEFAULT)
soulCondition:setTicks(4 * 60 * 1000)
soulCondition:setParameter(CONDITION_PARAM_SOULGAIN, 1)

local function useStamina(player)
	local staminaMinutes = player:getStamina()
	if staminaMinutes == 0 then
		return
	end

	local playerId = player:getId()
	local currentTime = os.time()
	local timePassed = currentTime - nextUseStaminaTime[playerId]
	if timePassed <= 0 then
		return
	end

	if timePassed > 60 then
		if staminaMinutes > 2 then
			staminaMinutes = staminaMinutes - 2
		else
			staminaMinutes = 0
		end
		nextUseStaminaTime[playerId] = currentTime + 120
	else
		staminaMinutes = staminaMinutes - 1
		nextUseStaminaTime[playerId] = currentTime + 60
	end
	player:setStamina(staminaMinutes)
end

  
  -- exp card
	local BONUS_EXP_STORAGE = 61398
	local BONUS_EXP_MULT = 1.3
	-- exp card
	
	
function Player:onGainExperience(source, exp, rawExp)
 	if not source or source:isPlayer() then
 		return exp
 	end
	
	-- Soul regeneration
	local vocation = self:getVocation()
	if self:getSoul() < vocation:getMaxSoul() and exp >= self:getLevel() then
		soulCondition:setParameter(CONDITION_PARAM_SOULTICKS, vocation:getSoulGainTicks() * 1000)
		self:addCondition(soulCondition)
	end

	-- Apply experience stage multiplier
	exp = exp * Game.getExperienceStage(self:getLevel())

	-- Stamina modifier
	if configManager.getBoolean(configKeys.STAMINA_SYSTEM) then
		useStamina(self)

		local staminaMinutes = self:getStamina()
		if staminaMinutes > 2400 and self:isPremium() then
			exp = exp * 1.5
		elseif staminaMinutes <= 840 then
			exp = exp * 0.5
		end
	end

	
   -- exp card
 if self:getStorageValue(BONUS_EXP_STORAGE) - os.time() > 0 then
  exp = exp * BONUS_EXP_MULT
 end
	-- exp card
	
	return exp
end

function Player:onLoseExperience(exp)
	return exp
end

function Player:onGainSkillTries(skill, tries)
	if APPLY_SKILL_MULTIPLIER == false then
		return tries
	end

	if skill == SKILL_MAGLEVEL then
		return tries * configManager.getNumber(configKeys.RATE_MAGIC)
	end
	return tries * configManager.getNumber(configKeys.RATE_SKILL)
end

 function Player:onMoveItem(item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	-- No move items with actionID 8000

--- LIONS ROCK START 

if self:getStorageValue(lionrock.storages.playerCanDoTasks) - os.time() < 0 then
        local p, i = lionrock.positions, lionrock.items
        local checkPr = false
        if item:getId() == lionrock.items.ruby and toPosition.x == p.ruby.x
                and toPosition.y == p.ruby.y  and toPosition.z == p.ruby.z then
            -- Ruby
            self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You place the ruby on the small socket. A red flame begins to burn.")
            checkPr = true
            if lionrock.taskactive.ruby ~= true then
                lionrock.taskactive.ruby = true
            end
           
            local tile = Tile(p.ruby)
            if tile:getItemCountById(i.redflame) < 1 then
                Game.createItem(i.redflame, 1, p.ruby)
            end
        end
       
        if item:getId() == lionrock.items.sapphire and toPosition.x == p.sapphire.x
                and toPosition.y == p.sapphire.y  and toPosition.z == p.sapphire.z then
            -- Sapphire
            self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You place the sapphire on the small socket. A blue flame begins to burn.")
            checkPr = true
            if lionrock.taskactive.sapphire ~= true then
                lionrock.taskactive.sapphire = true
            end
           
            local tile = Tile(p.sapphire)
            if tile:getItemCountById(i.blueflame) < 1 then
                Game.createItem(i.blueflame, 1, p.sapphire)
            end
        end
       
        if item:getId() == lionrock.items.amethyst and toPosition.x == p.amethyst.x
                and toPosition.y == p.amethyst.y  and toPosition.z == p.amethyst.z then
            -- Amethyst
            self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You place the topaz on the small socket. A yellow flame begins to burn.")
            checkPr = true
            if lionrock.taskactive.amethyst ~= true then
                lionrock.taskactive.amethyst = true
            end
           
            local tile = Tile(p.amethyst)
            if tile:getItemCountById(i.yellowflame) < 1 then
                Game.createItem(i.yellowflame, 1, p.amethyst)
            end
        end
       
        if item:getId() == lionrock.items.topaz and toPosition.x == p.topaz.x
                and toPosition.y == p.topaz.y  and toPosition.z == p.topaz.z then
            -- Topaz
            self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You place the amethyst on the small socket. A violet flame begins to burn.")
            checkPr = true
            if lionrock.taskactive.topaz ~= true then
                lionrock.taskactive.topaz = true
            end
           
            local tile = Tile(p.topaz)
            if tile:getItemCountById(i.violetflame) < 1 then
                Game.createItem(i.violetflame, 1, p.topaz)
            end
        end
       
        if checkPr == true then
            -- Adding the Fountain which gives present
            if lionrock.taskactive.ruby == true and lionrock.taskactive.sapphire == true
                and lionrock.taskactive.amethyst == true and lionrock.taskactive.topaz == true then
               
                local fountain = Game.createItem(i.rewardfountain, 1, { x=33073, y=32300, z=9})
                fountain:setActionId(41357)
               local stone = Tile({ x=33073, y=32300, z=9}):getItemById(3608)
			if stone ~= nil then
			stone:remove()
			end
                self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Something happens at the centre of the room ...");
            end
           
            -- Removing Item
            item:remove(1)
        end
    end
	
	---- LIONS ROCK END 
	
	local exhaust = { } -- SSA exhaust
    if toPosition.x == CONTAINER_POSITION and toPosition.y == CONST_SLOT_NECKLACE and item:getId() == 2197 then
        local pid = self:getId()
        if exhaust[pid] then   
            self:sendCancelMessage(RETURNVALUE_YOUAREEXHAUSTED)    
            return false
        else
            exhaust[pid] = true
            addEvent(function() exhaust[pid] = false end, 2000, pid)
            return true
        end
    end
 
	-- Store Inbox
	local containerIdFrom = fromPosition.y - 64
	local containerFrom = self:getContainerById(containerIdFrom)
	if (containerFrom) then
		if (containerFrom:getId() == ITEM_STORE_INBOX and toPosition.y >= 1 and toPosition.y <= 11 and toPosition.y ~= 3) then
			self:sendCancelMessage(RETURNVALUE_CONTAINERNOTENOUGHROOM)
			return false
		end
	end

	local containerTo = self:getContainerById(toPosition.y-64)
	if (containerTo) then
		if (containerTo:getId() == ITEM_STORE_INBOX) then
			self:sendCancelMessage(RETURNVALUE_CONTAINERNOTENOUGHROOM)
			return false
		end
	end

 	-- No move items with actionID 8000
 	if item:getActionId() == NOT_MOVEABLE_ACTION then
 		self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
 		return false
 	end
 
 	-- Check two-handed weapons 
 	if toPosition.x ~= CONTAINER_POSITION then
 		return true
 	end
 
 	if item:getTopParent() == self and bit.band(toPosition.y, 0x40) == 0 then	
 		local itemType, moveItem = ItemType(item:getId())
 		if bit.band(itemType:getSlotPosition(), SLOTP_TWO_HAND) ~= 0 and toPosition.y == CONST_SLOT_LEFT then
 			moveItem = self:getSlotItem(CONST_SLOT_RIGHT)	
 		elseif itemType:getWeaponType() == WEAPON_SHIELD and toPosition.y == CONST_SLOT_RIGHT then
 			moveItem = self:getSlotItem(CONST_SLOT_LEFT)
 			if moveItem and bit.band(ItemType(moveItem:getId()):getSlotPosition(), SLOTP_TWO_HAND) == 0 then
 				return true
 			end
 		end
 
 		if moveItem then
 			local parent = item:getParent()
 			if parent:getSize() == parent:getCapacity() then
 				self:sendTextMessage(MESSAGE_STATUS_SMALL, Game.getReturnMessage(RETURNVALUE_CONTAINERNOTENOUGHROOM))
 				return false
 			else
 				return moveItem:moveTo(parent)
 			end
 		end
 	end
	
 	-- Reward System
 	if toPosition.x == CONTAINER_POSITION then
 		local containerId = toPosition.y - 64
 		local container = self:getContainerById(containerId)
 		if not container then
			return true
 		end
 
 		-- Do not let the player insert items into either the Reward Container or the Reward Chest
 		local itemId = container:getId()
 		if itemId == ITEM_REWARD_CONTAINER or itemId == ITEM_REWARD_CHEST then
 			self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
 			return false
 		end
 
 		-- The player also shouldn't be able to insert items into the boss corpse
 		local tile = Tile(container:getPosition())
 		for _, item in ipairs(tile:getItems() or { }) do
 			if item:getAttribute(ITEM_ATTRIBUTE_CORPSEOWNER) == 2^31 - 1 and item:getName() == container:getName() then
 				self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
 				return false
 			end
 		end
 	end
 
 	-- Do not let the player move the boss corpse.
 	if item:getAttribute(ITEM_ATTRIBUTE_CORPSEOWNER) == 2^31 - 1 then
 		self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
 		return false
 	end
 
	-- Players cannot throw items on reward chest
	local tile = Tile(toPosition)
	if tile and tile:getItemById(ITEM_REWARD_CHEST) then
		self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		self:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	-- Players cannot throw items on teleports
	if blockTeleportTrashing and toPosition.x ~= CONTAINER_POSITION then
		local thing = Tile(toPosition):getItemByType(ITEM_TYPE_TELEPORT)
		if thing then
			self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

 	return true
 end  
	
	-- MOVER PRO TP 
	if blockTeleportTrashing and toPosition.x ~= CONTAINER_POSITION then
        local thing = Tile(toPosition):getItemByType(ITEM_TYPE_TELEPORT)
        if thing then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
            self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
    end
	
	-- MOVER PARCEL  
	if item:getWeight() > 90000 and item:getId() == 2595 then 
	self:sendCancelMessage('YOU CANNOT MOVE PARCELS TOO HEAVY.')
	return false 
	end
 
    --local tile = Tile(toPosition)
        if tile and tile:getItemById(21584) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		--[[if tile and tile:getItemById(369) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(370) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(408) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(409) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(410) then
            self:sendCancelMessage('Sorry, you can not put items there.')
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(411) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(423) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(427) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(428) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(429) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(432) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(433) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3135) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3136) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3137) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3138) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3219) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3220) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(4834) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(4835) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(4836) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(4837) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8276) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8277) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8279) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8280) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8281) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8282) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8283) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8284) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8285) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8286) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(9574) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(9606) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(9846) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1386) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3678) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(5543) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8599) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1385) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1396) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(5258) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(5259) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(5260) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3687) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3688) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1398) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1400) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1402) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1404) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3681) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(3685) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22862) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22863) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(5691) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(19674) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(19675) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22864) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22865) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22866) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22867) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(9573) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1390) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1392) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1394) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(1388) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
			
		if tile and tile:getItemById(459) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(383) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(385) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(392) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		-----
		if tile and tile:getItemById(469) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(470) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(482) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(484) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(485) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(489) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(5731) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(462) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(475) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(476) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(479) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(480) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(924) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(5081) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6127) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6128) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6129) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(6130) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6173) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6174) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(6917) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(6918) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(6919) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6920) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6921) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(6922) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(6923) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(6924) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(8559) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8560) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(8561) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8562) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8563) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8564) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8565) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8566) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6909) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6911) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6913) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(6915) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8372) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8374) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8376) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8378) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8595) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
			
		if tile and tile:getItemById(8596) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8709) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8715) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(8716) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(9625) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(11123) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(12694) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(384) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(418) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(12696) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		--------------
		
		
		if tile and tile:getItemById(15029) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15030) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15031) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15032) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15033) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15034) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15035) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15036) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15037) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15038) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15039) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15040) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15041) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15042) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15043) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15044) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15045) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15046) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15047) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15048) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15049) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15050) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15051) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15052) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15053) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15054) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15055) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15056) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15057) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15058) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15059) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15060) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15061) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15062) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15063) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15064) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15179) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15181) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15183) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(15185) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(17557) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(17559) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(17561) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(17563) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(17766) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(17767) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(17768) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18234) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18530) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18531) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18532) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18533) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18534) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18535) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18960) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18962) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18964) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18966) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18968) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18970) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18972) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(18974) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(19516) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(19518) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(19519) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(20967) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(20969) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(20971) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(20973) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(21536) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(21552) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(21924) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(21925) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22587) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22588) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22589) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22590) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22593) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22594) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22595) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22596) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22597) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22859) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		if tile and tile:getItemById(22860) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(23713) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
		
		
		if tile and tile:getItemById(23715) then
            self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end--]]
		
		
		
    -- Do not let the player move the boss corpse.
    if item:getAttribute(ITEM_ATTRIBUTE_CORPSEOWNER) == 2^31 - 1 then
        self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
        return false
    end

    return true
end