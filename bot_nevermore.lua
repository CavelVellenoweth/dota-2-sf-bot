local myMode 
local enemyTowerHP = 1600;
local aggresiveness = RandomFloat(0,1)
local cockyness = RandomFloat(0,1)
local tiltability = RandomFloat(0,1)
local accuracy = RandomFloat(0,1)
local greed = RandomFloat(0,1)
function GetAverageCreepLocation(creepList)
local averageCreepLocation = nil;
	if #creepList > 0 then
		averageCreepLocation = Vector(0,0)
	end
	for k,creep in ipairs(creepList) do
		averageCreepLocation = averageCreepLocation + creep:GetLocation()
	end
	if averageCreepLocation ~= nil then
		averageCreepLocation = averageCreepLocation/#creepList	
	end	
return averageCreepLocation
end
function HasCatapult(creepList)
	local hasCatapult = false;
	for k,creep in ipairs(creepList) do
		if creep:GetUnitName() == "npc_dota_goodguys_siege" or creep:GetUnitName() == "npc_dota_goodguys_siege_upgraded" or creep:GetUnitName() == "npc_dota_goodguys_siege_upgraded_mega" or creep:GetUnitName() == "npc_dota_badguys_siege" or creep:GetUnitName() == "npc_dota_badguys_siege_upgraded" or creep:GetUnitName() == "npc_dota_badguys_siege_upgraded_mega" then
			hasCatapult = true;
		end
	end
	return hasCatapult
end
function ChooseBotMode(me,enemyHero,enemyID,myTower,enemyTower,myCreeps,enemyCreeps,myCourier)
	myMode = "laneandtrade";

--lanepassive
	--if enemyHero ~= nil and enemyHero:GetAttackDamage() > me:GetAttackDamage() + 20 or enemyHero:GetLevel() > me:GetLevel() + 1 or me:GetHealth() <= me:GetMaxHealth() * 0.5 or me:GetMana() < me:GetMaxMana()*0.5 then

	--end

--laneandtrade
	if enemyHero ~= nil then
		if enemyHero:GetAttackDamage() > me:GetAttackDamage() - 10 and enemyHero:GetAttackDamage() < me:GetAttackDamage() + 10 then
			if me:GetMana() >= enemyHero:GetMana()*0.9 and me:GetHealth() >= enemyHero:GetHealth()*0.9 then
				myMode = "laneandtrade"
			end
		elseif enemyHero:GetMana() < enemyHero:GetMaxMana()*0.5 and me:GetHealth() > me:GetMaxHealth()*0.5 then
			myMode = "laneandtrade"
		end
	end

--tradeheavy
	if enemyHero ~= nil then
		if enemyHero:GetAttackDamage() +20 - (10 * aggresiveness) <= me:GetAttackDamage() and me:GetHealth() >= enemyHero:GetHealth() then
			if me:GetMana() > me:GetMaxMana()*(0.5 * aggresiveness) or enemyHero:GetMana() < enemyHero:GetMaxMana()*0.5 then
				myMode = "tradeheavy"
			end
		end
	end
--zone
	if enemyHero ~= nil then
		if GetAverageCreepLocation(enemyCreeps) ~= nil and GetUnitToLocationDistance(enemyTower,GetAverageCreepLocation(enemyCreeps)) > 1200 then 
			if me:GetHealth() > me:GetMaxHealth() * 0.75 then
				if enemyHero:GetHealth() < enemyHero:GetMaxHealth() * 0.5 and me:GetMana() > me:GetMaxMana()*0.5 then
					myMode = "zone"
				elseif enemyHero:GetAttackDamage() +20 - (10 * aggresiveness) <= me:GetAttackDamage() then
					myMode = "zone"
				end
			end
		end
	end
--push
	if myTower:GetHealth() < myTower:GetMaxHealth()*0.5 or enemyTowerHP < 800 then	
		if CalculateTotalHpFromList(enemyCreeps) < CalculateTotalHpFromList(myCreeps) *0.75 and HasCatapult(myCreeps) then
			myMode = "push"
		elseif CalculateTotalHpFromList(enemyCreeps) *0.75 > CalculateTotalHpFromList(myCreeps) then
			myMode = "push"
		end
	end
	
	if HasCatapult(myCreeps) then
		if GetHeroLastSeenInfo(enemyID)[2] ~= nil then
			if GetHeroLastSeenInfo(enemyID)[2] > 5 or GetHeroLastSeenInfo(enemyID)[2] > 10 then
				myMode = "push"
			end
		else
			myMode = "push"
		end
	end
	if IsHeroAlive(enemyID) == false then
			myMode = "push"
			return;
	end
--retreat
	if me:GetHealth() < me:GetMaxHealth() *0.1 and IsHeroAlive(enemyID) == true then
		myMode = "retreat"
	end
	if me:HasModifier("modifier_flask_healing") == true or me:GetHealth() < me:GetMaxHealth() *0.5 and me:FindItemSlot("item_flask") < 6 then
		myMode = "retreat"
		return;
	end 
	if enemyHero ~= nil then
		if me:GetMana() < me:GetMaxMana() *0.5 or enemyHero:GetHealth() > enemyHero:GetMaxHealth() *0.75 then
			if enemyHero:GetMana() > enemyHero:GetMaxMana() *0.5 and me:GetHealth() < me:GetMaxHealth() *0.5 then
				myMode = "retreat"
			end
		end
	end

--kill
	if enemyHero ~= nil and me:GetLevel() > 1 then
		if enemyHero:GetHealth() < enemyHero:GetMaxHealth() *0.5 then
			myMode = "kill"
		end
		if enemyHero:GetMana() < enemyHero:GetMaxMana() *0.25 or me:GetHealth() > me:GetMaxHealth() *0.5 then
			if me:GetMana() > me:GetMaxMana() *0.25 and enemyHero:GetHealth() < enemyHero:GetMaxHealth() *0.6 then
				myMode = "kill"
			end
		end
	end
--dive
	if enemyHero ~= nil and me:GetLevel() > 2 then
		if enemyHero:GetHealth() < enemyHero:GetMaxHealth() *0.1 and GetUnitToUnitDistance(me,enemyHero) < 500 + (200 * aggresiveness) then
			myMode = "dive"
		end
	end
