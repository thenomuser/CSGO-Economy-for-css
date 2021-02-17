
#include <sourcemod>
#include <sdktools>
#include <cstrike>

new Handle:Enabled
//new normalKill = 0; //rifle grenade pistol p90
new knifeKill = 1200; //knife
new awp = -200; //awp
new shotgun = 600; //shotgun
new smgs = 300; //submachines
new bool:g_isHooked

new g_iAccount
new hasplant
new hasdefuse
new ctpoint = 0;
new tpoint = 0;

new String:weapon_list[][] = {"ak47","m4a1","awp","deagle","mp5navy","aug","p90","famas","galil","scout","g3sg1","hegrenade","usp", "glock","m249","m3","elite","fiveseven","mac10","p228","sg550","sg552","tmp","ump45","xm1014","knife","smokegrenade","flashbang"};

public Plugin:myinfo = 
{
	name = "CSGO Economy",
	author = "TheNomUser",
	description = "Gives a CSGO Economy for css",
	version = "1.2",
	url = "https://twitter.com/TheNomUser"
	//credits: 
	//GameTech WarMod
	//Fredd plant bomb & defuse script
}

public OnPluginStart()
{
	CreateConVar("csgo_economy", "1.2")
	
	Enabled	= CreateConVar("mp_economy", "1", "Enable/Disable the economy");
	
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount")
	
	HookEvent("bomb_planted", BombPlanted)
	HookEvent("bomb_defused", BombDefused)
	HookEvent("bomb_beginplant", BombBPlanted)
	HookEvent("bomb_begindefuse", BombBDefused)
	HookEvent("player_death", PlayerDeath)
	//HookEvent("bomb_exploded", BombExploded)
	HookEvent("round_end", RoundEnd)

	
	HookConVarChange(Enabled, ConvarChanged)	
}
public OnPluginEnd()
{
	if (g_isHooked == true)
	{
		UnhookEvent("bomb_planted", BombPlanted)
		UnhookEvent("bomb_defused", BombDefused)
		UnhookEvent("bomb_beginplant", BombBPlanted)
		UnhookEvent("bomb_begindefuse", BombBDefused)
		UnhookEvent("player_death", PlayerDeath)
		//UnhookEvent("bomb_exploded", BombExploded)
		UnhookEvent("round_end", RoundEnd)
	}
	
	UnhookConVarChange(Enabled, ConvarChanged);
}
public ConvarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	new value = !!StringToInt(newValue);
	if (value == 0)
	{
		if (g_isHooked == true)
		{
			g_isHooked = false;
            
			UnhookEvent("bomb_planted", BombPlanted)
			UnhookEvent("bomb_defused", BombDefused)
			UnhookEvent("bomb_beginplant", BombBPlanted)
			UnhookEvent("bomb_begindefuse", BombBDefused)
			UnhookEvent("player_death", PlayerDeath)
			//UnhookEvent("bomb_exploded", BombExploded)
			UnhookEvent("round_end", RoundEnd)
		}
	}
	else
	{
		g_isHooked = true;
        
		HookEvent("bomb_planted", BombPlanted)
		HookEvent("bomb_defused", BombDefused)
		HookEvent("bomb_beginplant", BombBPlanted)
		HookEvent("bomb_begindefuse", BombBDefused)
		HookEvent("player_death", PlayerDeath)
		//HookEvent("bomb_exploded", BombExploded)
		HookEvent("round_end", RoundEnd)

	}
}

public Action:BombPlanted(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"))
	PrintToChat(client, "\x04$300\x01: Por plantar la bomba");
	SetMoney(client, (GetMoney(client) + 300))
	if (GetMoney(client) >= 16000)
	{
		SetMoney(client, 16000)
	}
	hasplant = 1;
	return Plugin_Continue;
}

public Action:BombDefused(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	PrintToChat(client, "\x04$300\x01: Por Desactivar la bomba");
	SetMoney(client, (GetMoney(client) + 300));
	if (GetMoney(client) >= 16000)
	{
		SetMoney(client, 16000)
	}
	hasdefuse = 1;
	return Plugin_Continue;
}

public Action:BombBDefused(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	ClientCommand(client, "say_team Desactivando la Bomba");
	return Plugin_Continue;
}

