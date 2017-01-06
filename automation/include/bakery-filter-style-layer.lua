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

bakery_filter_style_layer_version="1.01"

function bakery_filter_style_layer(subtitle,result_table)
	if subtitle.class ~= "dialogue" 
	then
		return false
	end
	if result_table.restrict_style
	then
		if result_table.filter_style ~= subtitle.style
		then
			return false
		end
	end
	if result_table.restrict_layer
	then
		if result_table.filter_layer ~= subtitle.layer
		then
			return false
		end
	end
	return true
end

function bakery_get_filter_style_layer_ui_vertical(style_names,offset_x,offset_y)
	dialog_style_layer_vertical = {
		{class="checkbox",label="限定风格",name="restrict_style",x=offset_x,y=offset_y,width=5,height=1},
		{class="dropdown",name="filter_style",hint="style name",items=style_names,value=style_names[0],x=offset_x+6,y=offset_y,width=8,height=1},
		{class="checkbox",label="限定图层",name="restrict_layer",x=offset_x,y=offset_y + 1,width=5,height=1},
		{class="intedit",name="filter_layer",hint="layer id",x=offset_x + 6,y=offset_y + 1,width=2,height=1,min=0}
	}
	return dialog_style_layer_vertical
end

function bakery_get_filter_style_layer_ui_horizontal(style_names,offset_x,offset_y)
	dialog_style_layer_horizontal = {
		{class="checkbox",label="限定风格",name="restrict_style",x=offset_x,y=offset_y,width=5,height=1},
		{class="dropdown",name="filter_style",hint="style name",items=style_names,value=style_names[0],x=offset_x+5,y=offset_y,width=8,height=1},
		{class="checkbox",label="限定图层",name="restrict_layer",x=offset_x+13,y=offset_y,width=5,height=1},
		{class="intedit",name="filter_layer",hint="layer id",x=offset_x+18,y=offset_y,width=2,height=1}
	}
	return dialog_style_layer_horizontal
end

function bakery_filter_style_layer_macro(subtitles, selected_lines, active_line)
	available_styles=get_available_style_names(subtitles)
	
	clicked,result = aegisub.dialog.display(get_filter_style_layer_vertical(available_styles,0,0),
										{"Apply","Cancel"},
										{["ok"]="Apply", ["cancel"]="Cancel"})
	if clicked
	then
		
	end
end
