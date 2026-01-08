# 推送到 GitHub - 认证配置

代码已提交到本地仓库，但推送到 GitHub 需要认证。

## 方法 1: 使用 Personal Access Token（推荐）

1. **创建 GitHub Token**
   - 访问 https://github.com/settings/tokens
   - 点击 "Generate new token" -> "Generate new token (classic)"
   - 选择权限：
     - ✓ `repo` (完整仓库访问权限）
     - ✓ `workflow` (运行 GitHub Actions）
   - 设置过期时间（如 90 天）
   - 复制生成的 token（只显示一次！）

2. **推送代码**
   ```bash
   # 方法 A: 在 URL 中包含 token
   git push https://YOUR_TOKEN@github.com/free-pixel/PixelClockApp.git master
   
   # 方法 B: 使用 credential helper（推荐）
   git config credential.helper store
   git push https://github.com/free-pixel/PixelClockApp.git master
   # 输入用户名：free-pixel
   # 输入密码：粘贴刚才复制的 token
   ```

## 方法 2: 使用 SSH 密钥

1. **生成 SSH 密钥**
   ```bash
   ssh-keygen -t ed25519 -C "iestone@yeah.net"
   ```

2. **添加公钥到 GitHub**
   ```bash
   # 查看公钥
   cat ~/.ssh/id_ed25519.pub
   ```
   - 访问 https://github.com/settings/ssh
   - 点击 "New SSH key"
   - 粘贴公钥内容

3. **更改远程 URL**
   ```bash
   git remote set-url origin git@github.com:free-pixel/PixelClockApp.git
   ```

4. **推送代码**
   ```bash
   git push origin master
   ```

## 方法 3: 使用 GitHub CLI

```bash
# 安装 gh CLI（如果未安装）
brew install gh

# 登录
gh auth login

# 推送代码
git push origin master
```

## 推送成功后的后续步骤

1. **查看 Actions 运行**
   - 访问 https://github.com/free-pixel/PixelClockApp/actions
   - 查看工作流运行状态

2. **创建 Release（可选）**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   - 访问 https://github.com/free-pixel/PixelClockApp/releases

## 当前提交信息

提交哈希：`30d35a2`
分支：`master`
更改：
- 19 个文件被修改
- 1950 行添加
- 684 行删除

## 快速推送命令（选择一个）

```bash
# 选项 1: 使用 token（替换 YOUR_TOKEN）
git push https://YOUR_TOKEN@github.com/free-pixel/PixelClockApp.git master

# 选项 2: 配置 credential 后推送
git config credential.helper store
git push https://github.com/free-pixel/PixelClockApp.git master

# 选项 3: 使用 SSH（需要先配置）
git remote set-url origin git@github.com:free-pixel/PixelClockApp.git
git push origin master
```

## 推送后将自动触发

- ✅ CI 工作流：构建和测试
- ✅ 显示构建状态在 Actions 页面
- ✅ 生成构建摘要
