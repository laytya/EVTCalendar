----------------------------------------------------------------
-- EVTCalendar
-- Author: Reed
-- 
--
----------------------------------------------------------------

---Initialize tables
local table_Days = {};
local table_DayStr = {};
local table_DayVal = {};
local table_DayPos = {};
local table_EventDis = {}

---Initialize variables
local displayMonth;
local displayYear;
local displayDay;
local displayPos;
local initialized = false;
local allowEdit = true;

-- Asset Location
local ImgDayActive = "Interface\\AddOns\\EVTCalendar\\Images\\EVTDayFrameActive";
local ImgDayInactive = "Interface\\AddOns\\EVTCalendar\\Images\\EVTDayFrameInactive";
local ImgDayToday = "Interface\\AddOns\\EVTCalendar\\Images\\EVTDayFrameToday";
local ImgDaySelected = "Interface\\AddOns\\EVTCalendar\\Images\\EVTDayFrameSelected";
local ImgDayHightlight = "Interface\\AddOns\\EVTCalendar\\Images\\EVTDayFrameHighlight";

function EVT_OnLoad()
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("VARIABLES_LOADED");
	
	tinsert(UISpecialFrames, "EVTFrame");

	month = date("%m") + 0;
	day = date("%d") + 0;
	year = date("%Y") + 0;
	displayDay = day;
	displayMonth = month;
	displayYear = year;
	EVT_BuildCalendar();

	SLASH_EVT1 = EVT_SLASH;
	SlashCmdList["EVT"] = function(msg)
		if msg == "test" then
			displayYear = 2444;
			EVT_UpdateCalendar(displayMonth, displayYear)
		elseif msg == "leap" then
			isLeapYear(displayYear)
		else
			EVT_SlashCommand(msg);
		end
	end
	
	initialized = true;

end

function EVT_SlashCommand(msg)

--	if(msg ~= "") then
--		DEFAULT_CHAT_FRAME:AddMessage("No such command.", 0.1, 0.1, 1);
--	else
--		EVT_Toggle();
--	end
end

function EVT_Toggle()
	EVTButtonDay:SetText(day)
	if(EVTFrame:IsVisible()) then
		HideUIPanel(EVTFrame);
		PlaySoundFile("Sound\\interface\\uCharacterSheetClose.wav");
	else
		month = date("%m") + 0;
		day = date("%d") + 0;
		year = date("%Y") + 0;
		displayDay = day;
		displayMonth = month;
		displayYear = year;
		EVT_UpdateCalendar(month, year);
		EVT_DayClick(table_Days[table_DayPos[day]]:GetName(), false);
		ShowUIPanel(EVTFrame);
		PlaySoundFile("Sound\\interface\\uCharacterSheetOpen.wav");
	end
end

function EVT_GetCurrentTime()
	ampm = "AM";
	hour, minute = GetGameTime();
	
	if(hour > 12) then
		hour = hour - 12;
		ampm = "PM";
	end
		if(minute < 10) then
		minute = string.format("%02s", minute);
	end
	
	curtime = string.format("%s:%s%s", hour, minute, ampm);
	return curtime;
end

function EVT_IncMonth()
	displayMonth = displayMonth - 1;
	if (displayMonth < 1) then
		displayMonth = 12
		displayYear = displayYear - 1;
	end
	EVTMonthDisplay:SetText(table_Months[tostring(displayMonth)]);
	EVT_UpdateCalendar(displayMonth, displayYear);
end

function EVT_DecMonth()
	displayMonth = displayMonth + 1;
	if (displayMonth > 12) then
		displayMonth = 1
		displayYear = displayYear + 1;
	end
	EVTMonthDisplay:SetText(table_Months[tostring(displayMonth)]);
	EVT_UpdateCalendar(displayMonth, displayYear);
end

