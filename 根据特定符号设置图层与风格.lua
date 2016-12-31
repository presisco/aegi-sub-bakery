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

local tr = aegisub.gettext

script_name = tr"根据特定符号设置图层与风格"
script_description = tr"根据特定符号设置图层与风格（比如歌词）"
script_author = "presisco"
script_version = "1.00"
script_modified = "1 January 2017"
line_end = "\\N"

dialog_config = {
	{class="label",label="修改后的风格，不变动则为空",x=0,y=0,width=20,height=1},
	{class="textbox",name="new_style",hint="tags",x=0,y=1,width=20,height=1},
	{class="label",label="修改后的图层，不变动则为-1",x=0,y=2,width=20,height=1},
	{class="intedit",name="new_layer",hint="style name",x=0,y=3,width=4,height=1},
	{class="label",label="查找的特定符号",x=0,y=4,width=20,height=1},
	{class="textbox",name="restrict_letter",hint="style name",x=0,y=5,width=20,height=1}
}

function change_prop(subtitle,style,layer)
	local nline = subtitle
	nline.style=style
	nline.layer=layer
	return nline
end

function filter(subtitle,restrict_letter)
	if subtitle.class ~= "dialogue" 
		or subtitle.comment 
		or subtitle.text == "" 
	then
		return false
	end
	result=string.find(subtitle.text,restrict_letter)
	if result == nil
	then
		return false
	end
	return true
end

function change_style_layer(subtitles,style,layer,restrict_letter)
	for i = 1, #subtitles
	do
		aegisub.progress.set(i * 100 / #subtitles)
		if filter(subtitles[i],restrict_letter)
		then
			subtitles[i] = change_prop(subtitles[i],style,layer)
		end
	end
end

function change_style_layer_macro(subtitles, selected_lines, active_line)
	clicked,result = aegisub.dialog.display(dialog_config,
										{"Apply","Cancel"},
										{["ok"]="Apply", ["cancel"]="Cancel"})
	if clicked
	then
		change_style_layer(subtitles,
						result.new_style,
						result.new_layer,
						result.restrict_letter)
		aegisub.set_undo_point(script_name)
	end
end

function change_style_layer_filter(subtitles, config)
	change_style_layer(subtitles)
end

aegisub.register_macro(script_name, script_description, change_style_layer_macro)
aegisub.register_filter(script_name, script_description, 0, change_style_layer_filter)
