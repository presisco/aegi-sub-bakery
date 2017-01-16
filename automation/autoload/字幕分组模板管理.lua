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
bakery=require "bakery"
subtitle_group=require "subtitle-group"

local tr = aegisub.gettext

script_name = tr"字幕分组模板管理"
script_description = tr"对字幕分组模板进行管理"
script_author = "presisco"
script_version = "1.00"
script_modified = "15 January 2017"

subs={}
selections={}
active={}
style_names={}
export_config={}
group_tpl_table={}
group_tpl_config={}
group_config={}
sector_identifer=""
modified=false
quit_mod=false

--delete template

local tpl_sel_grid_layout_host={
  class="layout",
  orientation="vertical",
  items={
    {class="label",label="选择模板",width=4,height=1},
    {
      class="layout",
      type="grid",
      unit_width=6,
      unit_height=1,
      max_length=3,
      orientation="vertical",
      items={}
    }
  }
}

function del()
  names=subtitle_group.get_tpl_names(group_tpl_table)
  local del_names={}

  for i=1,#names
  do
    local del_name={class="checkbox",name=names[i],label=names[i],width=5,height=1}
    table.insert(del_names,del_name)
  end

  tpl_sel_grid_layout_host.items[2].items=del_names
  tpl_sel_grid_layout_host.items[1].label="勾选要删除的模板"

  after_selection=function(result)
    for key,value in pairs(result)
    do
      if type(value) == "boolean" and value
      then
        group_tpl_table[key]=nil
        modified=true
      end
    end
  end

  bakery.ui.dialog.ok_cancel(tpl_sel_grid_layout_host,
    after_selection,
    back_to_main)
end

--edit template

local tpl_edit_layout={
  class="layout",
  orientation="vertical",
  items={
    {
      class="layout",
      orientation="horizontal",
      items={
        {class="label",label="样式",width=2,height=1},
        {class="dropdown",name="style",items={},value="",width=8,height=1}
      }
    },
    {
      class="layout",
      orientation="horizontal",
      items={
        {class="label",label="图层",width=2,height=1},
        {class="intedit",name="layer",value=0,width=4,height=1}
      }
    },
    {
      class="layout",
      orientation="horizontal",
      items={
        {class="label",label="添加的文本与标签\n使用*代表一个原文区段\n\\*为一个'*'",width=2,height=1},
        {class="textbox",name="text",value="",width=12,height=6}
      }
    },
    {
      class="layout",
      orientation="horizontal",
      items={
        {class="label",label="角色",width=2,height=1},
        {class="textbox",name="actor",value="",width=12,height=6}
      }
    },
    {
      class="layout",
      orientation="horizontal",
      items={
        {class="label",label="特效",width=2,height=1},
        {class="textbox",name="effect",value="",width=12,height=4}
      }
    }
  }
}

local tpl_list_layout={
  class="layout",
  orientation="horizontal",
  items={
    {class="label",label="模板",width=2,height=1},
    {class="dropdown",name="template",items={},value="",width=8,height=1}
  }
}

function edit_group_tpl(result)
  local new_group_tpl={
    style=bakery.utils.trim_illegal_char(result.style),
    layer=result.layer,
    text=bakery.utils.trim_illegal_char(result.text),
    actor=bakery.utils.trim_illegal_char(result.actor),
    effect=bakery.utils.trim_illegal_char(result.effect),
  }
  group_tpl_table[result.name]=new_group_tpl
  modified=true
end

function update_edit_layout(tpl)
  bakery.ui.layout.get_control(tpl_edit_layout,"style").value=tpl.style
  bakery.ui.layout.get_control(tpl_edit_layout,"layer").value=tpl.layer
  bakery.ui.layout.get_control(tpl_edit_layout,"text").value=tpl.text
  bakery.ui.layout.get_control(tpl_edit_layout,"actor").value=tpl.actor
  bakery.ui.layout.get_control(tpl_edit_layout,"effect").value=tpl.effect
end

function edit()
  after_selection=function(result)
    selected_template=result.template
    tpl=group_tpl_table[selected_template]
    update_edit_layout(tpl)
    bakery.ui.dialog.ok_cancel(tpl_edit_layout,
      function(result)
        result["name"]=selected_template
        edit_group_tpl(result)
      end,
      back_to_main)
  end
  names=subtitle_group.get_tpl_names(group_tpl_table)
  bakery.ui.layout.get_control(tpl_list_layout,"template").items=names
  bakery.ui.layout.get_control(tpl_list_layout,"template").value=names[1]

  bakery.ui.dialog.ok_cancel(tpl_list_layout,
    after_selection,
    back_to_main)
end

--add template

local tpl_name_layout={
  class="layout",
  orientation="horizontal",
  items={
    {class="label",label="名称",width=2,height=1},
    {class="textbox",name="name",value="",width=8,height=1}
  }
}

local tpl_add_layout={
  class="layout",
  orientation="vertical",
  items={
    tpl_name_layout,
    tpl_edit_layout
  }
}

function generate()
  selected_sub=subs[selections[1]]
  local tpl={
    style=selected_sub.style,
    layer=selected_sub.layer,
    text=selected_sub.text,
    actor=selected_sub.actor,
    effect=selected_sub.effect}
  update_edit_layout(tpl)
  bakery.ui.dialog.ok_cancel(tpl_add_layout,
    edit_group_tpl,
    back_to_main)
end

--config template file

local tpl_file_op_ui={
  class="layout",
  orientation="horizontal",
  items={
    {class="label",label="选择操作",width=2,height=1},
    {class="dropdown",name="tpl_file_op",items={"更换模板文件","创建模板文件","从模板文件导入模板","导出模板到文件"},value="更换模板文件",width=8,height=1}
  }
}

