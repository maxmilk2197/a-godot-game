extends Node2D
## ============================================================
## 屋外世界 —— 2D 俯视走动底座
##
## 节点**全部是场景里的静态节点**，位置 / 范围 / 显示名 / 目标场景
## 都能在编辑器里直接调，本脚本只管逻辑：
##   · 相机（玩家子节点，严格同步，不在这里跟随）
##   · 交互提示的显示 / 隐藏
##   · 按交互键（空格 / 回车）进入目标场景
##   · 记住玩家离开时站的位置，回到屋外时原地出现
##
## 场景结构：
##   世界 (Node2D)
##   ├── 地面     TileMapLayer
##   ├── 边界     Node2D ── 上 / 下 / 左 / 右 (StaticBody2D)
##   ├── 玩家     CharacterBody2D（玩家.tscn 实例，出生点直接在场景里摆）
##   ├── 交互点   Node2D ── 家入口 / 便利店入口 (Area2D + 交互点.gd)
##   └── 玩家/相机 Camera2D（zoom 3，卡地图边界）
##   └── UI       CanvasLayer ── 回家按钮 / 便利店按钮 / 交互提示
##
## 分层约定：UI 层在 3D 化时不动，只替换场景层。
## ============================================================

@onready var 玩家: CharacterBody2D = $玩家
@onready var 提示: Label = $UI/交互提示
@onready var 地面: TileMapLayer = $地面
@onready var 萤火虫: GPUParticles2D = $萤火虫
@onready var 雨: GPUParticles2D = $雨
@onready var 雪: GPUParticles2D = $雪
@onready var 雾: ColorRect = $天气层/雾

## 当前站在哪个交互点的范围里（null = 不在任何门口）
var 当前交互点: Area2D = null

## 上一帧看到的时段 / 天气，用来发现变化
var _上次时段: String = ""
var _上次天气: String = ""

## 每种天气的雾层颜色与不透明度
const 天气雾色 := {
	"晴": Color(1.0, 1.0, 1.0, 0.00),
	"阴": Color(0.78, 0.80, 0.86, 0.16),
	"雨": Color(0.60, 0.68, 0.82, 0.22),
	"雪": Color(0.92, 0.95, 1.00, 0.14),
	"雾": Color(0.88, 0.92, 0.96, 0.40),
}


func _ready() -> void:
	_恢复位置()
	_刷新环境()

	var 容器 := get_node_or_null("交互点")
	if 容器 != null:
		for 点 in 容器.get_children():
			if 点.has_signal("玩家进入"):
				点.connect("玩家进入", _当进入交互区)
				点.connect("玩家离开", _当离开交互区)


# ---------------- 位置记忆 ----------------

## 回到屋外时，恢复上次离开的位置；没记录过就用场景里摆的出生点
func _恢复位置() -> void:
	if 玩家 == null:
		return
	var 位置 := Raise.屋外位置
	if 位置.x < 0.0 or 位置.y < 0.0:
		return
	玩家.global_position = 位置


## 离开屋外前把当前位置记进存档
func _记录位置() -> void:
	if 玩家 == null:
		return
	Raise.屋外位置 = 玩家.global_position
	Raise.保存()


# ---------------- 交互 ----------------

func _process(_增量: float) -> void:
	# 天气由「第二日时间过渡」每天掷一次，这里只跟着刷新画面
	if Raise.时段 != _上次时段 or Raise.天气 != _上次天气:
		_刷新环境()



## 统一刷新：夜晚色调（shader）+ 萤火虫 + 雨雪粒子 + 雾层
func _刷新环境() -> void:
	_上次时段 = Raise.时段
	_上次天气 = Raise.天气
	var 夜: bool = _上次时段 == "晚上"

	# 夜晚：用 shader 把瓦片换成冷蓝。modulate 做不到这个 ——
	# 草地蓝色分量本来就低，乘蓝色只会更暗，变不成蓝。
	if 地面 != null and 地面.material is ShaderMaterial:
		var 材质 := 地面.material as ShaderMaterial
		材质.set_shader_parameter("night_amount", 1.0 if 夜 else 0.0)
		材质.set_shader_parameter("night_gain", 0.55 if 夜 else 1.35)

	# 萤火虫：只有晴/阴的晚上才有，雨雪雾天不出现
	var 有萤火虫: bool = 夜 and (_上次天气 == "晴" or _上次天气 == "阴")
	if 萤火虫 != null:
		萤火虫.emitting = 有萤火虫
		萤火虫.visible = 有萤火虫

	# 雨 / 雪 粒子
	if 雨 != null:
		雨.emitting = _上次天气 == "雨"
		雨.visible = 雨.emitting
	if 雪 != null:
		雪.emitting =  _上次天气 == "雪"
		雪.visible = 雪.emitting

	# 雾层（晴 == 完全透明）
	if 雾 != null:
		var 色: Color = 天气雾色.get(_上次天气, Color(1, 1, 1, 0))
		if 夜:
			色 = Color(色.r * 0.55, 色.g * 0.65, 色.b * 0.85, 色.a)
		雾.color = 色


func _unhandled_input(事件: InputEvent) -> void:
	if 当前交互点 == null:
		return
	if 事件.is_action_pressed("interact") or 事件.is_action_pressed("ui_accept"):
		_进入交互点(当前交互点)


func _当进入交互区(点: Area2D) -> void:
	当前交互点 = 点
	提示.text = "按 E 进入「%s」" % str(点.get("显示名"))
	提示.visible = true


func _当离开交互区(点: Area2D) -> void:
	if 点 != 当前交互点:
		return
	当前交互点 = null
	提示.visible = false


func _进入交互点(点: Area2D) -> void:
	var 目标 := str(点.get("目标场景"))
	if 目标.is_empty():
		return
	_记录位置()
	get_tree().change_scene_to_file(目标)


# ---------------- 按钮出入口（移动端点击入口）----------------

func _on_回家按钮_pressed() -> void:
	_记录位置()
	get_tree().change_scene_to_file("res://场景/家/家.tscn")


func _on_便利店按钮_pressed() -> void:
	_记录位置()
	get_tree().change_scene_to_file("res://场景/屋外/便利店.tscn")
