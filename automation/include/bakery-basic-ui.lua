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

--[[
	layout:
	{
		class="layout"
		orientation="vertical" or "horizontal"
		items={
			{...},
			{...}
		}
	}
]]

--[[
	function_config:
	{
		filter_style=true,
		filter_layer=true,
		filter_time=true,
		filter_selection=true,
		selection=selections,
		subtitles=subs,
		effective_sub=func --> func(sub,result)
		on_cancel=func --> func(result)
	}
]]
function bakery_simple_dialog_with_filter(dialog_layout,function_config)
	subs=function_config.subtitles
	selection=function_config.selection
	style_names=bakery_get_available_style_names(subs)

	filter_config_style = {
		class="layout",
		orientation="vertical",
		items={
			{class="checkbox",label="限定样式",name="restrict_style",width=1,height=1},
			{class="dropdown",name="filter_style",hint="style name",items=style_names,value=style_names[1],width=1,height=1}
		}
	}
	
	filter_config_layer = {
		class="layout",
		orientation="vertical",
		items={
			{class="checkbox",label="限定图层",name="restrict_layer",width=1,height=1},
			{class="intedit",name="filter_layer",hint="layer id",width=1,height=1,min=0}
		}
	}
	
	config_start_time = {
		class="layout",
		orientation="vertical",
		items={
			{class="label",label="开始时间(h:m:s:ms)",width=2,height=1},
			{class="layout",
			orientation="horizontal",
			items={
				{class="intedit",name="filter_start_time_h",hint="hour",value="0",width=1,height=1,min=0,max=9},
				{class="intedit",name="filter_start_time_m",hint="minute",value="0",width=2,height=1,min=0,max=59},
				{class="intedit",name="filter_start_time_s",hint="second",value="0",width=2,height=1,min=0,max=59},
				{class="intedit",name="filter_start_time_ms",hint="millisecond",value="0",width=2,height=1,min=0,max=99}
				}
			}
		}
	}
	
	config_end_time = {
		class="layout",
		orientation="vertical",
		items={
			{class="label",label="终止时间(h:m:s:ms)",width=2,height=1},
			{class="layout",
			orientation="horizontal",
			items={
				{class="intedit",name="filter_end_time_h",hint="hour",value="0",width=1,height=1,min=0,max=9},
				{class="intedit",name="filter_end_time_m",hint="minute",value="0",width=2,height=1,min=0,max=59},
				{class="intedit",name="filter_end_time_s",hint="second",value="0",width=2,height=1,min=0,max=59},
				{class="intedit",name="filter_end_time_ms",hint="millisecond",value="0",width=2,height=1,min=0,max=99}
				}
			}
		}
	}
	
	filter_config_time = {
		class="layout",
		orientation="vertical",
		items={
			{class="checkbox",label="限制时间(格式与Aegisub相同)",name="restrict_time",width=2,height=1},
			config_start_time,
			config_end_time
		}
	}
	
	filter_config_selection = {
		class="layout",
		orientation="horizontal",
		items={
			{class="checkbox",label="限定为选择项",name="restrict_selection",width=2,height=1}
		}
	}
	
	local filter_config = {
		class="layout",
		orientation="horizontal",
		items={}
	}
	
	if function_config.filter_style
	then
		table.insert(filter_config.items,filter_config_style)
	end
	
	if function_config.filter_layer
	then
		table.insert(filter_config.items,filter_config_layer)
	end
	
	if function_config.filter_time
	then
		table.insert(filter_config.items,filter_config_time)
	end
	
	if function_config.filter_selection
	then
		table.insert(filter_config.items,filter_config_selection)
	end
	
	local final_config = {
		class="layout",
		orientation="vertical",
		items={
			dialog_layout,
			filter_config
		}
	}
	
--	bakery_log_table(final_config)
	
	bakery_compute_layout(final_config,0,0)
	dialog_config = bakery_convert_to_dialog(final_config)
