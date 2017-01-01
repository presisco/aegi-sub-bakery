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

script_name = tr"删除语气提示"
script_description = tr"删除字幕中的语气提示词[*]"
script_author = "presisco"
script_version = "1.00"
script_modified = "1 January 2017"

function remove_tone_tags_text(text)
	baked=string.gsub(text,"%[(.*)%]","")
	return baked
end

function clean_tone_tags_subs(subtitles)
	local lines_baked = 0
	for i = 1, #subtitles do
		aegisub.progress.set(i * 100 / #subtitles)
		if subtitles[i].class == "dialogue" and not subtitles[i].comment and subtitles[i].text ~= "" then
			ntext = remove_tone_tags_text(subtitles[i].text)
			local nline = subtitles[i]
			nline.text = ntext
			subtitles[i] = nline
			lines_baked = lines_baked + 1
			aegisub.progress.task(lines_baked.." lines baked")
		end
	end
end

function clean_tone_tags_macro(subtitles, selected_lines, active_line)
	clean_tone_tags_subs(subtitles)
	aegisub.set_undo_point(script_name)
end

function clean_tone_tags_filter(subtitles, config)
	clean_tone_tags_subs(subtitles)
end

aegisub.register_macro(script_name, script_description, clean_tone_tags_macro)
aegisub.register_filter(script_name, script_description, 0, clean_tone_tags_filter)
