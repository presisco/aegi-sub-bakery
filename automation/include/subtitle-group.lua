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
include "bakery.lua"

subtitle_group_version="1.00"

--[[
config_table={
  current_tpl_file="filepath",
  known_tpl_files={
    path,
    ...
  }
}
]]

--[[
  tpl_table={
    name={
      style="",
      layer=0,
      tags="",
      actor="",
      effects=""
    },
    ...
  }
]]

subtitle_group={}

local config_classname="subtitle-group-config"
local config_version="1.00"
local tpl_classname="subtitle-group-template"
local tpl_version="1.00"
local types={"simple","bilingual"}
local filetype="txt files (*.txt)|*.txt"
local sector_identifer="*"

local config_filepath=bakery.env.config_root.."group_config.txt"
local default_tpl_filepath=bakery.env.config_root.."group_tpl.txt"

local log_line=function(text)
  aegisub.log(text.."\n")
end

subtitle_group.get_tpl_classname=function()
  return tpl_classname
end

subtitle_group.get_tpl_file_type=function()
  return filetype
end

subtitle_group.get_sector_identifer=function()
  return sector_identifer
end

subtitle_group.load_config=function()
  return bakery.preference.read_from_file(
    config_filepath,
    config_classname,
    config_version,
    {current_tpl_file=default_tpl_filepath,known_tpl_files={default_tpl_filepath}})
end

subtitle_group.save_config=function(config_table)
  bakery.preference.print_to_file(
    config_filepath,
    config_table,
    config_classname,
    config_version)
end

subtitle_group.load_tpl=function(filepath)
  return bakery.preference.read_from_file(
    filepath,
    tpl_classname,
    tpl_version,
    {})
end

subtitle_group.save_tpl=function(filepath,tpl_table)
  bakery.preference.print_to_file(
    filepath,
    tpl_table,
    tpl_classname,
    tpl_version)
end

subtitle_group.get_tpl_names=function(tpl_table)
  local names={}
  for key,value in pairs(tpl_table)
  do
    table.insert(names,key)
  end
  return names
end

subtitle_group.get_known_filenames=function(config)
  local names={}
  for i=1,#config.known_tpl_files
  do
    table.insert(names,subtitle_group.get_name_from_path(config.known_tpl_files[i]))
  end
  return names
end

subtitle_group.get_name_from_path=function(filepath)
  return filepath:gsub("(.*)\\","")
end

subtitle_group.parse_tpl_text=function(text)
  local length=text:len()
  local sectors={}
  local buff=""
  local i = 1
  
  while i <= length
  do
    local char=text:sub(i,i)
    
    if char == "\\"
    then
      if text:sub(i+1,i+1) == sector_identifer
      then
        buff=buff..sector_identifer
        i=i+1
      else
        buff=buff..char
      end
    elseif char == sector_identifer
    then
      table.insert(sectors,buff)
      buff = ""
    else
      buff=buff..char
    end
    i=i+1
  end
  
  table.insert(sectors,buff)
  
  return sectors
end

return subtitle_group