function EVT_UpdateCalendar(disMonth, disYear)
	local startDay = GetDayofWeek(disYear, disMonth, 1);
	local z = 1;
	
	for step = 1, 42, 1 do
		local s = table_DayStr[step];
		local b = table_Days[step];
		local preMonth = disMonth - 1;
		local dispMonth = disMonth;
		if (preMonth < 1) then
			preMonth = 12
		end
		if ((disMonth == 2) and isLeapYear(disYear)) then
			dispMonth = "Leap";
		end
		if ((preMonth == 2) and isLeapYear(disYear)) then
			preMonth = "Leap";
		end
		if (step < startDay) then
			preNum = daysPerMonth[preMonth] - startDay + (step + 1);	
			s:SetText(preNum);
			table_DayVal[step] = nil;
			DisableButton(b, step);
		elseif (step >= (daysPerMonth[dispMonth] + startDay)) then
			newDays = (step - (daysPerMonth[dispMonth] + startDay - 1));
			s:SetText(newDays);
			table_DayPos[(daysPerMonth[dispMonth] + startDay) + newDays] = nil;
			DisableButton(b, step);
		else
			s:SetText(z);
			table_DayPos[z] = step;
			table_DayVal[step] = z;
			if ((z == day) and (disMonth == month) and (disYear == year)) then
				b:SetNormalTexture(ImgDayToday);
				if (initialized == false) then
					EVT_UpdateDayPanel();
				end
			else
				b:SetNormalTexture(ImgDayActive);
			end
			if (displayPos == step) then
				name = b:GetName();
				EVT_DayClick(name, false);
			end
			b:SetPushedTexture(ImgDayInactive);
			b:SetHighlightTexture(ImgDayHightlight);
			b:SetScript("OnClick", function()
				name = this:GetName();
				EVT_DayClick(name, true);
				PlaySoundFile("Sound\\interface\\iUiInterfaceButtonA.wav");
			end);
			z = z + 1;
		end
	end
	EVTMonthDisplay:SetText(table_Months[disMonth]);
end

	function DisableButton(Button, ButtonPos)
			table_DayVal[ButtonPos] = nil;
			Button:SetNormalTexture(ImgDayInactive);
			Button:SetPushedTexture(ImgDayInactive);
			Button:SetHighlightTexture("");
			Button:SetScript("Onclick", function()
			end);
			if (displayPos == ButtonPos) then
				name = Button:GetName();
				EVT_DayClick(name, false);
			end
	end

function EVT_BuildCalendar()
	local x = 1;
	local y = 1;


	for step = 1, 42, 1 do
		
		name = string.format("%s%s", "Day", step);
		namestr = string.format("%s%s%s", "Day", step, "str");
	
		if (x > 7) then
			x = 1;
			y = y + 1;
		end

		xoffset = (x * (77)) - 30;
		yoffset = (y * (-77)) + 23;
		
		x = x + 1;
		
		local b = CreateFrame("Button", name, EVTFrame, "UIPanelButtonTemplate");
		b:SetHeight(78);
		b:SetWidth(78);
		b:SetPoint("TOP", EVTFrame, "TOPLEFT", xoffset, yoffset);
		table_Days[step] = b;
		local s = b:CreateFontString(namestr, "ARTWORK", "GameFontNormal")
		s:SetHeight(20);
		s:SetWidth(20);		
		s:SetPoint("TOP", b, "TOP", -25, -5);
		s:SetText(step);
		table_DayStr[step] = s;
	end
	EVT_UpdateCalendar(month, year);
end


function EVT_DayClick(name, pressed)
	local dayNum = tonumber(strsub(name, 4));

	if (displayPos ~= nil) then
		local b2 = table_Days[tonumber(displayPos)];
		if ((displayDay == day) and (displayMonth == month) and (displayYear == year)) then
			b2:SetNormalTexture(ImgDayToday);	
		else
			if (table_DayVal[tonumber(displayPos)] ~= nil) then
				b2:SetNormalTexture(ImgDayActive);
			else
				if (displayPos >= 21) then
					for x = displayPos, 20, -1 do
						if (table_DayVal[x] ~= nil) then
							dayNum = x;
							break;
						end
					end
				else 
					for x = displayPos, 21, 1 do
						if (table_DayVal[x] ~= nil) then
							dayNum = x;
							break;
						end
					end
				end
			end
		end
	end
	local b = table_Days[dayNum];
	b:SetNormalTexture(ImgDaySelected);
	displayDay = table_DayVal[dayNum];	
	displayPos = dayNum;	
	EVT_UpdateDayPanel();
end	

function EVT_UpdateDayPanel()
	local dow = table_Dotw[GetDayofWeek(displayYear, displayMonth, displayDay)];
	dayString = string.format("%s, %s %s, %s", dow, table_Months[displayMonth], displayDay, displayYear);
	EVTDate:SetText(dayString);
	EVT_UpdateScrollBar();
end

function EVT_UpdateScrollBar()
	local y;
	local yoffset;
	local tableSize = table.getn(table_EventDis);

	FauxScrollFrame_Update(EventListScrollFrame, tableSize, 5, 20);

	for y = 1, 5, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(EventListScrollFrame);
		if (yoffset <= tableSize) then
			if (table_EventDis[yoffset] == nil) then
				getglobal("EventButton"..y):Hide();	
			else
				getglobal("EventButton"..y.."Info"):SetText(tostring(table_EventDis[yoffset]));
				getglobal("EventButton"..y):Show();
			end
		else
			getglobal("EventButton"..y):Hide();	
		end
	end		
end