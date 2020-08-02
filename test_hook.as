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
				
	}


	[Hook]
	void TownRecordLoad(TownRecord@ record, SValue@ sval)
	{

	}

}
