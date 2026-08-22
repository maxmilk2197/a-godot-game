extends Node
## ============================================================
## 音量设置（全局唯一，autoload 注册名：Audio）
## 负责音乐/音效两条总线的音量调节与持久化保存。
## 用法：
##   Audio.音乐音量 = 0.8        # 0.0 ~ 1.0
##   Audio.音效音量 = 0.6
##   Audio.读取设置()            # 启动时自动调用，恢复上次的音量
## ============================================================

const 设置路径 := "user://audio_settings.cfg"
const 音乐总线名 := "Music"
const 音效总线名 := "SFX"
const 保存延迟 := 0.5  ## 拖动滑块会连续触发 setter，停手 0.5 秒后才写盘一次

## 线性音量 0.0 ~ 1.0（对外统一用这个，内部转 dB）
var 音乐音量: float = 1.0:
	set(值):
		音乐音量 = clampf(值, 0.0, 1.0)
		_应用总线音量(音乐总线名, 音乐音量)

var 音效音量: float = 1.0:
	set(值):
		音效音量 = clampf(值, 0.0, 1.0)
		_应用总线音量(音效总线名, 音效音量)

var _保存定时器: Timer
## 读取配置期间置真，避免 setter 触发写文件
var _读取中 := false


func _ready() -> void:
	_确保总线()

	_保存定时器 = Timer.new()
	_保存定时器.one_shot = true
	_保存定时器.wait_time = 保存延迟
	_保存定时器.timeout.connect(_立刻保存)
	add_child(_保存定时器)

	读取设置()


func _exit_tree() -> void:
	# 退出游戏时若还有未落盘的改动，立即保存
	if _保存定时器 and not _保存定时器.is_stopped():
		_立刻保存()


## 确保 Music / SFX 两条总线存在（重复调用安全）
## 正常情况下总线由 res://default_bus_layout.tres 提供，这里只是兜底
func _确保总线() -> void:
	for 总线名 in [音乐总线名, 音效总线名]:
		if AudioServer.get_bus_index(总线名) == -1:
			var 新位 := AudioServer.get_bus_count()
			AudioServer.add_bus(新位)
			AudioServer.set_bus_name(新位, 总线名)
			AudioServer.set_bus_send(新位, "Master")


## 把线性音量写到总线（改 dB + 静音），读取配置时不触发保存
func _应用总线音量(总线名: String, 音量: float) -> void:
	_确保总线()
	var 总线 := AudioServer.get_bus_index(总线名)
	AudioServer.set_bus_volume_db(总线, linear_to_db(音量))
	AudioServer.set_bus_mute(总线, 音量 <= 0.0)
	if not _读取中:
		_延迟保存()


## 从配置文件恢复音量
func 读取设置() -> void:
	_读取中 = true
	var cfg := ConfigFile.new()
	if cfg.load(设置路径) == OK:
		音乐音量 = cfg.get_value("音量", "音乐", 1.0)
		音效音量 = cfg.get_value("音量", "音效", 1.0)
	else:
		音乐音量 = 1.0
		音效音量 = 1.0
	_读取中 = false


## 把当前音量写入配置文件（对外接口，内部走延迟合并）
func 保存设置() -> void:
	_延迟保存()


func _延迟保存() -> void:
	if _保存定时器 == null:  # _ready 之前就被赋值的情况，直接落盘
		_立刻保存()
		return
	_保存定时器.stop()
	_保存定时器.start()


func _立刻保存() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("音量", "音乐", 音乐音量)
	cfg.set_value("音量", "音效", 音效音量)
	cfg.save(设置路径)
