# aegi-sub-backery
简单好用的Aegisub Automation lua增强库

## bakery库简介
bakery库的目的在于简化Automation插件的开发难度，大幅提升插件的弹性。

###bakery.lua
bakery库的总入口，如果不知道要包含哪个的话使用

###bakery-basic-ui.lua
bakery库的窗口排版及增强功能。模式参考自Android的Layout，使用时对table进行多层嵌套。
Layout目前包含Vertical和Horizontal两种模式，对应垂直布局与水平布局。
对于示例布局：
	登录 文本框
	密码 文本框
可用Layout表示为：
	{
		class="layout",
		orientation="vertical",
		items={
			{
				class="layout",
				orientation="horizontal",
				items={
					{登录label},
					{用户名textedit}
				}
			},
			{
				class="layout",
				orientation="horizontal",
				items={
					{密码label},
					{密码textedit}
				}
			}
		}
	}
Layout的重点在于使用时不需要手动计算控件的位置(*.x,*.y)，而是由bakery自动完成位置计算。

###bakery-env.lua
bakery库的运行环境参数

###bakery-locale.lua
bakery库的多语言识别及支持

###bakery-preference.lua
bakery库的插件设置保存工具

###bakery-utils.lua
bakery库的杂项工具

## autoload下是什么？
autoload内为个人编写的bakery及Automation使用示例，使用bakery时可进行参考

## 安装说明
将automation文件夹复制到Aegisub文件夹下，include文件夹内为bakery库文件