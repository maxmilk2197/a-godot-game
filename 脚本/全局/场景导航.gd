extends Node
## ============================================================
## 场景导航（全局唯一，autoload 注册名：SceneNav）
## 集中管理主场景引用。各场景脚本只依赖这里（单向依赖）。
##
## 注意：必须用 load()（字面量路径）而【不要】用 preload。
## 若用 preload：SceneNav 会强制加载主界面 → 主界面脚本又访问
## SceneNav.设置 → 编译期互相解析 => 触发 Godot 的 cyclic reference。
## load() 不会建立这样强制的编译期依赖，能打破这个环。
## ============================================================

var 主界面: PackedScene = load("res://场景/主菜单/主界面.tscn")
var 设置: PackedScene = load("res://场景/主菜单/设置.tscn")
var 更多设置: PackedScene = load("res://场景/主菜单/更多设置.tscn")
var 关于: PackedScene = load("res://场景/主菜单/关于.tscn")
