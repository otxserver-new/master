local freeBlessMaxLevel = 120

function onLogin(cid)
    local player = Player(cid)
    if player:getLevel() <= freeBlessMaxLevel then
        for i = 1, 6 do
            player:addBlessing(i)
        end
    	player:sendTextMessage(MESSAGE_EVENT_ADVANCE,'You received all blessing for you to be level less than ' .. freeBlessMaxLevel .. '!')
        player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
    end
    return true
end