--  bakery_log_table(dialog_config)
	
	clicked,result_table = aegisub.dialog.display(dialog_config,
										{"Apply","Cancel"},
										{["ok"]="Apply", ["cancel"]="Cancel"})
	
	local time_floor=0
	local time_roof=0
	local time_interval={0,0}
	if function_config.filter_time
	then
		time_floor = (result_table.filter_start_time_h*3600
					+ result_table.filter_start_time_m*60
					+ result_table.filter_start_time_s)*1000
					+ result_table.filter_start_time_ms*10
		time_roof = (result_table.filter_end_time_h*3600
					+ result_table.filter_end_time_m*60
					+ result_table.filter_end_time_s)*1000
					+ result_table.filter_end_time_ms*10
		time_interval={time_floor,time_roof}
	end
	
	is_effective = function(sub)
		if sub.class ~= "dialogue" 
		then
			return false
		end
		if function_config.filter_style and result_table.restrict_style
		then
			if result_table.filter_style ~= sub.style
			then
				return false
			end
		end
		if function_config.filter_layer and result_table.restrict_layer
		then
			if result_table.filter_layer ~= sub.layer
			then
				return false
			end
		end
		if function_config.filter_time and result_table.restrict_time
		then
			if ( not bakery_number_in_close_intervals(sub.start_time,time_interval))
				or ( not bakery_number_in_close_intervals(sub.end_time,time_interval))
			then
				return false
			end
		end
		return true
	end
										
	if clicked
	then
		if function_config.filter_selection and result_table.restrict_selection
		then
			for i=1,#selection
			do
				aegisub.progress.set(i * 100 / #selection)
				if is_effective(subs[selection[i]])
				then
					subs[selection[i]]=function_config.effective_sub(subs[selection[i]],result_table)
				end
			end
		else
			for i=1,#subs
			do
				aegisub.progress.set(i * 100 / #subs)
				if is_effective(subs[i])
				then
					subs[i]=function_config.effective_sub(subs[i],result_table)
				end
			end
		end
	else
		function_config.on_cancel(result_table)
	end
end

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

function bakery_convert_to_dialog(layout)
	local dialog_config={}
	if layout.class == "layout"
	then
		local items=layout.items
		for i=1,#items
		do
			if items[i].class == "layout"
			then
				child_config=bakery_convert_to_dialog(items[i])
				bakery_merge_table(dialog_config,child_config)
			else
				table.insert(dialog_config,items[i])
			end
		end
	end
	return dialog_config
end

function bakery_move_layout(layout,offset_x,offset_y)
	if layout.class == "layout"
	then
		local items=layout.items
		for i=1,#items
		do
			if items[i].class == "layout"
			then
				bakery_move_layout(items[i],offset_x,offset_y)
			else
				items[i].x = items[i].x + offset_x
				items[i].y = items[i].y + offset_y
			end
		end
	end
end

function bakery_compute_layout(layout,offset_x,offset_y)
	if layout.class ~= "layout"
	then
		return
	end
	
	local items=layout.items
	
	local total_height=0
	local total_width=0
	local orientation=layout.orientation
	
	for i=1,#items
	do
		if items[i].class == "layout"
		then
			child_width,child_height=bakery_compute_layout(items[i],offset_x,offset_y)
			if orientation == "vertical"
			then
				offset_y=offset_y+child_height
				total_height=total_height+child_height
				if child_width > total_width
				then
					total_width=child_width
				end
			else
				offset_x = offset_x + child_width
				total_width = total_width + child_width
				if child_height > total_height
				then
					total_height=child_height
				end
			end
		else
			items[i].x=offset_x
			items[i].y=offset_y
			if orientation == "vertical"
			then
				offset_y=offset_y+items[i].height
				total_height=total_height+items[i].height
				if items[i].width > total_width
				then
					total_width=items[i].width
				end
			else
				offset_x=offset_x+items[i].width
				total_width=total_width+items[i].width
				if items[i].height > total_height
				then
					total_height=items[i].height
				end
			end
		end
	end
	
	return total_width,total_height
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