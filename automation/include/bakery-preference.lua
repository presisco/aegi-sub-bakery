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
include "bakery-env.lua"
include "bakery-utils.lua"
require "lfs"

bakery_preference_version="1.00"
bakery_pref_key_prefix={
  ["unknown"]="u_",
  ["string"] ="s_",
  ["number"]="n_",
  ["boolean"]="b_",
  ["table"]="t_"
}
bakery_pref_value_wrap={
  ["unknown"]={"?","?"},
  ["string"]={"\"","\""},
  ["number"]={"(",")"},
  ["boolean"]={"[","]"},
  ["table"]={"{","}"}
}
bakery_pref_kv_seperator="="
bakery_pref_section_seperator="----------------"
bakery_pref_format_blank="\t"

function bakery_get_preferences_from_file(filename)
  aegisub.log("opening preference file:"..filename.."\n")
  pref_file,err_msg=io.open(filename,"r")
  if pref_file == nil
  then
    aegisub.log("open failed:"..err_msg.."\n")
    return nil,err_msg
  end
  
  local lines={}
  
  for line in pref_file:lines()
  do
    table.insert(lines,line)
  end
  
  pref_file:close()

  return bakery_get_preferences_from_lines(lines),nil
end

function bakery_get_preferences_from_lines(lines)
  local pref_table={}
  local pref={}

  kv_sp=bakery_pref_kv_seperator
  k_prefix=bakery_pref_key_prefix
  v_wrap=bakery_pref_value_wrap
  
  aegisub.log("total lines:"..#lines.."\n")

  pref_read_itr=function(raw_lines,index)
    local i=index
    local pref_table={}
    local force_break=false
    while i < #raw_lines and not force_break
    do
      line=raw_lines[i]:gsub(bakery_pref_format_blank,"")
      if line == v_wrap["table"][2]
      then
        force_break=true
        i=i+1
      else
        midground=line:find(kv_sp)
        k_raw=line:sub(1,midground-1)
        v_raw=line:sub(midground+1,line:len())
        local k=nil
        local v=nil
        k_header=k_raw:sub(1,2)

        if k_prefix["number"] == k_header
        then
          k=tonumber(k_raw:sub(3,k_raw:len()))
        elseif k_prefix["boolean"] == k_header
        then
          k=bakery_text_to_boolean(k_raw:sub(3,k_raw:len()))
        else
          k=k_raw:sub(3,k_raw:len())
        end

        if v_raw == v_wrap["table"][1]
        then
          v,i=pref_read_itr(raw_lines,i+1)
        else
          local wrap_head=v_raw:sub(1,1)
          local v_text=v_raw:sub(2,v_raw:len()-1)
          if wrap_head == v_wrap["string"][1]
          then
            v=v_text
          elseif wrap_head == v_wrap["number"][1]
          then
            v=tonumber(v_text)
          elseif wrap_head == v_wrap["boolean"][1]
          then
            v=bakery_text_to_boolean(v_text)
          else
            v=""
          end
          i=i+1
        end
        pref_table[k]=v
      end
    end
    return pref_table,i
  end
  
  pref_table=pref_read_itr(lines,1)
  
  return pref_table
end

function bakery_print_preferences_to_file(filename,pref_table)
  aegisub.log("opening preference file:"..filename.."\n")
  pref_file,err_msg=io.open(filename,"w")
  if pref_file == nil
  then
    aegisub.log("open failed:"..err_msg.."\n")
    return err_msg
  end

  kv_sp=bakery_pref_kv_seperator
  k_prefix=bakery_pref_key_prefix
  v_wrap=bakery_pref_value_wrap

  get_blanks=function(depth)
    return bakery_pref_format_blank:rep(depth)
  end

  pref_print_itr=function(depth,file,pref)
    for k,v in pairs(pref)
    do
      local value_type=type(v)
      local key_type=type(k)
      local key=nil
      
      if key_type=="boolean"
      then
        key=bakery_boolean_to_text(k)
      else
        key=k
      end
      
      if value_type == "table"
      then
        file:write(get_blanks(depth)..k_prefix[key_type]..key
          ..kv_sp..v_wrap[value_type][1].."\n")
        pref_print_itr(depth+1,file,v)
        file:write(get_blanks(depth)..v_wrap[value_type][2].."\n")
      elseif value_type == "boolean"
      then
        file:write(get_blanks(depth)..k_prefix[key_type]..key
          ..kv_sp..v_wrap[value_type][1]..bakery_boolean_to_text(v)..v_wrap[value_type][2].."\n")
      else
        file:write(get_blanks(depth)..k_prefix[key_type]..key
          ..kv_sp..v_wrap[value_type][1]..v..v_wrap[value_type][2].."\n")
      end
    end
  end

  pref_print_itr(0,pref_file,pref_table)

  pref_file:flush()
  pref_file:close()

  return nil
end
