#include <sourcemod>
#include <sdktools>
#include <clientprefs>
 
#undef REQUIRE_PLUGIN
#include <shavit>
 
#pragma newdecls required
#pragma semicolon 1

Handle gH_FJTCookie;
bool gB_FJT[MAXPLAYERS +1];

public Plugin myinfo =
{
	name = "[shavit] First Jump Tick",
	author = "Blank",
	description = "Print which tick first jump was at",
	version = "1.0",
	url = ""
}
 
chatstrings_t gS_ChatStrings;
 
public void OnAllPluginsLoaded()
{
	HookEvent("player_jump", OnPlayerJump);
}
 
public void OnPluginStart()
{
	LoadTranslations("shavit-firstjumptick.phrases");
	
	RegConsoleCmd("sm_fjt", Command_FJT, "Toggles Jump Tick Printing");
	RegConsoleCmd("sm_jumptick", Command_FJT, "Toggles Jump Tick Printing");
	
	gH_FJTCookie = RegClientCookie("FJT_enabled", "FJT_enabled", CookieAccess_Protected);
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(AreClientCookiesCached(i))
		{
			OnClientCookiesCached(i);
		}
	}
}

public void OnClientCookiesCached(int client)
{
	gB_FJT[client] = GetClientCookieBool(client, gH_FJTCookie);
}
 
public void Shavit_OnChatConfigLoaded()
{
	Shavit_GetChatStrings(sMessageText, gS_ChatStrings.sText, sizeof(chatstrings_t::sText));
	Shavit_GetChatStrings(sMessageVariable, gS_ChatStrings.sVariable, sizeof(chatstrings_t::sVariable));
}

public Action Command_FJT(int client, int args)
{
	if(!gB_FJT[client])
	{
		gB_FJT[client] = true;
		Shavit_PrintToChat(client, "%T", "FirstJumpTickEnabled", client, gS_ChatStrings.sVariable);
	}
	else
	{
		gB_FJT[client] = false;
		Shavit_PrintToChat(client, "%T", "FirstJumpTickDisabled", client, gS_ChatStrings.sVariable);
	}
}
 
public Action OnPlayerJump(Event event, char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);
   
	if(IsFakeClient(client))
	{
		return;
	}
 
 	if(gB_FJT[client] == true)
 	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && ((!IsPlayerAlive(i) && GetEntPropEnt(i, Prop_Data, "m_hObserverTarget") == client && GetEntProp(i, Prop_Data, "m_iObserverMode") != 7 || (i == client))))
			{
				PrintJumpTick(i, client);
			}
		}
	}
	else
	{
		return;
	}
}
 
void PrintJumpTick(int client, int target)
{  
	if(Shavit_GetTimerStatus(target) == Timer_Running && !Shavit_InsideZone(target, Zone_Start, -1) && Shavit_GetClientJumps(target) == 1)
		Shavit_PrintToChat(client, "%T", "PrintFirstJumpTick", client, gS_ChatStrings.sVariable, RoundToFloor(Shavit_GetClientTime(target) * 100), gS_ChatStrings.sText);
	if(Shavit_InsideZone(target, Zone_Start, -1))
		Shavit_PrintToChat(client, "%T", "ZeroTick", client, gS_ChatStrings.sVariable, gS_ChatStrings.sText);
		
}

stock bool GetClientCookieBool(int client, Handle cookie)
{
	char sValue[8];
	GetClientCookie(client, gH_FJTCookie, sValue, sizeof(sValue));
	return (sValue[0] != '\0' && StringToInt(sValue));
}

stock void SetClientCookieBool(int client, Handle cookie, bool value)
{
	char sValue[8];
	IntToString(value, sValue, sizeof(sValue));
	SetClientCookie(client, cookie, sValue);
}