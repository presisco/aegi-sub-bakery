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

script_name = tr"预处理原始字幕"
script_description = tr"对原始字幕进行预处理，以便于进行翻译"
script_author = "presisco"
script_version = "1.00"
script_modified = "1 January 2017"

function remove_unecessary_text(text)
	local baked=string.gsub(text,"%[(.*)%]","")
	baked=string.gsub(baked,"\\N"," ")
	baked=string.gsub(baked,"%s%s+"," ")
	
	local length=string.len(baked)
	if length > 1
	then
		if string.sub(baked,1,1) == " "
		then
			baked=string.sub(baked,2,length)
		end
	else
		if string.sub(baked,1,1) == " "
		then
			baked=""
		end
	end
	
	return baked
end

function is_useful_dialog(subtitle)
	if subtitle.class == "dialogue" 
		and not subtitle.comment
	then
		return true
	else
		return false
	end
end

function bake_raw_subs(subtitles)
	local total=#subtitles
	
	aegisub.progress.task("清理无用文本")
	for i=1,total
	do
		aegisub.progress.set(i * 100 / total)
		if is_useful_dialog(subtitles[i])
		then
			ntext = remove_unecessary_text(subtitles[i].text)
			local nline = subtitles[i]
			nline.text = ntext
			subtitles[i] = nline
		end
	end
	
	local i=1
	aegisub.progress.task("清理空行")
	while(i <= total)
	do
		aegisub.progress.set(i * 100 / total)
		if is_useful_dialog(subtitles[i])
		then
			if subtitles[i].text == ""
			then
				subtitles.delete(i)
				total=total-1
				i=i-1
			end
		end
		i=i+1
	end
end

function bake_raw_subs_macro(subtitles, selected_lines, active_line)
	bake_raw_subs(subtitles)
	aegisub.set_undo_point(script_name)
end

function bake_raw_subs_filter(subtitles, config)
	bake_raw_subs(subtitles)
end

aegisub.register_macro(script_name, script_description, bake_raw_subs_macro)
aegisub.register_filter(script_name, script_description, 0, bake_raw_subs_filter)
