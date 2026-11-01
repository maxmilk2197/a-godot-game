extends Area2D
## ============================================================
## 屋外交互入口（挂在 Area2D 上）
## 显示名、目标场景都在检查器里填，不用改代码。
## 玩家进入 / 离开范围时发信号给世界脚本。
## ============================================================

## 提示里显示的名字，比如「家」「便利店」
@export var 显示名: String = "入口"
## 进入后切换到的场景（检查器里可以直接选 .tscn）
@export_file("*.tscn") var 目标场景: String = ""

signal 玩家进入(点: Area2D)
signal 玩家离开(点: Area2D)


func _ready() -> void:
	if not body_entered.is_connected(_当进入):
		body_entered.connect(_当进入)
	if not body_exited.is_connected(_当离开):
		body_exited.connect(_当离开)


func _当进入(体: Node2D) -> void:
	if 体 is CharacterBody2D:
		玩家进入.emit(self)


func _当离开(体: Node2D) -> void:
	if 体 is CharacterBody2D:
		玩家离开.emit(self)
