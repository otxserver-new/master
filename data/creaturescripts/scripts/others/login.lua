local events = {
    'ElementalSpheresOverlords',
    'BigfootBurdenVersperoth',
    'Razzagorn',
    'Shatterer',
    'Zamulosh',	
	'The Hunger',
	'The Rage',
	'Eradicator',
	'Eradicator1',
	'Rupture',
	'World Devourer',	
    'Tarbaz',
    'Shulgrax',
    'Ragiaz',
    'Plagirath',
    'Mazoran',
    'Destabilized',
    'BigfootBurdenWiggler',
    'SvargrondArenaKill',
    'NewFrontierShardOfCorruption',
    'NewFrontierTirecz',
    'ServiceOfYalaharDiseasedTrio',
    'ServiceOfYalaharAzerus',
    'ServiceOfYalaharQuaraLeaders',
    'InquisitionBosses',
    'InquisitionUngreez',
    'KillingInTheNameOfKills',
	'KillingInTheNameOfKillss',
	'KillingInTheNameOfKillsss',
    'MastersVoiceServants',
    'SecretServiceBlackKnight',
    'ThievesGuildNomad',
    'WotELizardMagistratus',
    'WotELizardNoble',
    'WotEKeeper',
    'WotEBosses',
    'WotEZalamon',
    'WarzoneThree',
    'PlayerDeath',
    'AdvanceSave',
    'bossesWarzone',
    'AdvanceRookgaard',
    'PythiusTheRotten',
    'DropLoot',
    'Yielothax',
    'BossParticipation',
    'Energized Raging Mage',
    'Raging Mage', 
    'modalMD1',
	'VibrantEgg',
    'DeathCounter',
    'KillCounter',
    'bless1',
	'lowerRoshamuul' 
}
 
local function onMovementRemoveProtection(cid, oldPosition, time)
    local player = Player(cid)
    if not player then
        return true
    end
 
    local playerPosition = player:getPosition()
    if (playerPosition.x ~= oldPosition.x or playerPosition.y ~= oldPosition.y or playerPosition.z ~= oldPosition.z) or player:getTarget() then
        player:setStorageValue(Storage.combatProtectionStorage, 0)
        return true
    end
 
    addEvent(onMovementRemoveProtection, 1000, cid, oldPosition, time - 1) 
end
 
function onLogin(player)
	local loginStr = 'Welcome to ' .. configManager.getString(configKeys.SERVER_NAME) .. '!'
	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. ' Please choose your outfit.'
		player:sendOutfitWindow()
		player:sendTutorial(1)
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		loginStr = string.format('Your last visit was on %s.', os.date('%a %b %d %X %Y', player:getLastLoginSaved()))
	end
 
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
   
    local playerId = player:getId()
 
    -- Stamina
    nextUseStaminaTime[playerId] = 1
 
    -- STAMINA DEVIDO A QUEDAS START
   
    --local stamina_full = 42 * 60 -- config. 42 = horas
   -- if player:getStamina() >= stamina_full then
      --  player:sendCancelMessage("Your stamina is already full.")
   -- elseif player:getPremiumDays() < 1 then
     --   player:sendCancelMessage("You must have a premium account.")
   -- else
      --  player:setStamina(stamina_full)
     -- player:sendTextMessage(MESSAGE_INFO_DESCR, "Your stamina has been refilled.")      
   -- end
   
    -- STAMINA DEVIDO A QUEDAS END
   
    -- Promotion
   --[[ local vocation = player:getVocation()
    local promotion = vocation:getPromotion()
    if player:isPremium() then
        local value = player:getStorageValue(Storage.Promotion)
        if not promotion and value ~= 1 then
            player:setStorageValue(Storage.Promotion, 1)
        elseif value == 1 then
            player:setVocation(promotion)
        end
    elseif not promotion then
        player:setVocation(vocation:getDemotion())
    end--]]
   
     -- ABRIR CHANNELS
    if(not isInArray({1,2,3,5,6,7,8}, player:getVocation():getId()) or player:getLevel() < 6) then
   -- player:openChannel(7)   -- help channel
    player:openChannel(3)   -- world chat 
    player:openChannel(6)   -- advertsing rook main
    else
  --  player:openChannel(7)   -- help channel
    player:openChannel(3)   -- world chat
    player:openChannel(5)   -- advertsing main 
    end
   
    --
    -- Rewards
    local rewards = #player:getRewardList()
    if(rewards > 0) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You have %d %s in your reward chest.", rewards, rewards > 1 and "rewards" or "reward"))
    end
 
    -- Update player id
    local stats = player:inBossFight()
    if stats then
        stats.playerId = player:getId()
    end
 
    -- fury gates
   
    if Game.getStorageValue(GlobalStorage.FuryGates, (9710)) == 1 then -- for venore
      player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Fury Gate is on Venore Today.')
elseif Game.getStorageValue(GlobalStorage.FuryGates, (9711)) == 2 then -- for ab...
      player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Fury Gate is on Abdendriel Today.')
      elseif Game.getStorageValue(GlobalStorage.FuryGates, (9712)) == 3 then -- for ab...
      player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Fury Gate is on Thais Today.')
      elseif Game.getStorageValue(GlobalStorage.FuryGates, (9713)) == 4 then -- for ab...
      player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Fury Gate is on Carlin Today.')
      elseif Game.getStorageValue(GlobalStorage.FuryGates, (9714)) == 5 then -- for ab...
      player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Fury Gate is on Edron Today.')
      elseif Game.getStorageValue(GlobalStorage.FuryGates, (9716)) == 6 then -- for ab...
     player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Fury Gate is on Kazordoon Today.')
      end
     
   
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, 'OTXServer Global by Malucooo http://www.github.com/malucooo/otxserver-testing/')
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[BONUS EXP] Command for check !exp.')
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[GUILD LEADER COMMAND] Will change all outfits from members !outfit.')
   
    -- Events
    for i = 1, #events do
        player:registerEvent(events[i])
    end
 
    if player:getStorageValue(Storage.combatProtectionStorage) <= os.time() then
        player:setStorageValue(Storage.combatProtectionStorage, os.time() + 10)
        onMovementRemoveProtection(playerId, player:getPosition(), 10)
    end
    return true
end