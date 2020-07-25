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
		auto customDrinksShopMenu = CustomDrinksMenuContent();
		auto effects = customDrinksShopMenu.drinks;

		builder.PushDictionary();
		builder.PushArray("drinks");
		for (uint i = 0; i < effects.length(); i++)
			builder.PushString(effects[i]);
		builder.PopArray();
		builder.PopDictionary();
				
	}


	[Hook]
	void TownRecordLoad(TownRecord@ record, SValue@ sval)
	{
		// Load all available drink presets in town
		auto customDrinksShopMenu = CustomDrinksMenuContent();
		auto effects = customDrinksShopMenu.drinks;

		effects.removeRange(0, effects.length());
		auto arrEffects = GetParamArray(UnitPtr(), sval, "drinks", false);
		if (arrEffects !is null)
		{
			for (uint i = 0; i < arrEffects.length(); i++)
				effects.insertLast(arrEffects[i].GetInteger());
		}
	}

}
