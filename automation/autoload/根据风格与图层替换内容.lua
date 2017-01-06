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
require "bakery"

local tr = aegisub.gettext

script_name = tr"替换内容"
script_description = tr"根据图层，风格，时间或所选字幕替换特定内容"
script_author = "presisco"
script_version = "1.20"
script_modified = "6 January 2017"
line_end = "\\N"

function replace_text(sub,result)
	newtext = string.gsub(subtitle.text,result.original,result.replacement)
	local newline = sub
	newline.text = newtext
	return newline
end

function replace_by_style_layer_macro(subtitles, selected_lines, active_line)
	local dialog_config = {
		class="layout",
		orientation="vertical",
		items={
			{class="label",label="原内容",width=5,height=1},
			{class="textbox",name="original",hint="tags/text",width=5,height=3},
			{class="label",label="替换为",width=5,height=1},
			{class="textbox",name="replacement",hint="tags/text",width=5,height=3}
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
			effective_sub=replace_text,
			on_cancel=function(result)	aegisub.cancel() end
		})
	aegisub.set_undo_point(script_name)
end

function replace_by_style_layer_filter(subtitles, config)
	replace_by_style_layer(subtitles)
end

aegisub.register_macro(script_name, script_description, replace_by_style_layer_macro)
aegisub.register_filter(script_name, script_description, 0, replace_by_style_layer_filter)
