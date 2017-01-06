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

bakery_basic_ui_version="1.00"

function bakery_simple_dialog_ok_cancel(dialog_config,on_ok,on_cancel)
	clicked,result = aegisub.dialog.display(dialog_config,
										{"Apply","Cancel"},
										{["ok"]="Apply", ["cancel"]="Cancel"})
	if clicked
	then
		on_ok(result)
	else
		on_cancel(result)
	end
	
end

function bakery_get_control_by_name(dialog_config,name)
	for k,v in pairs(dialog_config)
	do
		if v.name == name
		then
			return v
		end
	end
	return nil
end

function bakery_get_max_width(layout)
	local max_width=0
	for i=1,#layout
	do
		if layout[i].width > max_width
		then
			max_width=layout[i].width
		end
	end
	return max_width
end

function bakery_get_max_height(layout)
	local max_height=0
	for i=1,#layout
	do
		if layout[i].height > max_height
		then
			max_height=layout[i].height
		end
	end
	return max_height
end

function bakery_get_total_height(layout)
	local total_height=0
	for i=1,#layout
	do
		total_height=total_height+layout[i].height
	end
	return total_height
end

function bakery_compute_layout_vertical(layout,offset_x,offset_y)
	for i=1,#layout
	do
		layout[i].x=offset_x
		layout[i].y=offset_y
		offset_y=offset_y+layout[i].height
	end
end

function bakery_compute_layout_horizontal(layout,offset_x,offset_y)
	for i=1,#layout
	do
		layout[i].x=offset_x
		layout[i].y=offset_y
		offset_x=layout[i].width
	end
end

function bakery_set_control_value_by_name(dialog_config,name,value)
	for k,v in pairs(dialog_config)
	do
		if v.name == name
		then
			v.value = value
		end
	end
end