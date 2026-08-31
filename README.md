# docker-base

维护镜像配方、构建入口和验证约定。业务代码、RAW 数据、模型权重、deb 包及
预装环境不放入 Git；大型输入由仓库外的 BuildKit named context 提供。

## 目录与镜像

`thirdparty/` 面向上游软件，包括原样镜像同步和自行封装；`platform/` 面向内部
维护的运行环境或工具链组合。目录名不一定等于镜像名，以下映射为准。

| 配方/工具目录 | 目标镜像（省略 REGISTRY） | 本地入口 / 输入 |
| --- | --- | --- |
| thirdparty/python | thirdparty/python | python38-slim-mirror：拉取、打标并**推送** |
| thirdparty/signalp6 | thirdparty/signalp6 | signalp6-build / signalp6_package |
| platform/core-runtime | platform/core-runtime | runtime-build / thirdparty/python |
| platform/core-build | platform/core-build | build-build / core-runtime |
| platform/core-runtime-lo | platform/core-runtime（LO tag） | runtime-lo-build / core-runtime + lo_debs |
| platform/trait-association-cli | platform/trait-association-cli | trait-association-cli-build / LO runtime + trait_association_cli_env |
| platform/mono-runtime | platform/mono-runtime | mono-build / 固定 digest 的 Harbor Ubuntu |
| releases | 发布记录，不是构建输入 | 见 releases/README.md |

## 构建和检查

从仓库根目录运行；单独 `make` 只显示帮助，不再隐式构建镜像。

```bash
make check
make mono-build REGISTRY=192.168.30.202:23099
make mono-smoke REGISTRY=192.168.30.202:23099
```

`REGISTRY` 的历史默认值仍为 `ghcr.io/fuqingzh`。现有 target 和镜像地址保持不变。
简单配方使用各自目录作 context；需要外部 named context 的配方使用仓库根目录。
两种 context 都必须保持小体积，依赖包不要复制到配方目录。

`make check` 使用 Bash、GNU Make 和 Python 3 标准库，检查 shell 语法、构建入口的
本地/发布边界以及 Mono 检查脚本的失败传播。它不是 Dockerfile linter，也不证明
所有镜像可以运行。修改配方后应构建对应镜像并运行其实际能力检查；Mono 见
[专用说明](platform/mono-runtime/README.md)。现有其他镜像不因这次整理而自动获得
重新验证或依赖锁定的声明。

默认 `NO_PROXY_BUILD=1` 清空构建代理；确有需要时显式设为 `0`，使用当前代理环境。
不要把代理凭据写入 Dockerfile、文档或版本库。

## 发布边界

`*-build` 仅本地构建；`*-push` 才推送。历史 `*-buildx-push` 会构建并推送，
`python38-slim-mirror` 会同步并推送，`promote-stable` 会更新远程 stable 标签。
`all-buildx-push` 仅覆盖 core-runtime 和 core-build，并非所有镜像。
这些入口均需明确发布授权，不属于 `make check` 或 smoke 测试。

使用固定版本 tag；基础 digest、包清单和本地 image ID 用于追溯。
本地验证与远端发布分别记录，不把本地构建当作 Harbor 已发布。
