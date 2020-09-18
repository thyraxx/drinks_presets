class DrinkPreset
{
	array<string> drinks;

	void Save(SValueBuilder@ builder)
	{
		builder.PushDictionary();
		builder.PushArray("drinks");
		for (uint i = 0; i < drinks.length(); i++){
			builder.PushString(drinks[i]);
		}
		builder.PopArray();
		builder.PopDictionary();
	}

	void Load(SValue@ data)
	{
		drinks.removeRange(0, drinks.length());
		auto arrEffects = GetParamArray(UnitPtr(), data, "drinks", false);
		if (arrEffects !is null)
		{
			for (uint i = 0; i < arrEffects.length(); i++){
				//print(arrEffects[i].GetString());
				drinks.insertLast(arrEffects[i].GetString());
			}
		}
	}
}

class CustomDrinksMenuContent : ShopMenuContent
{
	array<DrinkPreset@> m_drinkPresets;

	TextWidget@ m_wHeaderText;

	ScrollableWidget@ m_wList;

	Widget@ m_wTemplateItem;
	Widget@ m_wTemplateSprite;

	Widget@ m_wListPresets;
	Widget@ m_wTemplatePreset;

	array<string> cantAfford = {
		"Can't afford.",
		"Git rich.",
		"Peasant",
		"Too poor."
	};

	// Argh, ugly fix but the easiest/fastest I could come up with
	CustomDrinksMenuContent()
	{
		super();
	}

	CustomDrinksMenuContent(UnitPtr unit, SValue& params)
	{
		super();
	}

