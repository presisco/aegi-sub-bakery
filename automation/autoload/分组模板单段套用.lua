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

script_name = tr"分组模板单段套用"
script_description = tr"对单段分组模板套用字幕（一个*）"
script_author = "presisco"
script_version = "1.00"
script_modified = "16 January 2017"

subs={}
selections={}
active={}
style_names={}
export_config={}
group_tpl={}

function cook_text(text,tpl_text_sectors,result)
  if result.drop_tags
  then
    text=text:gsub("{[^}]+}","")
  end
  
  local cooked=tpl_text_sectors[1]..text..tpl_text_sectors[2]

  return cooked
end

function scan_subs(result)
  local tpl=group_tpl[result.tpl_name]
  for key,value in pairs(selections)
  do
    local mod_sub=subs[value]
    mod_sub.layer=tpl.layer
    mod_sub.style=tpl.style
    mod_sub.text=cook_text(mod_sub.text,subtitle_group.parse_tpl_text(tpl.text),result)
    mod_sub.actor=tpl.actor
    mod_sub.effect=tpl.effect
    subs[value]=mod_sub
  end
end

function get_valid_tpl_names()
  local names={}
  for key,value in pairs(group_tpl)
  do
    local tpl_text_sectors=subtitle_group.parse_tpl_text(value.text)
    if #tpl_text_sectors == 2
    then
      table.insert(names,key)
    end
  end
  return names
end

function entry()
  local valid_tpl_names=get_valid_tpl_names()
  if #valid_tpl_names == 0
  then
    bakery.ui.dialog.warning("没有适合的单段模板！")
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
      {class="checkbox",label="丢弃原来的标签",name="drop_tags",width=1,height=1}
    }
  }
  bakery.ui.dialog.ok_cancel(dialog_layout,scan_subs,function(result) aegisub.cancel()  end)
end

function bilingual_group_op_macro(subtitles, selected_lines, active_line)
  subs=subtitles
  selections=selected_lines
  active=active_line
  
  group_config=subtitle_group.load_config()
  group_tpl=subtitle_group.load_tpl(group_config.current_tpl_file)

  entry()

  aegisub.set_undo_point(script_name)
end

function bilingual_group_op_filter(subtitles, config)
end

aegisub.register_macro(script_name, script_description, bilingual_group_op_macro)
aegisub.register_filter(script_name, script_description, 0, bilingual_group_op_filter)
