extends Control
#region 声名变量
@export var 过渡类型 : Tween.TransitionType = Tween.TRANS_QUAD
@export var 缓动类型 : Tween.EaseType = Tween.EASE_IN_OUT

@onready var 遮罩 = $"遮罩"

var 当前页数 : int = 0
var 最大页数 : int = 6

# 翻页动画节奏参数 —— 带范围滑块，可在检查器的“翻页动画节奏”分组里直接拖动微调
@export_category("翻页动画节奏")
@export_range(0.05, 0.5, 0.01) var 运动时长 : float = 0.22   ## 单个按钮平移的运动时间（越大越慢）
@export_range(0.05, 0.5, 0.01) var 渐变时长 : float = 0.18   ## 按钮淡入淡出时间
@export_range(0.0, 0.3, 0.01) var 按钮动画间隔 : float = 0.06 ## 三个按钮错峰的间隔（越大越有层次）

# 滚轮翻页采用“目标页”队列模型：动画进行中滚动不丢失，翻完自动补翻，跟手不掉
var 目标页 : int = 0
var 正在翻页 : bool = false

# 滚轮去抖：一个物理轮齿常被系统拆成多个 WHEEL 事件，同一波连续滚动只翻一页
const 去抖时间 := 0.15          # 去抖窗口（秒）
var 本波开始时间 := -INF        # 当前这波滚动的开始时刻
var 本波已翻页 := false         # 这一波是否已经翻过一页
#endregion

# =========================
# 初始化
# =========================
func _ready() -> void:
	目标页 = 当前页数
	刷新存档显示()


func 获取按钮(i: int) -> Button:
	return get_node("按钮组/保存加载按钮%d" % i)


# =========================
# 刷新存档UI
# =========================
func 刷新存档显示() -> void:
	for i in range(1, 4):
		填充单个按钮(获取按钮(i), 当前页数 * 3 + (i - 1))


# 填充单个按钮的槽位数据（刷新与轮播克隆屏共用）
func 填充单个按钮(按钮: Button, 槽位: int) -> void:
	var 标签 = 按钮.get_node("标签") as Label
	var 主标签 = 按钮.get_node("主标签") as Label

	# 槽位 0 是自动存档档：禁止覆盖
	if 槽位 == 0:
		标签.text = "自动存档"
		主标签.text = "禁止覆盖"
		按钮.disabled = true
		return

	标签.text = "存档 " + str(槽位)
	主标签.text = "空"
	按钮.disabled = false

	# 若该槽位已有存档，则显示存档信息
	if save.检查槽位有无存档(槽位):
		var d = save.加载指定槽位(槽位)
		# JSON 读档后数字是 float，天数显示前转回整数
		主标签.text = "第 " + str(int(d.get("游玩天数", 0))) + " 天 · " + str(d.get("最后游玩时间", "占"))


# 填充一整屏（轮播克隆屏用）
func 填充按钮列表(按钮列表: Array, 起始槽位: int) -> void:
	for i in range(3):
		填充单个按钮(按钮列表[i] as Button, 起始槽位 + i)


# =========================
# 动画
# =========================
# 轮播平移单个按钮：从 起始a 平滑滑到 目标位置
func 延迟滑(按钮: Control, 目标位置: Vector2, 延迟: float, 起始a: float) -> Tween:
	按钮.modulate.a = 起始a
	var tween = create_tween().bind_node(按钮)
	tween.tween_interval(延迟)
	tween.tween_property(按钮, "position", 目标位置, 运动时长)\
		.set_trans(过渡类型)\
		.set_ease(缓动类型)
	tween.parallel().tween_property(按钮, "modulate:a", 1.0 - 起始a, 渐变时长)
	return tween


