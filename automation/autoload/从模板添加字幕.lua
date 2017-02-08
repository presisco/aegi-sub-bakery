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

bakery=require "bakery"
subtitle_group=require "subtitle-group"

local tr = aegisub.gettext

script_name = tr"从模板添加字幕"
script_description = tr"添加新字幕并套用指定模板"
script_author = "presisco"
script_version = "1.10"
script_modified = "2 February 2017"

subs={}
selections={}
active={}
style_names={}
export_config={}
group_tpl={}

prefered_config_file=bakery.env.config_root.."add_sub_with_group_tpl.conf"
prefered_config_classname="add_sub_with_group_tpl"
prefered_config_version="1.00"
prefered_config_default={
  last_sel_tpl="",
  last_sel_mode="与所选字幕相同",
  sub_duration=2
}
prefered_config={}

function add_sub(result)
  local tpl=group_tpl[result.tpl_name]
  local offset=0
  for key,value in pairs(selections)
  do
    local new_sub=subs[value+offset]
    local new_text=table.concat(subtitle_group.parse_tpl_text(tpl.text))
    subtitle_group.set_sub_props(new_sub,tpl)
    new_sub.text=new_text
    
    if result.add_mode == "在所选字幕之后"
    then
      new_sub.start_time=new_sub.end_time
      new_sub.end_time=new_sub.start_time+1000*result.sub_duration
    elseif result.add_mode == "与所选字幕相同"
    then
      
    else
      new_sub.end_time=new_sub.start_time
      new_sub.start_time=new_sub.end_time-1000*result.sub_duration
      if new_sub.start_time < 0
      then
        new_sub.start_time = 0
      end
    end
    
    offset=offset+1
    subs.insert(value+offset,new_sub)
  end
  
  prefered_config.last_sel_tpl=result.tpl_name
  prefered_config.last_sel_mode=result.add_mode
  prefered_config.sub_duration=result.sub_duration
  
  bakery.preference.print_to_file(
    prefered_config_file,
    prefered_config,
    prefered_config_classname,
    prefered_config_version)
end

function get_valid_tpl_names()
  local names={}
  for key,value in pairs(group_tpl)
  do
    table.insert(names,key)
  end
  return names
end

function entry()
  local valid_tpl_names=get_valid_tpl_names()
  if #valid_tpl_names == 0
  then
    bakery.ui.dialog.warning("没有模板！")
    aegisub.cancel()
  end

  local dialog_layout={
    class="layout",
    type="linear",
    orientation="vertical",
    items={
      {class="layout",
        type="linear",
        orientation="horizontal",
        items={
          {class="label",label="选择模板",width=1,height=1},
          {class="dropdown",name="tpl_name",items=valid_tpl_names,value=valid_tpl_names[1],width=5,height=1}
        }},
      {class="layout",
        type="linear",
        orientation="horizontal",
        items={
          {class="label",label="添加模式",width=1,height=1},
          {class="dropdown",name="add_mode",items={"在所选字幕之后","与所选字幕相同","在所选字幕之前"},value="与所选字幕相同",width=5,height=1}
        }},
      {class="layout",
        type="linear",
        orientation="vertical",
        items={
          {class="label",label="字幕时长（选择“与所选字幕相同”时不起作用）",width=1,height=1},
          {class="floatedit",name="sub_duration",value=2,width=1,height=1,min=0.0}
        }}
    }
  }
  
  if prefered_config.last_sel_tpl ~= "" and group_tpl[prefered_config.last_sel_tpl] ~= nil
  then
    bakery.ui.layout.get_control(dialog_layout,"tpl_name").value=prefered_config.last_sel_tpl
  end
  
  bakery.ui.layout.get_control(dialog_layout,"add_mode").value=prefered_config.last_sel_mode
  bakery.ui.layout.get_control(dialog_layout,"sub_duration").value=prefered_config.sub_duration
  
  bakery.ui.dialog.ok_cancel(dialog_layout,add_sub,function(result) aegisub.cancel()  end)
end

function bilingual_group_op_macro(subtitles, selected_lines, active_line)
  subs=subtitles
  selections=selected_lines
  active=active_line

  group_config=subtitle_group.load_config()
  group_tpl=subtitle_group.load_tpl(group_config.current_tpl_file)
  
  prefered_config=bakery.preference.read_from_file(
    prefered_config_file,
    prefered_config_classname,
    prefered_config_version,
    prefered_config_default)

  entry()

  aegisub.set_undo_point(script_name)
end

function bilingual_group_op_filter(subtitles, config)
end

aegisub.register_macro(script_name, script_description, bilingual_group_op_macro)
aegisub.register_filter(script_name, script_description, 0, bilingual_group_op_filter)
