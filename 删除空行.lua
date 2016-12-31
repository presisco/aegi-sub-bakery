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

script_name = tr"删除空字幕"
script_description = tr"删除空字幕"
script_author = "presisco"
script_version = "1.00"
script_modified = "1 January 2017"

function clean_empty_subs(subtitles)
	local i=1
	local total=#subtitles
	while(i <= total)
	do
		aegisub.progress.set(i * 100 / total)
		if subtitles[i].text == ""
		then
			subtitles.delete(i)
			total=total-1
		else
			i=i+1
		end
	end
end

function clean_empty_subs_macro(subtitles, selected_lines, active_line)
	clean_empty_subs(subtitles)
	aegisub.set_undo_point(script_name)
end

function clean_empty_subs_filter(subtitles, config)
	clean_empty_subs(subtitles)
end

aegisub.register_macro(script_name, script_description, clean_empty_subs_macro)
aegisub.register_filter(script_name, script_description, 0, clean_empty_subs_filter)