end
function CourierUsageThink()
	local myCourier = GetCourier(0)
	local npcBot = GetBot();
	if GetCourierState(myCourier) == 6 or IsCourierAvailable() == false then
		return
	end
	if npcBot:GetStashValue() > 450 + (200 * greed) or npcBot:FindItemSlot("item_flask") > 8 or myCourier:FindItemSlot("item_flask") ~= nil	 then
		npcBot:ActionImmediate_Courier( myCourier, 6)
	end
end
function IsBackPackEmpty(unit)
	for i = 6,8 do
		if unit:GetItemInSlot(i) ~= nil then
			return false
		end	
	end
	return true
end
function ItemUsageThink()
	local npcBot = GetBot();
	myWandCharges = 0;
	myWandSlot = nil;
	if npcBot:FindItemSlot("item_magic_wand") >= 0 then
		myWandSlot = npcBot:FindItemSlot("item_magic_wand")
		myWandCharges = npcBot:GetItemInSlot(myWandSlot):GetCurrentCharges();
	elseif npcBot:FindItemSlot("item_magic_stick")  >= 0 then
		myWandSlot = npcBot:FindItemSlot("item_magic_stick")
		myWandCharges = npcBot:GetItemInSlot(myWandSlot):GetCurrentCharges();
	end

	for i=0,5 do 
		if npcBot:GetItemInSlot(i) == nil or npcBot:GetItemInSlot(i):GetName() == "item_tpscroll" then
			if IsBackPackEmpty(npcBot) == false then
				for x=6,8 do
					if npcBot:GetItemInSlot(x) ~= nil then
						npcBot:ActionImmediate_SwapItems(i, x)
						break;
					end
				end
			end
		end
	end
	if enemyHero ~= nil and npcBot:GetHeath() < npcBot:GetMaxHealth() *0.2 then
		if enemyHero:IsCastingAbility() == true or enemyHero:GetAttackTarget() == npcBot then
			if WandSlot ~= nil and WandSlot < 6 and myWandCharges > 0 then
				if npcBot:FindItemSlot("item_magic_wand") >= 0 then
					npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_magic_wand")))
				elseif npcBot:FindItemSlot("item_magic_stick") >= 0 then
					npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_magic_stick")))
				end
			end
		end
	end
	if npcBot:GetHealth() < npcBot:GetMaxHealth() / 2 or npcBot:GetHealth() + 400 < npcBot:GetMaxHealth() then
		if npcBot:FindItemSlot("item_flask") < 6 and npcBot:HasModifier("modifier_flask_healing") == false then
			if enemyHero ~= nil and getUnitToUnitDistance(enemyHero, npcBot) > 800 then
				npcBot:Action_UseAbilityOnEntity(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_flask")),npcBot)
			elseif enemyHero == nil then
				npcBot:Action_UseAbilityOnEntity(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_flask")),npcBot)
			end
		end
	end
	if npcBot:GetMana() + 200 < npcBot:GetMaxMana() then
		if npcBot:FindItemSlot("item_enchanted_mango") < 6 then
			npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_enchanted_mango")))
		end
	end
	if RandomFloat(0,1) < cockyness then
		if GetItemInSlot(1) ~= nil then
			npcBot:Action_DropItem(GetItemInSlot(1),npcBot:GetLocation())
		end
	end
end
function CanCastRazeOnTarget( npcTarget )
	return not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function GetDirectionAndNormalize(vector1, vector2)
	local vector = vector2 - vector1
	local vectorMag = math.sqrt(((vector[1]*vector[1]) + (vector[2]*vector[2])))
	vector = vector / vectorMag
	return vector
end
function ConsiderRaze(razeNum)

	local npcBot = GetBot();
	local ability = npcBot:GetAbilityByName( "nevermore_shadowraze"..razeNum ) 
	-- Get some of its values
	local nRadius = ability:GetSpecialValueInt( "shadowraze_radius" );
	local nCastRange = ability:GetSpecialValueInt( "shadowraze_range" );
	local nDamage = ability:GetSpecialValueInt( "shadowraze_damage" );
	local nCastPoint = abilityRaze1:GetCastPoint();

	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps(1600, true);
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:GetHealth() < nDamage) 
		then
			if CanCastRazeOnTarget(npcEnemy) then
				return 1 , npcEnemy:GetLocation();
			end
		end
	end
	---modes
	--push
	if myMode == "push" then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1600, nRadius,nCastPoint, 9999 );
		if locationAoE.count >= 2 then		
			return 1, locationAoE.targetloc;	
		end
	end
	--laneandtrade
	if myMode == "laneandtrade" then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1600, nRadius,nCastPoint, 9999 );
		if locationAoE.count >= 2 then		
			return 1, locationAoE.targetloc;	
		end
	end
	--tradeheavy
	if myMode == "tradeheavy" then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes ) do
			return 1 , npcEnemy:GetLocation();
		end
	end
	--kill/dive
	if myMode == "kill" or myMode == "dive" then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes ) do
			return 1 , npcEnemy:GetLocation();
		end
	end
	return 0, 0;
end

