extends Control
#region 声名变量
@export var 过渡类型 : Tween.TransitionType = Tween.TRANS_QUAD
@export var 缓动类型 : Tween.EaseType = Tween.EASE_IN_OUT

@onready var 遮罩 = $"遮罩"

var 当前页数 : int = 0
var 最大页数 : int = 6

var 按钮动画间隔 : float = 0.08
@export var 运动时长 : float = 0.1
@export var 渐变时长 : float = 0.15

var 允许翻页 : bool = true
var 翻页冷却 : bool = false
var 上一页 : bool = false
#endregion

func _ready() -> void:
	刷新存档显示()


func 获取按钮(i: int) -> Button:
	return get_node("按钮组/保存加载按钮%d" % i)


func 获取标签(i: int, 子节点名: String) -> Label:
	return get_node("按钮组/保存加载按钮%d/%s" % [i, 子节点名])


func 刷新存档显示() -> void:
	var 槽位1 = 当前页数 * 3
	var 槽位2 = 槽位1 + 1
	var 槽位3 = 槽位1 + 2

	for i in range(1, 4):
		var btn = 获取按钮(i)
		btn.disabled = true
		获取标签(i, "主标签").text = "空"
		获取标签(i, "标签").text = "存档 " + str(当前页数 * 3 + i - 1)

	_刷新槽位(1, 槽位1)
	_刷新槽位(2, 槽位2)
	_刷新槽位(3, 槽位3)


func _刷新槽位(按钮编号: int, 槽位: int) -> void:
	if 槽位 == 0:
		获取标签(按钮编号, "标签").text = "自动存档"
		获取标签(按钮编号, "主标签").text = "禁止覆盖"
		return

	获取标签(按钮编号, "标签").text = "存档 " + str(槽位)
	var btn = 获取按钮(按钮编号)
	btn.disabled = false

	if save.检查槽位有无存档(槽位):
		var d = save.加载指定槽位(槽位)
		获取标签(按钮编号, "主标签").text = d.get("最后游玩时间", "占")


func 延迟移出(按钮: Button, 目标位置: Vector2, 延迟: float) -> Tween:
	var tween = create_tween()
	tween.tween_interval(延迟)
	tween.tween_property(按钮, "position", 目标位置, 运动时长)\
		.set_trans(过渡类型)\
		.set_ease(缓动类型)
	tween.parallel().tween_property(按钮, "modulate:a", 0.0, 渐变时长)
	return tween


func 延迟移入(按钮: Button, 目标位置: Vector2, 延迟: float) -> Tween:
	按钮.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_interval(延迟)
	tween.tween_property(按钮, "position", 目标位置, 运动时长)\
		.set_trans(过渡类型)\
		.set_ease(缓动类型)
	tween.parallel().tween_property(按钮, "modulate:a", 1.0, 渐变时长 - 0.1)
	return tween


func 执行翻页动画() -> void:
	允许翻页 = false
	var b1 = 获取按钮(1)
	var b2 = 获取按钮(2)
	var b3 = 获取按钮(3)

	var 移出目标_x: float
	var 重置位置_x: float
	if 上一页:
		移出目标_x = 1146.0
		重置位置_x = -1146.0
	else:
		移出目标_x = -1146.0
		重置位置_x = 1146.0

	var _t1 = 延迟移出(b1, Vector2(移出目标_x, 0), 0)
	var _t2 = 延迟移出(b2, Vector2(移出目标_x, 200), 按钮动画间隔)
	var t3_out = 延迟移出(b3, Vector2(移出目标_x, 400), 按钮动画间隔 * 2)
	await t3_out.finished

	刷新存档显示()

	b1.position = Vector2(重置位置_x, 0)
	b2.position = Vector2(重置位置_x, 200)
	b3.position = Vector2(重置位置_x, 400)

	var _i1 = 延迟移入(b1, Vector2(0, 0), 0)
	var _i2 = 延迟移入(b2, Vector2(0, 200), 按钮动画间隔)
	var t3_in = 延迟移入(b3, Vector2(0, 400), 按钮动画间隔 * 2)
	await t3_in.finished

	允许翻页 = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		关闭窗口()
		get_viewport().set_input_as_handled()
		return

	if not 允许翻页:
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			关闭窗口()
			get_viewport().set_input_as_handled()
			return

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			上一页 = true
			翻页()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			上一页 = false
			翻页()


func 翻页() -> void:
	if 翻页冷却:
		return
	翻页冷却 = true
	var 旧页 = 当前页数
	if 上一页:
		当前页数 = max(0, 当前页数 - 1)
	else:
		当前页数 = min(最大页数, 当前页数 + 1)
	if 旧页 == 当前页数:
		翻页冷却 = false
		return
	$"页码".text = str(当前页数) + " / " + str(最大页数)
	await 执行翻页动画()
	翻页冷却 = false


func 按下_保存加载按钮1() -> void:
	_保存到槽位(当前页数 * 3)


func 按下_保存加载按钮2() -> void:
	_保存到槽位(当前页数 * 3 + 1)


func 按下_保存加载按钮3() -> void:
	_保存到槽位(当前页数 * 3 + 2)


func _保存到槽位(槽位: int) -> void:
	if 槽位 == 0:
		return

	var 当前时间字典 = Time.get_datetime_dict_from_system()
	var 月 = 当前时间字典.month
	var 日 = 当前时间字典.day
	var 时 = 当前时间字典.hour
	var 分 = 当前时间字典.minute

	var 已有数据 = save.加载指定槽位(槽位)
	var 游玩天数 = 已有数据.get("游玩天数", 0)
	# 如果槽位已有数据且与当前存档同一槽位，累加天数
	if save.检查槽位有无存档(槽位) and 槽位 == save.当前存档:
		pass  # 保持已有天数
	elif not save.检查槽位有无存档(槽位):
		游玩天数 = 0 if 槽位 != save.当前存档 else save.加载().get("游玩天数", 0)

	var 当前场景路径 = get_tree().current_scene.scene_file_path

	var 数据 = {
		"游玩天数": 游玩天数,
		"最后游玩时间": "%d月%d日 %02d:%02d" % [月, 日, 时, 分],
		"最后游玩场景": 当前场景路径,
		"上次存档": 槽位,
		"ai_memory": {"_global": save.当前AI记忆()},
	}
	save.保存指定槽位(槽位, 数据)

	聊天数据.复制到槽位(槽位)

	遮罩.modulate = Color(0, 0, 0, 0)
	遮罩.show()
	var tween = create_tween().bind_node(遮罩)
	tween.tween_property(遮罩, "modulate", Color.WHITE, 0.15)
	await tween.finished
	遮罩.modulate = Color(0, 0, 0, 0)
	遮罩.hide()

	刷新存档显示()


func 关闭窗口() -> void:
	var tween = create_tween()
	tween.tween_property(遮罩, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()
