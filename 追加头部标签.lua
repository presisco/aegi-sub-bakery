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

script_name = tr"追加头部标签"
script_description = tr"对字幕追加头部标签"
script_author = "presisco"
script_version = "1.00"
script_modified = "1 January 2017"
line_end = "\\N"

dialog_config = {
	{class="label",label="添加的效果",x=0,y=0,width=20,height=1},
	{class="textbox",name="prefix",hint="tags",x=0,y=1,width=20,height=3},
	{class="label",label="限定处理的风格，无则为空",x=0,y=4,width=20,height=1},
	{class="textbox",name="restrict_style",hint="style name",x=0,y=5,width=20,height=1},
	{class="label",label="限定处理的图层，无则为-1",x=0,y=6,width=20,height=1},
	{class="intedit",name="restrict_layer",hint="style name",x=0,y=7,width=4,height=1}
}

function cook_text(subtitle,tags)
	ntext = tags .. subtitle.text
	local nline = subtitle
	nline.text = ntext
	return nline
end

function filter(subtitle,style,layer)
	if subtitle.class ~= "dialogue" 
		or subtitle.comment 
		or subtitle.text == "" 
	then
		return false
	end
	if(style ~= "")
	then
		if(style ~= subtitle.style)
		then
			return false
		end
	end
	if(layer ~= -1)
	then
		if(layer~=subtitle.layer)
		then
			return false
		end
	end
	return true
end

function add_prefix(subtitles,style,layer,tags)
	for i = 1, #subtitles
	do
		aegisub.progress.set(i * 100 / #subtitles)
		if filter(subtitles[i],style,layer)
		then
			subtitles[i] = cook_text(subtitles[i],tags)
		end
	end
end

function add_prefix_macro(subtitles, selected_lines, active_line)
	clicked,result = aegisub.dialog.display(dialog_config,
										{"Apply","Cancel"},
										{["ok"]="Apply", ["cancel"]="Cancel"})
	if clicked
	then
		add_prefix(subtitles,
						result.restrict_style,
						result.restrict_layer,
						result.prefix)
		aegisub.set_undo_point(script_name)
	end
end

function add_prefix_filter(subtitles, config)
	add_prefix(subtitles)
end

aegisub.register_macro(script_name, script_description, add_prefix_macro)
aegisub.register_filter(script_name, script_description, 0, add_prefix_filter)
