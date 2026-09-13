extends Control
## ============================================================
## 存档窗口公共基类
## 保存界面 / 加载界面共用的翻页、动画、滚轮输入逻辑都放这里，
## 子类只需要实现 填充单个按钮 和各自的槽位点击处理。
## ============================================================

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
## 最多允许排到「当前页」前后几页。
## 连滚时按这个把目标页排队（放完一页立刻翻下一页，不丢输入），
## 但也别排太长 —— 否则甩一下排一长队、松手了还在自己翻。
@export_range(1, 6, 1) var 预翻余量 : int = 2

# 翻页状态：动画播放中不再丢弃输入，而是把目标页往后排，放完立刻接着翻
var 目标页 : int = 0
var 正在翻页 : bool = false

# 滚轮：按 event.factor 累积，满一齿翻一页（高精度滚轮一次只给 0.1 也照样对）。
# 短去抖只用来吞掉「一个物理轮齿被系统拆成好几个事件」的情况。
const 滚轮去抖 := 0.04          # 秒，同一瞬间的重复事件合并
var 滚轮累积 := 0.0
var 上次滚轮时刻 := -INF

# 滑动翻页（触屏 + 鼠标拖动共用一套逻辑）
const 滑动阈值 := 80.0          # 画布像素，横向位移超过它才算一次滑动
var 滑动中 := false
var 滑动已用 := false           # 一次手势只翻一页
var 滑动起点 := Vector2.ZERO
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


# 填充一整屏（轮播克隆屏用）
func 填充按钮列表(按钮列表: Array, 起始槽位: int) -> void:
	for i in range(3):
		填充单个按钮(按钮列表[i] as Button, 起始槽位 + i)


# 子类实现各自的槽位显示逻辑（保存界面 / 加载界面不同）
func 填充单个按钮(_按钮: Button, _槽位: int) -> void:
	pass


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
	# 触屏模拟出来的鼠标事件直接跳过。
	# 项目没关 emulate_mouse_from_touch，一次触摸会同时发「触摸事件」和「模拟鼠标事件」，
	# 两条路都收的话一次滑动会被算两遍 —— 翻两页。
	# 模拟鼠标事件仍然会正常派发给 GUI，所以按钮点击不受影响。
	if (event is InputEventMouseButton or event is InputEventMouseMotion) \
			and event.device == InputEvent.DEVICE_ID_EMULATION:
		return

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

		# 按住左键拖动 = 用鼠标模拟滑动（PC 上也能翻，逻辑和触屏共用）
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				滑动开始(event.position)
			else:
				滑动结束(event.position)
			return

		# 滚轮翻页
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if not event.pressed:
				return
			get_viewport().set_input_as_handled()
			滚轮翻页(event.button_index == MOUSE_BUTTON_WHEEL_DOWN, event.factor)
			return

	if event is InputEventMouseMotion and 滑动中:
		滑动移动(event.position)
		return

	# ---- 触屏 ----
	if event is InputEventScreenTouch:
		if event.pressed:
			滑动开始(event.position)
		else:
			滑动结束(event.position)
		return

	if event is InputEventScreenDrag and 滑动中:
		滑动移动(event.position)
		return


# =========================
# 滚轮 / 滑动
# =========================
## 滚轮翻页。按 event.factor 累积（有些设备一次只给 0.1），满 1 齿翻一页。
## 关键是**动画期间也照收**：只更新目标页排队，当前这页放完立刻接着翻，
## 所以快速连滚不会「滚一半被吞掉、得停一下再滚」。
func 滚轮翻页(向下: bool, 因数: float) -> void:
	var 现在 := Time.get_ticks_msec() / 1000.0
	if 现在 - 上次滚轮时刻 < 滚轮去抖:
		return
	上次滚轮时刻 = 现在

	# factor 为 0 的设备兜底成 1 齿
	var 齿 := absf(因数)
	if 齿 <= 0.0:
		齿 = 1.0
	滚轮累积 += 齿 if 向下 else -齿

	while absf(滚轮累积) >= 1.0:
		var 向 := 1 if 滚轮累积 > 0.0 else -1
		滚轮累积 -= float(向)
		排队翻页(向)


## 排一页到目标页。目标从**当前目标**往上加，所以连滚会排队；
## 但最多只排到当前页前后 预翻余量 页，免得甩一下排一长队、松手了还在自己翻。
func 排队翻页(方向: int) -> void:
	if 方向 == 0:
		return
	目标页 = clampi(目标页 + 方向,
		maxi(0, 当前页数 - 预翻余量),
		mini(最大页数, 当前页数 + 预翻余量))
	推进翻页()


func 滑动开始(位置: Vector2) -> void:
	滑动中 = true
	滑动已用 = false
	滑动起点 = 位置


func 滑动移动(位置: Vector2) -> void:
	if not 滑动中 or 滑动已用:
		return
	if _判滑动(位置):
		get_viewport().set_input_as_handled()


func 滑动结束(位置: Vector2) -> void:
	if 滑动中 and not 滑动已用:
		_判滑动(位置)
	滑动中 = false


## 横向位移够了就翻一页（往左滑 = 下一页，和轮播方向一致）。
## 纵向位移更大就不算 —— 免得斜着滑也触发。
func _判滑动(位置: Vector2) -> bool:
	var 位移 := 位置 - 滑动起点
	if absf(位移.x) < M3Theme.px(滑动阈值) or absf(位移.x) <= absf(位移.y):
		return false
	滑动已用 = true
	排队翻页(1 if 位移.x < 0.0 else -1)
	return true


# =========================
# 翻页逻辑
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
	# 保险：正常情况下动画期间滚动被锁，目标页不会变；万一不一致就补翻到一致
	if 目标页 != 当前页数:
		推进翻页()


# =========================
# 关闭窗口
# =========================
func 关闭窗口() -> void:
	var tween = create_tween()
	tween.tween_property(遮罩, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()