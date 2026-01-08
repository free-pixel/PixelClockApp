#!/bin/bash

# PixelClock 构建脚本
# 支持 Debug 和 Release 配置

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 默认配置为 Debug
CONFIGURATION="${1:-Debug}"
ARCH="${2:-universal}"

# 验证配置
if [ "$CONFIGURATION" != "Debug" ] && [ "$CONFIGURATION" != "Release" ]; then
    echo "错误: 配置必须是 Debug 或 Release"
    echo "用法: ./build.sh [Debug|Release] [arm64|x86_64|universal]"
    exit 1
fi

# 验证架构
if [ "$ARCH" != "arm64" ] && [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "universal" ]; then
    echo "错误: 架构必须是 arm64, x86_64, 或 universal"
    echo "用法: ./build.sh [Debug|Release] [arm64|x86_64|universal]"
    exit 1
fi

echo "正在构建 PixelClock..."
echo "配置: $CONFIGURATION"
echo "架构: $ARCH"
echo ""

# 构建命令
BUILD_CMD="xcodebuild -project \"$PROJECT_DIR/PixelClock.xcodeproj\" -target PixelClock -configuration $CONFIGURATION"

# 添加架构特定参数
if [ "$ARCH" != "universal" ]; then
    BUILD_CMD="$BUILD_CMD ARCHS=$ARCH ONLY_ACTIVE_ARCH=YES"
fi

# 执行构建
eval "$BUILD_CMD"

# 检查构建结果
APP_PATH="$PROJECT_DIR/build/$CONFIGURATION/PixelClock.app"

if [ ! -d "$APP_PATH" ]; then
    echo "错误: 构建失败，找不到应用程序"
    exit 1
fi

echo ""
echo "构建成功！"
echo "应用程序位置: $APP_PATH"
echo ""
echo "可执行文件信息:"
file "$APP_PATH/Contents/MacOS/PixelClock"
echo ""

# 可选：打开应用程序
read -p "是否要打开应用程序？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$APP_PATH"
fi
