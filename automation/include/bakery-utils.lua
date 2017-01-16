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
bakery_utils_version="1.10"

bakery_utils={}

local raw_line_seperator=","
local raw_line_classname_tail=": "
local log_type_wrap={
  ["unknown"]={"?","?"},
  ["string"]={"\"","\""},
  ["number"]={"(",")"},
  ["boolean"]={"[","]"},
  ["table"]={"{","}"}
}
local log_depth_blank="\t"
local log_kv_seperator="="
local illegal_ascii={0x00,0x1F}

bakery_utils.uniq_insert=function(array_table,item)
  for key,value in pairs(array_table)
  do
    if value == item
    then
      return
    end
  end
  table.insert(array_table,item)
end

bakery_utils.get_filename_from_path=function(filepath)
  return filepath:gsub("(.*)\\","")
end

bakery_utils.get_full_path=function(filepath)
  return filepath:match("(.*)\\").."\\"
end

bakery_utils.trim_illegal_char=function(subtitle_text)
  
  local trimed=""
  local raw_length=subtitle_text:len()
  local illegal_ascii_dec={tonumber(illegal_ascii[1]),tonumber(illegal_ascii[2])}
  
  for i=1,raw_length
  do
    if not bakery_utils.num_in_close_intervals(subtitle_text:byte(i,i),illegal_ascii_dec)
    then
      trimed=trimed..subtitle_text:sub(i,i)
    end
  end
  return trimed
end

bakery_utils.text2ms=function (text_time)
  local millis=0
  millis=tonumber(text_time:sub(1))
end

bakery_utils.text2bool=function(text)
  if text == "true"
  then
    return true
  else
    return false
  end
end

bakery_utils.bool2text=function(bool)
  if bool
  then
    return "true"
  else
    return "false"
  end
end

bakery_utils.num_in_close_intervals=function(number,intervals)
  local i = 1
  local in_intervals = false
  while i < #intervals
  do
    if number > intervals[i] and number < intervals[i+1]
    then
      in_intervals = true
    end
    i=i+2
  end
  return in_intervals
end

bakery_utils.print_table_itr=function(output,depth,table)
  kv_sp=log_kv_seperator
  t_wrap=log_type_wrap
  get_blanks=function(depth)
    return log_depth_blank:rep(depth)
  end
  for k,v in pairs(table)
  do
    local value_type=type(v)
    local key_type=type(k)
    local key=nil

    if key_type=="boolean"
    then
      key=bool2text(k)
    else
      key=k
    end

    if value_type == "table"
    then
      output(get_blanks(depth)..t_wrap[key_type][1]..key..t_wrap[key_type][2]
        ..kv_sp..t_wrap[value_type][1].."\n")
      bakery_utils.print_table_itr(output,depth+1,v)
      output(get_blanks(depth)..t_wrap[value_type][2].."\n")
    else
      local value=nil
      if value_type == "boolean"
      then
        value=bool2text
      elseif value_type == "string"
      then
        value=v:gsub("\n"," ")
        value=value:gsub("\r"," ")
      else
        value=v
      end
      output(get_blanks(depth)..t_wrap[key_type][1]..key..t_wrap[key_type][2]
        ..kv_sp..t_wrap[key_type][1]..value..t_wrap[key_type][2].."\n")
    end
  end
end

bakery_utils.read_table_itr=function(lines,index)
  local i=index
  kv_sp=log_kv_seperator
  t_wrap=log_type_wrap
  text2bool=text2bool
  local pref_table={}
  local force_break=false
  while i < #lines and not force_break
  do
    line=lines[i]:gsub(log_depth_blank,"")
    if line == t_wrap["table"][2]
    then
      force_break=true
    else
      local midground=line:find(kv_sp)
      local key=line:sub(2,midground-2)
      local value=line:sub(midground+2,line:len()-1)
      local k_header=line:sub(1,1)
      local v_header=line:sub(midground+1,midground+1)

      if k_header == t_wrap["number"][1]
      then
        key=tonumber(key)
      elseif k_header == t_wrap["boolean"][1]
      then
        key=text2bool(key)
      end

      if v_header == t_wrap["string"][1]
      then
      elseif v_header == t_wrap["number"][1]
      then
        value=tonumber(value)
      elseif v_header == t_wrap["boolean"][1]
      then
        value=text2bool(value)

      else
        value,i=bakery_utils.read_table_itr(lines,i+1)
      end

      pref_table[key]=value
      i=i+1
    end
  end
  return pref_table,i