public Action:BombBPlanted(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	ClientCommand(client, "say_team Plantando la bomba");
	return Plugin_Continue;
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));

	new String:weapon[64];

	GetEventString(event, "weapon", weapon, 64);
	new weapon_index = GetWeaponIndex(weapon);

	if (GetClientTeam(attacker) == GetClientTeam(victim))
	{
		PrintToChat(attacker, "\x03-$300\x01: Por matar un Amigo");
		SetMoney(attacker, (GetMoney(attacker) + 3000));
		if (GetMoney(attacker) <= 0)
		{
			SetMoney(attacker, 0)
		}
	}
	else if (weapon_index == 25)
	{
		PrintToChat(attacker, "\x04$1500\x01: Por matar un enemigo con cuchillo");
		SetMoney(attacker, (GetMoney(attacker) + knifeKill));
		if (GetMoney(attacker) >= 16000)
		{
			SetMoney(attacker, 16000)
		}
	}
	else if (weapon_index == 2)
	{
		PrintToChat(attacker, "\x04$100\x01: Por matar un enemigo con awp");
		SetMoney(attacker, (GetMoney(attacker) + awp));
		if (GetMoney(attacker) >= 16000)
		{
			SetMoney(attacker, 16000)
		}
	}
	else if (weapon_index <= 1 || weapon_index == 3 || (weapon_index >= 5 && weapon_index <= 14) || weapon_index == 16 || weapon_index == 17 || (weapon_index >= 19 && weapon_index <= 21))
	{	
		PrintToChat(attacker, "\x04$300\x01: Por matar un enemigo");
	}
	else if (weapon_index == 4 || weapon_index == 18 || (weapon_index >= 22 && weapon_index <= 23))
	{
		PrintToChat(attacker, "\x04$600\x01: Por matar un enemigo con subfusil");
		SetMoney(attacker, (GetMoney(attacker) + smgs));
		if (GetMoney(attacker) >= 16000)
		{
			SetMoney(attacker, 16000)
		}
	}
	else if (weapon_index == 24 || weapon_index == 15)
	{
		PrintToChat(attacker, "\x04$900\x01: Por matar un enemigo con escopeta");
		SetMoney(attacker, (GetMoney(attacker) + shotgun));
		if (GetMoney(attacker) >= 16000)
		{
			SetMoney(attacker, 16000)
		}
	}

	return Plugin_Continue;
}

//public Action:BombExploded(Handle:event, const String:name[], bool:dontBroadcast)
//{
//	return Plugin_Continue;
//}

public Action:RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	EconomyManager(event);
	return Plugin_Continue;
}

public Action:EconomyManager(Handle:event)
{	
	new winner = GetEventInt(event, "winner");
	if (winner == CS_TEAM_T)
	{
		tpoint += 1;
		if (tpoint >= 5) { tpoint = 5; }
		ctpoint = 0;
	}
	else if (winner == CS_TEAM_CT)
	{
		ctpoint += 1;
		if (ctpoint >= 5) { ctpoint = 5; }
		tpoint = 0;
	}
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsPlayerAlive(i) && IsClientInGame(i) && GetClientTeam(i) == winner)
		{
			if(hasplant == 1 && hasdefuse == 0)
			{
				PrintToChat(i, "\x04$3500\x01: Por ganar Plantando la bomba");
				hasplant = 0;
			}
			else if (hasdefuse == 1)
			{	
				SetMoney(i, (GetMoney(i) + 250));
				PrintToChat(i, "\x04$3500\x01: Por ganar Desactivando la bomba");
				hasdefuse = 0;
			}
			else if (hasplant == 0)
			{
				PrintToChat(i, "\x04$3250\x01: Por ganar Eliminando al equipo enemigo");
			}
		}
		else if (IsClientInGame(i) && GetClientTeam(i) != winner)
		{
			if (hasplant == 1 && hasdefuse == 1)
			{	
				SetMoney(i, (GetMoney(i) + 700));
				PrintToChat(i, "\x04$2200\x01: Por plantar la bomba");
				hasplant = 0;
			}
			else if (tpoint == 2 || ctpoint == 2)
			{
				SetMoney(i, (GetMoney(i) + 400));
				PrintToChat(i, "\x04$1900\x01: Por perder");
			}
			else if (tpoint == 3 || ctpoint == 3)
			{
				SetMoney(i, (GetMoney(i) + 900));
				PrintToChat(i, "\x04$2400\x01: Por perder");
			}
			else if (tpoint == 4 || ctpoint == 4)
			{
				SetMoney(i, (GetMoney(i) + 1400));
				PrintToChat(i, "\x04$2900\x01: Por perder");
			}
			else if (tpoint >= 5 || ctpoint >= 5)
			{
				SetMoney(i, (GetMoney(i) + 1900));
				PrintToChat(i, "\x04$3400\x01: Por perder");
			}
			else if (hasplant == 0 && hasdefuse == 0)
			{
				PrintToChat(i, "\x04$1400\x01: Por perder");
			}

		}
		if (GetMoney(i) >= 16000)
		{
			SetMoney(i, 16000)
		}
		else if (GetMoney(i) <= 0)
		{
			SetMoney(i, 0)
		}

	}

}

GetWeaponIndex(const String:weapon[])
{
	for (new i = 0; i < 28; i++)
	{
		if (StrEqual(weapon, weapon_list[i], false))
		{
			return i;
		}
	}
	return -1;
}

public GetMoney(client)
{
	if(g_iAccount != -1)
	{
		return GetEntData(client, g_iAccount);
	}
	return 0;
}
public SetMoney(client, amount)
{
	if(g_iAccount != -1)
	{
		SetEntData(client, g_iAccount, amount);
	}
}
