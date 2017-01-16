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

script_name = tr"双语分组模板操作"
script_description = tr"使用模板进行双语处理"
script_author = "presisco"
script_version = "1.00"
script_modified = "15 January 2017"

subs={}
selections={}
active={}
style_names={}
export_config={}
group_tpl={}

linebreaker_hint={
  first="第一个换行符区分内容",
  nearby="通过最近换行符切分",
  none="不通过换行符切分"
}

prefered_config_file=bakery.env.config_root.."bilingual_group_tpl.conf"
prefered_config_classname="bilingual_group_tpl"
prefered_config_version="1.00"
prefered_config={}

function cook_text(text,tpl_text_sectors,result)
  local orig_length=text:len()
  local pivot = 1
  local final_pivot = 1
  local top_line=""
  local bottom_line=""
  local lb=result.linebreaker

  pivot=bakery.locale.bilingual_pivot(text,result.language,result.reverse_scan)
  if result.linebreaker_mode == linebreaker_hint.first
  then
    final_pivot=text:find(result.linebreaker,1,true)

    if final_pivot ~= nil
    then
      top_line=text:sub(1,final_pivot-1)
      bottom_line=text:sub(final_pivot+lb:len(),orig_length)
    elseif pivot == 0
    then
      top_line = ""
      bottom_line = text
    else
      top_line = text
      bottom_line = ""
    end
  elseif result.linebreaker_mode == linebreaker_hint.nearby
  then
    if result.reverse_scan
    then
      local reversed_text=text:reverse()
      local reversed_pattern=lb:reverse()
      final_pivot=orig_length-reversed_text:find(reversed_pattern,orig_length-pivot,true)
    else
      final_pivot=text:find(lb,pivot,true)
    end

    if pivot == 0
    then
      top_line = ""
      bottom_line = text
    elseif pivot >= orig_length
    then
      top_line = text
      bottom_line = ""
    else
      top_line=text:sub(1,final_pivot-1)
      bottom_line=text:sub(final_pivot+lb:len(),orig_length)
    end

  else
    top_line=text:sub(1,pivot)
    bottom_line=text:sub(pivot+1,orig_length)
  end
  
  top_line=top_line:gsub(lb,"")
  bottom_line=bottom_line:gsub(lb,"")
  
  if result.drop_top_tags
  then
    top_line=top_line:gsub("{[^}]+}", "")
  end

  if result.drop_bottom_tags
  then
    bottom_line=bottom_line:gsub("{[^}]+}", "")
  end

  local cooked=""
  if result.switch_lines
  then
    cooked=tpl_text_sectors[1]..bottom_line..tpl_text_sectors[2]..top_line..tpl_text_sectors[3]
  else
    cooked=tpl_text_sectors[1]..top_line..tpl_text_sectors[2]..bottom_line..tpl_text_sectors[3]
  end

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
  
  bakery.preference.print_to_file(
    prefered_config_file,
    result,
    prefered_config_classname,
    prefered_config_version)
end

function get_valid_tpl_names()
  local names={}
  for key,value in pairs(group_tpl)
  do
    local tpl_text_sectors=subtitle_group.parse_tpl_text(value.text)
    if #tpl_text_sectors == 3
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
    bakery.ui.dialog.warning("没有适合双语处理的模板！")
    aegisub.cancel()
  end

  local linebreaker_hint_text={}
  for key,value in pairs(linebreaker_hint)
  do
    table.insert(linebreaker_hint_text,value)
  end

  local available_languages=bakery.locale.get_language_names()

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
          {class="label",label="识别语言",width=1,height=1},
          {class="dropdown",name="language",hint="language",items=available_languages,value=available_languages[1],width=5,height=1},
        }},
      {class="layout",
        type="linear",
        orientation="horizontal",
        items={
          {class="label",label="换行符",width=1,height=1},
          {class="textbox",name="linebreaker",hint="characters",value="\\N",width=6,height=1}
        }},
      {class="layout",
        type="linear",
        orientation="horizontal",
        items={
          {class="label",label="换行符在识别时的作用",width=1,height=1},
          {class="dropdown",name="linebreaker_mode",hint="linebreaker mode",items=linebreaker_hint_text,value=linebreaker_hint_text[1],width=8,height=1},
        }},
      {class="checkbox",label="反向扫描",name="reverse_scan",width=1,height=1},
      {class="checkbox",label="丢弃翻译的标签",name="drop_top_tags",width=1,height=1},
      {class="checkbox",label="丢弃原文的标签",name="drop_bottom_tags",width=1,height=1},
      {class="checkbox",label="交换输出行",name="switch_lines",width=1,height=1},
    }
  }
  
  bakery.ui.layout.set_items_value(dialog_layout,prefered_config)
  
  if group_tpl[prefered_config.tpl_name] == nil
  then
    bakery.ui.layout.set_value(dialog_layout,"tpl_name",valid_tpl_names[1])
  end
  
  bakery.ui.dialog.ok_cancel(dialog_layout,scan_subs,function(result) aegisub.cancel()  end)
end

function bilingual_group_op_macro(subtitles, selected_lines, active_line)
  subs=subtitles
  selections=selected_lines
  active=active_line

  style_names=bakery.utils.get_style_names(subs)

  group_config=subtitle_group.load_config()
  group_tpl=subtitle_group.load_tpl(group_config.current_tpl_file)
  
  prefered_config=bakery.preference.read_from_file(
    prefered_config_file,
    prefered_config_classname,
    prefered_config_version,
    {})
  
  entry()

  aegisub.set_undo_point(script_name)
end

function bilingual_group_op_filter(subtitles, config)
end

aegisub.register_macro(script_name, script_description, bilingual_group_op_macro)
aegisub.register_filter(script_name, script_description, 0, bilingual_group_op_filter)
