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
require "bakery-filter-style-layer"
require "bakery-basic-ui"
require "bakery-utils"

local tr = aegisub.gettext

script_name = tr"双语模板操作"
script_description = tr"对字幕进行模板操作，包括双语预处理，后处理等"
script_author = "presisco"
script_version = "1.00"
script_modified = "3 January 2017"

dialog_mode={
	{class="label",label="选择模式",x=0,y=0,width=5,height=1},
	{class="dropdown",name="mode",items={"生成模板","套用模板"},value="套用模板",x=0,y=1,width=5,height=1}
}

dialog_export_config={
	{class="label",label="风格",x=0,y=0,width=20,height=1},
	{class="textbox",name="style",hint="style",x=0,y=1,width=8,height=1,value=""},
	{class="label",label="图层",x=0,y=0,width=20,height=1},
	{class="intedit",name="layer",hint="layer",x=0,y=1,width=8,height=1,value=0,min=0},
	{class="label",label="文本",x=0,y=0,width=20,height=1},
	{class="textbox",name="text",hint="text",x=0,y=1,width=20,height=3,value=""},
	{class="label",label="第一行的效果",x=0,y=4,width=20,height=1},
	{class="textbox",name="trans_prefix",hint="tags",x=0,y=5,width=20,height=3,value=""},
	{class="label",label="第二行的效果",x=0,y=8,width=20,height=1},
	{class="textbox",name="src_prefix",hint="tags",x=0,y=9,width=20,height=3,value=""},
	{class="label",label="分隔符",x=0,y=12,width=20,height=1},
	{class="textbox",name="seperator",hint="seperator",x=0,y=13,width=5,height=1,value=""},
	{class="label",label="模板名称",x=0,y=14,width=20,height=1},
	{class="textbox",name="tpl_name",hint="text",x=0,y=15,width=8,height=1,value="模板"}
}

dialog_import_config={
	{class="label",label="翻译的效果",x=0,y=0,width=20,height=1},
	{class="textbox",name="trans_prefix",hint="tags",x=0,y=1,width=20,height=3},
	{class="label",label="原文的效果",x=0,y=4,width=20,height=1},
	{class="textbox",name="src_prefix",hint="tags",x=0,y=5,width=20,height=3}
}

function tpl_file_load(filename)
then
	local tpl_table={}
	local tpl_file=io.open(filename,r)
	
	for line in tpl_file:lines()
	do
		
	end
	
	tpl_file:close()
	return tpl_table
end

function export(subtitles,selected_lines)
	local tpl_sub=subtitles[selected_lines[0]]
	local tpl_style=bakery_get_style_by_name(tpl_sub.style)
	
	bakery_set_control_value_by_name(dialog_export_config,"style",tpl_sub.style)
	bakery_set_control_value_by_name(dialog_export_config,"layer",tpl_sub.layer)
	bakery_set_control_value_by_name(dialog_export_config,"text",tpl_sub.text)
	
	result = bakery_simple_dialog_ok_quit(dialog_export_config)
	
	file_name = aegisub.dialog.save("保存模板", "template.tpl", "", wildcards, true)
	if file_name == nil
	then
		aegisub.cancel()
	end
	
	
end

function import(subtitles)
end

function entry(subtitles,selected_lines)
	result = bakery_simple_dialog_ok_quit(dialog_mode)
	
	if result.mode == "生成模板"
	then
		export(subtitles,selected_lines)
	else
		import()
	end
end

function bilingual_tpl_macro(subtitles, selected_lines, active_line)
	entry(subtitles,selected_lines)
	aegisub.set_undo_point(script_name)
end

function bilingual_tpl_filter(subtitles, config)
	entry(subtitles)
end

aegisub.register_macro(script_name, script_description, bilingual_tpl_macro)
aegisub.register_filter(script_name, script_description, 0, bilingual_tpl_filter)
