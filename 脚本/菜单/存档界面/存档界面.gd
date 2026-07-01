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

# =========================
# 初始化
# =========================
func _ready() -> void:
	刷新存档显示()


# =========================
# 获取按钮
# =========================
func 获取按钮(i: int) -> Button:
	return get_node("按钮组/保存加载按钮%d" % i)


func 获取标签(i: int, 子节点名: String) -> Label:
	return get_node("按钮组/保存加载按钮%d/%s" % [i, 子节点名])


# =========================
# 刷新存档UI
# =========================
func 刷新存档显示() -> void:

	var 槽位1 = 当前页数 * 3
	var 槽位2 = 槽位1 + 1
	var 槽位3 = 槽位1 + 2

	print("[信息] 当前页:", 当前页数)

	for i in range(1, 4):
		var btn = 获取按钮(i)
		btn.disabled = true
		获取标签(i, "主标签").text = "没有存档"
		获取标签(i, "标签").text = "存档 " + str(当前页数 * 3 + i - 1)

	# 1
	if save.检查槽位有无存档(槽位1):
		var d1 = save.加载指定槽位(槽位1) as 存档
		var b1 = 获取按钮(1)
		b1.disabled = false
		获取标签(1, "主标签").text = d1.最后游玩时间

	# 2
	if save.检查槽位有无存档(槽位2):
		var d2 = save.加载指定槽位(槽位2) as 存档
		var b2 = 获取按钮(2)
		b2.disabled = false
		获取标签(2, "主标签").text = d2.最后游玩时间

	# 3
	if save.检查槽位有无存档(槽位3):
		var d3 = save.加载指定槽位(槽位3) as 存档
		var b3 = 获取按钮(3)
		b3.disabled = false
		获取标签(3, "主标签").text = d3.最后游玩时间


# =========================
# 动画：移出（错峰并行）
# =========================
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


# =========================
# 翻页动画主逻辑
# =========================
func 执行翻页动画() -> void:
	允许翻页 = false

	var b1 = 获取按钮(1)
	var b2 = 获取按钮(2)
	var b3 = 获取按钮(3)

	# 根据方向决定移出目标位置和重置位置
	var 移出目标_x: float
	var 重置位置_x: float
	if 上一页:
		移出目标_x = 1146.0
		重置位置_x = -1146.0
	else:
		移出目标_x = -1146.0
		重置位置_x = 1146.0

	# 1) 移出动画（未使用的补间加 _ 前缀）
	var _t1 = 延迟移出(b1, Vector2(移出目标_x, 0), 0)
	var _t2 = 延迟移出(b2, Vector2(移出目标_x, 200), 按钮动画间隔)
	var t3_out = 延迟移出(b3, Vector2(移出目标_x, 400), 按钮动画间隔 * 2)
	await t3_out.finished

	# 2) 更新存档数据
	刷新存档显示()

	# 3) 将按钮挪到另一侧
	b1.position = Vector2(重置位置_x, 0)
	b2.position = Vector2(重置位置_x, 200)
	b3.position = Vector2(重置位置_x, 400)

	# 4) 移入动画（同样处理）
	var _i1 = 延迟移入(b1, Vector2(0, 0), 0)
	var _i2 = 延迟移入(b2, Vector2(0, 200), 按钮动画间隔)
	var t3_in = 延迟移入(b3, Vector2(0, 400), 按钮动画间隔 * 2)
	await t3_in.finished

	允许翻页 = true


# =========================
# 输入控制
# =========================
func _input(event: InputEvent) -> void:
	# ESC 关闭窗口 —— 不论是否允许翻页，都应该可以退出
	if event.is_action_pressed("ui_cancel"):
		关闭窗口()
		get_viewport().set_input_as_handled()
		return

	# 如果动画正在播放，禁止其他输入
	if not 允许翻页:
		get_viewport().set_input_as_handled()
		return

	# 鼠标按键处理
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
		
# =========================
# 翻页逻辑
# =========================
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


# =========================
# 点击存档
# =========================
func 按下_保存加载按钮1() -> void:
	读取存档(当前页数 * 3)


func 按下_保存加载按钮2() -> void:
	读取存档(当前页数 * 3 + 1)


func 按下_保存加载按钮3() -> void:
	读取存档(当前页数 * 3 + 2)



func 关闭窗口() -> void:
	var tween = create_tween()
	tween.tween_property(遮罩, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()


func 读取存档(槽位: int) -> void:
	遮罩.modulate = Color(0,0,0,0)   # 透明
	遮罩.show()
	var tween = create_tween().bind_node(遮罩)
	tween.tween_property(遮罩, "modulate", Color.BLACK, 0.2)
	await tween.finished
	save.切换槽位(槽位)
	var 数据资源 = save.加载()
	var 存档数据 = 数据资源 as 存档
	if 存档数据 == null:
		printerr("加载的文件不是有效的存档资源")
		return
	get_tree().change_scene_to_file(存档数据.最后游玩场景)
