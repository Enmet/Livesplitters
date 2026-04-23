//Original script by Pixelquick. Updated version by Enmet.
//This script is only compatible with US SNES version of Toy Story.
//For questions and feedback, go to the Toy Story Speedrun Community Discord Server.

state("higan"){}
state("snes9x"){}
state("snes9x-x64"){}
state("bsnes") {}
state("emuhawk") {}

startup
{

}

//init and emulator memory offsets found in https://raw.githubusercontent.com/Spiraster/ASLScripts/master/LiveSplit.SMW/LiveSplit.SMW.asl

init
{
	refreshRate = 30;	//Risk of double splitting at higher refresh rates
	int memoryOffset = 0;
	while (memoryOffset == 0)
	{
		switch (modules.First().ModuleMemorySize)
		{
			case 5914624: //snes9x (1.53)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x6EFBA4);
				break;
			case 6909952: //snes9x (1.53-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x140405EC8);
				break;
			case 6447104: //snes9x (1.54.1)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x7410D4);
				break;
			case 7946240: //snes9x (1.54.1-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1404DAF18);
				break;
			case 6602752: //snes9x (1.55)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x762874);
				break;
			case 8355840: //snes9x (1.55-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1405BFDB8);
				break;
			case 9646080: //snes9x-rr (1.60)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x97EE04);
				break;
			case 13565952: //snes9x-rr (1.60-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x140925118);
				break;
			case 9027584: //snes9x (1.60)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x94DB54);
				break;
			case 12836864: //snes9x (1.60-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1408D8BE8);
				break;
			case 10399744: //snes9x (1.62.3)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x9B74D0);
				break;
			case 15474688: //snes9x (1.62.3-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x140A62390);
				break;
			case 11124736: //snes9x (1.63)
				memoryOffset = memory.ReadValue<int>((IntPtr)0xA63DF0);
				break;
			case 16994304: //snes9x (1.63-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x140BC1CA0);
				break;
			case 12509184: //higan (v102)
				memoryOffset = 0x915304;
				break;
			case 13062144: //higan (v103)
				memoryOffset = 0x937324;
				break;
			case 15859712: //higan (v104)
				memoryOffset = 0x952144;
				break;
			case 16756736: //higan (v105tr1)
				memoryOffset = 0x94F144;
				break;
			case 16019456: //higan (v106)
				memoryOffset = 0x94D144;
				break;
			default:
				memoryOffset = 1;
				break;
		}
	}

	vars.watchers = new MemoryWatcherList
	{
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x000E) { Name = "screenID" },							//Used for dev logos and which menu the game is currently in
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x000F) { Name = "screenID2" },							//Similar to above, but only ever changes for the TT and Psyg logos
    new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x0A14) { Name = "menuArrowX" },							//X-position of the main menu arrow
	new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x001A) { Name = "levelID" }, 							//Level index, changes after "Level Complete" fades out.
	new MemoryWatcher<ushort>((IntPtr)memoryOffset + 0x004A) { Name = "CamX" },								//Camera X-position, used as a condition for the final level.
	};
}

update
{
	vars.watchers.UpdateAll(game);
}

start
{
	if (vars.watchers["screenID"].Current == 0x02) {
		return ((vars.watchers["menuArrowX"].Current > 0x83) && (vars.watchers["menuArrowX"].Old < 0x84)); 	//Main menu arrow exceeds 0x83 when start game is triggered
	}
}

reset
{
	if (vars.watchers["screenID"].Current == 0x02){															//Main menu and many loading screens uses this index
		if (vars.watchers["screenID2"].Current == 0x01){													//Is always zero except for dev logos, indicating a soft or hard reset
			return true;
		} else {
			return (vars.watchers["menuArrowX"].Current == 0x83);											//Main menu arrow can be detected from its x-pos for a reset
		}
	}
}

split
{
	if (vars.watchers["levelID"].Old > 0x0F){    															//Check for final level as it uses a special split condition
		if (vars.watchers["screenID"].Current == 0x0F){														//Make sure game is still in the level and not in a loading screen
			if ((vars.watchers["CamX"].Current == 0x3C53) && (vars.watchers["CamX"].Old < 0x3C53)){			//Check pos and against old so script is compatible with multi game setups
				return true;
			}
		}
	} else { 																								//Splits as soon as "Level Complete" fades out
		if (vars.watchers["levelID"].Old == (vars.watchers["levelID"].Current - 1)){						//Only if increased by 1, some emus can randomly give the ID large numbers
			return true;
		}
	}
}
