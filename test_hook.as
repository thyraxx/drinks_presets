namespace drinkspresets 
{
	
	[Hook]
	void WidgetHosterResourceAdded(Widget@ parent, Widget@ w, GUIBuilder@ b, GUIDef@ def){
		// This is just an experiment to modify the gui without actually overwriting the gui file
		print("Parent: " + parent.m_id + " w: " + w.m_id + " GUIDef: " + def.GetPath());
		
		if(def.GetPath() == "gui/shop/drinks.gui"){
			print("----------");
			//parent.AddResource(b, "gui/town/ledger/info.gui");
		}
	}

	[Hook]
	void TownRecordSave(TownRecord@ record, SValueBuilder &builder)
	{
		// Save all available drink presets in town
		//auto customDrinksShopMenu = CustomDrinksMenuContent();
		//auto effects = customDrinksShopMenu.drinks;

		//builder.PushDictionary("drinkspresets");
		//builder.PushArray("drinks");
		//for (uint i = 0; i < effects.length(); i++)
		//	builder.PushString(effects[i]);
		//builder.PopArray();
		//builder.PopDictionary();
				
	}


	[Hook]
	void TownRecordLoad(TownRecord@ record, SValue@ sval)
	{
		// Load all available drink presets in town
		//auto customDrinksShopMenu = CustomDrinksMenuContent();
		//auto effects = customDrinksShopMenu.drinks;
		//print("Town Record Load");


		//effects.removeRange(0, effects.length());
		//auto arrEffects = GetParamArray(UnitPtr(), sval, "drinks", false);
		//if (arrEffects !is null)
		//{
		//	for (uint i = 0; i < arrEffects.length(); i++){
		//		effects.insertLast(arrEffects[i].GetString());
		//		print("drinks: " + arrEffects[i].GetString());
		//	}

		//}
		CustomDrinksMenuContent test;
		auto arrFountainPresets = GetParamArray(UnitPtr(), sval, "drinks", false);
		if (arrFountainPresets !is null)
		{
			uint num = min(arrFountainPresets.length(), test.m_drinkPresets.length());
			for (uint i = 0; i < num; i++)
			{
				auto newPreset = DrinkPreset();
				newPreset.Load(arrFountainPresets[i]);
				test.m_drinkPresets[i] = newPreset;
			}
		}
	}

}