function AbilityUsageThink()

	local npcBot = GetBot();
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() ) then return end;
	abilityRaze1 = npcBot:GetAbilityByName( "nevermore_shadowraze1" );
	if abilityRaze1:GetLevel() == 0 then
		return
	end
	abilityRaze2 = npcBot:GetAbilityByName( "nevermore_shadowraze2" );
	abilityRaze3 = npcBot:GetAbilityByName( "nevermore_shadowraze3" );
	local nCastPoint = abilityRaze1:GetCastPoint();
	local nRadius = abilityRaze1:GetSpecialValueInt( "shadowraze_radius" );
	local nDamage = abilityRaze1:GetSpecialValueInt( "shadowraze_damage" );
	local nCastRange1 = abilityRaze1:GetSpecialValueInt( "shadowraze_range" );
	local nCastRange2 = abilityRaze2:GetSpecialValueInt( "shadowraze_range" );
	local nCastRange3 = abilityRaze3:GetSpecialValueInt( "shadowraze_range" );
				
	--Consider using each ability
	castRaze1Desire, enemy = ConsiderRaze(1);
	castRaze2Desire, enemy = ConsiderRaze(2);
	castRaze3Desire, enemy = ConsiderRaze(3);

	if(castRaze1Desire > 0 or castRaze2Desire > 0 or castRaze3Desire > 0 )then
		if enemyHero ~= nil and GetUnitToUnitDistance(npcBot,enemyHero) > 1000 then
			castRaze1Desire = 0
			castRaze2Desire = 0
			castRaze3Desire = 0
		end
		if myMode == "laneandtrade" and abilityRaze3:IsFullyCastable() then
			castRaze1Desire = 0
			castRaze2Desire = 0
		end
		if myMode == "tradeheavy" then
			if (GetUnitToLocationDistance(npcBot,enemy) < 325 and castRaze1Desire > 0 and abilityRaze1:IsFullyCastable()) then
					castRaze2Desire = 0
					castRaze3Desire = 0
				if not abilityRaze2:IsFullyCastable() or not abilityRaze3:isFullyCastable() then
					castRaze1Desire = 0
				end
			elseif (GetUnitToLocationDistance(npcBot,enemy) > 575 and castRaze3Desire > 0 and abilityRaze3:IsFullyCastable()) then
					castRaze1Desire = 0
					castRaze2Desire = 0
				if not abilityRaze1:IsFullyCastable() or not abilityRaze2:isFullyCastable() then
					castRaze2Desire = 0
				end
			elseif (castRaze2Desire > 0 and abilityRaze2:IsFullyCastable())then
					castRaze1Desire = 0
					castRaze3Desire = 0
				if not abilityRaze1:IsFullyCastable() or not abilityRaze3:isFullyCastable() then
					castRaze2Desire = 0
				end
			else
				castRaze1Desire = 0
				castRaze2Desire = 0
				castRaze3Desire = 0
			end
		end
		if myMode == "push" then
		if (GetUnitToLocationDistance(npcBot,enemy) < 325 and castRaze1Desire > 0 and abilityRaze1:IsFullyCastable()) then
				castRaze2Desire = 0
				castRaze3Desire = 0
			elseif (GetUnitToLocationDistance(npcBot,enemy) > 575 and castRaze3Desire > 0 and abilityRaze3:IsFullyCastable()) then
				castRaze1Desire = 0
				castRaze2Desire = 0
			elseif (castRaze2Desire > 0 and abilityRaze2:IsFullyCastable())then
				castRaze1Desire = 0
				castRaze3Desire = 0
			else
				castRaze1Desire = 0
				castRaze2Desire = 0
				castRaze3Desire = 0
			end
		end
		if myMode == "kill" or myMode == "dive" then
			if (GetUnitToLocationDistance(npcBot,enemy) < 325 and castRaze1Desire > 0 and abilityRaze1:IsFullyCastable()) then
				castRaze2Desire = 0
				castRaze3Desire = 0
			elseif (GetUnitToLocationDistance(npcBot,enemy) > 575 and castRaze3Desire > 0 and abilityRaze3:IsFullyCastable()) then
				castRaze1Desire = 0
				castRaze2Desire = 0
				if enemyHero ~= nil and abilityRaze2:IsCooldownReady() and enemyHero:GetHealth() > nDamage then
					castRaze2Desire = 1
				end
			elseif (castRaze2Desire > 0 and abilityRaze2:IsFullyCastable())then
				castRaze1Desire = 0
				castRaze3Desire = 0
			else
				castRaze1Desire = 0
				castRaze2Desire = 0
				castRaze3Desire = 0
			end
		end
	end
	if ( castRaze1Desire > 0 ) 
	then
		if myMode == "push" then
			npcBot:Action_MoveToLocation(enemy)
			if GetUnitToLocationDistance(npcBot,enemy) < nCastRange1 + nRadius/5 and GetUnitToLocationDistance(npcBot,enemy) > nCastRange1 - nRadius/5 and npcBot:IsFacingLocation(enemy,20) then
				npcBot:Action_UseAbility(abilityRaze1);
				return;
			end
		end
		if enemyHero ~= nil then
		npcBot:Action_MoveToLocation(npcBot:GetLocation() + GetDirectionAndNormalize(npcBot:GetLocation(),enemyHero:GetExtrapolatedLocation(nCastPoint))*75);
		end
		if enemyHero ~= nil and GetUnitToLocationDistance(npcBot,enemy) < nCastRange1 + nRadius and GetUnitToLocationDistance(npcBot,enemy) > nCastRange1 - nRadius then
			if npcBot:IsFacingLocation( enemyHero:GetLocation(), 20) then
				npcBot:Action_UseAbility(abilityRaze1);
			return;
			end
		end
		return;
	end

	if ( castRaze2Desire > 0 ) 
	then
		if myMode == "push" then
			npcBot:Action_MoveToLocation(enemy)
			if GetUnitToLocationDistance(npcBot,enemy) < nCastRange2 + nRadius/5 and GetUnitToLocationDistance(npcBot,enemy) > nCastRange2 - nRadius/5  and npcBot:IsFacingLocation(enemy,20) then
				npcBot:Action_UseAbility(abilityRaze2);
				return;
			elseif GetUnitToLocationDistance(npcBot,enemy) < nCastRange2 then
				npcBot:Action_MoveToLocation(Vector(6923.0, 6337.0, 384.0))
			end
		end
		if GetUnitToLocationDistance(npcBot,enemy) < nCastRange2 and abilityRaze1:IsCooldownReady() == true then
				npcBot:Action_MoveToLocation(Vector(6923.0, 6337.0, 384.0))
		end
		if enemyHero ~= nil then
			npcBot:Action_MoveToLocation(npcBot:GetLocation() + GetDirectionAndNormalize(npcBot:GetLocation(),enemyHero:GetExtrapolatedLocation(nCastPoint))*75);
		end
		if enemyHero ~= nil and GetUnitToLocationDistance(npcBot,enemy) < nCastRange2 + nRadius/5 and GetUnitToLocationDistance(npcBot,enemy) > nCastRange2 - nRadius/5 then
			
			if npcBot:IsFacingLocation( enemyHero:GetLocation(), 20) then
				npcBot:Action_UseAbility(abilityRaze2);
			return;
			end
		end
		return;
	end

	if ( castRaze3Desire > 0 ) 
	then
		if myMode == "push" then
			if GetUnitToLocationDistance(npcBot,enemy) < nCastRange3 + nRadius/10 and GetUnitToLocationDistance(npcBot,enemy) > nCastRange3 - nRadius/10 and npcBot:IsFacingLocation(enemy,20) then
				npcBot:Action_UseAbility(abilityRaze3);
				return;
			elseif GetUnitToLocationDistance(npcBot,enemy) < nCastRange3 then
				npcBot:Action_MoveToLocation(Vector(6923.0, 6337.0, 384.0))
			end
		end
		npcBot:Action_MoveToLocation(enemy)
		if GetUnitToLocationDistance(npcBot,enemy) < nCastRange3 and abilityRaze1:IsCooldownReady() == true and abilityRaze2:IsCooldownReady() == true then
				npcBot:Action_MoveToLocation(Vector(6923.0, 6337.0, 384.0))
		end
		if enemyHero ~= nil then
			npcBot:Action_MoveToLocation(npcBot:GetLocation() + GetDirectionAndNormalize(npcBot:GetLocation(),enemyHero:GetExtrapolatedLocation(nCastPoint))*75);
		end
		if enemyHero ~= nil and GetUnitToLocationDistance(npcBot,enemy) < nCastRange3 + nRadius/2 and GetUnitToLocationDistance(npcBot,enemy) > nCastRange3/2 - nRadius then
			if npcBot:IsFacingLocation( enemyHero:GetLocation(), 10) then
				npcBot:Action_UseAbility(abilityRaze3);
			return;
			end
		end
		return;
	end
