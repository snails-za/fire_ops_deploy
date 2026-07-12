# fire_ops_deploy

`fire_ops_deploy` 是消安云管系统的 Docker Compose 部署目录，负责拉起后端服务、Web 前端、Redis、PostgreSQL 和 Qdrant。

## 文件说明

```text
fire_ops_deploy/
├── docker-compose.yml          # ARM 环境部署配置
├── docker-compose-x86.yml      # x86 环境部署配置
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

| 服务 | 容器名 | 说明 | 对外端口 |
| --- | --- | --- | --- |
| `fire_ops` | `fire_ops` | 后端 API 服务 | `18000:8000` |
| `front_html` | `front_html` | Web 前端 Nginx | `80:80`、`443:443` |
| `redis` | `redis` | 缓存和 Celery broker | `16379:6379` |
| `postgres` | `postgres` | PostgreSQL 数据库 | `15432:5432` |
| `qdrant` | `qdrant` | 向量数据库 | `16333:6333`、`16334:6334` |

Elasticsearch 和 Kibana 配置目前保留为注释，当前 compose 不会启动。

## 启动

ARM 环境：

```bash
docker compose -f docker-compose.yml up -d
```

x86 环境：

```bash
docker compose -f docker-compose-x86.yml up -d
```

查看日志：

```bash
docker compose -f docker-compose.yml logs -f
```

## HTTPS 证书

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

这两个文件会被 `front_html` 容器挂载到 Nginx。

## 镜像导出

导出 x86 镜像：

```bash
./save_image.sh
```

导出 ARM 镜像：

```bash
./save_image_arm.sh
```

脚本会读取对应 compose 文件中的未注释 `image:` 行，拉取镜像后打包到 `images/` 目录。

## 配置

主要环境变量在：

```text
data/global_config/global_config.env
```

这里包含 PostgreSQL、Redis、OpenAI 兼容接口、向量库、OCR 和搜索阈值等配置。生产环境提交前需要确认敏感信息是否应该进入版本库。

