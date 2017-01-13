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
bakery=require "bakery"
unicode = require 'aegisub.unicode'

local tr = aegisub.gettext

script_name = tr"双语处理"
script_description = tr"对字母进行双语处理（两行形式），目前只支持英语和非英语"
script_author = "presisco"
script_version = "2.20"
script_modified = "12 January 2017"
line_end = "\\N"
left_brace = 123
right_brace = 125
ignored_symbols_seperator = ","

subs={}
selections={}
active={}
available_styles={}
export_config={}

function find_last_pos(line,judger)
	local reading_tags=false
	local last_pos=0
	local i=0
	
	for char in unicode.chars(line)
	do
		local char_length=char:len()
		i=i+char_length
		if char == left_brace
		then
			reading_tags=true
		elseif char == right_brace
		then
			reading_tags=false
		elseif not reading_tags
		then
			if judger(char)
			then
				last_pos=i
			end
		end
	end
	
	return last_pos
end

function reassgin_line(line,last_pos,linebreaker)
	local top_text=""
	local bottom_text=""
	
	divide_start,divide_end=line:find(linebreaker,last_pos,true)
	
	if last_pos == 0
	then
		bottom_text=line:gsub(linebreaker,"")
	elseif divide_start ~= nil
	then
		top_text=line:sub(1,divide_start-1)
		top_text=top_text:gsub(linebreaker,"")
		if divide_end < line:len()
		then
			bottom_text=line:sub(divide_end+1,line:len())
			bottom_text=bottom_text:gsub(linebreaker," ")
		end
	else
		top_text=line:gsub(linebreaker,"")
	end
	
	return top_text,bottom_text
end

function left_overs(subtitle,top_text,bottom_text,result)
	
	if result.drop_top_tags 
	then
		top_text=top_text:gsub("{[^}]+}", "")
	end
	
	if result.drop_bottom_tags 
	then
		bottom_text=bottom_text:gsub("{[^}]+}", "")
	end
	
	local top_complete=""
	local bottom_complete=""
	local divider=""
	local new_text=""
	
	if result.cook_empty 
	then
		top_complete=result.top_tags..top_text
		bottom_complete=result.bottom_tags..bottom_text
		divider=result.linebreaker
	else
		if top_text ~= ""
		then
			top_complete=result.top_tags..top_text
		end
		if bottom_text ~= ""
		then
			bottom_complete=result.bottom_tags..bottom_text
		end
		if bottom_text ~= "" and top_text ~= ""
		then
			divider=result.linebreaker
		end
	end	
	
	if result.switch_lines
	then
		new_text=bottom_complete..divider..top_complete
	else
		new_text=top_complete..divider..bottom_complete
	end
	
	local new_line = subtitle
	
	if result.alter_style
	then
		new_line.style = result.new_style
	end
	
	if result.alter_layer
	then
		new_line.layer = result.new_layer
	end
	
	new_line.text = new_text
	return new_line
end

function scan_subs(sub,result)
  last_pos=1
  if not result.cut_by_first_seperator
  then
    last_pos=find_last_pos(sub.text,bakery.locale.get_language_judger_by_name(result.top_language))
	end
	top_text,bottom_text=reassgin_line(sub.text,last_pos,result.linebreaker)
	return left_overs(sub,top_text,bottom_text,result)
end

function entry()
	available_styles=bakery.utils.get_style_names(subs)
	available_languages=bakery.locale.get_language_names()
	
	local final_config={}
	
	local config_1 = {
		class="layout",
		orientation="vertical",
		items={
			{class="label",label="上层要添加的标签",width=6,height=1},
			{class="textbox",name="top_tags",hint="tags",width=6,height=3},
			{class="label",label="下层要添加的标签",width=6,height=1},
			{class="textbox",name="bottom_tags",hint="tags",width=6,height=3},
			{class="label",label="上层原先的主要语言",width=6,height=1},
			{class="dropdown",name="top_language",hint="language",items=available_languages,value=available_languages[1],width=5,height=1},
			{class="label",label="换行符",width=6,height=1},
			{class="textbox",name="linebreaker",hint="characters",value="\\N",width=6,height=1}
		}
	}
	
	local config_2 = {
		class="layout",
		orientation="vertical",
		items={
			{class="layout",
			orientation="horizontal",
			items={
				{class="checkbox",label="更改风格",name="alter_style",width=1,height=1},
				{class="dropdown",name="new_style",hint="style name",items=available_styles,value=available_styles[1],width=1,height=1}
				}
			},
			{class="layout",
			orientation="horizontal",
			items={
				{class="checkbox",label="更改图层",name="alter_layer",width=1,height=1},
				{class="intedit",name="new_layer",hint="layer id",width=1,height=1,min=0}
				}
			},
			{class="checkbox",label="第一个换行符区分翻译与原文",name="cut_by_first_seperator",width=1,height=1},
			{class="checkbox",label="丢弃翻译的标签",name="drop_top_tags",width=1,height=1},
			{class="checkbox",label="丢弃原文的标签",name="drop_bottom_tags",width=1,height=1},
			{class="checkbox",label="交换输出行",name="switch_lines",width=1,height=1},
			{class="checkbox",label="空行添加标签和换行",name="cook_empty",value=true,width=1,height=1}
		}
	}
	
	local config_3 = {
		class="layout",
		orientation="horizontal",
		items={config_1,config_2}
	}
	
--	bakery_print_preferences_to_file(bakery_env_config_root.."layout.txt",config_3)
	
	bakery.ui.dialog.with_filter(config_3
		,{
			filter_style=true,
			filter_layer=true,
			filter_time=true,
			filter_selection=true,
			selection=selections,
			subtitles=subs,
			effective_sub=scan_subs,
			on_cancel=function(result)	aegisub.cancel() end
		})
end

function bilingual_cook_macro(subtitles, selected_lines, active_line)
	subs=subtitles
	selections=selected_lines
	active=active_line
	entry()
	aegisub.set_undo_point(script_name)
end

function bilingual_cook_filter(subtitles, config)
	subs=subtitles
	export_config=config
	entry()
end

aegisub.register_macro(script_name, script_description, bilingual_cook_macro)
aegisub.register_filter(script_name, script_description, 0, bilingual_cook_filter)