	void OnShow() override
	{
		@m_wHeaderText = cast<TextWidget>(m_widget.GetWidgetById("headertext"));

		@m_wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));

		@m_wTemplateItem = m_widget.GetWidgetById("template-item");
		@m_wTemplateSprite = m_widget.GetWidgetById("template-sprite");

		@m_wListPresets = m_widget.GetWidgetById("preset-list");
		@m_wTemplatePreset = m_widget.GetWidgetById("preset-template");

		ReloadList();
		ReloadPresets();
	}

	void ReloadPresets()
	{
		auto gm = cast<Campaign>(g_gameMode);
		auto town = gm.m_townLocal;

		m_wListPresets.ClearChildren();

		for (uint i = 0; i < 3; i++)
		{
			auto preset = i;

			auto wNewItem = m_wTemplatePreset.Clone();
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			auto wButtonLoad = cast<ScalableSpriteButtonWidget>(wNewItem.GetWidgetById("button-load"));
			if (wButtonLoad !is null)
			{
				int price = 0;
				bool canBuy;

				string strName = Resources::GetString(".fountain.presets.name", { { "num", i + 1 } });
				wButtonLoad.SetText(strName);
				wButtonLoad.m_tooltipTitle = strName;

				string strTooltip;
				bool secondEffect = false;

				for(uint k = 0; k < Drinkspresets::m_drinkPresets[i].drinks.length(); k++)
				{

					auto drink = GetTavernDrink(HashString(Drinkspresets::m_drinkPresets[i].drinks[k]));


					if(drink.localCount <= 0)
					{
						price = price + drink.cost;
					}

					canBuy = (town.m_gold >= price && (GetLocalPlayerRecord().tavernDrinksBought.length() <= 0));
				}

				for(uint k = 0; k < Drinkspresets::m_drinkPresets[i].drinks.length(); k++)
				{

					auto drink = GetTavernDrink(HashString(Drinkspresets::m_drinkPresets[i].drinks[k]));
					ActorItemQuality drinkQuality = drink.quality;

					// Debugging total price cost
					//print("Total price: " + price);

					// Adds color rarity to the text
				
					if(canBuy)
					{
						if (drinkQuality == 1)
							strTooltip += "\\cffffff";

						if (drinkQuality == 2)
							strTooltip += "\\c00ff00";

						if (drinkQuality == 3)
							strTooltip += "\\c0099ff";
					}
					else
					{
						strTooltip += "\\c737372";
					}

				 	strTooltip += Resources::GetString(".drink." + drink.id + ".name");
				 	strTooltip += "\n";
				}

				// Ugly code color mess :(
				if(!canBuy)
				{
					strTooltip += "\n";
					strTooltip += "\\cff0000";
					
					if(price > town.m_gold)
					{
						strTooltip += cantAfford[randi(cantAfford.length())];
					}
					else if(GetLocalPlayerRecord().tavernDrinksBought.length() > 0)
					{
						strTooltip += "No mixing!";
					}
				}

				wButtonLoad.m_enabled = canBuy;
				wButtonLoad.m_func = "load-preset " + i;

				wButtonLoad.m_tooltipText = strTooltip;
			}

			auto wButtonSave = cast<ScalableSpriteButtonWidget>(wNewItem.GetWidgetById("button-save"));
			if (wButtonSave !is null)
				wButtonSave.m_func = "save-preset " + i;

			m_wListPresets.AddChild(wNewItem);
		}
	}

	void ReloadList() override
	{
		int level = m_shopMenu.m_currentShopLevel;

		auto record = GetLocalPlayerRecord();

%if HARDCORE
		int titleIndex = record.GetTitleIndex();
		auto titleList = record.GetTitleList();
%endif

		int numDrinks = level + 2;
		bool hadEnough = (int(record.tavernDrinks.length()) >= numDrinks);

		if (hadEnough)
			m_wHeaderText.SetText(Resources::GetString(".shop.drinks.message.enough"));
		else
			m_wHeaderText.SetText(record.tavernDrinks.length() + " / " + numDrinks);

		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		for (uint i = 0; i < g_tavernDrinks.length(); i++)
		{
			auto drink = g_tavernDrinks[i];
			if (drink.localCount == -1 && !drink.unlocked)
				continue;

%if HARDCORE
			bool canAfford = Currency::CanAfford(record, drink.cost) && titleIndex >= int(drink.quality) - 1;
%else
			bool canAfford = (drink.localCount > 0 || Currency::CanAfford(record, drink.cost) || drink.unlocked);
%endif

			bool hasConsumed = false;
			for (uint j = 0; j < record.tavernDrinks.length(); j++)
			{
				if (drink.idHash == HashString(record.tavernDrinks[j]))
				{
					hasConsumed = true;
					break;
				}
			}

			Widget@ wNewItem = null;

			if (canAfford && !hasConsumed && !hadEnough)
			{
				auto wNewButton = cast<ScalableSpriteButtonWidget>(m_wTemplateItem.Clone());
				wNewButton.m_func = "buy-drink " + drink.idHash;

				@wNewItem = wNewButton;
			}
			else
			{
				@wNewItem = m_wTemplateSprite.Clone();

				if (hasConsumed)
				{
					auto wCheck = wNewItem.GetWidgetById("icon-check");
					if (wCheck !is null)
						wCheck.m_visible = true;
				}
				else if (hadEnough)
				{
					auto wLock = wNewItem.GetWidgetById("icon-lock");
					if (wLock !is null)
						wLock.m_visible = true;
				}
			}

			if (drink.quality != ActorItemQuality::Common)
			{
				auto wQuality = cast<RectWidget>(wNewItem.GetWidgetById("quality"));
				if (wQuality !is null)
				{
					wQuality.m_parent.m_visible = true;
					wQuality.m_color = GetItemQualityColor(drink.quality);
				}
			}

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
			{
				wIcon.SetSprite(drink.icon);
				if (!canAfford && !hasConsumed)
					wIcon.m_colorize = true;
			}

			auto wCount = cast<TextWidget>(wNewItem.GetWidgetById("count"));
			if (wCount !is null)
			{
%if HARDCORE
				wCount.m_visible = false;
%else
				wCount.SetText("" + drink.localCount);
%endif
			}

			if (wNewItem !is null)
			{
				wNewItem.SetID("");
				wNewItem.m_visible = true;

				wNewItem.m_tooltipTitle = "\\c" + GetItemQualityColorString(drink.quality) + utf8string(Resources::GetString(drink.name)).toUpper().plain();
				wNewItem.m_tooltipText = Resources::GetString(drink.desc);

%if HARDCORE
				if (titleIndex < int(drink.quality) - 1)
				{
					auto titleRequired = titleList.GetTitle(int(drink.quality) - 1);
					wNewItem.m_tooltipText += "\n\\cff0000" + Resources::GetString(".shop.menu.restriction.player-title", {
						{ "title", Resources::GetString(titleRequired.m_name) }
					});
				}
%endif

%if !HARDCORE
				if (drink.localCount == 0)
%endif
					wNewItem.AddTooltipSub(m_def.GetSprite("icon-gold"), formatThousands(drink.cost));

				m_wList.AddChild(wNewItem);
			}
		}

		m_wList.ResumeScrolling();

		m_shopMenu.DoLayout();
	}

	void OnFunc(Widget@ sender, string name) override
	{

		auto parse = name.split(" ");
		if (parse[0] == "buy-drink")
		{
			uint id = parseUInt(parse[1]);

			auto drink = GetTavernDrink(id);
			if (drink is null)
			{
				PrintError("Couldn't find drink for ID " + id + "!");
				return;
			}

			auto player = GetLocalPlayer();

%if !HARDCORE
			if (drink.localCount <= 0)
			{
%endif
				if (!Currency::CanAfford(player.m_record, drink.cost))
				{
					PrintError("Not enough gold for that drink. How did you even trigger this error");
					return;
				}

				Currency::Spend(player.m_record, drink.cost);
%if !HARDCORE
				drink.localCount = 0;
			}
			else
				drink.localCount--;
%endif

			player.AddDrink(drink);
			player.m_record.tavernDrinksBought.insertLast(drink.id);
			player.RefreshModifiers();

			PlaySound2D(Resources::GetSoundEvent("event:/ui/swallow_drink"));

			ReloadList();
			ReloadPresets();
		}
		else if (parse[0] == "save-preset")
		{
			uint saveSlot = parseUInt(parse[1]);
			print("Saved in slot " + saveSlot);

			auto drinkPreset = DrinkPreset();

			SValueBuilder builder;

			for(uint i = 0; i < GetLocalPlayerRecord().tavernDrinksBought.length(); i++){
				drinkPreset.drinks.insertLast(GetLocalPlayerRecord().tavernDrinksBought[i]);
			}

			Drinkspresets::m_drinkPresets[saveSlot] = drinkPreset;
			ReloadPresets();
		}
		else if(parse[0] == "load-preset")
		{
			auto gm = cast<Campaign>(g_gameMode);
			auto town = gm.m_townLocal;

			auto player = GetLocalPlayer();
			uint loadSlot = parseUInt(parse[1]);

			for(uint i = 0; i < Drinkspresets::m_drinkPresets[loadSlot].drinks.length(); i++){
				OnFunc(sender, "buy-drink " + HashString(Drinkspresets::m_drinkPresets[loadSlot].drinks[i]));

				// Debugging which drink is actually added to the player
				//print("Added " + drink.name + " to player.");
			}

			player.RefreshModifiers();
			ReloadList();
			ReloadPresets();
		}
		else
			ShopMenuContent::OnFunc(sender, name);
	}

	string GetTitle() override
	{
		return Resources::GetString(".shop.drinks");
	}

	string GetGuiFilename() override
	{
		return "gui/shop/drinks.gui";
	}
}
