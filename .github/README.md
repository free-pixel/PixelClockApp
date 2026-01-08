# GitHub Actions Configuration

此目录包含 PixelClock 项目的 GitHub Actions 工作流配置。

## 工作流文件

| 文件 | 描述 | 触发条件 |
|------|------|---------|
| `build.yml` | 常规构建工作流 | push, pull_request, manual |
| `test.yml` | 单元测试工作流 | push, pull_request |
| `release.yml` | 发布构建工作流 | tag push, manual |

## 快速开始

### 首次推送

1. 将代码推送到 GitHub 仓库
2. GitHub Actions 会自动触发构建和测试
3. 在 Actions 标签页查看构建状态

### 创建 Release

```bash
# 更新代码
git add .
git commit -m "Update for release"
git push

# 创建版本标签
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 将自动创建 Release 并上传构建产物。

## 使用说明

详细的使用说明请参考 [README.md](./README.md)。

## 相关文档

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [工作流语法](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [项目 AGENTS.md](../../AGENTS.md)
