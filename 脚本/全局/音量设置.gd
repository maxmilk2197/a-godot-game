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

## 线性音量 0.0 ~ 1.0（对外统一用这个，内部转 dB）
var 音乐音量: float = 1.0:
	set(值):
		音乐音量 = clampf(值, 0.0, 1.0)
		_确保总线()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(音乐总线名), linear_to_db(音乐音量))
		AudioServer.set_bus_mute(AudioServer.get_bus_index(音乐总线名), 音乐音量 <= 0.0)
		保存设置()

var 音效音量: float = 1.0:
	set(值):
		音效音量 = clampf(值, 0.0, 1.0)
		_确保总线()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(音效总线名), linear_to_db(音效音量))
		AudioServer.set_bus_mute(AudioServer.get_bus_index(音效总线名), 音效音量 <= 0.0)
		保存设置()


func _ready() -> void:
	_确保总线()
	读取设置()


## 确保 Music / SFX 两条总线存在（重复调用安全）
func _确保总线() -> void:
	for 总线名 in [音乐总线名, 音效总线名]:
		if AudioServer.get_bus_index(总线名) == -1:
			var 新位 := AudioServer.get_bus_count()
			AudioServer.add_bus(新位)
			AudioServer.set_bus_name(新位, 总线名)
			AudioServer.set_bus_send(新位, "Master")


## 从配置文件恢复音量
func 读取设置() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(设置路径) != OK:
		音乐音量 = 1.0
		音效音量 = 1.0
		return
	音乐音量 = cfg.get_value("音量", "音乐", 1.0)
	音效音量 = cfg.get_value("音量", "音效", 1.0)


## 把当前音量写入配置文件
func 保存设置() -> void:
	var cfg := ConfigFile.new()
	cfg.load(设置路径)
	cfg.set_value("音量", "音乐", 音乐音量)
	cfg.set_value("音量", "音效", 音效音量)
	cfg.save(设置路径)