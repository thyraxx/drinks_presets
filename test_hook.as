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
		CustomDrinksMenuContent test;
		
		builder.PushArray("drink-presets");
		for (uint i = 0; i < test.m_drinkPresets.length(); i++)
			test.m_drinkPresets[i].Save(builder);
		builder.PopArray();
	}


	[Hook]
	void TownRecordLoad(TownRecord@ record, SValue@ sval)
	{
		CustomDrinksMenuContent test;
		auto drinkPresets = test.m_drinkPresets;

		//for (uint i = 0; i < drinkPresets.length(); i++)
		//	@drinkPresets[i] = DrinkPreset();

		auto arrFountainPresets = GetParamArray(UnitPtr(), sval, "drink-presets", false);
		if (arrFountainPresets !is null)
		{
			uint num = min(arrFountainPresets.length(), drinkPresets.length());
			for (uint i = 0; i < num; i++)
			{
				auto newPreset = DrinkPreset();
				newPreset.Load(arrFountainPresets[i]);
				@drinkPresets[i] = newPreset;
			}
		}
	}

}
