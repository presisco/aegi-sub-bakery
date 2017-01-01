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
require "filter-style-layer"
re=require "aegisub.re"

local tr = aegisub.gettext

script_name = tr"根据风格与图层替换内容"
script_description = tr"根据图层与风格替换特定字幕的内容"
script_author = "presisco"
script_version = "1.00"
script_modified = "1 January 2017"
line_end = "\\N"

function replace_text(subtitle,original,replacement)
	newtext = string.gsub(subtitle.text,original,replacement)
	local newline = subtitle
	newline.text = newtext
	return newline
end

function replace_by_style_layer(subtitles,result)
	for i = 1, #subtitles
	do
		aegisub.progress.set(i * 100 / #subtitles)
		if filter_style_layer(subtitles[i],result)
		then
			subtitles[i] = replace_text(subtitles[i],result.original,result.replacement)
		end
	end
end

function replace_by_style_layer_macro(subtitles, selected_lines, active_line)
	available_styles=get_available_style_names(subtitles)
	local dialog_config = {
		{class="label",label="原内容",x=0,y=0,width=5,height=1},
		{class="textbox",name="original",hint="tags/text",x=0,y=1,width=20,height=3},
		{class="label",label="替换为",x=0,y=4,width=5,height=1},
		{class="textbox",name="replacement",hint="tags/text",x=0,y=5,width=20,height=3}
	}
	merge_dialog_config(dialog_config,get_filter_style_layer_ui_vertical(available_styles,0,8))
	clicked,result = aegisub.dialog.display(dialog_config,
										{"Apply","Cancel"},
										{["ok"]="Apply", ["cancel"]="Cancel"})
	if clicked
	then
		replace_by_style_layer(subtitles,result)
		aegisub.set_undo_point(script_name)
	end
end

function replace_by_style_layer_filter(subtitles, config)
	replace_by_style_layer(subtitles)
end

aegisub.register_macro(script_name, script_description, replace_by_style_layer_macro)
aegisub.register_filter(script_name, script_description, 0, replace_by_style_layer_filter)
