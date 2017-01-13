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
script_modified = "8 January 2017"

subs={}
selections={}
active={}
style_names={}
export_config={}
group_tpl_table={}
group_tpl_config={}
group_config={}
modified=false
quit_mod=false

--delete template

local tpl_sel_grid_layout_host={
  class="layout",
  orientation="vertical",
  items={
    {class="label",label="勾选要删除的模板",width=4,height=1},
    {
      class="layout",
      orientation="horizontal",
      items={}
    }
  }
}

function inflate_tpl_sel_grid(name_table)
  
end

function del()
  local max_column_length=10
  names=subtitle_group.get_tpl_names(group_tpl_table)

  local container={}
  local full_column_count=math.floor(#names/max_column_length)

  for i=1,full_column_count
  do
    local full_column={class="layout",orientation="vertical",items={}}
    local step=(i-1)*max_column_length

    for j=1,max_column_length
    do
      local item={class="checkbox",name=names[step+j],label=names[step+j],width=4,height=1}
      table.insert(full_column.items,item)
    end

    table.insert(container,full_column)
  end

  local remain_column={class="layout",orientation="vertical",items={}}
  for i=#names-#names%max_column_length+1,#names
  do
    local item={class="checkbox",name=names[i],label=names[i],width=4,height=1}
    table.insert(remain_column.items,item)
  end

  table.insert(container,remain_column)
  
  tpl_del_layout_host.items[2].items=container

  after_selection=function(result)
    for key,value in result
    do
      if type(value) == "boolean" and value
      then
        group_tpl_table[key]=nil
      end
    end
  end

  bakery.ui.dialog.ok_cancel(tpl_del_layout_host,
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
        {class="label",label="标签,使用\"*\"区分多个原文区段",width=2,height=1},
        {class="textbox",name="tags",value="",width=12,height=6}
      }
    },
    {
      class="layout",
      orientation="horizontal",
      items={
        {class="label",label="特效t)",width=2,height=1},
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
    style=result.style,
    layer=result.layer,
    tags=result.tags,
    effect=result.effect
  }
  group_tpl_table[result.name]=new_group_tpl
  modified=true
end

function update_edit_layout(tpl)
  bakery.ui.layout.get_control(tpl_edit_layout,"style").value=tpl.style
  bakery.ui.layout.get_control(tpl_edit_layout,"layer").value=tpl.layer
  bakery.ui.layout.get_control(tpl_edit_layout,"tags").value=tpl.tags
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
  local tpl={style=selected_sub.style,layer=selected_sub.layer,tags=selected_sub.text}
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

local tpl_file_list={
  class="layout",
  orientation="horizontal",
  items={
    {class="label",label="选择模板文件",width=4,height=1},
    {class="dropdown",name="tpl_files",items={},value="",width=10,height=1}
  }
}

function swith_tpl_file(new_filepath)
  subtitle_group.save_tpl(group_tpl_config.current_tpl_file
    ,group_tpl_table)

  group_tpl_config.current_tpl_file=new_filepath
  table.insert(group_tpl_config.known_tpl_files,new_filepath)

  subtitle_group.save_config(group_tpl_config)
  subtitle_group.save_tpl(group_tpl_config.current_tpl_file
    ,{classname=subtitle_group.get_tpl_classname()})
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
      local names=subtitle_group.get_known_filenames(group_tpl_config)
      local default=subtitle_group.get_name_from_path(group_tpl_config.current_tpl_file)
      dropdown=bakery.layout.get_control(tpl_file_list,"tpl_files")
      dropdown.items=names
      dropdown.value=default
    elseif result.tpl_file_op == "创建模板文件"
    then
      local new_tpl_filename = aegisub.dialog.save(
        "选择创建的文件",
        "template.txt",
        bakery.env.config_root,
        subtitle_group.get_tpl_file_type(),
        false)
      if new_tpl_filename ~= nil
      then
        swith_tpl_file(new_tpl_filename)
      end
    elseif result.tpl_file_op == "从模板文件导入模板"
    then
      bakery.ui.dialog.warning("将会覆盖目前同名的模板！")
      local import_filename= aegisub.dialog.open(
        "选择导入的文件",
        "template.txt",
        bakery.env.config_root,
        subtitle_group.filetype,
        false)
      if import_filename ~= nil
      then
        imported_tpls=subtitle_group.load_tpl(import_filename)
        bakery.utils.merge_table_pairs(group_tpl_table,imported_tpls)
        modified=true
      end
    else
      local export_filename= aegisub.dialog.save(
        "选择导出文件",
        "template.txt",
        bakery.env.config_root,
        subtitle_group.filetype,
        false)
      if export_filename ~= nil
      then
        imported_tpls=subtitle_group.load_tpl(export_filename)
        bakery.utils.merge_table_pairs(group_tpl_table,imported_tpls)
        modified=true
      end
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

function group_tpl_macro(subtitles, selected_lines, active_line)
  subs=subtitles
  selections=selected_lines
  active=active_line

  style_names=bakery.utils.get_style_names(subs)

  bakery.ui.layout.get_control(tpl_edit_layout,"style").items=style_names

  group_tpl_config=subtitle_group.load_config()
  group_tpl_table=subtitle_group.load_tpl(group_tpl_config.current_tpl_file)

  group_tpl()

  if modified
  then
    subtitle_group.save_tpl(group_tpl_table)
  end
  quit_mod=false
  aegisub.set_undo_point(script_name)
end

function group_tpl_filter(subtitles, config)
end

aegisub.register_macro(script_name, script_description, group_tpl_macro)
aegisub.register_filter(script_name, script_description, 0, group_tpl_filter)
