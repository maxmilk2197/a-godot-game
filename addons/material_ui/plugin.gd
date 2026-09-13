@tool
extends EditorPlugin
## ============================================================
## Material 3 UI Kit（GDScript 版）插件入口。
## 启用后会：
##   1. 自动注册 M3ThemeManager 单例（若项目里还没有）
##   2. 把涟漪参数登记进「项目设置 → m3」，不用改代码就能全局调
## 组件本身是通过 class_name 注册的，不启用插件也能用
## （只是项目设置里那几项不会出现，全局值就取 M3Theme 里的默认）。
## ============================================================

const 单例名 := "M3ThemeManager"
const 单例路径 := "res://addons/material_ui/core/m3_theme_manager.gd"

## 项目设置里暴露的涟漪参数：键 -> [默认值, 范围提示]
## 默认值照 Material Web 官方 ripple（生长 450 / 淡入 105 / 淡出 375 / 最小按压 225 ms）。
## 这几个就是「一个地方改、所有按钮都跟着变」的地方；
## 单个按钮想不一样，在按钮的「涟漪」分组里把对应项设成 0 或正数即可（-1 = 跟随全局）。
const 项目设置表 := {
	"m3/ripple/opacity": [0.55, "0,1,0.01"],
	"m3/ripple/grow_duration": [0.45, "0.05,3,0.005"],
	"m3/ripple/fade_in_duration": [0.105, "0,1,0.005"],
	"m3/ripple/fade_out_duration": [0.375, "0,2,0.005"],
	"m3/ripple/minimum_press": [0.225, "0,2,0.005"],
}


func _enter_tree() -> void:
	_注册项目设置()
	if not ProjectSettings.has_setting("autoload/" + 单例名):
		add_autoload_singleton(单例名, 单例路径)


func _exit_tree() -> void:
	if ProjectSettings.has_setting("autoload/" + 单例名):
		remove_autoload_singleton(单例名)


## 登记进项目设置，这样在 项目设置 面板里就能看到并修改（保存在 project.godot）
func _注册项目设置() -> void:
	for 键 in 项目设置表.keys():
		var 项: Array = 项目设置表[键]
		if not ProjectSettings.has_setting(键):
			ProjectSettings.set_setting(键, 项[0])
		ProjectSettings.add_property_info({
			"name": 键,
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": 项[1],
		})
		ProjectSettings.set_initial_value(键, 项[0])
