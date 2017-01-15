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
include("bakery-utils.lua")

bakery_layout_version="1.10"

--[[




  layout:




  {




    class="layout"




    type="grid/linear"  if dont have type then it's as linear




    unit_width=(1)  for grid layout




    unit_height=(1) for grid layout




    max_length=(10) for grid layout,relative to orientation




    orientation="vertical" or "horizontal" in grid layout means column first or row first




    items={




      {...},




      {...}




    }




  }




]]

bakery_layout={}

bakery_layout.get_control=function (layout,name)
  if layout.class ~= "layout"
  then
    return nil
  end

  local items=layout.items
  local queue={}
  for i=1,#items
  do
    if items[i].class == "layout"
    then
      table.insert(queue,items[i])
    elseif items[i].name == name
    then
      return items[i]
    end
  end
  for i=1,#queue
  do
    result=bakery_layout.get_control(queue[i],name)
    if result ~= nil
    then
      return result
    end
  end
end

bakery_layout.set_value=function (layout,name,value)
  bakery_layout.get_control(layout,name).value=value
end

bakery_layout.layout2dialog=function(layout)
  local dialog_config={}
  if layout.class == "layout"
  then
    local items=layout.items
    for i=1,#items
    do
      if items[i].class == "layout"
      then
        child_config=bakery_layout.layout2dialog(items[i])
        bakery_utils.merge_table(dialog_config,child_config)
      else
        table.insert(dialog_config,items[i])
      end
    end
  end
  return dialog_config
end

bakery_layout.move_layout=function(layout,offset_x,offset_y)
  if layout.class == "layout"
  then
    local items=layout.items
    for i=1,#items
    do
      if items[i].class == "layout"
      then
        bakery_layout.move_layout(items[i],offset_x,offset_y)
      else
        items[i].x = items[i].x + offset_x
        items[i].y = items[i].y + offset_y
      end
    end
  end
end

local compute_linear_layout_coordinate=function(linear_layout,offset_x,offset_y)
  if linear_layout.class ~= "layout"
  then
    return
  end

  local items=linear_layout.items

  local total_height=0
  local total_width=0

  local orientation=linear_layout.orientation

  for i=1,#items
  do
    if items[i].class == "layout"
    then
      child_width,child_height=bakery_layout.compute_layout_coordinate(items[i],offset_x,offset_y)
      if orientation == "vertical"
      then
        offset_y=offset_y+child_height
        total_height=total_height+child_height
        if child_width > total_width
        then
          total_width=child_width
        end
      else
        offset_x = offset_x + child_width
        total_width = total_width + child_width
        if child_height > total_height
        then
          total_height=child_height
        end
      end
    else
      items[i].x=offset_x
      items[i].y=offset_y

      if items[i].width == nil
      then
        items[i].width = 1
      end

      if items[i].height == nil
      then
        items[i].height = 1
      end

      if orientation == "vertical"
      then
        offset_y=offset_y+items[i].height
        total_height=total_height+items[i].height
        if items[i].width > total_width
        then
          total_width=items[i].width
        end
      else
        offset_x=offset_x+items[i].width
        total_width=total_width+items[i].width
        if items[i].height > total_height
        then
          total_height=items[i].height
        end
      end
    end
  end

  return total_width,total_height
end

local compute_grid_layout_coordinate=function(grid_layout,offset_x,offset_y)
  local items=grid_layout.items

  local total_height=0
  local total_width=0

  local unit_height=grid_layout.unit_height
  local unit_width=grid_layout.unit_width
  local orientation=grid_layout.orientation
  local max_length=grid_layout.max_length

  local split_count=math.ceil(#items/max_length)
  local i=0

  local scanner=0
  local step=0
  local ceil=0

  while i < split_count
  do
    step=i*max_length
    if orientation == "vertical"
    then
      scanner=offset_x
    else
      scanner=offset_y
    end

    if i < split_count - 1
    then
      ceil = max_length
    else
      ceil = #items - i*max_length
    end

    for j=1,ceil
    do
      if items[step+j].class == "layout"
      then
        if orientation == "vertical"
        then
          bakery_layout.compute_layout_coordinate(items[step+j],offset_x,scanner)
          scanner=scanner+unit_height
        else
          bakery_layout.compute_layout_coordinate(items[step+j],scanner,offset_y)
          scanner=scanner+unit_width
        end
      else
        if orientation == "vertical"
        then
          items[step+j].x=offset_x
          items[step+j].y=scanner
          scanner=scanner+unit_height
        else
          items[step+j].x=scanner
          items[step+j].y=offset_y
          scanner=scanner+unit_width
        end
      end
    end
    
    if orientation == "vertical"
    then
      offset_x=offset_x+unit_width
    else
      offset_y=offset_y+unit_height
    end
    i=i+1
  end

  if orientation == "vertical"
  then
    if #items < max_length
    then
      return unit_width , #items * unit_height
    else
      return split_count * unit_width , max_length * unit_height
    end
  else
    if #items < max_length
    then
      return #items * unit_width , unit_height
    else
      return max_length * unit_width , split_count * unit_height
    end
  end
end

bakery_layout.compute_layout_coordinate=function(layout,offset_x,offset_y)
  if layout.class ~= "layout"
  then
    return
  end

  if layout.type == "linear" or layout.type == nil
  then
    return compute_linear_layout_coordinate(layout,offset_x,offset_y)
  else
    return compute_grid_layout_coordinate(layout,offset_x,offset_y)
  end
end

return bakery_layout