return
end

function Sort(array)
	local temp = nil;
 	for k,v in ipairs(array) do
		for l,b in ipairs(array) do
			if array[l+1] ~= nil and array[l][2] > array[l+1][2] then
				local temp = array[l][2]
				array[l][2] = array[l+1][2]	
				array[l+1][2] = temp	
			end
		end
	end
	return array
end

function IsInTowerRangeList(unitList, tower)
	local state = false
	for k,v in ipairs(unitList) do
		if GetUnitToUnitDistance(tower,v) <= 815 then
			state = true
		end
	end
	return state
end

function IsInTowerRange(unit,tower)
	local state = false;
	if GetUnitToUnitDistance(tower,unit) <= 815 then
		state = true
	end
	return state
end

function CalculateDamageAfterReductions(damage, enemy)	
	damage = damage * (1 - (0.05 * enemy:GetArmor()/ (1+0.05*enemy:GetArmor())))
	return damage
end

function FindSafestUnit(unitList)
	local safest = nil;
	safest = unitList[1];
	for k,v in ipairs(unitList) do
		if GetUnitToLocationDistance(safest, Vector(0,0)) >= GetUnitToLocationDistance(v,Vector(0,0)) then
			safest = v
		end
	end
	return safest
end

function FindLowestHpUnitFromList(unitList)
	lowestHpUnit = nil;
	for k,v in ipairs(unitList) do 
		if lowestHpUnit == nil then
			lowestHpUnit = v;
		end
		if lowestHpUnit ~= nil and lowestHpUnit:GetHealth() > v:GetHealth() then
			lowestHpUnit = v;
		end
	end
	return lowestHpUnit
end

function FindLowestPercentHpUnitFromList(unitList)
	lowestPercentHpUnit = nil;
	for k,v in ipairs(unitList) do 
		if lowestPercentHpUnit == nil then
			lowestPercentHpUnit = v;
		end
		if lowestPercentHpUnit ~= nil and lowestPercentHpUnit:GetHealth()/lowestPercentHpUnit:GetMaxHealth() > v:GetHealth()/v:GetMaxHealth() then
			lowestPercentHpUnit = v;
		end
	end
	return lowestPercentHpUnit
end

function CalculateTotalHpFromList(unitList)
	local total = 0;
	for k,v in ipairs(unitList) do
		total = total + v:GetHealth()
	end 
	return total
end

function CheckIfUnitIsKillable(unitIncomingDamageMatrix,totalIncomingDamage, myDamage,unit)
	local killtime = 10000;
	local damagesum = 0;
	if (unit ~= nil and CalculateDamageAfterReductions(myDamage,unit) > unit:GetHealth()) then
		return 0
	end
	if (unit ~= nil and CalculateDamageAfterReductions(totalIncomingDamage + myDamage,unit) > unit:GetHealth()) then
		for k,v in ipairs(unitIncomingDamageMatrix) do
			damagesum = damagesum + unitIncomingDamageMatrix[k][1]:GetAttackDamage()
			if CalculateDamageAfterReductions(damagesum + myDamage, unit) > unit:GetHealth() then
				killtime = unitIncomingDamageMatrix[k][2]
				break
			end
		end
	end
	return killtime;
end

function GetAttackingUnitsList(unitList, target)
	local attackedbycount = 0;
	local attackedbylist = {};
	local totalincdamage = 0;
	for k,v in ipairs(unitList) do
		if target ~= nil and v:GetAttackTarget() == target then
			attackedbycount = attackedbycount + 1;
			attackedbylist[attackedbycount] = v;
			--lowestEnemyHpDPS = lowestEnemyHpDPS + (v:GetAttackDamage() / v:GetSecondsPerAttack())
			totalincdamage = totalincdamage + v:GetAttackDamage();
			if totalincdamage > target:GetHealth() then	
			end
		end
			
	end
	
	return attackedbylist, totalincdamage
end

function EstimateDeathTime(unitList, target)
	local targetDTPS = 0;
	local deathTime = 0;
	for k,v in ipairs(unitList) do
		targetDTPS = targetDTPS + (CalculateDamageAfterReductions(v:GetAttackDamage(),target) / v:GetSecondsPerAttack())	
	end
	deathTime = target:GetHealth()/targetDTPS
	return deathTime

end

