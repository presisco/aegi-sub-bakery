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
bakery_utils_version="1.00"
bakery_raw_line_seperator=","
bakery_raw_line_classname_tail=": "

function bakery_get_millis_from_text(text_time)
	local millis=0
	millis=tonumber(text_time:sub(1))
end

function bakery_number_in_close_intervals(number,intervals)
	local i = 1
	local in_intervals = false
	while i < #intervals
	do
		if number > intervals[i] and number < intervals[i+1]
		then
			in_intervals = true
		end
		i=i+2
	end
	return in_intervals
end

function bakery_log_table_itr(content_table,prefix)
	aegisub.log(prefix.."{\n")
	for k,v in pairs(content_table)
	do
		if type(content_table[k]) == "table"
		then
			aegisub.log(prefix.."  "..k..":\n")
			bakery_log_table_itr(content_table[k],prefix.."  ")
		elseif type(content_table[k]) == "boolean"
		then
			if content_table[k]
			then
				aegisub.log(prefix.."  "..k..":".."true".."\n")
			else
				aegisub.log(prefix.."  "..k..":".."false".."\n")
			end
		else
			aegisub.log(prefix.."  "..k..":"..v.."\n")
		end
	end
	aegisub.log(prefix.."}\n")
end

function bakery_log_table(content_table)
	bakery_log_table_itr(content_table,"")
end

function bakery_get_style_by_name(subtitles,name)
	for i=1,#subtitles
	do
		if subtitles[i].class == "style" 
			and subtitles[i].name == name
		then
			return subtitles[i]
		end
	end
	return nil
end

function bakery_get_available_style_names(subtitles)
	local style_names={}
	
	for i=1,#subtitles
	do
		if subtitles[i].class == "style"
		then
			table.insert(style_names,subtitles[i].name)
		end
	end
	
	return style_names
end

function bakery_merge_table(dst,src)
	for i=1,#src
	do
		table.insert(dst,src[i])
	end
end

function bakery_get_classname_from_raw(raw_line)
	local tail=raw_line:find(bakery_raw_line_classname_tail)
	return raw_line:sub(1,tail-1)
end

function bakery_get_values_from_raw(raw_line)
	local parsed={}
	local tmp=""
	local length=raw_line:len()
	local start_index=raw_line:find(bakery_raw_line_classname_tail)+2
	local end_index=raw_line:find(bakery_raw_line_seperator,start_index)
	while end_index ~= nil
	do
		if end_index == start_index
		then
			table.insert(parsed,"")
		else
			table.insert(parsed,raw_line:sub(start_index,end_index-1))
		end
		start_index=end_index+1
		end_index=raw_line:find(bakery_raw_line_seperator,start_index)
	end
	if start_index > length
	then
		table.insert(parsed,"")
	else
		table.insert(parsed,raw_line:sub(start_index,length))
	end
	return parsed
end

function bakery_get_dialogue_from_raw(tpl,raw_line)
	aegisub.log("parsing dialogue info from raw text\n")
--[[
	local parsed={
		class="dialogue"
		raw=raw_line
		section=
		comment=
		layer=
		start_time=
		end_time=
		style=
		actor=
		margin_l=
		margin_r=
		margin_t=
		margin_b=
		effect=
		userdata=
		text=
	}
]]
end

function bakery_get_style_from_raw(tpl,raw_line)
	aegisub.log("parsing style info from raw text\n")
	local values=bakery_get_values_from_raw(raw_line)
	local tmp=""
	
	tpl.class="style"
	tpl.raw=raw_line
	tpl.section="[V4+ Styles]"
	tpl.name=values[1]
	tpl.fontname=values[2]
	tpl.fontsize=values[3]
	tpl.color1=values[4].."&"
	tpl.color2=values[5].."&"
	tpl.color3=values[6].."&"
	tpl.color4=values[7].."&"
	if values[8] == 0
	then
		tpl.bold=false
	else
		tpl.bold=true
	end
	if values[9] == 0
	then
		tpl.italic=false
	else
		tpl.italic=true
	end
	if values[10] == 0
	then
		tpl.underline=false
	else
		tpl.underline=true
	end
	if values[11] == 0
	then
		tpl.strikeout=false
	else
		tpl.strikeout=true
	end
	tpl.scale_x=values[12]
	tpl.scale_y=values[13]
	tpl.spacing=values[14]
	tpl.angle=values[15]
	tpl.borderstyle=values[16]
	tpl.outline=values[17]
	tpl.shadow=values[18]
	tpl.align=values[19]
	tpl.margin_l=values[20]
	tpl.margin_r=values[21]
	tpl.margin_t=values[22]
	tpl.margin_b=values[22]
	tpl.encoding=values[23]
	tpl.relative_to=2
	return tpl
end

function bakery_get_subtitle_from_raw(tpl,raw_line)
	if tpl.class == "dialogue"
	then
		parsed=bakery_get_dialogue_from_raw(tpl,raw_line)
	elseif tpl.class == "style"
	then
		parsed=bakery_get_style_from_raw(tpl,raw_line)
	end
	return parsed
end