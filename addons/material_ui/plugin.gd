@tool
extends EditorPlugin
## ============================================================
## Material 3 UI Kit（GDScript 版）插件入口。
## 启用后自动注册 M3ThemeManager 单例（若项目里还没有）。
## 组件本身是通过 class_name 注册的，不启用插件也能用。
## ============================================================

const 单例名 := "M3ThemeManager"
const 单例路径 := "res://addons/material_ui/core/m3_theme_manager.gd"


func _enter_tree() -> void:
	if not ProjectSettings.has_setting("autoload/" + 单例名):
		add_autoload_singleton(单例名, 单例路径)


func _exit_tree() -> void:
	if ProjectSettings.has_setting("autoload/" + 单例名):
		remove_autoload_singleton(单例名)