function ProcessIncomingDamage(attackingUnitList,attackedUnit)
	local matrix = {};
	local timetohit = 1000;
	local nextdamage = 0;
	for k,v in ipairs(attackingUnitList) do
			matrix[k] = {}
      			for j=1,2 do
       				matrix[k][j] = 0
      			end
			matrix[k][1] = v;
		if v:GetAttackRange() > 200 then 
			if (v:GetSecondsPerAttack() * v:GetAnimCycle()) < v:GetAttackPoint() then
				matrix[k][2] = (v:GetAttackPoint() - (v:GetSecondsPerAttack() * v:GetAnimCycle())) + (GetUnitToUnitDistance(attackedUnit,v)/v:GetAttackProjectileSpeed())
				if (v:GetAttackPoint() - (v:GetSecondsPerAttack() * v:GetAnimCycle())) + (GetUnitToUnitDistance(attackedUnit,v)/v:GetAttackProjectileSpeed()) < timetohit then
					timetohit = (v:GetAttackPoint() - (v:GetSecondsPerAttack() * v:GetAnimCycle())) + (GetUnitToUnitDistance(attackedUnit,v)/v:GetAttackProjectileSpeed())
					nextdamage = CalculateDamageAfterReductions(v:GetAttackDamage(),attackedUnit)
				end
			elseif (v:GetSecondsPerAttack() * v:GetAnimCycle()) > v:GetAttackPoint() then
				matrix[k][2] = (v:GetAttackPoint() + (1 - (v:GetSecondsPerAttack() * v:GetAnimCycle()))) + (GetUnitToUnitDistance(attackedUnit,v)/v:GetAttackProjectileSpeed())
				if (v:GetAttackPoint() + (1 - (v:GetSecondsPerAttack() * v:GetAnimCycle()))) + (GetUnitToUnitDistance(attackedUnit,v)/v:GetAttackProjectileSpeed()) < timetohit then
					timetohit = (v:GetAttackPoint() + (1 - (v:GetSecondsPerAttack() * v:GetAnimCycle()))) + (GetUnitToUnitDistance(attackedUnit,v)/v:GetAttackProjectileSpeed())
					nextdamage = CalculateDamageAfterReductions(v:GetAttackDamage(),attackedUnit)
				end
				incomingProjectiles = attackedUnit:GetIncomingTrackingProjectiles();
				if incomingProjectiles ~= nil then
					for l,projectile in ipairs(incomingProjectiles) do
						if projectile ~= nil and projectile.caster == v then 
							matrix[k][2] = (GetUnitToLocationDistance(attackedUnit,projectile.location)/projectile.caster:GetAttackProjectileSpeed())
							if timetohit > (GetUnitToLocationDistance(attackedUnit,projectile.location)/projectile.caster:GetAttackProjectileSpeed()) then
								timetohit = (GetUnitToLocationDistance(attackedUnit,projectile.location)/projectile.caster:GetAttackProjectileSpeed())
								nextdamage = CalculateDamageAfterReductions(projectile.caster:GetAttackDamage(),attackedUnit)	
							end
						end
					end
				end
					
			end
		else 	
			if v:GetAnimCycle() < v:GetAttackPoint() then
				
				matrix[k][2] = (v:GetAttackPoint() - v:GetAnimCycle())
				if (v:GetAttackPoint() -v:GetAnimCycle()) < timetohit then
					timetohit = (v:GetAttackPoint() - v:GetAnimCycle())
					nextdamage = CalculateDamageAfterReductions(v:GetAttackDamage(),attackedUnit)
				end
			elseif v:GetAnimCycle() > v:GetAttackPoint() then
				matrix[k][2] = (v:GetAttackPoint() + (1 - v:GetAnimCycle()))
				if (v:GetAttackPoint() + (1 - v:GetAnimCycle())) < timetohit then
					timetohit = (v:GetAttackPoint() + (1 - v:GetAnimCycle()))
					nextdamage = CalculateDamageAfterReductions(v:GetAttackDamage(),attackedUnit)
				end
			end
		end
		

	end
	return matrix, timetohit, nextdamage
end

local skillBuild = {
			"nevermore_necromastery",
			"nevermore_shadowraze1",
			"nevermore_shadowraze1",
			"nevermore_necromastery",
			"nevermore_shadowraze1",
			"nevermore_necromastery",
			"nevermore_shadowraze1",
			"nevermore_necromastery",
			"nevermore_dark_lord",
			"special_bonus_attack_speed_20",
			"nevermore_dark_lord",
			"nevermore_dark_lord",
			"nevermore_dark_lord",
			"nevermore_requiem",
			"special_bonus_movement_speed_40",
			"nevermore_requiem",
			"nevermore_requiem",
			"special_bonus_unique_nevermore_2",
			"special_bonus_unique_nevermore_1",
		};