# 翻页动画（轮播式：旧屏滑出 + 新屏从另一侧同步滑入，全程无全空、无瞬移）
func 执行翻页动画(方向: int) -> void:
	var 旧按钮 := [获取按钮(1), 获取按钮(2), 获取按钮(3)]
	# 记录每个按钮此刻的静止位置（锚点布局算出的真实坐标）
	var 静止位 := {}
	for i in range(3):
		静止位[i] = 旧按钮[i].position

	# 滑出距离：略大于视口宽度，保证完全滑出屏幕外
	var 偏移 := get_viewport_rect().size.x + 100.0

	# 1) 克隆一组“新屏”按钮载入下一页数据，先放到屏幕外
	var 新按钮 := []
	for i in range(3):
		var 克隆 = 旧按钮[0].duplicate() as Control
		$"按钮组".add_child(克隆)
		克隆.position = 静止位[i] + Vector2(方向 * 偏移, 0)
		新按钮.append(克隆)
	填充按钮列表(新按钮, 当前页数 * 3)

	# 2) 同步相向滑动：旧屏滑出 + 新屏从另一侧滑入（两边一直在动）
	var 旧屏补间: Array = []
	for i in range(3):
		旧屏补间.append(延迟滑(旧按钮[i], 静止位[i] - Vector2(方向 * 偏移, 0), 按钮动画间隔 * i, 1.0))
	var 新屏补间: Array = []
	for i in range(3):
		新屏补间.append(延迟滑(新按钮[i], 静止位[i], 按钮动画间隔 * i, 0.0))

	# 等新屏完全到位（最慢的那个 = 间隔最大，即最后一个）
	await (新屏补间[2] as Tween).finished

	# 3) 收尾：移除克隆屏，旧按钮放回原位并刷新为下一页数据（无缝衔接）
	for 按钮 in 新按钮:
		按钮.queue_free()
	for i in range(3):
		旧按钮[i].position = 静止位[i]
		旧按钮[i].modulate.a = 1.0
	刷新存档显示()


# =========================
# 输入控制
# =========================
func _input(event: InputEvent) -> void:
	# ESC 关闭窗口 —— 始终可用
	if event.is_action_pressed("ui_cancel"):
		关闭窗口()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		# 右键关闭
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			关闭窗口()
			get_viewport().set_input_as_handled()
			return

		# 滚轮翻页：带时间去抖，同一波连续滚动只翻一页，避免连翻、跟手不掉
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if not event.pressed:
				return
			get_viewport().set_input_as_handled()

			var 现在 := Time.get_ticks_msec() / 1000.0

			# 超过去抖窗口 => 视为新的一波滚动，重置“本波已翻页”
			if 现在 - 本波开始时间 > 去抖时间:
				本波开始时间 = 现在
				本波已翻页 = false

			# 这一波已经翻过一页就忽略后续事件（防止一个轮齿触发多次）
			if 本波已翻页:
				return

			本波已翻页 = true
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				目标页 = max(0, 目标页 - 1)
			else:
				目标页 = min(最大页数, 目标页 + 1)
			推进翻页()


# =========================
# 翻页逻辑（目标页队列：连翻不掉）
# =========================
func 推进翻页() -> void:
	# 正在翻页时：目标页已记录，等当前这页放完会自动继续
	if 正在翻页:
		return
	if 目标页 == 当前页数:
		return

	正在翻页 = true

	# 由 目标页-当前页 决定方向（+1 下一页，-1 上一页）
	var 方向 := 1 if 目标页 > 当前页数 else -1
	当前页数 = clamp(当前页数 + 方向, 0, 最大页数)
	$"页码".text = str(当前页数) + " / " + str(最大页数)

	await 执行翻页动画(方向)

	# 动画期间窗口可能已被关闭（ESC/右键），此时直接退出
	if not is_inside_tree():
		return

	正在翻页 = false
	# 动画期间可能又有新的滚动目标，继续补翻直到与目标一致
	if 目标页 != 当前页数:
		推进翻页()


# =========================
# 点击存档
# =========================
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

	var 当前场景路径 = get_tree().current_scene.scene_file_path

	# 存档里带上养成数据（心情/好感/体力/金币/时段/行动点），
	# 这样读档时养成进度能完整恢复
	var 数据 = {
		"游玩天数": Raise.游玩天数,
		"最后游玩时间": "%d月%d日 %02d:%02d" % [月, 日, 时, 分],
		"最后游玩场景": 当前场景路径,
		"上次存档": 槽位,
		"心情": Raise.心情,
		"好感": Raise.好感,
		"体力": Raise.体力,
		"金币": Raise.金币,
		"时段": Raise.时段,
		"剩余行动点": Raise.剩余行动点,
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