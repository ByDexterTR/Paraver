#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Para Gönderme", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	RegConsoleCmd("sm_paraver", Command_GiftMoney, "");
}

public Action Command_GiftMoney(int client, int args)
{
	if (args != 2)
	{
		ReplyToCommand(client, "[SM] \x01Kullanım: sm_paraver <#userid|name> <miktar>");
		return Plugin_Handled;
	}
	
	char arg1[128];
	GetCmdArg(1, arg1, 128);
	int target = FindTarget(client, arg1, false, false);
	if (target == -1 || target == client)
	{
		return Plugin_Handled;
	}
	
	if (GetClientMoney(target) >= GetConVarInt(FindConVar("mp_maxmoney")))
	{
		ReplyToCommand(client, "[SM] \x01Bu kullanıcını zaten zengin.");
		return Plugin_Handled;
	}
	
	int amount = 0;
	char arg2[20];
	GetCmdArg(2, arg2, 20);
	if (StringToIntEx(arg2, amount) == 0)
	{
		ReplyToCommand(client, "[SM] \x01Kullanım: sm_paraver <#userid|name> <miktar>");
		return Plugin_Handled;
	}
	
	if (amount < 1)
	{
		ReplyToCommand(client, "[SM] \x10 1'den fazla \x01miktar belirtmelisin.");
		return Plugin_Handled;
	}
	
	if (amount > GetConVarInt(FindConVar("mp_maxmoney")))
	{
		amount = GetConVarInt(FindConVar("mp_maxmoney"));
	}
	
	if (GetClientMoney(client) < amount)
	{
		ReplyToCommand(client, "[SM] \x01Bu kadar paran yok, \x04Mevcut Paran: %d", GetClientMoney(client));
		return Plugin_Handled;
	}
	
	if (GetConVarInt(FindConVar("mp_maxmoney")) - GetClientMoney(target) < amount)
	{
		amount = GetConVarInt(FindConVar("mp_maxmoney")) - GetClientMoney(target);
		ReplyToCommand(client, "[SM] \x10Gönderdiğin miktar \x01kullanıcıya çok olduğu için \x04%d olarak düzeltildi", amount);
	}
	
	SetClientMoney(client, GetClientMoney(client) - amount);
	SetClientMoney(target, GetClientMoney(target) + amount);
	PrintToChat(client, "[SM] \x10%N \x01adlı kullanıcıya \x04%d para \x01yolladın.", target, amount);
	PrintToChat(target, "[SM] \x10%N \x01size \x04%d para \x01yolladı.", client, amount);
	return Plugin_Handled;
}

void SetClientMoney(int client, int val)
{
	SetEntProp(client, Prop_Send, "m_iAccount", val);
}

int GetClientMoney(int client)
{
	return GetEntProp(client, Prop_Send, "m_iAccount");
} 