--[[
local tpl_file_list={
  class="layout",
  type="linear",
  orientation="vertical",
  items={
    {class="layout",
      orientation="horizontal",
      items={
        {class="label",label="选择已知的模板文件",width=4,height=1},
        {class="dropdown",name="tpl_files",items={},value="",width=10,height=1}}
    },
    {class="checkbox",name="add_tpl_file",label="添加模板文件",width=4,height=1}
  }
}
]]

function swith_tpl_file_op(new_filepath)
  subtitle_group.save_tpl(group_tpl_config.current_tpl_file
    ,group_tpl_table)

  group_tpl_config.current_tpl_file=new_filepath
  bakery.utils.uniq_insert(group_tpl_config.known_tpl_files,new_filepath)

  subtitle_group.save_config(group_tpl_config)

  group_tpl_table=subtitle_group.load_tpl(group_tpl_config.current_tpl_file)
end

function switch_tpl_file()
  
  local current_file=group_tpl_config.current_tpl_file
  local name=bakery.utils.get_filename_from_path(current_file)
  local path=bakery.utils.get_full_path(current_file)
--  aegisub.log("name:"..name..",path:"..path.."\n")
  
  local switched_file= aegisub.dialog.open(
    "选择导入的文件",
    name,
    path,
    subtitle_group.get_tpl_file_type(),
    false)
  
  if switched_file ~= nil
  then
    swith_tpl_file_op(switched_file)
  end
end

function create_tpl_file()
  local new_tpl_filename = aegisub.dialog.save(
    "选择创建的文件",
    "template.txt",
    bakery.env.config_root,
    subtitle_group.get_tpl_file_type(),
    false)
  if new_tpl_filename ~= nil
  then
    swith_tpl_file_op(new_tpl_filename)
  end
end

function import_tpl_file()
  bakery.ui.dialog.warning("将会覆盖目前同名的模板！")
  local import_filename= aegisub.dialog.open(
    "选择导入的文件",
    "template.txt",
    bakery.env.config_root,
    subtitle_group.get_tpl_file_type(),
    false)
  if import_filename ~= nil
  then
    imported_tpls=subtitle_group.load_tpl(import_filename)
    bakery.utils.merge_table_pairs(group_tpl_table,imported_tpls)
    modified=true
  end
end

function export_tpl_file()

  local export_filename= aegisub.dialog.open(
    "选择导出的文件",
    "template.txt",
    bakery.env.config_root,
    subtitle_group.get_tpl_file_type(),
    false)
  if export_filename ~= nil
  then
    names=subtitle_group.get_tpl_names(group_tpl_table)
    local del_names={}

    for i=1,#names
    do
      local del_name={class="checkbox",name=names[i],label=names[i],width=5,height=1}
      table.insert(del_names,del_name)
    end

    tpl_sel_grid_layout_host.items[2].items=del_names
    tpl_sel_grid_layout_host.items[1].label="勾选要导出的模板"

    after_selection=function(result)
      local export_tpls={}
      for key,value in pairs(result)
      do
        if type(value) == "boolean" and value
        then
          export_tpls[key]=group_tpl_table[key]
        end
      end
      subtitle_group.save_tpl(export_filename,export_tpls)
    end

    bakery.ui.dialog.ok_cancel(tpl_sel_grid_layout_host,
      after_selection,
      back_to_main)
  end
end

local tpl_export_selection_layout_host={
  class="layout",
  orientation="vertical",
  items={
    {class="label",label="勾选要导出的模板",width=4,height=1},
    {
      class="layout",
      orientation="horizontal",
      items={}
    }
  }
}


function tpl_file_op()
  on_ok=function(result)
    if result.tpl_file_op == "更换模板文件"
    then
      switch_tpl_file()
    elseif result.tpl_file_op == "创建模板文件"
    then
      create_tpl_file()
    elseif result.tpl_file_op == "从模板文件导入模板"
    then
      import_tpl_file()
    else
      export_tpl_file()
    end
  end
  bakery.ui.dialog.ok_cancel(tpl_file_op_ui,
    on_ok,
    back_to_main)
end

function back_to_main(result)

end

function quit(result)
  quit_mod=true
end

--entry point

entry_layout={
  class="layout",
  orientation="horizontal",
  items={
    {class="label",label="选择操作",width=4,height=1},
    {class="dropdown",name="op",items={"添加模板","更改模板","删除模板","模板文件管理"},value="更改模板",width=4,height=1}
  }
}

function group_tpl()
  while not quit_mod
  do
    bakery.ui.dialog.ok_cancel(entry_layout,
      function(result)
        if result.op == "添加模板"
        then
          generate()
        elseif result.op == "更改模板"
        then
          edit()
        elseif result.op == "删除模板"
        then
          del()
        elseif result.op == "模板文件管理"
        then
          tpl_file_op()
        else

        end
      end,
      quit)
  end
end

function group_tpl_manager_macro(subtitles, selected_lines, active_line)
  subs=subtitles
  selections=selected_lines
  active=active_line

  style_names=bakery.utils.get_style_names(subs)

  bakery.ui.layout.get_control(tpl_edit_layout,"style").items=style_names

  group_tpl_config=subtitle_group.load_config()
  group_tpl_table=subtitle_group.load_tpl(group_tpl_config.current_tpl_file)
  sector_identifer=subtitle_group.get_sector_identifer()

  group_tpl()

  if modified
  then
    subtitle_group.save_tpl(group_tpl_config.current_tpl_file,group_tpl_table)
  end
  quit_mod=false
  aegisub.set_undo_point(script_name)
end

function group_tpl_manager_filter(subtitles, config)
end

aegisub.register_macro(script_name, script_description, group_tpl_manager_macro)
aegisub.register_filter(script_name, script_description, 0, group_tpl_manager_filter)
