# PixelClock GitHub Actions 工作流

本项目配置了 GitHub Actions 来自动构建和测试 PixelClock 应用程序。

## 工作流

### 1. 构建工作流 (`build.yml`)

触发条件：
- 推送到 `main` 或 `develop` 分支
- 针对 `main` 或 `develop` 的 Pull Request
- 手动触发（workflow_dispatch）

构建配置：
- **Debug** 配置：构建 arm64 和 universal 版本
- **Release** 配置：仅构建 universal 版本
- 所有构建均禁用代码签名（用于 CI 环境）

输出：
- 自动上传构建产物（ZIP 格式的 .app 文件）
- 保留 30 天
- 在 GitHub Actions 摘要中显示构建信息

### 2. 测试工作流 (`test.yml`)

触发条件：
- 推送到 `main` 或 `develop` 分支
- 针对 `main` 或 `develop` 的 Pull Request

功能：
- 运行单元测试
- 启用代码覆盖率统计
- 使用 Debug 配置

### 3. 发布工作流 (`release.yml`)

触发条件：
- 推送版本标签（如 `v1.0.0`）
- 手动触发

功能：
- 构建 Release 配置的 universal 二进制文件
- 创建 GitHub Release
- 自动附加 ZIP 文件到 Release
- 自动生成 Release Notes
- 构建产物保留 90 天

## 本地测试工作流

在推送之前，可以使用 `act` 工具在本地测试 GitHub Actions 工作流：

```bash
# 安装 act
brew install act

# 列出所有工作流
act -l

# 运行构建工作流
act push --workflow .github/workflows/build.yml

# 运行测试工作流
act push --workflow .github/workflows/test.yml
```

## 构建产物

所有构建产物都以 ZIP 格式提供：

```
PixelClock-Debug-macOS.zip
PixelClock-Release-macOS.zip
```

解压后可直接运行 `PixelClock.app`。

## 版本发布流程

1. 更新 `AGENTS.md` 或代码中的版本号
2. 提交更改：`git commit -m "Bump version to X.Y.Z"`
3. 推送到远程：`git push origin main`
4. 创建并推送版本标签：
   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```
5. GitHub Actions 自动触发 Release 工作流
6. Release 页面将自动更新，包含可下载的 ZIP 文件

## 工作流配置文件

所有工作流配置文件位于 `.github/workflows/` 目录：

- `build.yml` - 常规构建工作流
- `test.yml` - 测试工作流
- `release.yml` - 发布工作流

## 环境变量

工作流使用以下环境变量：

| 变量 | 说明 | 值 |
|------|------|-----|
| `CODE_SIGN_IDENTITY` | 代码签名身份 | `""` (禁用) |
| `CODE_SIGNING_REQUIRED` | 是否需要代码签名 | `NO` |
| `CODE_SIGNING_ALLOWED` | 是否允许代码签名 | `NO` |

注意：CI 环境中的构建未进行代码签名。用户下载后首次运行时需要在系统设置中允许。

## 故障排除

### 构建失败

如果构建失败，请检查：

1. Xcode 版本兼容性（需要 Xcode 15.0+）
2. macOS 部署目标（设置为 macOS 13.0）
3. 代码语法错误（Swift 版本 5.0）
4. 依赖项是否正确引用

### 测试失败

如果测试失败，请检查：

1. 测试代码是否正确
2. 测试目标是否正确配置
3. 测试依赖是否正确设置

### Release 创建失败

如果 Release 创建失败：

1. 确保标签格式正确（`v*`，如 `v1.0.0`）
2. 检查 GitHub Token 权限（需要 `contents: write`）
3. 确认仓库 Settings > Actions > General > Workflow permissions 已设置为 "Read and write permissions"

## 自定义

要修改工作流行为，编辑相应的 `.github/workflows/*.yml` 文件。

### 示例：添加新架构

```yaml
strategy:
  matrix:
    architecture: [universal, arm64, x86_64]  # 添加 x86_64
```

### 示例：更改构建配置

```yaml
strategy:
  matrix:
    configuration: [Debug, Release, Custom]  # 添加 Custom
```

### 示例：启用代码签名

```yaml
- name: Build PixelClock
  run: |
    xcodebuild -project PixelClock.xcodeproj \
      -target PixelClock \
      -configuration Release \
      CODE_SIGN_IDENTITY="${{ secrets.CODE_SIGNING_CERTIFICATE }}" \
      CODE_SIGNING_REQUIRED=YES \
      CODE_SIGNING_ALLOWED=YES
```

注意：使用代码签名需要将证书和配置文件存储为 GitHub Secrets。

## 参考资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Xcode 构建系统文档](https://developer.apple.com/documentation/xcode/build-system)
- [act 工具](https://github.com/nektos/act)
