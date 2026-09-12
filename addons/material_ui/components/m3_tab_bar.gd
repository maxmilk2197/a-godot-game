@tool
class_name M3TabBar
extends HBoxContainer
## ============================================================
## Material 3 标签栏：把若干 M3Tab 放进来，自动做互斥选中。
## 切换时发出 切换(索引)。
## ============================================================

signal 切换(索引: int)

@export var 当前索引: int = 0:
	set(值):
		当前索引 = 值
		_应用()


func _ready() -> void:
	add_theme_constant_override("separation", int(round(4 * M3Theme.scale)))
	_接线()
	_应用()
	if not child_entered_tree.is_connected(_子节点加入):
		child_entered_tree.connect(_子节点加入)


func _子节点加入(节点: Node) -> void:
	var 标签 := 节点 as M3Tab
	if 标签 == null:
		return
	if not 标签.toggled.is_connected(_某个标签切换):
		标签.toggled.connect(_某个标签切换.bind(标签))


func _接线() -> void:
	for 节点 in get_children():
		var 标签 := 节点 as M3Tab
		if 标签 == null:
			continue
		if not 标签.toggled.is_connected(_某个标签切换):
			标签.toggled.connect(_某个标签切换.bind(标签))


func _某个标签切换(按下: bool, 标签: M3Tab) -> void:
	if 按下:
		var 列表 := _标签列表()
		var 位置 := 列表.find(标签)
		if 位置 >= 0 and 位置 != 当前索引:
			当前索引 = 位置
		切换.emit(当前索引)
	else:
		# 至少保持一个选中
		标签.set_pressed_no_signal(true)
	_应用()


func _标签列表() -> Array[M3Tab]:
	var 结果: Array[M3Tab] = []
	for 节点 in get_children():
		var 标签 := 节点 as M3Tab
		if 标签 != null:
			结果.append(标签)
	return 结果


func _应用() -> void:
	var 列表 := _标签列表()
	if 列表.is_empty():
		return
	var 目标 := clampi(当前索引, 0, 列表.size() - 1)
	for i in range(列表.size()):
		列表[i].选中 = (i == 目标)
