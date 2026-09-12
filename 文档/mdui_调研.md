# mdui 调研报告 —— 用于 Godot M3 组件库的行为/参数对齐

> 调研对象：**mdui 2.1.5**（Material Design 3 / Material You 的 Web Components 实现）
> 调研日期：本次会话
> 调研方法：本机 `github.com` / `raw.githubusercontent.com` 不可达，但 `cdn.jsdelivr.net`、`api.github.com`、`data.jsdelivr.com` 可达。
> 因此本报告**全部结论来自真实源码**：已把 `mdui@2.1.5` 的 npm 包用 jsdelivr 完整镜像到本地 `.mdui_cache/`（147 个组件 JS + 145 个 `.d.ts` + `mdui.css` + `custom-elements.json`），并逐条 grep 出数值，再与官方文档交叉验证。
>
> **可信度说明**：凡是标注具体数值/代码的地方，都是直接从源码文件里抄出来的原文；凡未能核实的，明确写「未能核实」，不做推测填充。

---

## 1. 项目概况

| 项 | 值 | 来源 |
|---|---|---|
| 名称 | mdui | [package.json](https://cdn.jsdelivr.net/npm/mdui@2.1.5/package.json) |
| 当前最新版 | **2.1.5**（tag `latest`） | [data.jsdelivr.com](https://data.jsdelivr.com/v1/packages/npm/mdui) |
| 作者 | zdhxiong（zdhxiong@gmail.com） | package.json / LICENSE |
| License | **MIT**（Copyright (c) 2016-present zdhxiong@gmail.com） | [LICENSE](https://cdn.jsdelivr.net/npm/mdui@2.1.5/LICENSE) |
| 描述 | Material Design 3(Material You) UI components using Web Components. | GitHub API |
| Star 数 | **4523** | `api.github.com/repos/zdhxiong/mdui` |
| Fork | 376；open issues 38 | 同上 |
| 主语言 | **TypeScript** | 同上 |
| 创建时间 | 2016-07-11 | 同上 |
| 最近 push | **2026-07-21**；`updated_at` 2026-09-12 | 同上 |
| 最新 release | **v2.1.5，2026-07-14** | `api.github.com/repos/zdhxiong/mdui/releases` |
| 官网 | https://www.mdui.org | 同上 |
| Topics | css, javascript, material, material-design, material-design-3, material-you, web-components | 同上 |

**维护状态**：活跃但节奏较慢。大版本 2.0.0 之后，2.0.x 密集发布，2.1.0（2024-04）→ 2.1.5（2026-07）间隔较长，属「稳定维护、低频发版」。不是弃坑状态。

### 依赖（决定了它的能力边界）

来自 [package.json](https://cdn.jsdelivr.net/npm/mdui@2.1.5/package.json)：

- `lit` ^3.3.0 / `@lit/reactive-element` / `@lit/localize` —— Web Components 基座 + 本地化
- **`@material/material-color-utilities` ^0.3.0** —— 动态配色（种子色→整套配色）的算法来源，**这是 Google 官方库**
- `@floating-ui/utils` ^0.2.10 —— tooltip/menu/dropdown 的定位计算
- `@mdui/jq`、`@mdui/shared`、`@mdui/icons-shared` —— 作者自己拆出的内部包
- 无框架依赖（Vue/React 都能用）

### mdui 1 与 mdui 2 的区别

官方文档明确写着（见 [mdui 1 文档首页](https://www.mdui.org/zh-cn/docs/1/) 顶部横幅）：

> 「基于 Material Design 3 和 Web Components 的全新 mdui 2 现已发布」

两者的实质差异（据文档结构与仓库语言实测）：

| 维度 | mdui 1（1.0.2） | mdui 2（2.1.5） |
|---|---|---|
| 设计规范 | Material Design **2** | Material Design **3 / Material You** |
| 技术栈 | CSS 类名 + `mdui.$`（自研 jQuery 风格 DOM 库）+ JS 插件 | **Web Components**（Lit + TypeScript） |
| 用法 | `<button class="mdui-btn mdui-btn-raised">` | `<mdui-button variant="filled">` |
| 配色 | 预置 CSS 变量主题，手选主色 | **动态配色**：任意种子色/图片自动生成整套 scheme |
| 组件名 | button/fab/select/panel/tab/toolbar/appbar/drawer/bottom_nav… | 见第 2 节（命名更贴近 MD3 词汇：top-app-bar、navigation-bar…） |
| JS 工具库 | 有 `mdui.$`、`mdui.JQ`（0.4.3 更名到 1.0.0） | 改为 ES 模块函数 `setTheme`/`setColorScheme`/`dialog`/`snackbar`… |

**注意**：mdui 2 **没有**沿用 mdui 1 的 `mdui.$` 体系，2.x 依赖的是拆出去的独立 `@mdui/jq` 包。1→2 是**重写**，不是增量升级。

> 未能核实：mdui 1 与 2 都**没有**提供「1→2 迁移指南」页面（`https://www.mdui.org/zh-cn/docs/2/migration` 返回 404，实测）。官方只有 0.4.3→1.0.0 的迁移文档。

---

## 2. 完整组件清单（v2.1.5）

来源：本地镜像的 [`custom-elements.json`](https://cdn.jsdelivr.net/npm/mdui@2.1.5/custom-elements.json)（Custom Elements Manifest）。共 **46 个已注册自定义元素**，外加内部使用的 `mdui-ripple`（未登记在 manifest，但 [components/ripple/index.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/ripple/index.js) 中 `customElement('mdui-ripple')` 可证）→ 实际 **47 个**。

「我们」列 = `D:\sister\addons\material_ui\` 现有组件。

### 2.1 我们已有的

| mdui 元素 | 一句话说明 | 我们对应 |
|---|---|---|
| `mdui-button` | 按钮，5 种 variant | `M3Button` |
| `mdui-card` | 卡片，elevated/filled/outlined | `M3Card` |
| `mdui-divider` | 分隔线，支持 vertical/inset/middle | `M3Divider` |
| `mdui-badge` | 徽标（小圆点/带文本） | `M3Badge` |
| `mdui-circular-progress` | 环形进度（确定/不定） | `M3ProgressIndicator`(CIRCULAR) |
| `mdui-linear-progress` | 线性进度（确定/不定） | `M3ProgressIndicator`(LINEAR) |
| `mdui-switch` | 开关 | `M3Switch` |
| `mdui-checkbox` | 复选框（含 indeterminate） | `M3Checkbox` |
| `mdui-radio` + `mdui-radio-group` | 单选框 + 单选组 | `M3RadioButton` |
| `mdui-slider` + `mdui-range-slider` | 单值/区间滑块 | `M3Slider`（仅单值） |
| `mdui-text-field` | 文本框，filled/outlined | `M3TextField` |
| `mdui-tabs` + `mdui-tab` + `mdui-tab-panel` | 选项卡组/项/面板 | `M3TabBar` + `M3Tab` |
| `mdui-tooltip` | 工具提示，plain/rich | `M3Tooltip` |
| `mdui-navigation-bar` + `-item` | 底部导航栏 | `M3NavigationBar` |
| `mdui-navigation-rail` + `-item` | 侧边导航栏 | `M3NavigationRail` |
| `mdui-navigation-drawer` | 抽屉导航 | `M3NavigationDrawer` |
| `mdui-ripple` | 涟漪效果（内部组件，被各组件复用） | `M3Ripple` |
| （无） | —— | `M3Surface`、`M3ScrollStretch`（**mdui 没有对应物**） |

### 2.2 我们**没有**的（重点补齐候选）

| mdui 元素 | 一句话说明 |
|---|---|
| `mdui-button-icon` | 图标按钮，standard/filled/tonal/outlined，可 selectable |
| `mdui-fab` | 浮动操作按钮，primary/surface/secondary/tertiary × normal/small/large，可 extended |
| `mdui-chip` | 标签/纸片，assist/filter/input/suggestion |
| `mdui-dialog` | 对话框，含 overlay / 全屏 / stacked-actions |
| `mdui-menu` + `mdui-menu-item` | 菜单 + 菜单项，支持子菜单、单选/多选 |
| `mdui-snackbar` | 消息条（轻提示 + 操作按钮） |
| `mdui-segmented-button` + `-group` | 分段按钮 + 组，单选/多选 |
| `mdui-select` | 下拉选择，filled/outlined |
| `mdui-dropdown` | 下拉容器（任意内容 + 定位） |
| `mdui-collapse` + `mdui-collapse-item` | 折叠面板，可 accordion |
| `mdui-top-app-bar` + `mdui-top-app-bar-title` | 顶部应用栏，center-aligned/small/medium/large |
| `mdui-bottom-app-bar` | 底部应用栏（可挂 FAB） |
| `mdui-list` + `mdui-list-item` + `mdui-list-subheader` | 列表 + 列表项 + 小标题 |
| `mdui-avatar` | 头像（图片/文字/图标） |
| `mdui-icon` | Material Icons 图标（字体图标载体） |
| `mdui-layout` + `-item` + `-main` | 应用骨架布局容器 |

> 我们额外有的、mdui 没有的：**`M3Surface`（面）**、**`M3ScrollStretch`（滚动拉伸）**。这两个是 Godot 侧特有需求，无可对齐对象。

---

## 3. 色彩系统

### 3.1 变量命名与切换机制

来源：[mdui.css](https://cdn.jsdelivr.net/npm/mdui@2.1.5/mdui.css) + [官方设计令牌文档](https://www.mdui.org/zh-cn/docs/2/styles/design-tokens)

每个颜色角色生成 **3 个** CSS 变量：

```css
--mdui-color-{name}-light   /* 浅色模式的值，如 103, 80, 164 */
--mdui-color-{name}-dark    /* 深色模式的值 */
--mdui-color-{name}         /* 别名：浅色下指向 -light，深色下指向 -dark */
```

值是 **R,G,B 三段数字**（不带 `rgb()`），使用时必须自己包 `rgb()` / `rgba()`：

```css
background-color: rgb(var(--mdui-color-primary));
background-color: rgba(var(--mdui-color-primary), 0.8);
```

**深浅色切换靠 class，不是一个变量**：

| class | 效果 | 来源 |
|---|---|---|
| `.mdui-theme-light` / `:root` | 全部 `--mdui-color-{name}` 指向 `-light` | mdui.css |
| `.mdui-theme-dark` | 全部指向 `-dark`，并设 `color-scheme:dark` | mdui.css |
| `.mdui-theme-auto` | 同样指向 `-dark`，但**由 JS 按 `prefers-color-scheme` 决定是否加这个 class** | mdui.css + setTheme.js |

JS 入口：[functions/setTheme.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/functions/setTheme.js)

```js
setTheme(theme, target = document.documentElement)
// theme: 'light' | 'dark' | 'auto'，通过 addClass/removeClass('mdui-theme-'+theme)
```

`getTheme()` 默认返回 `'light'`（未设置过时）。

### 3.2 完整颜色变量名列表（37 个，含浅/深默认值）

以下为**全部**颜色角色，值已从 mdui.css 抄录，并与官方文档表格逐条核对一致。

| 颜色名（中文） | 变量 | light 默认值 | dark 默认值 |
|---|---|---|---|
| Primary | `--mdui-color-primary` | `103, 80, 164` | `208, 188, 255` |
| Primary container | `--mdui-color-primary-container` | `234, 221, 255` | `79, 55, 139` |
| On primary | `--mdui-color-on-primary` | `255, 255, 255` | `55, 30, 115` |
| On primary container | `--mdui-color-on-primary-container` | `33, 0, 94` | `234, 221, 255` |
| Inverse primary | `--mdui-color-inverse-primary` | `208, 188, 255` | `103, 80, 164` |
| Secondary | `--mdui-color-secondary` | `98, 91, 113` | `204, 194, 220` |
| Secondary container | `--mdui-color-secondary-container` | `232, 222, 248` | `74, 68, 88` |
| On secondary | `--mdui-color-on-secondary` | `255, 255, 255` | `51, 45, 65` |
| On secondary container | `--mdui-color-on-secondary-container` | `30, 25, 43` | `232, 222, 248` |
| Tertiary | `--mdui-color-tertiary` | `125, 82, 96` | `239, 184, 200` |
| Tertiary container | `--mdui-color-tertiary-container` | `255, 216, 228` | `99, 59, 72` |
| On tertiary | `--mdui-color-on-tertiary` | `255, 255, 255` | `73, 37, 50` |
| On tertiary container | `--mdui-color-on-tertiary-container` | `55, 11, 30` | `255, 216, 228` |
| Surface | `--mdui-color-surface` | `254, 247, 255` | `20, 18, 24` |
| Surface dim | `--mdui-color-surface-dim` | `222, 216, 225` | `20, 18, 24` |
| Surface bright | `--mdui-color-surface-bright` | `254, 247, 255` | `59, 56, 62` |
| Surface container lowest | `--mdui-color-surface-container-lowest` | `255, 255, 255` | `15, 13, 19` |
| Surface container low | `--mdui-color-surface-container-low` | `247, 242, 250` | `29, 27, 32` |
| Surface container | `--mdui-color-surface-container` | `243, 237, 247` | `33, 31, 38` |
| Surface container high | `--mdui-color-surface-container-high` | `236, 230, 240` | `43, 41, 48` |
| Surface container highest | `--mdui-color-surface-container-highest` | `230, 224, 233` | `54, 52, 59` |
| Surface variant | `--mdui-color-surface-variant` | `231, 224, 236` | `73, 69, 79` |
| On surface | `--mdui-color-on-surface` | `28, 27, 31` | `230, 225, 229` |
| On surface variant | `--mdui-color-on-surface-variant` | `73, 69, 78` | `202, 196, 208` |
| Inverse surface | `--mdui-color-inverse-surface` | `49, 48, 51` | `230, 225, 229` |
| Inverse on surface | `--mdui-color-inverse-on-surface` | `244, 239, 244` | `49, 48, 51` |
| Background | `--mdui-color-background` | `254, 247, 255` | `20, 18, 24` |
| On background | `--mdui-color-on-background` | `28, 27, 31` | `230, 225, 229` |
| Error | `--mdui-color-error` | `179, 38, 30` | `242, 184, 181` |
| Error container | `--mdui-color-error-container` | `249, 222, 220` | `140, 29, 24` |
| On error | `--mdui-color-on-error` | `255, 255, 255` | `96, 20, 16` |
| On error container | `--mdui-color-on-error-container` | `65, 14, 11` | `249, 222, 220` |
| Outline | `--mdui-color-outline` | `121, 116, 126` | `147, 143, 153` |
| Outline variant | `--mdui-color-outline-variant` | `196, 199, 197` | `68, 71, 70` |
| Shadow | `--mdui-color-shadow` | `0, 0, 0` | `0, 0, 0` |
| Surface tint | `--mdui-color-surface-tint-color` | `103, 80, 164` | `208, 188, 255` |
| Scrim | `--mdui-color-scrim` | `0, 0, 0` | `0, 0, 0` |

> 两点注意：
> 1. **`surface-tint-color`** 这个命名带 `-color` 后缀，与其它 token 的命名风格不一致（容易误写成 `surface-tint`）。官方文档表格里叫「Surface tint」，变量名同样是 `--mdui-color-surface-tint-color`。
> 2. `on-surface-variant` 的 **light 是 `73, 69, 78`**（注意末位是 **78**），**dark 是 `202, 196, 208`**；而 `surface-variant` 的 dark 是 `73, 69, 79`（末位 **79**）。两组数字只差一位、极易混淆，已从 `mdui.css` 实测确认。

**组件级局部变量**：`--mdui-comp-ripple-state-layer-color` —— 各组件用它声明「我的涟漪/状态层用什么颜色」，ripple 里以 `var(--mdui-comp-ripple-state-layer-color, var(--mdui-color-on-surface))` 兜底。这是一个很值得抄的模式（见第 5 节）。

### 3.3 种子色 / 动态配色 / 从图片取色

来源：[internal/colorScheme.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/internal/colorScheme.js)、[functions/setColorScheme.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/functions/setColorScheme.js)、[functions/getColorFromImage.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/functions/getColorFromImage.js)

**核心算法来自 Google 官方 `@material/material-color-utilities`**，不是自己写的：

```js
const schemes = {
  light: Scheme.light(source).toJSON(),
  dark:  Scheme.dark(source).toJSON(),
};
```

`Scheme.light/dark(source)` 里 `source` 是 **ARGB int**（`argbFromHex('#f82506')`）。

**关键实现细节 —— 它手工补了官方库缺失的 8 个 token**（源码里有 `todo` 注释，指向 material-color-utilities issue #98）：

```js
const palette = CorePalette.of(source);
// 浅色
'surface-dim':                  palette.n1.tone(87),
'surface-bright':               palette.n1.tone(98),
'surface-container-lowest':     palette.n1.tone(100),
'surface-container-low':        palette.n1.tone(96),
'surface-container':            palette.n1.tone(94),
'surface-container-high':       palette.n1.tone(92),
'surface-container-highest':    palette.n1.tone(90),
'surface-tint-color':           schemes.light.primary,
// 深色
'surface-dim':                  palette.n1.tone(6),
'surface-bright':               palette.n1.tone(24),
'surface-container-lowest':     palette.n1.tone(4),
'surface-container-low':        palette.n1.tone(10),
'surface-container':            palette.n1.tone(12),
'surface-container-high':       palette.n1.tone(17),
'surface-container-highest':    palette.n1.tone(22),
'surface-tint-color':           schemes.dark.primary,
```

> 这组 **tone 数值（87/98/100/96/94/92/90 与 6/24/4/10/12/17/22）是极有参考价值的一手数据**——MD3 官方规范里 surface container 系列没有给出明确 tone，mdui 这组是实际在用的取值。

**自定义扩展色**（`customColors` 选项）：对每个自定义色调 `customColor(source, {name, value, blend: true})`，生成 4 个变量：

```
--mdui-color-{name}
--mdui-color-on-{name}
--mdui-color-{name}-container
--mdui-color-on-{name}-container
```

**DOM 落地方式**：生成一个 `<style id="mdui-custom-color-scheme-{source}-{n}">` 插到 `<head>`，内容是该 class 下的全部 light/dark 变量，然后给 target 加这个 class。深色覆盖靠：

```css
.mdui-theme-dark .{class}, .mdui-theme-dark.{class} { /* 用 -dark */ }
@media (prefers-color-scheme: dark) {
  .mdui-theme-auto .{class}, .mdui-theme-auto.{class} { /* 用 -dark */ }
}
```

**从图片取色**：

```js
export const getColorFromImage = async (image) => {
  const source = await sourceColorFromImage($(image)[0]);
  return hexFromArgb(source);
};
```

即：先用官方库的 `sourceColorFromImage` 从图片提取主色，再喂给 `setColorScheme`。官方文档页面里确实有「从壁纸提取颜色」的交互演示（见[设计令牌页](https://www.mdui.org/zh-cn/docs/2/styles/design-tokens)）。

---

## 4. 动效参数（重点，全部为源码实测值）

### 4.1 统一动效 token

mdui **有**一套完整的统一动效 token，定义在 [mdui.css](https://cdn.jsdelivr.net/npm/mdui@2.1.5/mdui.css) 的 `:root`。**时长** 16 档：

| 变量 | 值 | 变量 | 值 |
|---|---|---|---|
| `--mdui-motion-duration-short1` | **50ms** | `--mdui-motion-duration-long1` | **450ms** |
| `--mdui-motion-duration-short2` | **100ms** | `--mdui-motion-duration-long2` | **500ms** |
| `--mdui-motion-duration-short3` | **150ms** | `--mdui-motion-duration-long3` | **550ms** |
| `--mdui-motion-duration-short4` | **200ms** | `--mdui-motion-duration-long4` | **600ms** |
| `--mdui-motion-duration-medium1` | **250ms** | `--mdui-motion-duration-extra-long1` | **700ms** |
| `--mdui-motion-duration-medium2` | **300ms** | `--mdui-motion-duration-extra-long2` | **800ms** |
| `--mdui-motion-duration-medium3` | **350ms** | `--mdui-motion-duration-extra-long3` | **900ms** |
| `--mdui-motion-duration-medium4` | **400ms** | `--mdui-motion-duration-extra-long4` | **1000ms** |

**缓动** 7 档：

| 变量 | 值 |
|---|---|
| `--mdui-motion-easing-linear` | `cubic-bezier(0, 0, 1, 1)` |
| `--mdui-motion-easing-standard` | `cubic-bezier(0.2, 0, 0, 1)` |
| `--mdui-motion-easing-standard-accelerate` | `cubic-bezier(0.3, 0, 1, 1)` |
| `--mdui-motion-easing-standard-decelerate` | `cubic-bezier(0, 0, 0, 1)` |
| `--mdui-motion-easing-emphasized` | **`var(--mdui-motion-easing-standard)`**（即别名，等于 `cubic-bezier(0.2, 0, 0, 1)`） |
| `--mdui-motion-easing-emphasized-accelerate` | `cubic-bezier(0.3, 0, 0.8, 0.15)` |
| `--mdui-motion-easing-emphasized-decelerate` | `cubic-bezier(0.05, 0.7, 0.1, 1)` |

> **重要发现 1**：mdui 的 `--mdui-motion-easing-emphasized` **不是** MD3 规范里那条独立曲线，而是**直接等于 standard**。MD3 规范中 emphasized 是一条 M3 特有的三段贝塞尔（约 `cubic-bezier(0.2, 0.0, 0, 1.0)` 的近似，规范给的是 `0.2, 0, 0, 1` 的「两段」形式）——mdui 这里做了简化。
>
> **重要发现 2**：mdui **没有**任何弹簧（spring）token。`--mdui-motion-spring-*` 完全不存在（我 grep 了全部 217 个 `--mdui-*` 变量名，无 spring）。**M3 Expressive 的弹簧是我们这边独有的扩展**，mdui 无对应物，不要试图从它对齐。

总变量数：217 个 `--mdui-*`（含 37 色 ×3 + 15 typescale ×4 + 上述 motion/shape/elevation/state-layer/breakpoint）。

### 4.2 涟漪 ripple（源码级完整还原）

来源：[components/ripple/style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/ripple/style.js) + [components/ripple/index.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/ripple/index.js)

**CSS 原文（逐字抄录）：**

```css
.surface{position:absolute;top:0;left:0;width:100%;height:100%;
  transition-duration:280ms;transition-property:background-color;pointer-events:none;
  transition-timing-function:var(--mdui-motion-easing-standard)}
.hover{background-color:rgba(var(--mdui-comp-ripple-state-layer-color,var(--mdui-color-on-surface)),var(--mdui-state-layer-hover))}
:host-context([focus-visible]) .focused{background-color:rgba(var(--mdui-comp-ripple-state-layer-color,var(--mdui-color-on-surface)),var(--mdui-state-layer-focus))}
.dragged{background-color:rgba(var(--mdui-comp-ripple-state-layer-color,var(--mdui-color-on-surface)),var(--mdui-state-layer-dragged))}

.wave{position:absolute;z-index:1;
  background-color:rgb(var(--mdui-comp-ripple-state-layer-color,var(--mdui-color-on-surface)));
  border-radius:50%;transform:translate3d(0,0,0) scale(.4);opacity:0;
  animation:225ms ease 0s 1 normal forwards running mdui-comp-ripple-radius-in,
            75ms  ease 0s 1 normal forwards running mdui-comp-ripple-opacity-in;
  pointer-events:none}
.out{transform:translate3d(var(--mdui-comp-ripple-transition-x,0),var(--mdui-comp-ripple-transition-y,0),0) scale(1);
  animation:150ms ease 0s 1 normal none running mdui-comp-ripple-opacity-out}

@keyframes mdui-comp-ripple-radius-in{
  from{transform:translate3d(0,0,0) scale(.4);animation-timing-function:var(--mdui-motion-easing-standard)}
  to{transform:translate3d(var(--mdui-comp-ripple-transition-x,0),var(--mdui-comp-ripple-transition-y,0),0) scale(1)}}
@keyframes mdui-comp-ripple-opacity-in{
  from{opacity:0;animation-timing-function:linear}
  to{opacity:var(--mdui-state-layer-pressed)}}
@keyframes mdui-comp-ripple-opacity-out{
  from{animation-timing-function:linear;opacity:var(--mdui-state-layer-pressed)}
  to{opacity:0}}
```

**核心参数汇总：**

| 项 | 值 |
|---|---|
| 扩散（半径）时长 | **225ms** |
| 扩散缓动 | `--mdui-motion-easing-standard` = `cubic-bezier(0.2, 0, 0, 1)` |
| 起始缩放 | **`scale(0.4)`** |
| 淡入时长 | **75ms**，`linear` |
| **不透明度峰值** | **`var(--mdui-state-layer-pressed)` = 0.12** |
| 淡出时长 | **150ms**，`linear` |
| 表面背景色过渡 | **280ms**，`standard` |

> 注意 CSS 的 `animation` 简写里写的是 `ease`，但两个 `@keyframes` 内部都用 `animation-timing-function` 覆盖成了真正的缓动（`standard` / `linear`），**实际生效的是 keyframes 内的声明**，`ease` 只是占位。

**JS 定位/尺寸逻辑（index.js `startPress`）：**

```js
const touchStartX = touchPosition.pageX - offset.left;   // 相对 surface 的点击点
const touchStartY = touchPosition.pageY - offset.top;

// 涟漪直径 = max(surface 对角线长度, 48)
const diameter = Math.max(Math.sqrt(surfaceHeight**2 + surfaceWidth**2), 48);

// 位移量：把圆的中心从点击点移到 surface 中心
const translateX = `${-touchStartX + surfaceWidth / 2}px`;
const translateY = `${-touchStartY + surfaceHeight / 2}px`;
```

元素样式：

```js
.css({
  width: diameter, height: diameter,
  marginTop: -diameter / 2, marginLeft: -diameter / 2,  // 以点击点为圆心
  left: touchStartX, top: touchStartY,
})
```

- **未传事件对象时**：从 surface 中心扩散（`touchStartX = w/2, touchStartY = h/2`）。
- **点击位置在 surface 外**：直接 return，不播放。
- 通过 `wave.clientLeft` 强制重绘后再设 `transform`，保证动画重启。

**按住/松开行为：**

- `startPress` → `.wave` 元素插入，两个动画并行。
- `animationend` 且 `animationName === 'mdui-comp-ripple-radius-in'` → 打标记 `data('filled', true)`（**表示扩散已完成**）。
- `endPress`：
  - 标记为 `removing`（防止重复）；
  - **若扩散未完成**（没有 `filled`）→ 挂 `animationend` 监听，等扩散跑完再 `hideAndRemove`；
  - **若扩散已完成** → 立刻 `hideAndRemove`。
- `hideAndRemove` = 加 `.out` class → 强制重绘 → 等 `animationend` → `remove()` 元素。

即：**轻点会先把扩散补完再淡出；长按则保持满幅、松开直接淡出。** 且**同一按钮可同时存在多个 wave 元素**（多点触控/连点会叠加多条涟漪）。

**状态层与阴影分工**（源码注释原文）：

> 「处理点击时的涟漪动画；及添加 hover、focused、dragged 的背景色。背景色通过在 `.surface` 元素上添加对应的 class 实现。阴影在 ripple-mixin 中处理。」

### 4.3 circular-progress 的 `@keyframes` 原文

来源：[components/circular-progress/style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/circular-progress/style.js)

```css
.indeterminate{font-size:0;letter-spacing:0;white-space:nowrap;
  animation:mdui-comp-circular-progress-rotate 1568ms var(--mdui-motion-easing-linear) infinite}
.indeterminate .layer{animation:mdui-comp-circular-progress-layer-rotate 5332ms var(--mdui-motion-easing-standard) infinite both}
.indeterminate .clipper.left  .circle{animation:mdui-comp-circular-progress-left-spin  1333ms var(--mdui-motion-easing-standard) infinite both}
.indeterminate .clipper.right .circle{animation:mdui-comp-circular-progress-right-spin 1333ms var(--mdui-motion-easing-standard) infinite both}

@keyframes mdui-comp-circular-progress-rotate{to{transform:rotate(360deg)}}
@keyframes mdui-comp-circular-progress-layer-rotate{
  12.5%{transform:rotate(135deg)}  25%{transform:rotate(270deg)}
  37.5%{transform:rotate(405deg)}  50%{transform:rotate(540deg)}
  62.5%{transform:rotate(675deg)}  75%{transform:rotate(810deg)}
  87.5%{transform:rotate(945deg)}  100%{transform:rotate(1080deg)}}
@keyframes mdui-comp-circular-progress-left-spin{0%{transform:rotate(265deg)} 50%{transform:rotate(130deg)} 100%{transform:rotate(265deg)}}
@keyframes mdui-comp-circular-progress-right-spin{0%{transform:rotate(-265deg)} 50%{transform:rotate(-130deg)} 100%{transform:rotate(-265deg)}}
```

**确定进度：**

```css
.determinate svg{transform:rotate(-90deg);fill:transparent}   /* 从 12 点方向起 */
.determinate .circle{stroke:inherit;
  transition:stroke-dashoffset var(--mdui-motion-duration-long2) var(--mdui-motion-easing-standard)}  /* 500ms */
```

元素结构（关键）：`gap-patch`（`left:47.5%; width:5%`）、`clipper.left/right`（各 `width:50%`，`circle` 宽 `200%`）。这是经典的 Material 双半圆遮罩方案。

**汇总：**

| 项 | 值 |
|---|---|
| 容器整圈旋转 | **1568ms**，`linear`，无限 |
| layer 旋转（补齐角速度） | **5332ms**，`standard`，1080°/周期（恰好 3 圈） |
| 左/右半圆伸缩 | **1333ms**，`standard`，`265° ↔ 130°` |
| 确定进度弧长过渡 | **500ms**（long2），`standard` |

> 1568 : 5332 ≈ 1 : 3.4，5332/1568 = 3.4，而 layer 一个周期转 3 圈；两者叠加后容器净转速 ≈ 1568ms/圈 + 5332/3 ≈ 1777ms/圈的等效效果。**我们目前的实现是「周期 1.33s + 附加 0.6 圈」，这是自创的近似，与 mdui 的 1568/5332/1333 组合不是同一套数学。**

### 4.4 linear-progress 的 `@keyframes` 原文

来源：[components/linear-progress/style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/linear-progress/style.js)

```css
.determinate{height:100%;
  transition:width var(--mdui-motion-duration-long2) var(--mdui-motion-easing-standard)}  /* 500ms */
.indeterminate::before{position:absolute;top:0;bottom:0;left:0;background-color:inherit;
  animation:mdui-comp-progress-indeterminate 2s var(--mdui-motion-easing-linear) infinite;content:' '}
.indeterminate::after{position:absolute;top:0;bottom:0;left:0;background-color:inherit;
  animation:mdui-comp-progress-indeterminate-short 2s var(--mdui-motion-easing-linear) infinite;content:' '}

@keyframes mdui-comp-progress-indeterminate{
  0%{left:0;width:0}  50%{left:30%;width:70%}  75%{left:100%;width:0}}
@keyframes mdui-comp-progress-indeterminate-short{
  0%{left:0;width:0}  50%{left:0;width:0}  75%{left:0;width:25%}  100%{left:100%;width:0}}
```

**汇总：**

| 项 | 值 |
|---|---|
| 不定进度：两条光带，周期 | **2s**，`linear`，无限 |
| 主带 `progress-indeterminate` | 0%: `left 0 / width 0`；50%: `left 30% / width 70%`；75%: `left 100% / width 0` |
| 副带 `progress-indeterminate-short` | 0%: `left 0 / width 0`；50%: 仍 `left 0 / width 0`；75%: `left 0 / width 25%`；100%: `left 100% / width 0` |
| 确定进度宽度过渡 | **500ms**（long2），`standard` |
| 轨道高度 | `0.25rem`（=4px @16px 根字号） |
| 轨道背景 | `--mdui-color-surface-container-highest`；指示条 `--mdui-color-primary` |

主带与副带**同周期 2s 但相位错开**（副带前 50% 完全不动，75% 才长出 25% 并走到左边缘 0 宽度），合起来形成「一条反复穿梭的光带」效果。

> 我们的 `M3ProgressIndicator` 线性不定用了自创的「头 `lerp(-0.30, 1.0)` / 尾 `lerp(-0.50, 0.62)`」双滑条并把 `周期` 设为 1.33s，**与 mdui 的 2s + 两条 keyframes 完全不是一套**。

### 4.5 switch / checkbox / radio / slider 的过渡

**switch**（[components/switch/style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/switch/style.js)）

| 部件 | 过渡属性 | 时长 | 缓动 |
|---|---|---|---|
| `.track`（轨道） | `background-color, border-width` | **short4 = 200ms** | `standard` |
| `mdui-ripple`（状态层圆） | `left, top` | **short4 = 200ms** | `standard` |
| `.thumb`（滑块） | `width, height, left, background-color` | **short4 = 200ms** | `standard` |
| `.unchecked-icon` | `opacity, transform` | 勾选时 `short3=150ms` + delay `short1=50ms`；取消勾选时 `short1=50ms`、delay 0 | `linear` |
| `.checked-icon` | `opacity, transform` | 反向（勾选 `short3` + delay `short1`；取消 `short1`、delay 0） | `linear` |

**精确几何（关键数值）：**

- 轨道：`height: 2rem`（32px）、`width: 3.25rem`（52px）、`border: .125rem solid outline`（2px）、`border-radius: --mdui-shape-corner-full`
- 未选中滑块：`1rem × 1rem`、`left: .375rem`（6px）、色 `outline`
- 选中滑块：`1.5rem × 1.5rem`、`left: 1.5rem`（24px）、色 `on-primary`
- **按下滑块放大到 `1.75rem × 1.75rem`、`left: 0`**；按下且选中时 `left: 1.375rem`
- hover/focus/pressed 时**未选中滑块变 `1.5rem × 1.5rem`、`left: .125rem`**，色变 `on-surface-variant`
- 有 unchecked-icon 时未选中滑块就是 `1.5rem × 1.5rem`、`left: .125rem`

**checkbox**（[components/checkbox/style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/checkbox/style.js)）

| 部件 | 过渡 | 时长 | 缓动 |
|---|---|---|---|
| `.icon` | `color` | **short4 = 200ms** | `standard` |
| `.checked-icon` / `.indeterminate-icon` | `color, opacity, transform` | **short4 = 200ms** | `standard` |
| `.label` | `color` | **short4 = 200ms** | `standard` |

图标变换：未选中态 `opacity:1; transform:scale(1)`；选中/半选态 `opacity:0; transform:scale(.5)` 起步，激活时回到 `scale(1)`。

**radio**（[components/radio/radio-style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/radio/radio-style.js)）

| 部件 | 过渡 | 时长 | 缓动 |
|---|---|---|---|
| `.icon` | （`transition-duration`） | **short4 = 200ms** | `standard` |
| `.label` | `color` | **short4 = 200ms** | `standard` |

选中圆：`.checked-icon{opacity:0; transform:scale(.2)}` → 选中时 `opacity:1; transform:scale(.5)`（**注意终点是 0.5，不是 1**，因为图标本身已按 1.5rem 字号渲染）。

所有这三个组件都有一条重要规则：**`transition` 只加在 `.icon:not(.initial)` / `.label:not(.initial)` 上** —— 首帧带 `initial` class 不做过渡，避免初始渲染时闪一下动画。**这是个很值得抄的细节。**

**slider**（[components/slider/slider-base-style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/slider/slider-base-style.js)）

| 部件 | 过渡 | 时长 | 缓动 |
|---|---|---|---|
| `.label`（数值气泡） | `transform`（隐藏时） | **short2 = 100ms** | `standard` |
| `.label-visible`（弹出时） | `transform` | **short4 = 200ms** | `standard` |

- 气泡：`transform: translateX(-50%) scale(0)` → `.label-visible` 时 `scale(1)`，`transform-origin: center bottom`
- 气泡尺寸：`min-width: 1.75rem`、`height: 1.75rem`、`padding: .375rem .5rem`、`border-radius: full`、`bottom: 2.5rem`、色 `primary`/`on-primary`
- 气泡小尖角：`::after` 一个 `0.875rem × 0.875rem`、`rotate(45deg)`、`bottom: -.125rem` 的方块
- 轨道：高 `.25rem`、圆角 `full`；非活动轨 `surface-container-highest`，活动轨 `primary`
- **手柄**：容器 `2.5rem × 2.5rem`、`margin-top: -1.25rem`；其中 `.elevation` 与 `::before` 都是 `1.25rem × 1.25rem`、`left/top: .625rem`、`border-radius: full`；`.elevation` 是 `primary` 色 + `elevation-level1` 阴影，`::before` 是 `background` 色（形成「圆环」视觉）
- tickmark：`0.125rem × 0.125rem` 小圆点，未激活 `rgba(on-surface-variant, .38)`，激活 `rgba(on-primary, .38)`

### 4.6 其它组件的动效（供参考）

| 组件 | 动画 | 时长 | 缓动 |
|---|---|---|---|
| `mdui-button` | `box-shadow`（hover 抬升） | **short4 = 200ms** | `linear` |
| `mdui-fab` | `box-shadow` | **medium4 = 400ms** | `emphasized` |
| `mdui-fab` | label `opacity` | short2=100ms，delay short2=100ms；收起时 short1=50ms、delay 0 | `linear` |
| `mdui-tabs` `.indicator` | `transform, left, width`（或 `top, height`） | **medium2 = 300ms** | **`standard-decelerate`** |
| `mdui-navigation-bar-item` `.indicator` | `background-color` / `width` | **short1 = 50ms** / **short4 = 200ms** | `standard` |
| `mdui-navigation-bar-item` `.label` | `opacity` | short4 = 200ms | `linear` |
| `mdui-navigation-bar-item` `.container` | `padding` | short4 = 200ms | `standard` |
| `mdui-navigation-rail-item` `.indicator` | `background-color` / `width` / `height` | short1 = 50ms / short4 = 200ms / short4 = 200ms | `standard` |
| `mdui-collapse-item` `.body` | `height` | **short4 = 200ms**；展开中（`.active`）改 **medium4 = 400ms** | `emphasized` |
| `mdui-top-app-bar` | `transform, height` / `box-shadow, background-color` | **long2 = 500ms** / short4 = 200ms | `standard` / `linear` |
| `mdui-top-app-bar-title` `.label` | `opacity` | short2 = 100ms（带 short2 延迟） | `linear` |
| `mdui-bottom-app-bar` | `transform` | long2 = 500ms（隐藏时 short4 = 200ms） | `emphasized`（隐藏时 `emphasized-accelerate`） |
| `mdui-snackbar` | `transform`（展开） | **medium4 = 400ms** | `emphasized-decelerate` |
| `mdui-dialog`（打开） | overlay `opacity` / panel `transform` / panel `opacity` / children `opacity` | **medium4 = 400ms** | linear / **emphasized-decelerate** / linear / linear |
| `mdui-dialog`（关闭） | —— | **short4 = 200ms** | —— |
| `mdui-dropdown`（打开） | panel `scaleX/scaleY` `0.45 → 1` | **medium4 = 400ms** | **emphasized-decelerate** |
| `mdui-dropdown`（打开） | panel `opacity`（0 → 1@12.5% → 1） | medium4 = 400ms | linear |
| `mdui-dropdown`（关闭） | panel `scale` `1 → 0.45` + `opacity`（1 → 1@87.5% → 0） | **short4 = 200ms** | **emphasized-accelerate** / linear |

**dialog 打开动画细节**（[components/dialog/index.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/dialog/index.js)）：

```js
// overlay
[{opacity:0}, {opacity:1, offset:0.3}, {opacity:1}]           // linear
// panel
[{transform:'translateY(-1.875rem) scaleY(0)'}, {transform:'translateY(0) scaleY(1)'}]  // emphasized-decelerate
// panel 自身 opacity
[{opacity:0}, {opacity:1, offset:0.1}, {opacity:1}]           // linear
// 每个子元素
[{opacity:0}, {opacity:0, offset:0.2}, {opacity:1, offset:0.8}, {opacity:1}]  // linear
```

**dropdown 打开动画**：`transform: scaleX(0.45) → scaleX(1)`（或 `scaleY`，取决于展开方向是横向还是纵向——源码 `getCssScaleName()` 按 `animateDirection` 选）。

---

## 5. 状态层（state layer）

### 5.1 mdui 的实际取值 vs MD3 规范

来源：[mdui.css](https://cdn.jsdelivr.net/npm/mdui@2.1.5/mdui.css)（已与[官方设计令牌文档「状态层不透明度」表](https://www.mdui.org/zh-cn/docs/2/styles/design-tokens)逐条核对一致）

| 状态 | mdui 变量 | mdui 值 | MD3 常见规范值 | 是否照做 |
|---|---|---|---|---|
| hover（悬停） | `--mdui-state-layer-hover` | **0.08** | 0.08 | ✅ 照做 |
| focus（聚焦） | `--mdui-state-layer-focus` | **0.12** | 0.10 | ❌ **偏高** |
| pressed（按下） | `--mdui-state-layer-pressed` | **0.12** | 0.10 | ❌ **偏高** |
| dragged（拖动） | `--mdui-state-layer-dragged` | **0.16** | 0.16 | ✅ 照做 |

> **结论：mdui 并没有严格照做 MD3 的 8/10/10/16，而是用了 8/12/12/16。** focus 与 pressed 都比规范高 2 个百分点。
>
> 关于 MD3 规范原值：我尝试抓取 `https://m3.material.io/foundations/interaction/states/state-layers`，该页为 JS 渲染，只返回了标题「States – Material Design 3」，**正文数值未能从一手页面核实**。上表 MD3 列标注为「常见规范值」，请以该页实际渲染内容为准；**mdui 侧的值 100% 确定**（源码 + 官方文档双证）。

### 5.2 具体怎么写的

**不是**用 `::after` 叠一层，而是**一个独立的 `.surface` 元素承载状态层**，通过 class 开关：

```css
.surface{position:absolute;top:0;left:0;width:100%;height:100%;
  transition-duration:280ms;transition-property:background-color;
  transition-timing-function:var(--mdui-motion-easing-standard)}
.hover  {background-color:rgba(var(--mdui-comp-ripple-state-layer-color, var(--mdui-color-on-surface)), var(--mdui-state-layer-hover))}
:host-context([focus-visible]) .focused{... var(--mdui-state-layer-focus)}
.dragged{... var(--mdui-state-layer-dragged)}
```

对应 JS（ripple/index.js）：

```js
render() {
  return html`<div ${ref(this.surfaceRef)} class="surface ${classMap({
    hover: this.hover, focused: this.focused, dragged: this.dragged,
  })}"></div>`;
}
startHover(){ this.hover = true }   endHover(){ this.hover = false }
startFocus(){ this.focused = true } endFocus(){ this.focused = false }
startDrag() { this.dragged = true } endDrag() { this.dragged = false }
```

三层职责分离，非常清晰：

1. **hover / focus / dragged** → `.surface` 的 class（持久背景色），**过渡 280ms standard**
2. **pressed（点击涟漪）** → 独立的 `.wave` 元素动画（225ms/75ms/150ms）
3. **阴影** → 在 `ripple-mixin` 里通过 `:host` 属性选择器加 `box-shadow`

**button 上的实际叠加结果**（components/button/style.js）：

```css
:host([variant=elevated][hover]){box-shadow:var(--mdui-elevation-level2)}
:host([variant=filled][hover]),
:host([variant=tonal][hover]){box-shadow:var(--mdui-elevation-level1)}
```

即 hover 同时改状态层颜色**和**抬升阴影。

**`--mdui-comp-ripple-state-layer-color` 模式**：每个组件声明自己该用什么颜色做状态层，ripple 用 fallback 兜底：

```css
/* button */
:host([variant=filled]){--mdui-comp-ripple-state-layer-color:var(--mdui-color-on-primary)}
:host([variant=tonal]) {--mdui-comp-ripple-state-layer-color:var(--mdui-color-on-secondary-container)}
:host([variant=outlined]),:host([variant=text]){--mdui-comp-ripple-state-layer-color:var(--mdui-color-primary)}
/* checkbox 选中后 */
:host([checked]) i{--mdui-comp-ripple-state-layer-color:var(--mdui-color-primary)}
/* radio */
i{--mdui-comp-ripple-state-layer-color:var(--mdui-color-on-surface)}
```

> **这是本次调研里最值得抄的架构模式之一**：状态层颜色是「组件级可覆盖变量」，默认 `on-surface`，组件按自身 variant/选中态声明。

---

## 6. 组件结构要点

### 6.1 button 的变体

```html
<mdui-button variant="filled">按钮</mdui-button>
```

`variant` 属性（默认 **`filled`**，来自 custom-elements.json 的 `default`）：

| variant | 语义（源码 JSDoc 原文） | 背景 / 前景 |
|---|---|---|
| `elevated` | 带阴影的按钮，适用于需要将按钮与背景视觉分离的场景 | `surface-container-low` + `elevation-level1`，色 `primary` |
| `filled` | 视觉效果强烈，适用于重要流程的最终操作，如"保存"、"确认"等 | `primary` / `on-primary` |
| `tonal` | 视觉效果介于 filled 和 outlined 之间，适用于中高优先级的操作，如流程中的"下一步" | `secondary-container` / `on-secondary-container` |
| `outlined` | 带边框的按钮，适用于中等优先级，且次要的操作，如"返回" | 透明底 + `.0625rem`（1px）`outline` 边框，色 `primary` |
| `text` | 文本按钮，适用于最低优先级的操作 | 纯文本，色 `primary` |

其它：`full-width`、`icon`（左侧图标名）/ `slot="icon"`、`end-icon` / `slot="end-icon"`、`disabled`、`loading`。

尺寸：`min-width: 3rem`、`height: 2.5rem`（40px）、`padding: 0 1rem`、`border-radius: --mdui-shape-corner-full`。

> **`--mdui-shape-corner-full` 的具体值是 `1000rem`**（不是 `9999px` 也不是 `50%`）——一个超大值来保证胶囊形。我们的 `M3Shape` 用的还是 MD3 的 `--md-sys-shape-corner-full`（数值需自行确认）。

`mdui-button-icon`（我们**没有**）：`variant` 默认 `standard`（另有 `filled` / `tonal` / `outlined`），尺寸 `2.5rem × 2.5rem`、`font-size: 1.5rem`，外加 `selectable` + `selected`。

### 6.2 navigation-bar / rail / drawer

三者用法与差异（来源：各自 `.d.ts` + style.js）：

**`mdui-navigation-bar`（底部导航栏）**

| 属性 | 类型/默认 | 说明 |
|---|---|---|
| `label-visibility` | `'auto'`（默认）\| `'selected'` \| `'labeled'` \| `'unlabeled'` | `auto` = 选项 ≤3 个始终显示文本，>3 个仅选中显示 |
| `hide` | bool = false | 隐藏 |
| `scroll-behavior` | `'hide' \| 'shrink' \| 'elevate' \| undefined` | 滚动联动 |

子项 `mdui-navigation-bar-item`：`active`、`icon`、`active-icon`、`href` 等。
激活指示器：`.indicator` 默认 `2rem × 2rem`、透明；`[active]` 时 **`width: 4rem`** + 背景 `--mdui-color-secondary-container`。

**`mdui-navigation-rail`（侧边导航栏）**

| 属性 | 默认 | 说明 |
|---|---|---|
| `placement` | `'left'` \| `'right'` | 左右 |
| `alignment` | `'start'`（默认）\| `'center'` \| `'end'` | 竖排对齐 |
| `contained` | false | 相对定位（不固定） |
| `divider` | false | 显示分隔线 |

子项 `mdui-navigation-rail-item`：`active`、`icon`、`active-icon`。
激活指示器：默认 `2rem × 2rem`；`[active]` 时 **`width: 3.5rem`** + `secondary-container` 底；若无 label 则高度也变 `3.5rem`。激活项图标色 `on-secondary-container`。

**差异小结**：bottom bar 指示器是「横向拉长成 4rem 宽的胶囊」，rail 指示器是「3.5rem 宽胶囊（无 label 时接近方形）」，**两者都是 `secondary-container` 底 + `on-secondary-container` 图标**，过渡分别是 `background-color short1(50ms)` + `width short4(200ms)`。

**`mdui-navigation-drawer`（抽屉）**

| 属性 | 默认 | 说明 |
|---|---|---|
| `open` | false | 开合 |
| `modal` | false | 模态（带遮罩） |
| `placement` | `'left'`（默认）\| `'right'` | 左右 |
| `contained` | false | 相对定位 |
| `mobile` | false | 移动端样式 |
| `close-on-esc` / `close-on-overlay-click` | false | 关闭交互 |

样式要点：宽度 `22.5rem`；`modal`/`mobile` 时面板 `max-width: 80%`、背景 `surface-container-low`、`elevation-level1`、圆角 `--shape-corner-large`（`1rem`，仅一侧）；遮罩 `rgba(var(--mdui-color-scrim), .4)`。
**注意 `.4` 遮罩透明度** —— dialog 也是 `rgba(scrim, .4)`。

### 6.3 text-field 的 filled / outlined

`variant` 默认 **`filled`**。

**filled**：
```css
box-shadow: inset 0 -.0625rem 0 0 rgb(var(--mdui-color-on-surface-variant));  /* 底部 1px 线 */
background-color: rgb(var(--mdui-color-surface-container-highest));
border-radius: var(--mdui-shape-corner-extra-small) var(--mdui-shape-corner-extra-small) 0 0;  /* 上方两角 */
```

**outlined**：
```css
box-shadow: inset 0 0 0 .0625rem rgb(var(--mdui-color-outline));  /* 1px 全边框 */
border-radius: var(--mdui-shape-corner-extra-small);
```

**状态递进（两者都有）：**

| 状态 | filled | outlined |
|---|---|---|
| 默认 | 底边 1px `on-surface-variant` | 全边 1px `outline` |
| hover | 底边 1px `on-surface` | 全边 1px `on-surface` |
| focus | 底边 **2px**（`.125rem`）`primary` | 全边 **2px**（`.125rem`）`primary` |
| invalid | 底边 1px `error` | 全边 1px `error` |
| hover + invalid | 底边 1px `on-error-container` | 全边 1px `on-error-container` |
| focus + invalid | 底边 2px `error` | 全边 2px `error` |
| disabled | 底边 1px `rgba(on-surface,38%)` + 背景 `rgba(on-surface,4%)` | 全边 2px `rgba(on-surface,12%)` |

**浮动 label：**

- 默认：`top: 1rem`，`body-large` 字号，色 `on-surface-variant`
- 上浮（filled）：`top: .25rem`，降到 **`body-small`** 字号
- 上浮（outlined）：`top: -.5rem`、`left: .75rem`、背景 `--mdui-color-background`（**打孔效果**）、`padding: 0 .25rem; margin: 0 -.25rem`
- 过渡：`transition: all var(--mdui-motion-duration-short4) var(--mdui-motion-easing-standard)`（**200ms，且是 `all`**）
- focus 时 label 变 `primary`；invalid 时 `error`

**辅助文本**：`.supporting`（`padding: .25rem 1rem`，`space-between` 放 helper + counter）；`.helper` 透明度过渡 short4 + `linear`，配合 `helper-on-focus` 属性（聚焦时隐藏 helper）。

### 6.4 tabs

`mdui-tabs`：

| 属性 | 默认 | 说明 |
|---|---|---|
| `variant` | **`'primary'`** \| `'secondary'` | primary 用于 top-app-bar 下方主页面切换；secondary 用于页面内相关内容切换 |
| `placement` | **`'top-start'`**（另有 `top`/`top-end`/`bottom-start`/`bottom`/`bottom-end`/`left-start`/`left`/`left-end`/`right-start`/`right`/`right-end`） | 12 种 |
| `full-width` | false | 子 tab 等分 |

**指示器尺寸**：`primary` = `.1875rem`（3px）；`secondary` = `.125rem`（2px）。primary 指示器带同侧圆角（如 top 时为上方两角 `.1875rem`）。
**指示器过渡**：`transform, left, width`（横）或 `transform, top, height`（竖），**medium2 = 300ms**，**`standard-decelerate`**。
底部/侧边的分隔线是 `.container::after`，高/宽 `.0625rem`（1px），色 `surface-variant`。
`mdui-tab`：`inline`（图标与文字同行）、`active`；preset 默认竖排（`flex-direction: column`）、`min-height: 3rem`、`padding: .625rem 1rem`；label 用 `title-small`，图标 `1.5rem`。
`mdui-tab-panel`：`active` 控制 `display`。

### 6.5 tooltip 的定位规则

| 属性 | 默认 | 说明 |
|---|---|---|
| `placement` | **`'auto'`** | 另有 `top-left`/`top-start`/`top`/`top-end`/`top-right`/`bottom-left`/`bottom-start`/`bottom`/`bottom-end`/`bottom-right`/`left-*`/`right-*` 等 |
| `variant` | **`'plain'`** \| `'rich'` | plain 纯文本单行；rich 富文本（标题+正文+操作按钮） |
| `trigger` | **`'hover focus'`**（可组合字符串） | 还有 `click` / `manual` |
| `open-delay` | **150**（ms） | |
| `close-delay` | **150**（ms） | |
| `disabled` / `open` | false | |

**定位实现**：`position: fixed` + `--z-index: 2500`，用 `@floating-ui/utils` 计算（依赖里可见）。默认 `auto` 会按可用空间自动翻转/对齐。
**两种 variant 的差异完整列出：**

| | plain | rich |
|---|---|---|
| 圆角 | `--shape-corner-extra-small`（0.25rem） | `--shape-corner-medium`（0.75rem） |
| 背景 | `inverse-surface` | `surface-container` |
| 阴影 | 无 | `elevation-level2` |
| padding | `0 .5rem` | `.75rem 1rem .5rem 1rem` |
| 文本色 | `inverse-on-surface` | `on-surface-variant` |
| 字号 | `body-small` | `body-medium` |
| 尺寸 | `min-width: 1.75rem; max-width: 20rem` | 同 |

`display: contents` 在 `:host` 上——tooltip 元素本身不占布局，弹出的 `.popup` 是 `position: fixed` 的独立层。

### 6.6 dialog / menu / snackbar 的行为

**dialog**：属性 `open`、`fullscreen`、`close-on-esc`（默认 **false**）、`close-on-overlay-click`（默认 **false**）、`stacked-actions`（默认 false）。
- `--shape-corner-extra-large`（**1.75rem**）；`--z-index: 2300`；`padding: 3rem`
- 面板背景 `surface-container-high`，`box-shadow: elevation-level3`，`min-width: 17.5rem`、`max-width: 35rem`、`padding: 1.5rem`
- 遮罩 `rgba(var(--mdui-color-scrim), .4)`
- `fullscreen` 时：圆角归零、`padding: 0`、面板 100%×100%、`elevation-level0`
- 标题 `headline-small`；描述 `body-medium` / `on-surface-variant`；动作区 `justify-content: flex-end`、`padding-top: 1.5rem`、间距 `.5rem`；`stacked-actions` 时改竖排
- 打开动画见 §4.6

**menu**：`mdui-menu`（`--shape-corner-extra-small`、背景 `surface-container`、`elevation-level2`、`min-width: 7rem`、`max-width: 17.5rem`、上下 `padding: .5rem`）
- 属性：`selects`（`'single'`/`'multiple'`）、`dense`、`submenu-trigger`（默认 **`'click hover'`**）、`submenu-open-delay`（默认 **200**）、`submenu-close-delay`（默认 **200**）
- `mdui-menu-item`：`disabled`、`submenu-open`、`selected`
- 分隔线在 menu 内 `margin: .5rem 0`

**snackbar**：`open`、`placement`（默认 **`'bottom'`**，另有 `top`/`top-start`/`top-end`/`bottom-start`/`bottom-end`）、`action`、`action-loading`、`closeable`、`close-icon`、`auto-close-delay`（默认 **5000ms**）、`close-on-outside-click`（默认 false）、`mobile`、`message-line`
- 圆角 `extra-small`（0.25rem）；`--z-index: 2400`；`min-width: 20rem`、`max-width: 36rem`、`padding: .25rem 0`
- 背景 `inverse-surface` / 前景 `inverse-on-surface`，`elevation-level3`，字号 `body-medium`
- 展开：`transform: scaleY(0) → scaleY(1)`，`transform-origin` 按 placement 取 top/bottom；过渡 **medium4 = 400ms + `emphasized-decelerate`**（同时 `top`/`bottom` 用 short4=200ms + standard）
- `mobile` 时 `min-width: 0`、左右各 `1rem`；非 mobile 时 `top/bottom` 居中用 `translateX(-50%)`，`-start`/`-end` 贴边 `1rem`

---

## 7. 给我们 Godot 版的对齐建议

对照我们现有代码（`addons/material_ui/`）逐条列。

### 7.1 不一致项（建议改）

| # | 位置 | 我们现在 | mdui 实际 | 建议 |
|---|---|---|---|---|
| 1 | `core/m3_motion.gd:46-47` | `状态_聚焦 = 0.10`、`状态_按下 = 0.10` | **两者都是 `0.12`** | 若目标是「对齐 mdui」，改成 `0.12`；若目标是「对齐 MD3 规范」则保持 `0.10`。**二者不等价，必须选一个并写清注释。** |
| 2 | `components/m3_button.gd:34` | `涟漪不透明度 = 0.55` | ripple 峰值 = `--mdui-state-layer-pressed` = **0.12** | **差 4.6 倍，这是最显眼的偏差。** 0.55 的纯色涟漪在浅色底上几乎是不透明色块。建议降到 0.12（或最多 0.16 = dragged）。 |
| 3 | `effects/m3_ripple.gd:50` | `_半径 = _到最远角(位置)`（点到最远角距离） | 直径 = `max(surface 对角线, 48)`，半径 = 直径/2 | 数学不同。mdui 用**整体对角线**做直径（与点击点无关），保证任何位置点击都能覆盖全组件。建议改为 `半径 = max(sqrt(w²+h²), 48) / 2`。 |
| 4 | `effects/m3_ripple.gd:73` | 松开时收敛时长 `clamp(0.225*剩余, 0.04, 0.10)` | 行为是「**等扩散动画自然跑完**（最多 225ms）再淡出」，不截断 | mdui 不加速补完，而是挂 `animationend` 等它跑完。建议去掉 `clamp` 上限，直接用 `扩散时长 * 剩余`。 |
| 5 | `effects/m3_ripple.gd:82` | `播放()` 用 `create_timer(0.12)` 自动松开 | 无此 API（mdui 由 pointerdown/pointerup 驱动） | 可保留作为便捷方法，但 `0.12` 是拍的，建议与 `扩散时长`(0.225) 关联。 |
| 6 | `components/m3_progress_indicator.gd:19-21` | 周期 `1.33`，附加 `0.6` 圈，自创双滑条公式 | 线性：**2s** + 两条精确 keyframes；圆形：1568/5332/1333ms | **建议直接照抄 mdui 的两套公式**（见 §7.2 第 1、2 条），比自创近似更准且可验证。 |
| 7 | `core/m3_theme.gd:12-43` | 只有 24 个颜色令牌，且是硬编码蓝色系 | 37 个角色，且支持任意种子色动态生成 | **缺 13 个角色**：`inverse_primary`、`inverse_surface`、`inverse_on_surface`、`surface_dim`、`surface_bright`、`surface_container_lowest`、`surface_container_highest`、`background`、`on_background`、`scrim`、`surface_tint_color`。其中 **`background`/`on_background`/`scrim` 是 dialog/drawer/snackbar 的必需品**，不补就没法做这些组件。 |
| 8 | `core/m3_theme.gd:136-138` | `surface_container_low=96`、`container=94`、`container_high=92` | mdui 用 n1 色的：`low=96`、`container=94`、`high=92`、`highest=90`、`lowest=100`、`dim=87`、`bright=98` | **我们已有的 3 个数值与 mdui 完全一致**（96/94/92）✅。补 `highest=90`、`lowest=100`、`dim=87`、`bright=98` 即可。深色对应 10/12/17/22/4/6/24。 |
| 9 | `components/m3_slider.gd` | 静态 StyleBox，无过渡 | 气泡 label `scale(0)→scale(1)`，100ms/200ms；手柄结构 `1.25rem` 圆 + `background` 色圆环 | 我们用手柄 `直径 26`、无气泡。若要补气泡需加 100/200ms 过渡。 |
| 10 | `components/m3_switch.gd:19-23` | 轨道 `60×38`，拇指 `lerpf(高*0.22, 高*0.36)` | 轨道 `3.25rem × 2rem` = **52×32**；拇指未选 `1rem`(16)、选中 `1.5rem`(24)、按下 `1.75rem`(28)；未选 `left .375rem`、选中 `left 1.5rem` | 尺寸比例接近但不一致。**mdui 的「按下时拇指放大到 1.75rem」这个动效我们完全没有**，是很好的补充。 |
| 11 | `components/m3_switch.gd:69` / `m3_checkbox.gd:69` | 用 `M3Motion.弹簧_快`（M3 Expressive 弹簧，350ms，带过冲） | mdui 用 **200ms + `standard` 曲线，无过冲** | 这是**设计取向差异**，不一定是错。若要严格对齐 mdui 则换成 200ms+standard；若想要 M3 Expressive 手感则保持。**注意：mdui 完全没有弹簧 token，这一条无法从 mdui 对齐。** |
| 12 | 全部组件 | 无「首帧不做过渡」保护 | mdui 统一用 `:not(.initial)` 前缀避免初始渲染闪动 | **建议照抄这个模式**：给组件加 `initial` 标记，第一帧跳过 Tween。 |
| 13 | `core/m3_shape.gd` | MD3 命名（`大加强` 等） | mdui 用 `none/extra-small/small/medium/large/extra-large/full`，**`full = 1000rem`** | 确保 `full` 用一个足够大的绝对值（不是 `50%`），否则非正方形容器上做不出胶囊形。我们 `m3_button.gd` 的 `圆角 = M3Shape.大加强` 需确认是否等于 full。 |
| 14 | — | `M3ScrollStretch`、`M3Surface` | mdui 无对应物 | 保持独立，不要为对齐而改。 |

### 7.2 可以照抄的具体实现

**① 线性不定进度 —— 直接用 mdui 的两条 keyframes**

```
周期 2s，linear，无限
主带 progress-indeterminate:
  0%  → left 0,    width 0
  50% → left 30%,  width 70%
  75% → left 100%, width 0
副带 progress-indeterminate-short:
  0%  → left 0,    width 0
  50% → left 0,    width 0
  75% → left 0,    width 25%
  100%→ left 100%, width 0
```

两条同周期叠加，形成穿梭光带。比我们现在的 `lerp(-0.30,1.0)/lerp(-0.50,0.62)` 更好复现且可验证。

**② 圆形不定进度 —— 三个时长同时跑**

```
容器整圈：1568ms linear infinite          → rotate(0 → 360deg)
layer：  5332ms standard infinite both     → 1080deg/周期（每 12.5% 加 135deg）
左右半圆：1333ms standard infinite both     → 265° ↔ 130°（左）/ -265° ↔ -130°（右）
确定进度弧长过渡：500ms standard
```
配套结构：`gap-patch` 在 `left: 47.5%`、`width: 5%`；`clipper` 各 `width: 50%`，内部 `circle` 宽 `200%`。

**③ 涟漪完整参数表**

```
扩散：225ms，cubic-bezier(0.2, 0, 0, 1)，scale 0.4 → 1
淡入：75ms，linear，opacity 0 → 0.12
淡出：150ms，linear，opacity 0.12 → 0
表面色过渡：280ms，cubic-bezier(0.2, 0, 0, 1)
直径：max(sqrt(w² + h²), 48)
位移：圆心从点击点移到组件中心
松开时：等扩散自然跑完再淡出（不加速截断）
```

**④ 状态层「组件级可覆盖变量」模式**

我们可在 GDScript 里对应实现为一个虚方法 / 字段：

```gdscript
# 组件声明自己用什么颜色做状态层
func _状态层颜色() -> Color:
    return M3Theme.on_surface          # 默认兜底
# button filled 覆写为 on_primary，tonal 为 on_secondary_container，
# outlined/text 为 primary；checkbox 选中后为 primary
```

配合 4 档不透明度，比现在直接在 `M3Theme.状态层()` 里硬编码 `lerp` 更灵活（**我们现在的 `状态层()` 是用 `lerp` 混色，而 mdui 是叠加半透明层——在有背景/图片的场景下叠加语义更正确**）。

**⑤ 补齐背景/遮罩色**

```
background       = surface 同值（浅 254,247,255 / 深 20,18,24）
on_background    = on_surface 同值（浅 28,27,31 / 深 230,225,229）
scrim            = 0,0,0（遮罩统一用 rgba(scrim, 0.4)）
inverse_surface  = 浅 49,48,51 / 深 230,225,229
inverse_on_surface = 浅 244,239,244 / 深 49,48,51
```

`scrim` 遮罩 `0.4` 这个值在 dialog 和 drawer 里一致，可直接用。

### 7.3 数值速查表（对齐用）

| 令牌 | mdui 值 | 我们 `m3_motion.gd` | 一致？ |
|---|---|---|---|
| short1 | 50ms | `短1 = 0.05` | ✅ |
| short2 | 100ms | `短2 = 0.10` | ✅ |
| short3 | 150ms | `短3 = 0.15` | ✅ |
| short4 | 200ms | `短4 = 0.20` | ✅ |
| medium1 | 250ms | `中1 = 0.25` | ✅ |
| medium2 | 300ms | `中2 = 0.30` | ✅ |
| medium3 | 350ms | `中3 = 0.35` | ✅ |
| medium4 | 400ms | `中4 = 0.40` | ✅ |
| long1 | 450ms | `长1 = 0.45` | ✅ |
| long2 | 500ms | `长2 = 0.50` | ✅ |
| long3 | 550ms | `长3 = 0.55` | ✅ |
| long4 | 600ms | `长4 = 0.60` | ✅ |
| extra-long1 | 700ms | `超长1 = 0.70` | ✅ |
| extra-long2 | 800ms | `超长2 = 0.80` | ✅ |
| extra-long3 | 900ms | `超长3 = 0.90` | ✅ |
| extra-long4 | 1000ms | `超长4 = 1.00` | ✅ |
| linear | `cubic-bezier(0, 0, 1, 1)` | `线性` | ✅ |
| standard | `cubic-bezier(0.2, 0, 0, 1)` | `标准` | ✅ |
| standard-decelerate | `cubic-bezier(0, 0, 0, 1)` | `标准减速` | ✅ |
| standard-accelerate | `cubic-bezier(0.3, 0, 1, 1)` | `标准加速` | ✅ |
| emphasized | **= standard** | `强调` = `(0.2,0,0,1)` | ✅（巧合一致） |
| emphasized-decelerate | `cubic-bezier(0.05, 0.7, 0.1, 1)` | `强调减速` | ✅ |
| emphasized-accelerate | `cubic-bezier(0.3, 0, 0.8, 0.15)` | `强调加速` | ✅ |
| hover | 0.08 | `状态_悬停 = 0.08` | ✅ |
| **focus** | **0.12** | `状态_聚焦 = 0.10` | ❌ |
| **pressed** | **0.12** | `状态_按下 = 0.10` | ❌ |
| dragged | 0.16 | `状态_拖动 = 0.16` | ✅ |

> **动效时长与缓动我们已 100% 对齐 mdui** —— `m3_motion.gd` 里那 16 档时长和 7 条缓动曲线与 mdui 完全一致，这块不用动。
> **唯一的不一致集中在状态层的 focus / pressed 两个数字，以及涟漪峰值。**
> 弹簧（`弹簧_*` 系列）是我们超出 mdui 的扩展，保留。

---

## 8. 最值得照搬的 5 条

1. **状态层不透明度改成 `hover 0.08 / focus 0.12 / pressed 0.12 / dragged 0.16`，并把涟漪峰值从 `0.55` 降到 `0.12`。**
   依据：[mdui.css](https://cdn.jsdelivr.net/npm/mdui@2.1.5/mdui.css) + [官方设计令牌文档](https://www.mdui.org/zh-cn/docs/2/styles/design-tokens) 双证。我们 `m3_motion.gd` 已写 `0.08/0.10/0.10/0.16`，`m3_button.gd` 的 `涟漪不透明度 = 0.55` 则是明显偏高——mdui 的涟漪峰值就是 `var(--mdui-state-layer-pressed)` = **0.12**。

2. **涟漪的半径与扩散规则照抄：直径 = `max(sqrt(w²+h²), 48)`（与点击点无关），扩散 `225ms` + `cubic-bezier(0.2,0,0,1)` + `scale 0.4→1`，淡入 `75ms linear`，淡出 `150ms linear`，且松开时「等扩散自然跑完再淡出」而不加速截断。**
   依据：[components/ripple/style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/ripple/style.js) 与 [index.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/ripple/index.js)。我们现在的 `扩散时长 0.225`/`淡入 0.075`/`淡出 0.15`/`起始比例 0.4` 已经对了，**只需改半径算法（现为「点到最远角」）和去掉松开时的 `clamp(..., 0.04, 0.10)` 截断**。

3. **线性不定进度改用 mdui 的精确 keyframes：周期 `2s` + `linear`，主带 `0%: left 0/width 0 → 50%: left 30%/width 70% → 75%: left 100%/width 0`，副带 `0%: left 0/width 0 → 50%: left 0/width 0 → 75%: left 0/width 25% → 100%: left 100%/width 0`；确定进度宽度过渡 `500ms` + `standard`。**
   依据：[components/linear-progress/style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/linear-progress/style.js)。比我们自创的 `lerp(-0.30, 1.0)/lerp(-0.50, 0.62)` + 自定 1.33s 周期更准、可复现。

4. **圆形不定进度用「1568ms 整圈 linear + 5332ms 每周期 1080° 的 standard layer 旋转 + 1333ms 的 265°↔130° 左右半圆」三件套；确定进度弧长过渡 `500ms` + `standard`。**
   依据：[components/circular-progress/style.js](https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/circular-progress/style.js) 的 `@keyframes` 原文（已在 §4.3 逐字抄录）。我们现在用「周期 1.33s + 附加 0.6 圈」的近似，建议替换为这套三段时长。

5. **补全色彩令牌并引入「组件级状态层颜色变量」模式：**
   - 补 13 个缺失角色，其中 **`background` = `surface`（浅 `254,247,255` / 深 `20,18,24`）、`on_background` = `on_surface`（浅 `28,27,31` / 深 `230,225,229`）、`scrim` = `0,0,0`（遮罩统一 `rgba(scrim, 0.4)`）** 是 dialog / drawer / snackbar 的刚需；
   - surface container 档位用的 tone 值得记牢：**浅色 `lowest 100 / low 96 / container 94 / high 92 / highest 90 / dim 87 / bright 98`，深色 `4 / 10 / 12 / 17 / 22 / 6 / 24`**（我们已有的 96/94/92 与 mdui 完全一致）；
   - 状态层颜色做成组件可覆写的虚方法，默认 `on_surface`，`filled` 按钮用 `on_primary`、`tonal` 用 `on_secondary_container`、`outlined`/`text` 用 `primary`、checkbox/radio 选中后用 `primary`；
   - 状态层用**半透明叠加**而非 `lerp` 混色，在复杂背景上语义更正确。

   依据：[内部 colorScheme.js 的 tone 补丁](https://cdn.jsdelivr.net/npm/mdui@2.1.5/internal/colorScheme.js)、[mdui.css](https://cdn.jsdelivr.net/npm/mdui@2.1.5/mdui.css)、各组件 style.js。

---

## 9. 未能核实 / 存疑项

| 项 | 状态 |
|---|---|
| MD3 规范原文的 state layer 精确值（8/10/10/16） | **未能从一手页面核实**。`https://m3.material.io/foundations/interaction/states/state-layers` 为 JS 渲染，抓取只得到标题「States – Material Design 3」，正文无数值。上表「MD3 常见规范值」一列为通行说法，请自行确认。 |
| mdui 1 → mdui 2 官方迁移指南 | **不存在**（`/zh-cn/docs/2/migration` 返回 404）。1↔2 对比结论来自两版文档的结构差异 + 仓库语言 + `package.json` 依赖。 |
| mdui 是否有 M3 Expressive 弹簧 token | **确认没有**。已 grep 全部 217 个 `--mdui-*` 变量名，无任何 `spring`。 |
| `mdui-snackbar` 自身的额外 `@keyframes` | 其 `style.js` 中未发现自定义 `@keyframes`，动画通过 `transition` + `transform: scaleY()` 实现（非 keyframes）。 |
| GitHub star 数是快照值 | 4523，抓取于本次会话，会随时间变化。 |
| 本地镜像完整性 | `mdui@2.1.5` 组件 JS **147/147 全部下载成功**；组件 `.d.ts` **145/147**（2 个失败，未影响本报告任何结论——所有引用到的 `.d.ts` 均已在本地）。 |

---

## 10. 来源链接汇总

**一手源码（jsdelivr CDN，全部实测可达）**

- 包元数据 / 版本列表：https://data.jsdelivr.com/v1/packages/npm/mdui
- 文件树：https://data.jsdelivr.com/v1/packages/npm/mdui@2.1.5?structure=flat
- `package.json`：https://cdn.jsdelivr.net/npm/mdui@2.1.5/package.json
- `LICENSE`：https://cdn.jsdelivr.net/npm/mdui@2.1.5/LICENSE
- `README.md`：https://cdn.jsdelivr.net/npm/mdui@2.1.5/README.md
- **`mdui.css`（全部设计令牌）**：https://cdn.jsdelivr.net/npm/mdui@2.1.5/mdui.css
- `custom-elements.json`（46 个元素清单 + 属性默认值）：https://cdn.jsdelivr.net/npm/mdui@2.1.5/custom-elements.json
- 色彩引擎：https://cdn.jsdelivr.net/npm/mdui@2.1.5/internal/colorScheme.js
- 主题函数：https://cdn.jsdelivr.net/npm/mdui@2.1.5/functions/setTheme.js ｜ https://cdn.jsdelivr.net/npm/mdui@2.1.5/functions/getTheme.js
- 配色函数：https://cdn.jsdelivr.net/npm/mdui@2.1.5/functions/setColorScheme.js ｜ https://cdn.jsdelivr.net/npm/mdui@2.1.5/functions/getColorFromImage.js
- **涟漪**：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/ripple/style.js ｜ https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/ripple/index.js
- **圆形进度**：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/circular-progress/style.js
- **线性进度**：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/linear-progress/style.js
- switch：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/switch/style.js
- checkbox：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/checkbox/style.js
- radio：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/radio/radio-style.js
- slider：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/slider/slider-base-style.js
- button：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/button/style.js ｜ https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/button/index.d.ts
- button-icon：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/button-icon/style.js
- fab：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/fab/style.js
- chip：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/chip/style.js
- text-field：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/text-field/style.js
- tabs：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/tabs/tabs-style.js ｜ https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/tabs/tab-style.js
- tooltip：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/tooltip/style.js
- dialog：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/dialog/style.js ｜ https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/dialog/index.js
- dropdown：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/dropdown/index.js
- menu：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/menu/menu-style.js
- snackbar：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/snackbar/style.js
- navigation-bar：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/navigation-bar/navigation-bar-item-style.js
- navigation-rail：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/navigation-rail/navigation-rail-item-style.js
- navigation-drawer：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/navigation-drawer/style.js
- collapse：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/collapse/collapse-item-style.js
- top-app-bar：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/top-app-bar/top-app-bar-style.js
- bottom-app-bar：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/bottom-app-bar/style.js
- segmented-button：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/segmented-button/segmented-button-style.js
- list-item：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/list/list-item-style.js
- badge：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/badge/style.js
- avatar：https://cdn.jsdelivr.net/npm/mdui@2.1.5/components/avatar/style.js

**官方文档**

- 官网：https://www.mdui.org
- **设计令牌（颜色/圆角/排版/状态层/抬升/动效/断点，全文已核对）**：https://www.mdui.org/zh-cn/docs/2/styles/design-tokens
- mdui 2 文档首页：https://www.mdui.org/zh-cn/docs/2/
- mdui 1 文档首页（含「mdui 2 已发布」横幅）：https://www.mdui.org/zh-cn/docs/1/
- mdui 0.4.3 → 1.0.0 迁移：https://www.mdui.org/zh-cn/docs/1/migration

**仓库元数据（api.github.com，实测可达）**

- 仓库信息：https://api.github.com/repos/zdhxiong/mdui
- Releases：https://api.github.com/repos/zdhxiong/mdui/releases

**参考（外部资料，非一手）**

- MD3 状态层规范页（JS 渲染，正文未取到）：https://m3.material.io/foundations/interaction/states/state-layers
- material-color-utilities 缺失 token 的 issue（mdui 源码内注释引用）：https://github.com/material-foundation/material-color-utilities/issues/98

**本地镜像**

- `D:\sister\.mdui_cache\` —— mdui@2.1.5 完整镜像（147 组件 JS + 145 `.d.ts` + `mdui.css` + `custom-elements.json` + `mdui.esm.js`）。本报告所有数值均可在此目录离线复核。
