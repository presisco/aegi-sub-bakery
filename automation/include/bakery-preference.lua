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
include("bakery-env.lua")
include("bakery-utils.lua")
require "lfs"

bakery_preference_version="1.10"

bakery_preference={}

local log_line=function(text)
  aegisub.log(text.."\n")
end

local log_err=function(text)
  aegisub.log(1,text.."\n")
end

local log_dbg=function(text)
  aegisub.log(4,text.."\n")
end

local unwrap_preference = function(wrapped_table,classname,default_version,default_pairs)
  local pref_table={}
  
  if wrapped_table.class ~= nil and wrapped_table.class ~= classname
  then
    log_err("wrong config file for "..classname.." this is "..wrapped_table.class)
    return {}
  end
  
  log_dbg("config class:"..classname)
  
  if wrapped_table.version ~= nil and wrapped_table.version ~= default_version
  then
    log_dbg("unmatched version,need:"..default_version.."this is:"..wrapped_table.version)
  else
    log_dbg("config version:"..default_version)
  end
  
  local pref_table=wrapped_table.content
  if pref_table == nil
  then
    pref_table={}
  end
  
  for key,value in pairs(default_pairs)
  do
    if pref_table[key] == nil
    then
      pref_table[key] = value
    end
  end
  
  return pref_table
  
end

local wrap_preference = function(pref_table,classname,version)
  return {classname=classname,version=version,content=pref_table}
end

bakery_preference.read_from_file=function(filename,classname,default_version,default_pairs)
  log_dbg("opening preference file:"..filename.."\n")
  pref_file,err_msg=io.open(filename,"r")
  if pref_file == nil
  then
    if err_msg:find("No such file or directory") ~= nil
    then
      createfile=io.open(filename,"w")
      createfile:close()
      pref_file,err_msg=io.open(filename,"r")
    end
    if pref_file == nil
    then
      log_err("open failed:"..err_msg.."\n")
      return {},err_msg
    end
  end

  local lines={}

  for line in pref_file:lines()
  do
    table.insert(lines,line)
  end

  log_dbg("total lines:"..#lines.."\n")

  pref_file:close()
  
  local wrapped_table=bakery_utils.read_table(lines)
  
  return unwrap_preference(wrapped_table,classname,default_version,default_pairs),nil
end

bakery_preference.print_to_file=function(filename,pref_table,classname,version)
  log_dbg("saving preference file:"..filename.."\n")
  pref_file,err_msg=io.open(filename,"w")
  if pref_file == nil
  then
    log_err("save failed:"..err_msg.."\n")
    return err_msg
  end

  print_func=function(text)
    pref_file:write(text)
  end
  
  local wrapped_table=wrap_preference(pref_table,classname,version)

  bakery_utils.print_table_itr(print_func,0,wrapped_table)

  pref_file:flush()
  pref_file:close()

  return nil
end

return bakery_preference
