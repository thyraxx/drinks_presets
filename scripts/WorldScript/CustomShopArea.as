namespace WorldScript
{

	[WorldScript color="#B0C4DE" icon="system/icons.png;384;352;32;32"]
	class CustomShopArea : ShopArea
	{
		

		void Use(PlayerBase@ player) override
		{
			print("--------------USE_SHOP_AREA");
			if (m_used)
				return;

			auto gm = cast<Campaign>(g_gameMode);
			if (Type == ShopAreaType::UpgradeShop)
				gm.m_shopMenu.Show(this, UpgradeShopMenuContent(gm.m_shopMenu, Category), ShopLevel);
			else if (Type == ShopAreaType::Fountain)
				gm.m_shopMenu.Show(this, FountainShopMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::Statues)
				gm.m_shopMenu.Show(this, StatuesShopMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::Chapel)
				gm.m_shopMenu.Show(this, ChapelShopMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::Skills)
			{
%if HARDCORE
				gm.m_shopMenu.Show(this, HardcoreSkillsShopMenuContent(gm.m_shopMenu), ShopLevel);
%else
				gm.m_shopMenu.Show(this, SkillsShopMenuContent(gm.m_shopMenu), ShopLevel);
%endif
			}
			else if (Type == ShopAreaType::Townhall)
				gm.m_shopMenu.Show(this, TownhallMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::Drinks)
				gm.m_shopMenu.Show(this, CustomDrinksMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::GeneralStore)
				gm.m_shopMenu.Show(this, GeneralStoreMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::ItemForge)
				gm.m_shopMenu.Show(this, ItemForgeMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::DungeonStore)
				gm.m_shopMenu.Show(this, DungeonStoreMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::DesertStore)
				gm.m_shopMenu.Show(this, DesertStoreMenuContent(gm.m_shopMenu), ShopLevel);

			else if (Type == ShopAreaType::Custom)
			{
				if (Category == "")
				{
					PrintError("You forgot to set Category to a class to instantiate!");
					return;
				}

				SValueBuilder builder;
				builder.PushNull();
				auto menuContent = cast<ShopMenuContent>(InstantiateClass(Category, UnitPtr(), builder.Build()));
				if (menuContent is null)
				{
					PrintError("Couldn't instantiate class \"" + Category + "\" or is not of type ShopMenuContent!");
					return;
				}

				gm.m_shopMenu.Show(this, menuContent, ShopLevel);
			}

			User.Replace(player.m_unit);

			if (Network::IsServer())
				WorldScript::GetWorldScript(g_scene, this).Execute();
		}
	}
}
