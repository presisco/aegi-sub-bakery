--[[
Copyright (c) 2017 Presisco

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial 
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES 
OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

include("utils.lua")
include("unicode.lua")
include("bakery-utils.lua")
bakery_locale_version="1.00"

function bakery_is_chinese(char)
	return bakery_number_in_close_intervals(
		bakery_convert_3byte_utf8(char)
		,{tonumber("0x4E00"),tonumber("0x9FBF")})
end

function bakery_is_japanese(char)
	return bakery_number_in_close_intervals(
		bakery_convert_3byte_utf8(char)
		,{tonumber("0x3040"),tonumber("0x30FF")
			,tonumber("0x31F0"),tonumber("0x31FF")})
end

function bakery_is_korean(char)
	return bakery_number_in_close_intervals(
		bakery_convert_3byte_utf8(char)
		,{tonumber("0x1100"),tonumber("0x11FF")
			,tonumber("0x3130"),tonumber("0x318F")
			,tonumber("0xAC00"),tonumber("0xD7AF")})
end

function bakery_is_english(char)
	if char:len() == 1
	then
		return true
	else
		return false
	end
end

bakery_available_languages={
	-- english is 1 byte width
	{name="english",judger=bakery_is_english},
	-- below are 3 bytes width
	{name="chinese",judger=bakery_is_chinese},
	{name="japanese",judger=bakery_is_japanese},
	{name="korean",judger=bakery_is_korean}
}

function bakery_get_language_judger_by_name(name)
	for i=1,#bakery_available_languages
	do
		if bakery_available_languages[i].name == name
		then
			return bakery_available_languages[i].judger
		end
	end
	aegisub.log("can't find judger for "..name.."\n")
	return nil
end

function bakery_get_language_names()
	local languages_names={}
	for i=1,#bakery_available_languages
	do
		table.insert(languages_names
			,bakery_available_languages[i].name)
	end
	return languages_names
end

function bakery_utf_tail_to_bin(char,index)
	local length = char:len()
	local result=0
	
	for i=index,length
	do
		--shift left for 6 bits
		result=result*64
		--add new bits
		result=result+char:byte(i)%128
	end
	
	return result
end

function bakery_convert_3byte_utf8(char)
	if char:len() ~= 3
	then
		return -1
	end
	return ((char:byte(1)%224)*64*64+bakery_utf_tail_to_bin(char,2))
end

function bakery_is_3byte_symbols(char)
	return bakery_number_in_close_intervals(
		bakery_convert_3byte_utf8(char)
		,{tonumber("0x2000"),tonumber("0x2BFF")})
end

function bakery_detect_unicode_type_3char(char)
	-- short_value for 2 bytes value mode
	local short_value=(char:byte(1)%224)*64*64+bakery_utf_tail_to_bin(char,2)
	
	if short_value < tonumber("0x1100")
	then
		return "unknown"
	elseif short_value < tonumber("0x1200")
	then
		return "korean"
	-- find symbols
	elseif short_value < tonumber("0x2000")
	then
		return "unknown"
	elseif short_value < tonumber("0x2C00")
	then
		return "symbols"
	-- find japanese
	elseif short_value < tonumber("0x3040")
	then
		return "unknown"
	elseif short_value < tonumber("0x3100")
	then
		return "japanese"
	elseif short_value < tonumber("0x31F0")
	then
		return "unknown"
	elseif short_value < tonumber("0x3200")
	then
		return "japanese"
	-- find chinese
	elseif short_value < tonumber("0x4E00")
	then
		return "unknown"
	elseif short_value < tonumber("0x9FC0")
	then
		return "chinese"
	-- others
	else
		return "unknown"
	end
end

function bakery_detect_unicode_type_2char()

end

function bakery_detect_unicode_type(char)
	local length = char:len()
	if length == 1
	then
		return "english"
	elseif length == 3
	then
		return bakery_detect_unicode_type_3char(char)
	else
		return "unknown"
	end
end
