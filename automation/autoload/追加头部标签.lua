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
require "bakery-basic-ui"
require "bakery-utils"

local tr = aegisub.gettext

script_name = tr"追加头部内容"
script_description = tr"对字幕追加头部内容"
script_author = "presisco"
script_version = "1.20"
script_modified = "6 January 2017"
line_end = "\\N"

function cook_text(sub,result)
	new_text = result.tags .. sub.text
	local new_line = sub
	new_line.text = new_text
	return new_line
end

function add_prefix_macro(subtitles, selected_lines, active_line)
	local dialog_config = {
		class="layout",
		orientation="vertical",
		items={
			{class="label",label="添加的效果",x=0,y=0,width=20,height=1},
			{class="textbox",name="prefix",hint="tags",x=0,y=1,width=20,height=3}
		}
	}
	bakery_simple_dialog_with_filter(dialog_config
		,{
			filter_style=true,
			filter_layer=true,
			filter_time=true,
			filter_selection=true,
			selection=selected_lines,
			subtitles=subtitles,
			effective_sub=cook_text,
			on_cancel=function(result)	aegisub.cancel() end
		})
	
	aegisub.set_undo_point(script_name)
end

function add_prefix_filter(subtitles, config)
	add_prefix(subtitles)
end

aegisub.register_macro(script_name, script_description, add_prefix_macro)
aegisub.register_filter(script_name, script_description, 0, add_prefix_filter)
