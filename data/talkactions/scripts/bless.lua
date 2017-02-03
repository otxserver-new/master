-- function onSay(cid, words, param, channel)
      --  if getPlayerBlessing(cid, 5) == FALSE then
              --  if getPlayerMoney(cid) >= 50000 then
                       -- for i = 1,5 do
                      --          doPlayerAddBlessing(cid, i)
                     --   end
                   --     doSendMagicEffect(getCreaturePosition(cid), 50)
                 --       doPlayerRemoveMoney(cid, 50000)
               --         doSendMagicEffect(getPlayerPosition(cid), CONST_ME_HOLYDAMAGE)
             --          doPlayerSendTextMessage(cid, 22, "You have been blessed by the gods!")
              --  else
             --           doPlayerSendCancel(cid, "Sorry, but you dont have 5cc")
            --            doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
           --     end
       -- else
          --      doPlayerSendCancel(cid, "You have already been blessed.")
          --      doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
     --   end
--return true
--end 


function getCost(level)
	if level <= 30 then
		return 2000*5
	elseif level >= 120 then
		return 10000*5
	else
		return ((level - 20) * 200 * 5) 
	end
end

function onSay(cid, words, param)
	local p = Player(cid)
	local cost = getCost(getPlayerLevel(cid))
	if(not(isPlayerPzLocked(cid))) then
		if(p:hasBlessing(1) and p:hasBlessing(2) and p:hasBlessing(3) and p:hasBlessing(4) and p:hasBlessing(5) and p:hasBlessing(6)) then
			p:sendCancelMessage("You have already been blessed by the gods.")
			return false
		end
		if(p:removeMoney(cost)) then
			for b = 1,6 do
				p:addBlessing(b)
			end
			p:getPosition():sendMagicEffect(50)
			p:sendTextMessage(19, "You have been blessed by the gods!")
		else
			p:sendCancelMessage("You need "..cost.." gold coins to buy all blessings.")
		end
	else
		p:sendCancelMessage("You can't buy bless, when you are in a battle.")
	end
return false
end
