--[[
Author   : Shyam "Doggan" Guthikonda
Modified : 04.06.08
Desc     : WoWCalc add-on - an in-game calculator.
--]]

clearOnNextDigit = false;
readFromDisplay = true;

-- lhs op rhs -> i.e. 2 + 3
-- Results are stored in lhs. When we get an appropriate rhs, we execute the
--	tuple given the operator, and stored this in lhs. Repeat~
lhs, rhs, op = 0, 0, "+";

function WoWCalc_OnLoad()
	-- Register slashies.
    SLASH_WoWCalc1 = "/wowcalc";
    SlashCmdList["WoWCalc"] = WoWCalc_OnSlashCmd;
    
    WoWCalc_Frame_WindowTitle:SetText("WoWCalc");
    WoWCalc_Frame_Display:SetText("0");
end

function WoWCalc_OnSlashCmd(msg)
	WoWCalc_ToggleDisplay();
end

function WoWCalc_ToggleDisplay()
	if WoWCalc_Frame:IsShown() then
		WoWCalc_Frame:Hide();
	else
		WoWCalc_Frame:Show();
	end
end

function WoWCalc_SetDisplay(msg)
	WoWCalc_Frame_Display:SetText(msg);
end

function WoWCalc_GetDisplay(msg)
	return WoWCalc_Frame_Display:GetText();
end

function WoWCalc_Decimal(self)
	local displayVal = WoWCalc_GetDisplay();
	
	if clearOnNextDigit then
		WoWCalc_SetDisplay("0.");
		clearOnNextDigit = false;
	elseif not string.find(displayVal, "%.") then
		WoWCalc_SetDisplay(displayVal .. ".");
	end
end

-- Deletes a single value from the right side of the current value.
function WoWCalc_Delete(self)
	local displayVal = WoWCalc_GetDisplay();
	
	if not clearOnNextDigit then
		if #displayVal == 1 then
			WoWCalc_SetDisplay("0");
		else
			WoWCalc_SetDisplay(string.sub(displayVal, 1, -2));
			
			-- Handle some weird cases that the display might get into.
			if WoWCalc_GetDisplay() == "-0" or WoWCalc_GetDisplay() == "-" then
				WoWCalc_SetDisplay("0");
			end
		end
	end
end

-- Negate the current value in the display. Don't allow a -0 to appear.
function WoWCalc_Negate(self)
	local displayVal = WoWCalc_GetDisplay();
	
	if not clearOnNextDigit then
		if string.sub(displayVal, 1, 1) == "-" then
			WoWCalc_SetDisplay(string.sub(displayVal, 2));
		elseif #displayVal > 1 or string.sub(displayVal, 1, 1) ~= "0" then
			WoWCalc_SetDisplay("-" .. displayVal);
		end
	end
end

-- Handle inputting new numbers to the display.
function WoWCalc_Number(self, button, down)
	local displayVal = WoWCalc_GetDisplay();
	local buttonNum = string.sub(self:GetName(), -1);
	
	if clearOnNextDigit then
		WoWCalc_SetDisplay("");
		displayVal = "0";
	end
	
	clearOnNextDigit = false;
	
	local newDisplay = displayVal .. buttonNum;
	
	if #newDisplay > 1 and
			string.sub(newDisplay, 1, 1) == "0" and
			string.sub(newDisplay, 2, 2) ~= "." then
		newDisplay = string.sub(newDisplay, 2)
	end
	
	WoWCalc_SetDisplay(newDisplay);
	
	readFromDisplay = true;
end

-- Handle all operations.
function WoWCalc_Operator(self, operator)	
	if readFromDisplay then
		rhs = WoWCalc_GetDisplay();
		readFromDisplay = false;
	end
	
	local result;
		if op == "+" then
		result = lhs + tonumber(rhs);
	elseif op == "-" then
		result = lhs - tonumber(rhs);
	elseif op == "*" then
		result = lhs * tonumber(rhs);
	elseif op == "/" then
		if tonumber(rhs) == 0 then
			message("Cannot divide by 0.");
			result = lhs;
		else
			result = lhs / tonumber(rhs);
		end
	end
	
	lhs = result;
	
	WoWCalc_SetDisplay(result);
	
	if operator == "=" then
		op = "+";
		rhs = 0;
	else
		op = operator;
	end
	
	clearOnNextDigit = true;
end