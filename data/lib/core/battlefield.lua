	_Lib_Battle_Info = {
	Reward = {
		exp = {true, 100000}, items = {true, 21399, 1}, premium_days = {false, 1}
	},
	TeamOne = {name = "Black Vikings", storage = 140120, pos = {x = 31393, y = 32554, z = 8}},
	TeamTwo = {name = "Red Vikings", storage = 140121, pos = {x = 31437, y = 32554, z = 8}},
	storage_count = 180400,
	tpPos = {x = 32470, y = 32471, z = 6}, 
	limit_Time = 10 -- em minutos 
}

_Lib_Battle_Days = {
    ["Monday"] = {   -- segunda
		["22:30"] = {players = 30}
	},	
	["Tuesday"] = { -- terça
		["22:30"] = {players = 30}
	},
	["Wednesday"] = { -- quarta 
		["22:30"] = {players = 30}
	},
	["Thursday"] = { -- quinta
		["22:30"] = {players = 30}
	},
	["Friday"] = { --sexta
		["22:30"] = {players = 30}
	},
	["Saturday"] = { -- sabado
		["22:30"] = {players = 30}
	},
		
	["Sunday"] = { -- domingo
		["22:30"] = {players = 30}
	}
}

function resetBattle()
	Game.setStorageValue(_Lib_Battle_Info.TeamOne.storage, 0) 
	Game.setStorageValue(_Lib_Battle_Info.TeamTwo.storage, 0)
end

function doBroadCastBattle(type, msg)
	for _, cid in pairs(Game.getPlayers()) do
		if Player(cid):getStorageValue(_Lib_Battle_Info.TeamOne.storage) == 1 or Player(cid):getStorageValue(_Lib_Battle_Info.TeamTwo.storage) == 1 then
			Player(cid):sendTextMessage(type, msg)
		end
	end
end

function getWinnersBattle(storage)
	local str, c = "[BattleField] " , 0
	for _, cid in pairs(Game.getPlayers()) do
		local player = Player(cid)
		if player:getStorageValue(storage) >= 1 then
			if _Lib_Battle_Info.Reward.exp[1] then player:addExperience(_Lib_Battle_Info.Reward.exp[2], true) end
			if _Lib_Battle_Info.Reward.items[1] then player:addItem(_Lib_Battle_Info.Reward.items[2], _Lib_Battle_Info.Reward.items[3]) end
			if _Lib_Battle_Info.Reward.premium_days[1] then player:addPremiumDays(_Lib_Battle_Info.Reward.premium_days[2]) end
			player:teleportTo(player:getTown():getTemplePosition())
			player:setStorageValue(storage, -1)
			player:removeCondition(CONDITION_OUTFIT)
			c = c + 1 
		end
	end
	str = str .. "" .. c .. " jogadores" .. (c > 1 and "s" or "") .. " do time " .. (Game.getStorageValue(_Lib_Battle_Info.TeamOne.storage) == 0 and _Lib_Battle_Info.TeamTwo.name or _Lib_Battle_Info.TeamOne.name) .. " ganharam o evento!"
	resetBattle()
	OpenWallBattle()
	return broadcastMessage(str)
end

function OpenWallBattle()
	local B = {
		{1049, {x = 31424, y = 32550, z = 6, stackpos = 1}}, -- {x = 31424, y = 32550, z = 6}
		{1049, {x = 31424, y = 32551, z = 6, stackpos = 1}}, -- {x = 31424, y = 32551, z = 6}
		{1049, {x = 31424, y = 32552, z = 6, stackpos = 1}},
		{1049, {x = 31424, y = 32553, z = 6, stackpos = 1}},
		{1049, {x = 31424, y = 32554, z = 6, stackpos = 1}},
		{1049, {x = 31424, y = 32555, z = 6, stackpos = 1}},
		{1049, {x = 31424, y = 32556, z = 6, stackpos = 1}},
		{1049, {x = 31424, y = 32557, z = 6, stackpos = 1}}
	}

	for i = 1, #B do
		if getTileItemById(B[i][2], B[i][1]).uid == 0 then
			doCreateItem(B[i][1], 1, B[i][2])
		else
			doRemoveItem(getThingfromPos(B[i][2]).uid,1)
		end
	end
end

function removeBattleTp()
	local t = getTileItemById(_Lib_Battle_Info.tpPos, 1387).uid
	return t > 0 and doRemoveItem(t) and doSendMagicEffect(_Lib_Battle_Info.tpPos, CONST_ME_POFF)
end

function CheckEvent(delay)
	if delay > 0 and Game.getStorageValue(_Lib_Battle_Info.storage_count) > 0 then
		broadcastMessage("[BattleField] Faltam " .. Game.getStorageValue(_Lib_Battle_Info.storage_count) .. " jogadores para o evento comecar.")
	elseif delay == 0 and Game.getStorageValue(_Lib_Battle_Info.storage_count) > 0 then
		for _, cid in pairs(Game.getPlayers()) do
			local player = Player(cid)
			if player:getStorageValue(_Lib_Battle_Info.TeamOne.storage) == 1 or player:getStorageValue(_Lib_Battle_Info.TeamTwo.storage) == 1 then
				player:teleportTo(player:getTown():getTemplePosition())
				player:setStorageValue(_Lib_Battle_Info.TeamOne.storage, -1)
				player:setStorageValue(_Lib_Battle_Info.TeamTwo.storage, -1)
				player:removeCondition(CONDITION_OUTFIT)
			end
		end
		broadcastMessage("[BattleField] O evento nao foi iniciado por nao atingir o numero de jogadores.")
		Game.setStorageValue(_Lib_Battle_Info.storage_count, 0)
		resetBattle()
		removeBattleTp()
	end
	addEvent(CheckEvent, 60000, delay - 1)
end
