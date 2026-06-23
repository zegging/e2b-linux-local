# e2b-linux-local

这是一个用于在单台 Ubuntu bare-metal 主机上运行 E2B local sandbox 的轻量部署器。

它仍然以英文命令、服务名和配置名为主，中文部分主要解释用途、流程和注意事项。完整实现以主 README 和脚本为准。

## 这个项目解决什么问题

E2B 官方 infra 主要提供 AWS/GCP provider 路径，而这个仓库只聚焦 **single-host Linux local deployment**。

它把 upstream E2B `DEV-LOCAL.md` 里的 bare-metal 流程整理成更接近 IaC 的生命周期：

```bash
make init
make plan
make apply
make status
make destroy
```

当前目标不是完整替代 `provider-aws` 或 `provider-gcp`，也不是多机生产集群。它的定位是：

- 单台 Ubuntu 主机
- 本机 Docker Compose local infra
- systemd 后台运行 orchestrator / API / client proxy
- Firecracker 通过 `/dev/kvm` 启动 microVM sandbox
- 用 Makefile 提供可重复执行的操作入口

## 前置条件

Ubuntu 主机需要满足：

- 已 clone upstream `e2b-dev/infra`
- `/dev/kvm` 可用
- `/dev/net/tun` 可用
- cgroup v2
- 足够磁盘空间
- Docker 可用并能拉取所需镜像
- Go / Node / npm / make / curl / jq 等基础工具可用

可以先运行：

```bash
make plan
```

它会执行 preflight，并打印当前部署计划。

## 安装

在 Ubuntu 主机上 clone 本仓库：

```bash
mkdir -p ~/src
cd ~/src
git clone https://github.com/zegging/e2b-linux-local.git
cd e2b-linux-local
chmod +x scripts/*.sh
```

初始化配置文件：

```bash
make init
sudo nano /etc/e2b-linux-local.env
```

至少需要配置：

```bash
E2B_ROOT=/path/to/e2b-infra
E2B_API_KEY=<LOCAL_DEV_API_KEY>
```

`E2B_ROOT` 指向 upstream `e2b-dev/infra` 仓库路径。  
`E2B_API_KEY` 是 upstream local-dev seed database 生成的本地开发 API key。

## 部署流程

先查看计划：

```bash
make plan
```

如果主机缺基础依赖，可以执行：

```bash
make install-deps
```

首次部署时下载 E2B runtime artifacts：

```bash
make download-artifacts
```

应用部署：

```bash
make apply
```

`make apply` 会完成：

- 配置 host runtime settings
- 安装 systemd units
- enable services
- 按顺序启动 local infra、orchestrator、API、client proxy

## 服务管理

常用命令：

```bash
make start
make stop
make restart
make status
```

查看日志：

```bash
make logs SERVICE=orchestrator
make logs SERVICE=api
make logs SERVICE=client-proxy
```

也可以直接使用 systemd：

```bash
journalctl -u e2b-orchestrator -f
journalctl -u e2b-api -f
journalctl -u e2b-client-proxy -f
```

健康检查：

```bash
curl -s http://localhost:5008/health && echo
curl -s http://localhost:3000/health && echo
curl -s http://localhost:3003/health && echo
```

## 构建 base template

首次部署后需要构建 base template：

```bash
make build-base
```

注意：第一次 `local-build-base-template` 可能非常慢。它会拉取基础镜像、解压 layer，并创建 Firecracker rootfs。实际运行中可能需要几十分钟。

成功一次后，通常不需要每次重启都重新构建。

## 创建 sandbox

创建一个测试 sandbox：

```bash
make create-sandbox TIMEOUT=3600
```

如果从其他机器访问 API，可以直接调用：

```bash
curl -s -X POST http://<server-ip>:3000/sandboxes \
  -H "X-API-Key: <LOCAL_DEV_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"templateID":"base","timeout":3600}'
```

注意：创建 sandbox 时建议显式传 `timeout`。local dev 默认 timeout 可能很短。

## IaC 目录

单机 IaC contract 放在：

```text
iac/linux-local/
```

其中：

- `README.md` 描述 lifecycle 和当前管理的本地资源。
- `e2b-linux-local.env.example` 是公开配置模板。

当前 `destroy` 默认只停止并 disable services，不删除数据：

```bash
make destroy
```

更具破坏性的清理需要显式环境变量，见 `scripts/destroy.sh`。

## 端口说明

- `3000`: E2B API
- `3002`: SDK 使用的 sandbox URL
- `3003`: client proxy health endpoint
- `5008`: orchestrator health endpoint

## 当前边界

这个项目目前不处理：

- 多机调度
- Nomad/Consul cluster provisioning
- DNS/TLS
- external object storage / MinIO
- registry management
- secrets backend integration
- wildcard sandbox domains

这些属于未来真正 `provider-linux` 的范围。
