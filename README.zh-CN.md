# Webtor NAS 简体中文界面

本仓库是 `webtor-io/web-ui` 的 fork，为 Webtor 自建版增加简体中文。

## 汉化范围

- 已翻译 1,548 个条目：首页、导航、管理员登录、资源列表、下载与缓冲提示、播放器、音轨与字幕、媒体库、永久存储、个人设置、发现页面、通知、邮件和集成指南。
- 中文语言代码为 `zh`，语言菜单显示“简体中文”。支持浏览器语言识别，也可直接访问 `/zh/`。
- 扩展工具页面的长篇介绍文章暂保留英文回退；影片标题、剧情简介及第三方插件结果由内容来源提供，不由界面语言包翻译。
- 自建实例无需购买 webtor.io 在线服务套餐。翻译保留上游在线服务专用的付款文案，不改变其权限或计费逻辑。AI 等可选功能仍需要自行配置服务和密钥。

## NAS 一体化镜像

`.github/workflows/docker-image.yml` 使用 `Dockerfile.nas` 构建完整自建版镜像，保留官方 BT 下载、转码、数据库和存储服务，仅替换网页服务及其静态资源。

支持 `linux/amd64` 与 `linux/arm64`。镜像首次成功构建且包可公开拉取后，使用：

```text
ghcr.io/yuanbaian/webtor-zh:latest
```

在 GitHub 的 Actions 页面查看构建状态。新 fork 的工作流可能需要在网页上启用。首次发布的 GHCR 包若不是 Public，需要仓库所有者在包设置中改为 Public，或者在 NAS 上登录 GHCR 后拉取。

## 替换你已经运行的 Webtor

1. 编辑原有的 `webtor` Compose 项目，不要删除数据卷。
2. 只将 `image` 替换为上述中文镜像。
3. 保留原来的 `DOMAIN`、管理员密码、端口和三个数据卷映射。
4. 拉取新镜像并重建容器，完成后打开 `http://192.168.31.120:8085/zh/`。

仓库中的 `compose.nas.yml` 是新安装示例。旧安装应编辑原项目，以继续使用 `webtor_webtor-data`、`webtor_webtor-pgdata`、`webtor_webtor-storage` 等原有卷。

### 本地构建

```bash
docker build -f Dockerfile.nas -t webtor-zh:local .
```

将 Compose 中的 `image` 改为 `webtor-zh:local` 即可使用本机构建结果。构建需要联网获取上游镜像、Go 与 npm 依赖。

### 存储

- `/data`：种子下载缓存。
- `/pgdata`：账号、设置和媒体库数据库。
- `/storage`：海报、字幕和永久存储内容，应继续使用 Docker 命名卷。

## 更新上游

合并上游更新后，应检查 `locales/en.json` 的新增键，并补齐 `locales/zh.json`。运行现有语言包检查和前端构建：

```bash
go test ./services/i18n
npm ci
npm run build
```

一体化镜像基于上游 `self-hosted:latest`，上游变化后需重新验证服务之间的兼容性；回滚镜像前请先备份数据库和存储卷。
