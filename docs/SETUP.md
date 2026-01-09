# GitHub Actions 设置指南

本文档介绍如何为 PixelClock 项目设置和配置 GitHub Actions。

## 前置要求

1. GitHub 仓库已创建
2. 仓库中包含 PixelClock 项目代码
3. GitHub 账户有 Actions 权限

## 快速开始

### 1. 添加工作流文件

GitHub Actions 工作流文件已配置在 `.github/workflows/` 目录：

```
.github/
├── workflows/
│   ├── ci.yml          # CI 工作流（构建 + 测试）
│   ├── release.yml     # 发布工作流
│   └── README.md       # 工作流文档
└── README.md           # GitHub Actions 文档
```

### 2. 推送代码

将这些文件推送到 GitHub：

```bash
# 添加所有更改
git add .github/

# 提交
git commit -m "Add GitHub Actions workflows"

# 推送到远程仓库
git push origin main
```

### 3. 启用 Actions

1. 访问 GitHub 仓库页面
2. 点击 "Actions" 标签
3. 确认 "I understand my workflows, go ahead and enable them"（如果出现）
4. 查看正在运行的工作流

## 工作流说明

### CI 工作流 (`.github/workflows/ci.yml`)

**触发条件：**
- 推送到 `main` 或 `develop` 分支
- 针对 `main` 或 `develop` 的 Pull Request

**执行内容：**
1. 检出代码
2. 显示环境信息（OS、Xcode、Swift 版本）
3. 构建 Debug 配置
4. 构建 Release 配置
5. 运行单元测试
6. 验证二进制文件架构

**预计耗时：** 3-5 分钟

### Release 工作流 (`.github/workflows/release.yml`)

**触发条件：**
- 推送版本标签（如 `v1.0.0`）
- 手动触发（Actions 页面）

**执行内容：**
1. 检出代码
2. 显示环境信息
3. 构建 Release 配置（universal binary）
4. 验证二进制文件
5. 创建 ZIP 归档
6. 创建 GitHub Release
7. 上传 ZIP 到 Release
8. 上传构建产物

**预计耗时：** 3-5 分钟

## 使用场景

### 日常开发

每次推送到 `main` 或 `develop` 分支时，CI 工作流会自动运行，确保代码可以正常构建和测试。

### 代码审查

创建 Pull Request 时，CI 工作流会自动运行，帮助审查者了解代码质量。

### 发布版本

1. 确保所有更改已合并到 `main` 分支
2. 创建版本标签：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. Release 工作流自动触发
4. Release 页面自动更新
5. 用户可以下载 ZIP 文件

### 手动触发

1. 访问 GitHub 仓库的 Actions 页面
2. 选择工作流（如 "Release Build"）
3. 点击 "Run workflow" 按钮
4. 选择分支并运行

## 配置自定义

### 修改触发分支

编辑 `.github/workflows/ci.yml`：

```yaml
on:
  push:
    branches: [ main, develop, staging ]  # 添加 staging 分支
```

### 修改 Xcode 版本

编辑 `.github/workflows/ci.yml`：

```yaml
- name: Setup Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '15.1'  # 使用 Xcode 15.1
```

### 启用代码签名

首先，将证书和配置文件添加到 GitHub Secrets：

1. 访问仓库 Settings > Secrets and variables > Actions
2. 添加以下 secrets：
   - `CODE_SIGNING_CERTIFICATE`: Base64 编码的 .p12 证书
   - `CERTIFICATE_PASSWORD`: 证书密码
   - `PROVISIONING_PROFILE`: .mobileprovision 文件内容

然后修改工作流：

```yaml
- name: Build (Release)
  run: |
    # 导入证书
    echo "${{ secrets.CODE_SIGNING_CERTIFICATE }}" | base64 --decode > certificate.p12
    security create-keychain -p "" build.keychain
    security import certificate.p12 -k build.keychain -P "${{ secrets.CERTIFICATE_PASSWORD }}" -T /usr/bin/codesign
    security list-keychains -s build.keychain
    security set-key-partition-list -S apple-tool:,apple: -s -k "" build.keychain

    # 构建
    xcodebuild -project PixelClock.xcodeproj \
      -target PixelClock \
      -configuration Release \
      CODE_SIGN_IDENTITY="${{ secrets.CODE_SIGNING_IDENTITY }}" \
      CODE_SIGNING_REQUIRED=YES \
      CODE_SIGNING_ALLOWED=YES

    # 清理
    security delete-keychain build.keychain
```

### 添加 Slack 通知

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 故障排除

### 工作流未触发

检查：
1. 分支名称是否匹配（`main` 或 `develop`）
2. 工作流文件是否在 `.github/workflows/` 目录
3. YAML 语法是否正确
4. 仓库 Settings > Actions > General 是否启用了 Actions

### 构建失败

检查：
1. Xcode 版本兼容性（需要 Xcode 15.0+）
2. macOS 部署目标（设置为 macOS 13.0）
3. 代码是否有语法错误
4. Actions 日志中的错误信息

### Release 创建失败

检查：
1. 标签格式是否正确（`v*`，如 `v1.0.0`）
2. Settings > Actions > General > Workflow permissions 是否设置为 "Read and write permissions"
3. GitHub Token 是否有足够权限（`contents: write`）

### 工作流超时

默认超时时间为 360 分钟（6 小时）。如果需要修改：

```yaml
jobs:
  build:
    runs-on: macos-latest
    timeout-minutes: 30  # 设置为 30 分钟
    steps:
      # ...
```

## 最佳实践

1. **频繁推送**：小的、频繁的推送可以更快发现问题
2. **查看日志**：失败的构建日志包含详细的错误信息
3. **本地测试**：使用 `act` 在本地测试工作流
4. **版本标签**：使用语义化版本（如 `v1.0.0`, `v1.0.1`）
5. **更新文档**：修改工作流时同步更新文档

## 参考资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [工作流语法参考](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Marketplace](https://github.com/marketplace?type=actions) - 查找更多 Actions
- [项目 AGENTS.md](../AGENTS.md)
- [.github/workflows/README.md](./workflows/README.md)
