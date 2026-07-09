extends Node

var 设备是否为移动设备: bool = false

# 当前运行中的存档（内存）
var 当前存档: 存档 = null

var 开发者模式: bool = false
var 是否为编辑器运行: bool = false


func _ready() -> void:
	if OS.has_feature("android") or OS.has_feature("ios"):
		设备是否为移动设备 = true
		print("[信息]当前设备为移动设备")

	if OS.has_feature("editor"):
		是否为编辑器运行 = true
