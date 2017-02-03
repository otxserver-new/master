--function onSay(player, words, param)
	--if not player:getGroup():getAccess() then
	--	return true
	--end

	--local lookType = tonumber(param)
	--if lookType >= 0 and lookType ~= 1 and lookType ~= 135 and lookType ~= 411 and lookType ~= 415 and lookType ~= 424 and (lookType <= 160 or lookType >= 192) and lookType ~= 439 and lookType ~= 440 and lookType ~= 468 and lookType ~= 469 and (lookType < 474 or lookType > 485) and lookType ~= 501 and lookType ~= 518 and lookType ~= 519 and lookType ~= 520 and lookType ~= 524 and lookType ~= 525 and lookType ~= 536 and lookType ~= 543 and lookType ~= 549 and lookType ~= 576 and lookType ~= 581 and lookType ~= 582 and lookType <= 1500 then
	--	local playerOutfit = player:getOutfit()
	----	playerOutfit.lookType = lookType
	----	player:setOutfit(playerOutfit)
	--else
	--	player:sendCancelMessage("A look type with that id does not exist.")
	--end
--	return false
--end
 
 
 function doInterval(startNum, endNum, differ) --Makes Math Interval
	local result = {}
	local p, c = 1, endNum-startNum
	result[1] = startNum
	for i = 2, c do
		result[i] = startNum+(i-1)
	end
	if not isInArray(result, endNum) then
		result[#result+1] = endNum
	end
	if differ then
		for i = 1, #result do
			if result[i] == differ then
				table.remove(result, i)
				return result
			end
		end
	end
	return result
end

-- This is what to edit :D
-- It's up to 10.9
local lookTypes = {
	doInterval(2, 160, 135), doInterval(192, 414, 411), doInterval(416, 438, 424),
	doInterval(441, 467), doInterval(470, 473), doInterval(486, 517, 501),
	doInterval(521, 523), doInterval(526, 542, 536), doInterval(544, 580, 549),
	doInterval(583, 615, 597), doInterval(617, 624, 623), doInterval(626, 637),
	644, doInterval(647, 651), doInterval(664, 699, 678), 712, 714,
	doInterval(716, 717), doInterval(720, 721), doInterval(724, 740, 737),
	doInterval(745, 750, 748), doInterval(759, 763), doInterval(842, 863, 861)
}
function onSay(cid, words, param)
	local player = Player(cid)
	
	
	for i = 1, #lookTypes do
		if type(lookTypes[i]) == 'table' then
			for m = 1, #lookTypes[i] do
				if param-lookTypes[i][m] == 0 then
					local playerOutfit = player:getOutfit()
					playerOutfit.lookType = param
					player:setOutfit(playerOutfit)
					return true
				end
			end
		else
			if param == lookTypes[i] then
				local playerOutfit = player:getOutfit()
				playerOutfit.lookType = param
				player:setOutfit(playerOutfit)
				return true
			end
		end
	end
	
	player:sendCancelMessage("A look type with that id does not exist.")
	return false
end