# 构建问题排查文档

## 问题概述

项目无法在当前系统上打包和运行。

## 环境信息

| 项目 | 当前环境 |
|------|----------|
| macOS 版本 | 13.7.8 (Ventura) |
| Xcode 版本 | 15.1 |
| 芯片 | Apple Silicon |
| 内存 | 16 GB |

## 问题原因分析

### 1. SDK 配置错误（主要原因）

**问题**: 项目配置使用了 `iphoneos` SDK，但这是一个 **macOS 应用**。

```text
SDKROOT = iphoneos;          // 错误：应该是 macosx
IPHONEOS_DEPLOYMENT_TARGET = 18.4;  // 错误：应该是 MACOSX_DEPLOYMENT_TARGET
```

**影响**: Xcode 无法识别项目为 macOS 应用，导致项目文件损坏的假象。

### 2. Xcode 版本不兼容

**问题**: 项目使用 Xcode 16.3 创建（未来版本），当前系统只有 Xcode 15.1。

```text
LastUpgradeCheck = 1630;     // 表示 Xcode 16.3
CreatedOnToolsVersion = 16.3;
```

**影响**: 
- Xcode 15.1 无法解析未来的项目配置
- `objectVersion = 77` 可能是 Xcode 16+ 的新版本

### 3. 不支持的类（Xcode 15.1 不支持）

**问题**: 使用了 `PBXFileSystemSynchronizedRootGroup` 类，这是 Xcode 15.4+ 才支持的类。

```text
isa = PBXFileSystemSynchronizedRootGroup;  // Xcode 15.1 不支持
fileSystemSynchronizedGroups = (...);       // 相关的属性也不支持
```

**错误信息**: `didn't find classname for 'isa' key`

### 4. 对象版本不兼容

```text
objectVersion = 77;
preferredProjectObjectVersion = 77;
```

## 已完成的修复（2026-01-08）

✅ **修复内容**:

1. **修改 SDK 配置**:
   - `SDKROOT = iphoneos;` → `SDKROOT = macosx;`
   - `IPHONEOS_DEPLOYMENT_TARGET = 18.4;` → `MACOSX_DEPLOYMENT_TARGET = 13.0;`

2. **替换不支持的类**:
   - `PBXFileSystemSynchronizedRootGroup` → `PBXGroup`
   - 移除 `fileSystemSynchronizedGroups` 属性

3. **修复测试目标配置**:
   - PixelClockTests 的部署目标已更新
   - PixelClockUITests 的部署目标已更新

## 验证结果

```bash
# 构建命令
xcodebuild -project PixelClock.xcodeproj -scheme PixelClock -configuration Debug build

# 结果
** BUILD SUCCEEDED **

# 构建产物位置
~/Library/Developer/Xcode/DerivedData/PixelClock-*/Build/Products/Debug/PixelClock.app
```

## 推荐的系统环境

| 组件 | 推荐版本 |
|------|----------|
| macOS | 14.0 (Sonoma) 或更高 |
| Xcode | 15.4 或更高 |
| Swift | 5.10 |

## 快速修复命令

如果项目再次出现问题，运行以下命令：

```bash
# 备份项目文件
cp PixelClock.xcodeproj/project.pbxproj PixelClock.xcodeproj/project.pbxproj.backup

# 修复 SDKROOT 配置
sed -i '' 's/SDKROOT = iphoneos;/SDKROOT = macosx;/g' PixelClock.xcodeproj/project.pbxproj

# 修复部署目标配置
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 18.4;/MACOSX_DEPLOYMENT_TARGET = 13.0;/g' PixelClock.xcodeproj/project.pbxproj

# 替换不支持的类
sed -i '' 's/PBXFileSystemSynchronizedRootGroup/PBXGroup/g' PixelClock.xcodeproj/project.pbxproj

# 移除不支持的属性
sed -i '' '/fileSystemSynchronizedGroups/,/);/d' PixelClock.xcodeproj/project.pbxproj

# 重新构建
xcodebuild -project PixelClock.xcodeproj -scheme PixelClock -configuration Debug build
```

## 相关文件

- 项目配置文件: `PixelClock.xcodeproj/project.pbxproj`
- 构建脚本: `scripts/build.sh`
- 文档: `CONTRIBUTING.md`, `README.md`, `AGENTS.md`

## 备注

项目已成功修复并可以在当前环境构建运行。建议后续在更高版本的 macOS 和 Xcode 环境下进行开发，以避免兼容性问题。
