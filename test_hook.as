namespace drinkspresets {
	
	[Hook]
	void WidgetHosterResourceAdded(Widget@ parent, Widget@ w, GUIBuilder@ b, GUIDef@ def){
		print("Parent: " + parent.m_id + " w: " + w.m_id + " GUIDef: " + def.GetPath());
		
		if(def.GetPath() == "gui/shop/drinks.gui"){
			//print("----------");
			//parent.AddResource(b, "gui/town/ledger/info.gui");
		}
	}
}
