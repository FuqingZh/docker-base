# 发布记录

`ledger.tsv` 记录已完成远端读回验证的镜像发布；未列出的镜像不据此声明已发布。
发布时记录日期、目标 tag、源码 revision（dirty 状态需标明）、本地 image ID、
远端 manifest digest 和验证记录位置。未推送的本地构建报告留在仓库外测试输出目录，
不得填入伪造的远端 digest。

2026-08-31 Mono 首次发布已验证 Harbor manifest 的 config digest 等于本地 image ID。
镜像构建发生在源码提交之前；提交 `73d5862` 中的 Dockerfile、smoke.cs、检查脚本
与已构建文件的 SHA256 一致。该记录不是“CI 从 clean checkout 构建”的声明。
RAW 技术验收包含 54,889 条光谱、2,264 条 MS1 和非空 Base Peak 色谱，非真实 QC
重复性结论。测试宿主机的日志位置仅用于追溯，不是其他环境的运行依赖。