end

bakery_utils.log_table=function(content_table)
  if type(content_table) ~= "table"
  then
    aegisub.log("bakery.utils.log_table():".."wrong input type:"..type(content_table))
    return
  end
  aegisub.log(log_type_wrap["table"][1])
  bakery_utils.print_table_itr(aegisub.log,1,content_table)
  aegisub.log(log_type_wrap["table"][2])
end

bakery_utils.read_table=function(lines)
  return bakery_utils.read_table_itr(lines,1)
end

bakery_utils.get_style_by_name=function(subtitles,name)
  for i=1,#subtitles
  do
    if subtitles[i].class == "style"
      and subtitles[i].name == name
    then
      return subtitles[i]
    end
  end
  return nil
end

bakery_utils.get_style_names=function(subtitles)
  local style_names={}

  for i=1,#subtitles
  do
    if subtitles[i].class == "style"
    then
      table.insert(style_names,subtitles[i].name)
    end
  end

  return style_names
end

bakery_utils.merge_table=function(dst,src)
  for i=1,#src
  do
    table.insert(dst,src[i])
  end
end

bakery_utils.merge_table_pairs=function(dst,src)
  for key,value in pairs(src)
  do
    dst[key]=value
  end
end

bakery_utils.get_classname_from_raw=function(raw_line)
  local tail=raw_line:find(raw_line_classname_tail)
  return raw_line:sub(1,tail-1)
end

bakery_utils.get_values_from_raw=function(raw_line)
  local parsed={}
  local tmp=""
  local length=raw_line:len()
  local start_index=raw_line:find(raw_line_classname_tail)+2
  local end_index=raw_line:find(raw_line_seperator,start_index)
  while end_index ~= nil
  do
    if end_index == start_index
    then
      table.insert(parsed,"")
    else
      table.insert(parsed,raw_line:sub(start_index,end_index-1))
    end
    start_index=end_index+1
    end_index=raw_line:find(raw_line_seperator,start_index)
  end
  if start_index > length
  then
    table.insert(parsed,"")
  else
    table.insert(parsed,raw_line:sub(start_index,length))
  end
  return parsed
end

bakery_utils.get_dialogue_from_raw=function(tpl,raw_line)
  aegisub.log("parsing dialogue info from raw text\n")
  --[[
	local parsed={
		class="dialogue"
		raw=raw_line
		section=
		comment=
		layer=
		start_time=
		end_time=
		style=
		actor=
		margin_l=
		margin_r=
		margin_t=
		margin_b=
		effect=
		userdata=
		text=
	}
]]
end

bakery_utils.get_style_from_raw=function(tpl,raw_line)
  aegisub.log("parsing style info from raw text\n")
  local values=get_values_from_raw(raw_line)
  local tmp=""

  tpl.class="style"
  tpl.raw=raw_line
  tpl.section="[V4+ Styles]"
  tpl.name=values[1]
  tpl.fontname=values[2]
  tpl.fontsize=values[3]
  tpl.color1=values[4].."&"
  tpl.color2=values[5].."&"
  tpl.color3=values[6].."&"
  tpl.color4=values[7].."&"
  if values[8] == 0
  then
    tpl.bold=false
  else
    tpl.bold=true
  end
  if values[9] == 0
  then
    tpl.italic=false
  else
    tpl.italic=true
  end
  if values[10] == 0
  then
    tpl.underline=false
  else
    tpl.underline=true
  end
  if values[11] == 0
  then
    tpl.strikeout=false
  else
    tpl.strikeout=true
  end
  tpl.scale_x=values[12]
  tpl.scale_y=values[13]
  tpl.spacing=values[14]
  tpl.angle=values[15]
  tpl.borderstyle=values[16]
  tpl.outline=values[17]
  tpl.shadow=values[18]
  tpl.align=values[19]
  tpl.margin_l=values[20]
  tpl.margin_r=values[21]
  tpl.margin_t=values[22]
  tpl.margin_b=values[22]
  tpl.encoding=values[23]
  tpl.relative_to=2
  return tpl
end

bakery_utils.get_subtitle_from_raw=function(tpl,raw_line)
  if tpl.class == "dialogue"
  then
    parsed=get_dialogue_from_raw(tpl,raw_line)
  elseif tpl.class == "style"
  then
    parsed=get_style_from_raw(tpl,raw_line)
  end
  return parsed
end

bakery_utils.get_filename_from_full_path=function(full_path)
  return full_path:gsub("(.*)\\","")
end

return bakery_utils
