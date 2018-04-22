
local tableStartingItemsToBuy = 
			{ 				
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_flask",

			};
 
local tableItemsToBuy = { 
				"item_enchanted_mango",
				"item_magic_stick",
				"item_branches",
				"item_branches",
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_boots",
				"item_gloves",
				"item_belt_of_strength",
			};

local tableHPRegenToBuy = {
				"item_flask",
			};
local tableManaRegenToBuy = {
				"item_enchanted_mango",
			};
function BuyItemFromTable(bot, iTable, remove)
	local sNextItem = iTable[1];

	bot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) )
	if ( bot:GetGold() >= GetItemCost( sNextItem ) )
	then
		
		bot:ActionImmediate_Chat("buying item",true)
		bot:ActionImmediate_Chat(tostring(sNextItem),true)
		bot:ActionImmediate_PurchaseItem( sNextItem );
		if remove == true then
			table.remove( iTable, 1 );
		end
	end	
end
----------------------------------------------------------------------------------------------------
function BotHasRegen(bot,courier,type)
	local botHasRegen = false;
	if type == "hp" then
		if bot:FindItemSlot("item_flask") >= 0 then
			botHasRegen = true
		end
		if courier ~= nil then
			if courier:FindItemSlot("item_flask") >= 0 then
				botHasRegen = true
			end
		end
	else
		if bot:FindItemSlot("item_enchanted_mango") >= 0 then
			botHasRegen = true
		end
		if courier ~= nil then
			if courier:FindItemSlot("item_enchanted_mango") >= 0 then
				botHasRegen = true
			end
		end
	end
	return botHasRegen
end
function ItemPurchaseThink()
	local myCourier = GetCourier(0)
	local npcBot = GetBot();
	if #tableStartingItemsToBuy > 0 then
		BuyItemFromTable(npcBot, tableStartingItemsToBuy, true)
		return;
	end
	if BotHasRegen(npcBot, myCourier, "hp") == false then
		BuyItemFromTable(npcBot, tableHPRegenToBuy, false)
		return;
	end
	if BotHasRegen(npcBot, myCourier, "mana") == false then
		BuyItemFromTable(npcBot, tableManaRegenToBuy, false)
		return;
	end
	if ( #tableItemsToBuy == 0 )
	then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end
	BuyItemFromTable(npcBot, tableItemsToBuy, true)

end

----------------------------------------------------------------------------------------------------