function Think()
	
	for k,v in ipairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
		if v:GetUnitName() == "npc_dota_hero_nevermore" then
			enemyHero = v
		end
	end
	--local enemyHero = GetUnitList(UNIT_LIST_ENEMY_HEROES)[1]
	local enemyID = 0;
	local npcBot = GetBot();
	local lowestCreep = nil;
	local lowestEnemyCreep = nil;
	local lowestPercentFriendlyCreep = nil;
	local lowestPercentEnemyCreep = nil;
	local lowestFriendlyCreep = nil;
	local myAttackRange = npcBot:GetAttackRange();
	local myAttackPoint = npcBot:GetAttackPoint();
	local myAttackSpeed = npcBot:GetAttackSpeed();
	local myProjectileSpeed = npcBot:GetAttackProjectileSpeed();
	local tableEnemyLaneCreeps = npcBot:GetNearbyCreeps(1600, true);
	local tableFriendlyLaneCreeps = npcBot:GetNearbyCreeps(1600, false);
	local attackedbyenemy = {};
	local attackedbyfriendly = {};
	local nextdamageenemy = 0;
	local timetohitenemy = 10000000;
	local nextdamagefriendly = 0;
	local timetohitfriendly = 10000000;
	local totalincdamagefriendly = 0;
	local totalincdamageenemy = 0;
	local outgoingFriendlyDamage = {};
	local incomingEnemyDamage = {};
	local killtimefriendly = 10000;
	local killtimeenemy = 10000;

	if enemyHero ~= nil and math.fmod(math.floor(DotaTime()),60)then
		if enemyHero:GetLevel() > npcBot:GetLevel() then
			if RollPercentage(10 * tiltability) == true and accuracy > 0.1 then
				accuracy = accuracy -0.1
			end
		end
	end

	ChooseBotMode(npcBot,enemyHero,enemyID,GetTower(3,3),GetTower(2,3),tableFriendlyLaneCreeps,tableEnemyLaneCreeps,GetCourier(0));
	CourierUsageThink()

	if GetTower(2,3):GetHealth() > 0 then
		enemyTowerHP = GetTower(2,3):GetHealth()
	end

	if npcBot:GetAbilityPoints() > 0 then
		npcBot:ActionImmediate_LevelAbility(skillBuild[1])
		table.remove(skillBuild,1)
	end

	if IsInTowerRangeList(tableEnemyLaneCreeps, GetTower(3,3)) then
		table.insert(tableFriendlyLaneCreeps,GetTower(3,3))
	end

	if IsInTowerRangeList(tableFriendlyLaneCreeps, GetTower(2,3)) then
		table.insert(tableEnemyLaneCreeps,GetTower(2,3))
	end

	if IsInTowerRange(npcBot, GetTower(2,3)) then
		table.insert(tableEnemyLaneCreeps,GetTower(2,3))
	end

	local totalEnemyLaneCreepHP = CalculateTotalHpFromList(tableEnemyLaneCreeps);
	local totalFriendlyLaneCreepHP = CalculateTotalHpFromList(tableFriendlyLaneCreeps);
	lowestFriendlyCreep = FindLowestHpUnitFromList(tableFriendlyLaneCreeps)
 	lowestEnemyCreep = FindLowestHpUnitFromList(tableEnemyLaneCreeps)
	lowestPercentFriendlyCreep = FindLowestPercentHpUnitFromList(tableFriendlyLaneCreeps)
 	lowestPercentEnemyCreep = FindLowestPercentHpUnitFromList(tableEnemyLaneCreeps)	

	if lowestFriendlyCreep ~= nil and lowestEnemyCreep ~=nil and lowestFriendlyCreep:GetHealth() < lowestEnemyCreep:GetHealth() then
		lowestCreep = lowestFriendlyCreep
	else
		lowestCreep = lowestEnemyCreep
	end
	
	attackedbyfriendly, totalincdamagefriendly = GetAttackingUnitsList(tableFriendlyLaneCreeps, lowestEnemyCreep);
	attackedbyenemy, totalincdamageenemy = GetAttackingUnitsList(tableEnemyLaneCreeps, lowestFriendlyCreep);
	
	if enemyHero ~= nil and lowestFriendlyCreep ~= nil and enemyHero:GetAttackTarget() == lowestFriendlyCreep then
		table.insert(attackedbyenemy, enemyHero)
		totalincdamageenemy = totalincdamageenemy + enemyHero:GetAttackDamage()
	end

	if enemyHero ~= nil and lowestEnemyCreep ~= nil and enemyHero:GetAttackTarget() == lowestEnemyCreep and lowestEnemyCreep:GetHealth()<=lowestEnemyCreep:GetMaxHealth() then
		table.insert(attackedbyfriendly, enemyHero)
		totalincdamagefriendly = totalincdamagefriendly + enemyHero:GetAttackDamage()
	end

	outgoingFriendlyDamage, timetohitfriendly, nextdamagefriendly = ProcessIncomingDamage(attackedbyfriendly,lowestEnemyCreep)
	incomingEnemyDamage, timetohitenemy, nextdamageenemy = ProcessIncomingDamage(attackedbyenemy,lowestFriendlyCreep)
	outgoingFriendlyDamage = Sort(outgoingFriendlyDamage);
	incomingEnemyDamage = Sort(incomingEnemyDamage);	
	killtimefriendly = (CheckIfUnitIsKillable(outgoingFriendlyDamage, totalincdamagefriendly, npcBot:GetAttackDamage() - npcBot:GetBaseDamageVariance(), lowestEnemyCreep)+(1-accuracy))
	killtimeenemy = (CheckIfUnitIsKillable(incomingEnemyDamage, totalincdamageenemy, npcBot:GetAttackDamage() - npcBot:GetBaseDamageVariance(), lowestFriendlyCreep)+(1-accuracy))
	print("last hits")
	print(npcBot:GetLastHits())
	print("denies")
	print(npcBot:GetDenies())
	print(enemyHero)
	print(IsHeroAlive(enemyID))
	print(myMode)
	
	if (npcBot:GetHealth()>400 and npcBot:GetCurrentActionType() ~= 4 and npcBot:DistanceFromFountain() == 0) then
		--npcBot:Action_MoveToLocation(Vector(100,300))
	end

	if (#tableEnemyLaneCreeps > 0 and #tableFriendlyLaneCreeps > 0 and npcBot:GetCurrentActionType() ~= 2) then
		--npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0)+ RandomVector(-300))

		if myMode == "lanepassive"  and enemyHero ~= nil then
			if GetUnitToLocationDistance(enemyHero,GetLaneFrontLocation( 1, 2, 0)+ 600) > 500 then
				--npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0)+ RandomVector(700))
			else
				npcBot:Action_MoveToLocation(enemyHero:GetLocation() + RandomFloat(500,700))	
			end
		end

		if  myMode == "tradeheavy" or myMode == "push" then
			npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0) + RandomVector(RandomFloat(-200,200)))
		end

		if myMode == "laneandtrade" then 
			npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0) + RandomVector(RandomFloat(200,400)))
		end

		if myMode == "zone" then
			npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0) + RandomVector(RandomFloat(-400,0)))
		end
	end
	if (#tableEnemyLaneCreeps > 0 and #tableFriendlyLaneCreeps == 0) then
		npcBot:Action_MoveToLocation(Vector(6923.0, 6337.0, 384.0));

		if myMode == "zone" then
			npcBot:Action_MoveToLocation(Vector(0, 0, 0));
		end

	end

	if (#tableEnemyLaneCreeps == 0 and #tableFriendlyLaneCreeps > 0) then
		--npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0)+ RandomVector(-300))

		if myMode == "lanepassive" and enemyHero ~= nil then
			if GetUnitToLocationDistance(enemyHero,Vector(100,300)) > 500  then
				npcBot:Action_MoveToLocation(Vector(100,300))
			else
				npcBot:Action_MoveToLocation(enemyHero:GetLocation() + RandomFloat(500,700))		
			end

		end

		if myMode == "laneandtrade" or myMode == "tradeheavy" or myMode == "push" then
			npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0)+ RandomVector(RandomFloat(0,200)))
		end

		if myMode == "zone" then
			npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0)+ RandomVector(RandomFloat(-400,0)))
		end
	end
	if (#tableEnemyLaneCreeps == 0 and #tableFriendlyLaneCreeps == 0) then
		npcBot:Action_MoveToLocation(Vector(-300.0,500.0))

		if myMode == "lanepassive"  and enemyHero ~= nil then

			if GetUnitToLocationDistance(enemyHero,Vector(-300.0,500.0)) > 500 then
				npcBot:Action_MoveToLocation(Vector(-300.0,500.0))
			else
				npcBot:Action_MoveToLocation(enemyHero:GetLocation() + RandomFloat(500,700))	
			end
		end

		if myMode == "laneandtrade" or myMode == "tradeheavy" or myMode == "push" then
			npcBot:Action_MoveToLocation(Vector(-300.0,500.0))
		end

		if myMode == "zone" then
			npcBot:Action_MoveToLocation(Vector(0, 0, 0))
		end

	end

	if npcBot:GetHealth()<200 and npcBot:GetCurrentActionType() ~= 4 then
		npcBot:Action_MoveToLocation(Vector(6923.0, 6337.0, 384.0))
	end

	if (lowestCreep ~= nul and lowestCreep:GetHealth() <= CalculateDamageAfterReductions(npcBot:GetAttackDamage()*2, lowestEnemyCreep)) then
		--npcBot:Action_MoveToLocation(lowestEnemyCreep:GetLocation());
	end

	if npcBot:WasRecentlyDamagedByCreep(1) == true then
		npcBot:Action_MoveToLocation(Vector(-300.0,500.0))
		if #tableFriendlyLaneCreeps > 0 then
			npcBot:Action_MoveToLocation(Vector(-300.0,500.0))
		end
	end

	if myMode == "laneandtrade" and not npcBot:WasRecentlyDamagedByCreep(5.0) and npcBot:GetCurrentActionType() ~= 4 then
		if enemyHero ~= nil and GetUnitToUnitDistance(npcBot, enemyHero) <= myAttackRange then
			npcBot:Action_AttackUnit (enemyHero, true)
		end
	end

	if lowestFriendlyCreep ~= nil then
		if (killtimeenemy <= (myAttackPoint/(myAttackSpeed) + (GetUnitToUnitDistance(lowestFriendlyCreep, npcBot)/myProjectileSpeed)-0.05)) then
			if lowestFriendlyCreep:GetHealth() < lowestFriendlyCreep:GetMaxHealth()/2 then
				if myMode == "lanepassive" and enemyHero ~= nil and GetUnitToUnitDistance(npcBot,lowestFriendlyCreep) + 500 > GetUnitToUnitDistance(npcBot,enemyHero) and GetUnitToLocationDistance(enemyHero,Vector(-6923.0, -6337.0, 384.0)) < GetUnitToLocationDistance(lowestFriendlyCreep,Vector(-6923.0, -6337.0, 384.0)) then 
					npcBot:Action_AttackUnit (lowestFriendlyCreep, true)
				elseif myMode ~= "lanepassive" then
					npcBot:Action_AttackUnit (lowestFriendlyCreep, true)
				end
			end
		end
	end

	if lowestFriendlyCreep ~= nil and lowestEnemyCreep ~= nil and killtimeenemy > ((myAttackPoint/(myAttackSpeed) + (GetUnitToUnitDistance(lowestEnemyCreep, npcBot)/myProjectileSpeed)))*2.5 and killtimefriendly > ((myAttackPoint/(myAttackSpeed) + (GetUnitToUnitDistance(lowestEnemyCreep, npcBot)/myProjectileSpeed))-0.05)*2 and EstimateDeathTime(attackedbyenemy,lowestFriendlyCreep) < EstimateDeathTime(attackedbyfriendly,lowestEnemyCreep) + 0.5 and EstimateDeathTime(attackedbyenemy,lowestFriendlyCreep) > EstimateDeathTime(attackedbyfriendly,lowestEnemyCreep) - 0.5 then
		if EstimateDeathTime(attackedbyenemy,lowestFriendlyCreep) > EstimateDeathTime(attackedbyenemy,lowestEnemyCreep) and lowestFriendlyCreep:GetHealth() < lowestFriendlyCreep:GetMaxHealth()*0.5 then
			if myMode == "lanepassive" and enemyHero ~= nil and GetUnitToUnitDistance(npcBot,lowestFriendlyCreep) + 500 > GetUnitToUnitDistance(npcBot,enemyHero)  and GetUnitToLocationDistance(enemyHero,Vector(-6923.0, -6337.0, 384.0)) < GetUnitToUnitDistance(Vector(-6923.0, -6337.0, 384.0),lowestFriendlyCreep) then 
				npcBot:Action_AttackUnit (lowestFriendlyCreep, true)
			elseif myMode ~= "lanepassive" then
				npcBot:Action_AttackUnit (lowestFriendlyCreep, true)
			end
		else
			if myMode == "lanepassive" and enemyHero ~= nil and GetUnitToUnitDistance(npcBot,lowestEnemyCreep) + 500 > GetUnitToUnitDistance(npcBot,enemyHero) and GetUnitToLocationDistance(enemyHero,Vector(-6923.0, -6337.0, 384.0)) < GetUnitToLocationDistance(lowestEnemyCreep,Vector(-6923.0, -6337.0, 384.0))  then 
				npcBot:Action_AttackUnit (lowestEnemyCreep, true)
			elseif myMode ~= "lanepassive" then
				npcBot:Action_AttackUnit (lowestEnemyCreep, true)
			end
		end
	end

	if totalEnemyLaneCreepHP > totalFriendlyLaneCreepHP + 200 and killtimefriendly > ((myAttackPoint/(myAttackSpeed) + (GetUnitToUnitDistance(lowestEnemyCreep, npcBot)/myProjectileSpeed)))*2.5 then
			--push	
		if myMode == "lanepassive" and enemyHero ~= nil and GetUnitToUnitDistance(npcBot,lowestPercentEnemyCreep) + 500 > GetUnitToUnitDistance(npcBot,enemyHero)  and GetUnitToLocationDistance(enemyHero,Vector(-6923.0, -6337.0, 384.0)) < GetUnitToLocationDistance(lowestPercentEnemyCreep,Vector(-6923.0, -6337.0, 384.0)) then 
			npcBot:Action_AttackUnit (lowestPercentEnemyCreep, true)
		elseif myMode ~= "lanepassive" then
			npcBot:Action_AttackUnit (lowestPercentEnemyCreep, true)
		end
	end

	if myMode ~= "push" then	
		if lowestEnemyCreep ~= nil and totalFriendlyLaneCreepHP > totalEnemyLaneCreepHP - 200 and killtimeenemy > ((myAttackPoint/(myAttackSpeed) + (GetUnitToUnitDistance(lowestEnemyCreep, npcBot)/myProjectileSpeed)))*2.5 and lowestFriendlyCreep:GetHealth() < lowestFriendlyCreep:GetMaxHealth()/2 then
			--pull
			if myMode == "lanepassive" and enemyHero ~= nil and GetUnitToUnitDistance(npcBot,lowestPercentFriendlyCreep) + 500 > GetUnitToUnitDistance(npcBot,enemyHero) and GetUnitToLocationDistance(enemyHero,Vector(-6923.0, -6337.0, 384.0)) < GetUnitToLocationDistance(lowestPercentFriendlyCreep,Vector(-6923.0, -6337.0, 384.0)) then 
				npcBot:Action_AttackUnit (lowestPercentFriendlyCreep, true)
			elseif myMode ~= "lanepassive" then
				npcBot:Action_AttackUnit (lowestPercentFriendlyCreep, true)
			end
		end
			
		if totalFriendlyLaneCreepHP > totalEnemyLaneCreepHP and lowestFriendlyCreep:GetHealth() < lowestFriendlyCreep:GetMaxHealth()/2 then
			--pull
			if myMode == "lanepassive" and enemyHero ~= nil and GetUnitToUnitDistance(npcBot,lowestPercentFriendlyCreep) + 500 > GetUnitToUnitDistance(npcBot,enemyHero)  and GetUnitToLocationDistance(enemyHero,Vector(-6923.0, -6337.0, 384.0)) < GetUnitToLocationDistance(lowestPercentFriendlyCreep,Vector(-6923.0, -6337.0, 384.0)) then 
				npcBot:Action_AttackUnit (lowestPercentFriendlyCreep, true)
			elseif myMode ~= "lanepassive" then
				npcBot:Action_AttackUnit (lowestPercentFriendlyCreep, true)
			end
		end
	end

	if myMode == "tradeheavy" or "zone" then
		if enemyHero ~= nil and GetUnitToUnitDistance(npcBot, enemyHero) <= myAttackRange + 100 then
			npcBot:Action_AttackUnit (enemyHero, true)
		end
	end

	if lowestEnemyCreep ~= nil then
		if killtimefriendly <= ((myAttackPoint/(myAttackSpeed) + (GetUnitToUnitDistance(lowestEnemyCreep, npcBot)/myProjectileSpeed))-0.1)  then
			if myMode == "lanepassive" and enemyHero ~= nil and GetUnitToUnitDistance(npcBot,lowestEnemyCreep) + 500 > GetUnitToUnitDistance(npcBot,enemyHero)  and GetUnitToLocationDistance(enemyHero,Vector(-6923.0, -6337.0, 384.0)) < GetUnitToLocationDistance(lowestEnemyCreep,Vector(-6923.0, -6337.0, 384.0)) then 
				npcBot:Action_AttackUnit (lowestEnemyCreep, true)
			elseif myMode ~= "lanepassive" then
				npcBot:Action_AttackUnit (lowestEnemyCreep, true)
			end
		end
	end

	if myMode == "laneandtrade" and npcBot:WasRecentlyDamagedByCreep(0.5) == true then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0) + 700 )
	end

	if (enemyHero ~= nil and myMode == "lanepassive" and GetUnitToUnitDistance(npcBot,enemyHero) < 600) then
		npcBot:Action_MoveToLocation(enemyHero:GetLocation()+700);
	end

	if myMode == "push" and #npcBot:GetNearbyTowers(800,true) > 0 and #npcBot:GetNearbyCreeps(800, true) <= 0 then
		npcBot:Action_AttackUnit (GetTower(2,3), true)
	end

	if #npcBot:GetNearbyHeroes(800,true,BOT_MODE_NONE) >= 0 and #npcBot:GetNearbyCreeps(800,true) <= 0 and #npcBot:GetNearbyTowers(800,true) > 0 then
		npcBot:Action_AttackUnit(GetTower(2,3), true)
	end

	if myMode == "kill" and enemyHero ~= nil and GetUnitToUnitDistance(npcBot, enemyHero) <= myAttackRange + 100 then
		npcBot:Action_AttackUnit (enemyHero, true)
	end

	if myMode == "kill" and GetUnitToUnitDistance(npcBot,GetTower(2,3)) < 800 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation( 1, 2, 0) + 600 )
	end

	if GetTower(2,3):GetAttackTarget() == npcBot and myMode ~= "dive" then
		if IsInTowerRangeList(tableFriendlyLaneCreeps, GetTower(2,3)) then
			npcBot:Action_AttackUnit(lowestFriendlyCreep, true)
		else
			npcBot:Action_MoveToLocation(Vector(0,0))
		end
	end

	if myMode == "dive" and enemyHero ~= nil then
		npcBot:Action_AttackUnit(enemyHero, true)
	end

	if myMode == "retreat" then
		npcBot:Action_MoveToLocation(Vector(6923.0, 6337.0, 384.0))
	end

	ItemUsageThink()
	AbilityUsageThink()
	for k,v in ipairs(GetDroppedItemList()) do
		if v[1] ~= nil then
			npcBot:Action_PickUpItem(v[1])
		end
	end			
end