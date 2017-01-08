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
require "lfs"

local tr = aegisub.gettext

script_name = tr"bakery安装配置"
script_description = tr"复制bakery文件并配置环境"
script_author = "presisco"
script_version = "1.00"
script_modified = "8 January 2017"

function install_bakery()
	aegisub_root = aegisub.dialog.open("选择aegisub执行文件", "aegisub32.exe", "", "EXE files (.exe)", false, true)
	bakery_files = aegisub.dialog.open("选择bakery库文件", "bakery.lua", "", "", "lua files (.lua)", false, true)
	aegisub_root = aegisub_root:gmatch("(.*)\\")
	bakery_files = bakery_files:gmatch("(.*)\\")
end

function install_bakery_macro(subtitles, selected_lines, active_line)
	install_bakery()
end

function install_bakery_filter(subtitles, config)
end

aegisub.register_macro(script_name, script_description, install_bakery_macro)
aegisub.register_filter(script_name, script_description, 0, install_bakery_filter)
