class_name M3Motion
extends RefCounted
## ============================================================
## Material 3 动效令牌（时长 / 缓动 / 弹簧 / 状态层不透明度）。
##
## 数值来自两份一手实现：
##   · m3e（Material 3 Expressive，官方 sys token 名）—— 弹簧与状态层
##   · mdui 2 —— 时长与缓动（与 m3e 一致）
##
## 缓动是真·三次贝塞尔（等价 CSS cubic-bezier），不是 Godot 内置的近似曲线；
## 弹簧（spring）是 M3 Expressive 的特色，y 会略大于 1（带一点点过冲）。
## ============================================================

# ---------------- 时长（秒，--md-sys-motion-duration-*） ----------------
const 短1 := 0.05
const 短2 := 0.10
const 短3 := 0.15
const 短4 := 0.20
const 中1 := 0.25
const 中2 := 0.30
const 中3 := 0.35
const 中4 := 0.40
const 长1 := 0.45
const 长2 := 0.50
const 长3 := 0.55
const 长4 := 0.60
const 超长1 := 0.70
const 超长2 := 0.80
const 超长3 := 0.90
const 超长4 := 1.00

# ---------------- 弹簧时长（秒，M3 Expressive） ----------------
## 快速空间弹簧：位移/尺寸变化用，带过冲
const 弹簧_快_时长 := 0.35
## 默认空间弹簧
const 弹簧_默认_时长 := 0.50
## 慢速空间弹簧
const 弹簧_慢_时长 := 0.75
## 快速效果弹簧：颜色/透明度等“效果类”变化用，不过冲
const 弹簧_快_效果_时长 := 0.15
const 弹簧_默认_效果_时长 := 0.20
const 弹簧_慢_效果_时长 := 0.20

# ---------------- 状态层不透明度（--md-sys-state-*-state-layer-opacity） ----------------
const 状态_悬停 := 0.08
const 状态_聚焦 := 0.10
const 状态_按下 := 0.10
const 状态_拖动 := 0.16

# ---------------- 缓动（--md-sys-motion-easing-*） ----------------
## emphasized —— cubic-bezier(0.2, 0, 0, 1)
static func 强调(进度: float) -> float:
	return 三次贝塞尔(进度, 0.2, 0.0, 0.0, 1.0)


## emphasized-decelerate —— cubic-bezier(0.05, 0.7, 0.1, 1)
static func 强调减速(进度: float) -> float:
	return 三次贝塞尔(进度, 0.05, 0.7, 0.1, 1.0)


## emphasized-accelerate —— cubic-bezier(0.3, 0, 0.8, 0.15)
static func 强调加速(进度: float) -> float:
	return 三次贝塞尔(进度, 0.3, 0.0, 0.8, 0.15)


## standard —— cubic-bezier(0.2, 0, 0, 1)
static func 标准(进度: float) -> float:
	return 三次贝塞尔(进度, 0.2, 0.0, 0.0, 1.0)


## standard-decelerate —— cubic-bezier(0, 0, 0, 1)
static func 标准减速(进度: float) -> float:
	return 三次贝塞尔(进度, 0.0, 0.0, 0.0, 1.0)


## standard-accelerate —— cubic-bezier(0.3, 0, 1, 1)
static func 标准加速(进度: float) -> float:
	return 三次贝塞尔(进度, 0.3, 0.0, 1.0, 1.0)


# ---------------- 弹簧（--md-sys-motion-spring-*） ----------------
## 快速空间弹簧 —— cubic-bezier(0.27, 1.06, 0.18, 1)，350ms
static func 弹簧_快(进度: float) -> float:
	return 三次贝塞尔(进度, 0.27, 1.06, 0.18, 1.0)


## 默认空间弹簧 —— 同上曲线，500ms
static func 弹簧_默认(进度: float) -> float:
	return 三次贝塞尔(进度, 0.27, 1.06, 0.18, 1.0)


## 慢速空间弹簧 —— 同上曲线，750ms
static func 弹簧_慢(进度: float) -> float:
	return 三次贝塞尔(进度, 0.27, 1.06, 0.18, 1.0)


## 快速效果弹簧 —— cubic-bezier(0.31, 0.94, 0.34, 1)，150ms（不过冲）
static func 弹簧_快_效果(进度: float) -> float:
	return 三次贝塞尔(进度, 0.31, 0.94, 0.34, 1.0)


## 默认效果弹簧 —— cubic-bezier(0.34, 0.80, 0.34, 1)，200ms
static func 弹簧_默认_效果(进度: float) -> float:
	return 三次贝塞尔(进度, 0.34, 0.80, 0.34, 1.0)


## 慢速效果弹簧 —— cubic-bezier(0.34, 0.88, 0.34, 1)，200ms
static func 弹簧_慢_效果(进度: float) -> float:
	return 三次贝塞尔(进度, 0.34, 0.88, 0.34, 1.0)


## 线性
static func 线性(进度: float) -> float:
	return clampf(进度, 0.0, 1.0)


# ---------------- 三次贝塞尔求解 ----------------
## 等价 CSS cubic-bezier(x1, y1, x2, y2)：给定 x 求 y
static func 三次贝塞尔(进度: float, x1: float, y1: float, x2: float, y2: float) -> float:
	var x := clampf(进度, 0.0, 1.0)
	if x <= 0.0:
		return 0.0
	if x >= 1.0:
		return 1.0
	var t := x
	for _轮 in range(10):
		var 误差 := _贝塞尔(t, x1, x2) - x
		if absf(误差) < 0.0001:
			break
		var 斜率 := _贝塞尔导数(t, x1, x2)
		if absf(斜率) < 0.0001:
			break
		t = clampf(t - 误差 / 斜率, 0.0, 1.0)
	return _贝塞尔(t, y1, y2)


static func _贝塞尔(t: float, a1: float, a2: float) -> float:
	var u := 1.0 - t
	return 3.0 * u * u * t * a1 + 3.0 * u * t * t * a2 + t * t * t


static func _贝塞尔导数(t: float, a1: float, a2: float) -> float:
	var u := 1.0 - t
	return 3.0 * u * u * a1 + 6.0 * u * t * (a2 - a1) + 3.0 * t * t * (1.0 - a2)
