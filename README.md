# fire_ops_deploy

`fire_ops_deploy` 是消安云管系统的 Docker Compose 部署目录，负责拉起后端服务、Web 前端、Redis、PostgreSQL 和 Qdrant。

## 架构约定

| 文件 | 用途 |
| --- | --- |
| `docker-compose.yml` | **默认 x86** 主配置（改业务只改这个） |
| `docker-compose-arm.yml` | ARM **差异层**，与主配置合并后启动 |

x86 上改 volumes、env、`extra_hosts`、nginx 挂载等，ARM 会自动继承；ARM 文件只保留镜像、端口、HTTPS 证书等平台差异。

## 文件说明

```text
fire_ops_deploy/
├── docker-compose.yml          # 默认 x86 部署配置
├── docker-compose-arm.yml      # ARM 差异层（合并 x86 主配置）
├── build.sh                    # 构建 fire_ops:dp 镜像
├── generate-https-cert.sh      # 生成前端 Nginx 使用的自签名 HTTPS 证书
├── save_image.sh               # 导出 x86 compose 中使用的镜像
├── save_image_arm.sh           # 导出 ARM compose 中使用的镜像
├── portainer-agent.yml         # Portainer agent 配置
└── data/
    ├── fire_ops/               # 后端数据和日志挂载目录
    ├── front_html/             # 前端证书、日志、安装包目录
    ├── global_config/          # 容器环境变量
    ├── postgres/               # PostgreSQL 数据目录
    ├── qdrant/                 # Qdrant 数据目录
    └── redis/                  # Redis 数据目录
```

## 服务组成

### x86（默认）

| 服务 | 容器名 | 说明 | 对外端口 |
| --- | --- | --- | --- |
| `fire_ops` | `fire_ops` | 后端 API 服务 | 仅容器内 `8000`（由 front_html 反代） |
| `front_html` | `front_html` | Web 前端 Nginx | `8892:80` |
| `redis` | `redis` | 缓存和 Celery broker | 不暴露 |
| `postgres` | `postgres` | PostgreSQL 数据库 | 不暴露 |
| `qdrant` | `qdrant` | 向量数据库 | 不暴露 |

### ARM（合并后）

| 服务 | 容器名 | 说明 | 对外端口 |
| --- | --- | --- | --- |
| `fire_ops` | `fire_ops` | 后端 API 服务 | `18000:8000` |
| `front_html` | `front_html` | Web 前端 Nginx（含 HTTPS） | `80:80`、`443:443` |
| `redis` | `redis` | 缓存和 Celery broker | `16379:6379` |
| `postgres` | `postgres` | PostgreSQL 数据库 | `15432:5432` |
| `qdrant` | `qdrant` | 向量数据库 | `16333:6333`、`16334:6334` |

Elasticsearch 和 Kibana 配置目前保留为注释，当前 compose 不会启动。

## 启动

构建后端镜像（`fire-admin` 在 fire-admin 仓库单独构建）：

```bash
bash build.sh
```

x86 环境（默认）：

```bash
docker compose up -d
```

ARM 环境：

```bash
docker compose -f docker-compose.yml -f docker-compose-arm.yml up -d
```

查看日志：

```bash
# x86
docker compose logs -f

# ARM
docker compose -f docker-compose.yml -f docker-compose-arm.yml logs -f
```

## HTTPS 证书（ARM）

生成自签名证书：

```bash
./generate-https-cert.sh <domain-or-ip>
```

示例：

```bash
./generate-https-cert.sh 192.168.101.155
./generate-https-cert.sh admin.example.com
```

脚本会生成：

```text
data/front_html/cert.pem
data/front_html/private.key
```

这两个文件会被 ARM 的 `front_html` 容器挂载到 Nginx。

## 镜像导出

导出 x86 镜像：

```bash
./save_image.sh
```

导出 ARM 镜像：

```bash
./save_image_arm.sh
```

脚本会读取对应 compose 合并结果中的 `image:`，拉取镜像后打包到 `images/` 目录。

## 配置

主要环境变量在：

```text
data/global_config/global_config.env
```

这里包含 PostgreSQL、Redis、OpenAI 兼容接口、向量库、OCR 和搜索阈值等配置。生产环境提交前需要确认敏感信息是否应该进入版本库。
