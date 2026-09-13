@tool
class_name M3Icons
extends RefCounted
## ============================================================
## 取 Material Design Icons 的字体字形。
##
## 图标来自项目里的 **Godot-Material-Icons** 插件
## （`addons/material-design-icons/`，Templarian 的 MaterialDesign 图标集）。
## 这里**不用**它注册的 `MaterialIconsDB` 自动加载 —— 那个是编辑器插件装的，
## 导出/没打开过编辑器时不一定在。这里自己把字体和图标表读进来，稳一点。
##
## 为什么用字体而不是 SVG：字形是用 `draw_string` 画的，颜色直接跟着前景色走，
## 不像图标贴图那样要靠 modulate **相乘**（有色 SVG 乘深色前景会变黑）。
##
## 插件没装也不会炸：`可用()` 返回 false，调用方自己退化成贴图或纯文字。
##
## 名字去哪查：编辑器菜单 **工具 → Find Material Icon**（插件装的），
## 或者在 `addons/material-design-icons/icons/icons.json` 里搜。
## ============================================================

const 字体路径 := "res://addons/material-design-icons/fonts/material_design_icons.ttf"
const 图标表路径 := "res://addons/material-design-icons/icons/icons.json"

static var _字体: FontFile = null
static var _表: Dictionary = {}
static var _读过了 := false


## 这套图标在不在
static func 可用() -> bool:
	_确保读取()
	return _字体 != null


## 图标字体（拿不到返回 null）
static func 字体() -> FontFile:
	_确保读取()
	return _字体


## 名字 → 码点（没这个图标返回 0）
static func 取码(名: String) -> int:
	if 名.is_empty():
		return 0
	_确保读取()
	return int(_表.get(名, 0))


## 名字 → 字符（直接 draw_string 用；没这个图标返回空串）
static func 取字符(名: String) -> String:
	var 码 := 取码(名)
	if 码 <= 0:
		return ""
	return String.chr(码)


## 有没有这个名字的图标
static func 有(名: String) -> bool:
	return 取码(名) > 0


static func _确保读取() -> void:
	if _读过了:
		return
	_读过了 = true
	if ResourceLoader.exists(字体路径):
		var f := load(字体路径)
		if f is FontFile:
			_字体 = f
	# 图标表是普通 JSON，FileAccess 读就行（导出时记得把 *.json 加进包含文件）
	if FileAccess.file_exists(图标表路径):
		var 文 := FileAccess.get_file_as_string(图标表路径)
		if not 文.is_empty():
			var j := JSON.new()
			if j.parse(文) == OK and j.data is Dictionary:
				for k in (j.data as Dictionary).keys():
					var 十六: String = String(j.data[k]).to_lower()
					var 码 := ("0x" + 十六).hex_to_int()
					if 码 > 0:
						_表[String(k)] = 码


## 名字列表 → 字符列表（给调试用）
static func 批量取字符(名表: PackedStringArray) -> PackedStringArray:
	var 出 := PackedStringArray()
	for 名 in 名表:
		出.append(取字符(名))
	return 出
