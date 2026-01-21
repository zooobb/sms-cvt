# SMS-cvt 图标设计说明

## 设计理念

SMS-cvt 图标设计旨在传达"短信转发"的核心功能，采用现代简洁的设计风格。

### 视觉元素

1. **对话气泡** - 代表短信/消息功能
   - 双层气泡设计，外层为白色，内层使用渐变填充
   - 气泡底部带有小尾巴，增强对话感

2. **箭头图标** - 代表转发功能
   - 位于气泡中央，使用紫蓝渐变色
   - 箭头向右指，象征信息流转
   - 带有装饰线条，增加动感

3. **文字标识** - 应用名称
   - "SMS" - 大号粗体白色文字，位于下方
   - "cvt" - 小号字母，代表"converter/convert"（转换器）

4. **配色方案**
   - 主背景：紫色到蓝色的线性渐变 (#667eea → #764ba2)
   - 箭头：与主背景一致的渐变
   - 文字：白色 (#ffffff)
   - 装饰元素：半透明白色

### 设计特点

- **现代感**：采用渐变色彩和圆角设计
- **识别度高**：对话气泡+箭头的组合直观易懂
- **品牌一致性**：统一的配色方案
- **多场景适用**：支持浅色和深色主题

## 文件说明

### 源文件

- `icon_design.svg` - 主图标设计（浅色主题）
- `icon_dark.svg` - 深色主题版本

### 使用方法

### 生成不同尺寸的图标

使用 ImageMagick 从 SVG 生成 PNG 图标：

```bash
# 生成 Android 图标
convert -background none -density 300 -resize 192x192 icon_design.svg ic_launcher-xxxhdpi.png
convert -background none -density 300 -resize 144x144 icon_design.svg ic_launcher-xxhdpi.png
convert -background none -density 300 -resize 96x96 icon_design.svg ic_launcher-xhdpi.png
convert -background none -density 300 -resize 72x72 icon_design.svg ic_launcher-hdpi.png
convert -background none -density 300 -resize 48x48 icon_design.svg ic_launcher-mdpi.png

# 生成 iOS 图标
convert -background none -density 300 -resize 1024x1024 icon_design.svg Icon-App-1024x1024@1x.png
convert -background none -density 300 -resize 180x180 icon_design.svg Icon-App-60x60@3x.png
convert -background none -density 300 -resize 120x120 icon_design.svg Icon-App-60x60@2x.png
convert -background none -density 300 -resize 120x120 icon_design.svg Icon-App-40x40@3x.png
convert -background none -density 300 -resize 80x80 icon_design.svg Icon-App-40x40@2x.png
```

### 修改配色

如需调整配色，编辑 SVG 文件中的以下部分：

```xml
<!-- 主背景渐变 -->
<linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
  <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
  <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
</linearGradient>
```

修改 `stop-color` 值即可改变配色。

## 应用名称修改

已将应用名称统一修改为 "SMS-cvt"：

- Android: `AndroidManifest.xml` - `android:label="SMS-cvt"`
- iOS: `Info.plist` - `CFBundleDisplayName="SMS-cvt"`
- pubspec.yaml: `description: "SMS-cvt - 短信转发应用"`

## 图标预览

图标的实际效果请查看生成的 APK 文件或在设备上运行应用查看。

## 技术规格

- 格式：SVG（矢量图）
- 尺寸：1024x1024 px
- 色彩模式：RGB
- 支持：透明背景

## 更新记录

- 2026-01-20: 初始设计 - SMS转发主题图标
- 双主题版本：浅色和深色
- 支持 Android 和 iOS 多分辨率
