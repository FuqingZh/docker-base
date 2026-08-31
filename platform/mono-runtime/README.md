# Mono runtime

基于 Harbor `thirdparty/ubuntu:24.04` 的 linux/amd64 镜像，默认固定基础 manifest
digest，安装 Ubuntu Noble 的 `mono-complete=6.8.0.105+dfsg-3.6ubuntu2`。
这是 Ubuntu 打包的 Mono 6.8，不是 Docker Hub 的 Mono 6.12 镜像。
先保留完整 framework 集合（含开发工具），不以手工补单个 DLL 的方式裁剪依赖。

```bash
make check
make mono-build REGISTRY=192.168.30.202:23099
make mono-smoke REGISTRY=192.168.30.202:23099
```

构建需要 Ubuntu apt 源；该配方不是离线构建。基础 digest 和 Mono 主包固定，
其他依赖随 Ubuntu 仓库更新，完整安装版本记录于 `/opt/mono-runtime/packages.tsv`，
基础来源记录于 `/opt/mono-runtime/build-info.txt`。这些记录不等于全部依赖已锁定。
升级基础或 Mono 时，更新 Makefile 与 Dockerfile 默认值，并重新运行能力验收。

若宿主机代理仅监听 loopback，Linux 上可以显式启用构建阶段 host 网络：
`make mono-build REGISTRY=192.168.30.202:23099 NO_PROXY_BUILD=0 MONO_BUILD_NETWORK=host`。
代理来自当前环境，不写入镜像；默认仍使用隔离的构建网络。apt 索引下载失败即失败，
不接受缺失的索引继续安装。

`check-mono` 在构建时和容器启动测试时执行真实 DataTable/Select 操作，异常或
非零退出向上传播。`make mono-smoke` 禁止联网和自动拉取，默认限制 4 CPU / 2 GiB。
这项单元级能力检查不代替 Thermo RAW 转换。

## Thermo RAW 外部验收

此镜像不包含 ThermoRawFileParser、RAW、R 或 serum 业务代码。使用获授权的
外部程序目录只读挂载；在宿主机指定实际路径和已创建的输出目录，例如：

```bash
docker run --rm --init --network=none --cpus=4 --memory=16g --pids-limit=256 \
  -v /absolute/parser-directory:/parser:ro \
  -v /absolute/raw-directory:/raw:ro \
  -v /absolute/output-directory:/out \
  192.168.30.202:23099/platform/mono-runtime:ubuntu24.04-mono6.8.0.105-20260831 \
  timeout 20m mono /parser/ThermoRawFileParser.exe -i /raw/QC_1.raw -o /out -f 1
```

验收必须同时检查退出码、异常日志、完整可解析的 mzML、spectra 和 chromatograms，
不能以外层脚本退出 0 或“图已生成”代替。旧 QC 包装脚本忽略 converter 失败；
新镜像单独构建不会自动修复该包装脚本或改变 WDL 使用的镜像。
样本复制成 QC 只适合技术测试，不能证明真实 QC 重复性。

构建与推送分离；经批准才执行 `make mono-push REGISTRY=192.168.30.202:23099`。
