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

local tr = aegisub.gettext

script_name = tr"bakery安装配置"
script_description = tr"复制bakery文件并配置环境"
script_author = "presisco"
script_version = "1.00"
script_modified = "16 January 2017"

local log_err=function(text)
  aegisub.log(1,text.."\n")
end

local log_dbg=function(text)
  aegisub.log(4,text.."\n")
end

function print_table(table)
  for key,value in pairs(table)
  do
    aegisub.log(key..":"..value..",value type:"..type(value).."\n")
  end
end

function install_bakery()
  local aegisub_root = aegisub.dialog.open("选择aegisub执行文件", "aegisub.exe", "", "exe files (.exe)|*.exe", false, true)
  local bakery_files = aegisub.dialog.open("选择bakery库默认设置保存位置", "example.txt", "", "Text files (.txt)|*.txt",false, true)
  
  if aegisub_root ~= nil and bakery_files ~= nil
  then
    
    aegisub_root = aegisub_root:match("(.*)\\").."\\"
    bakery_files = bakery_files:match("(.*)\\").."\\"
    
    aegisub_root = aegisub_root:gsub("\\","\\\\")
    bakery_files = bakery_files:gsub("\\","\\\\")
    
    log_dbg("aegisub root:"..aegisub_root)
    log_dbg("bakery config:"..bakery_files)
    
    local bakery_env_filepath=aegisub_root.."automation\\include\\bakery-env.lua"
    
    log_dbg("creating bakery env file:"..bakery_env_filepath)
    
    local bakery_env_file,err_msg = io.open(bakery_env_filepath,"w")
    if err_msg ~= nil
    then
      log_err(err_msg)
      return
    end
    
    bakery_env_file:write("bakery_env_config_root = \""..bakery_files.."\"\n")
    bakery_env_file:write("bakery_env_aegisub_root = \""..aegisub_root.."\"\n")
    bakery_env_file:flush()
    bakery_env_file:close()
  else
    log_err("请选择或创建文件！")
  end
end

function install_bakery_macro(subtitles, selected_lines, active_line)
  install_bakery()
end

function install_bakery_filter(subtitles, config)
end

aegisub.register_macro(script_name, script_description, install_bakery_macro)
aegisub.register_filter(script_name, script_description, 0, install_bakery_filter)
