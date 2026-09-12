class_name M3Palette
extends RefCounted
## ============================================================
## Material Design 3 风格色调板。
##
## 用 CIELAB 的 L* 作为「色调 tone」（这正是 MD3 里 tone 的定义），
## 固定色相 / 彩度、只改明度来取各级色调，比 HSV 的线性插值准得多。
## 某个色调在 sRGB 里超出色域时，自动逐步降低彩度直到落回色域。
##
## 纯静态计算，不需要实例化。
## ============================================================

const 白点X := 0.95047
const 白点Y := 1.0
const 白点Z := 1.08883


## 种子色的 LAB 色相角（弧度）
static func 色相(色: Color) -> float:
	var lab := 到LAB(色)
	return atan2(lab.z, lab.y)


## 种子色的 LAB 彩度
static func 彩度(色: Color) -> float:
	var lab := 到LAB(色)
	return sqrt(lab.y * lab.y + lab.z * lab.z)


## 取某个色调（0~100）的颜色；超出 sRGB 色域就自动降彩度
static func 取色调(色相角: float, 彩度值: float, 色调: float) -> Color:
	var 用彩度 := maxf(0.0, 彩度值)
	for _轮 in range(48):
		var lab := Vector3(色调, cos(色相角) * 用彩度, sin(色相角) * 用彩度)
		var 色 := 从LAB(lab)
		if 色.r >= -0.002 and 色.r <= 1.002 and 色.g >= -0.002 and 色.g <= 1.002 and 色.b >= -0.002 and 色.b <= 1.002:
			return Color(clampf(色.r, 0.0, 1.0), clampf(色.g, 0.0, 1.0), clampf(色.b, 0.0, 1.0))
		用彩度 *= 0.88
	# 兜底：灰阶
	return Color(色调 / 100.0, 色调 / 100.0, 色调 / 100.0)


# ---------------- 色彩空间换算（sRGB ↔ XYZ ↔ CIELAB，D65） ----------------
static func 到LAB(色: Color) -> Vector3:
	var r := _线性化(色.r)
	var g := _线性化(色.g)
	var b := _线性化(色.b)
	var x := r * 0.4124564 + g * 0.3575761 + b * 0.1804375
	var y := r * 0.2126729 + g * 0.7151522 + b * 0.0721750
	var z := r * 0.0193339 + g * 0.1191920 + b * 0.9503041
	var fx := _f(x / 白点X)
	var fy := _f(y / 白点Y)
	var fz := _f(z / 白点Z)
	return Vector3(116.0 * fy - 16.0, 500.0 * (fx - fy), 200.0 * (fy - fz))


static func 从LAB(lab: Vector3) -> Color:
	var fy := (lab.x + 16.0) / 116.0
	var fx := fy + lab.y / 500.0
	var fz := fy - lab.z / 200.0
	var x := 白点X * _f逆(fx)
	var y := 白点Y * _f逆(fy)
	var z := 白点Z * _f逆(fz)
	var r := x * 3.2404542 + y * -1.5371385 + z * -0.4985314
	var g := x * -0.9692660 + y * 1.8760108 + z * 0.0415560
	var b := x * 0.0556434 + y * -0.2040259 + z * 1.0572252
	return Color(_反线性(r), _反线性(g), _反线性(b))


static func _线性化(c: float) -> float:
	if c <= 0.04045:
		return c / 12.92
	return pow((c + 0.055) / 1.055, 2.4)


static func _反线性(c: float) -> float:
	if c <= 0.0031308:
		return c * 12.92
	return 1.055 * pow(maxf(c, 0.0), 1.0 / 2.4) - 0.055


static func _f(t: float) -> float:
	if t > 0.008856:
		return pow(t, 1.0 / 3.0)
	return (903.3 * t + 16.0) / 116.0


static func _f逆(t: float) -> float:
	var t3 := t * t * t
	if t3 > 0.008856:
		return t3
	return (116.0 * t - 16.0) / 903.3
