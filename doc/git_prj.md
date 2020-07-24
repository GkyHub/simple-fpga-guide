# 使用Git来管理工程

代码开发过程中实行版本管理是非常必要的。Git作为目前较为主流的版本管理工具，在程序员中非常普及。个人用户也可以在GitHub上享受到免费的仓库服务。但是对于FPGA项目，项目文件中非文本文件多，且体积大，因此不适合直接采用Git维护所有文件。因此在维护时需要采用一些辅助手段。

FPGA开发中常见的工程包括Vivado工程、HLS工程、SDK工程、Petalinux工程等。为了进行仿真，用户也需要自己的Golden Model比如C或Python工程。维护这些工程不在本文的范围内。

1. [Vivado工程管理](git_vivado_prj.md)
2. [HLS工程管理](git_hls_prj.md)
3. SDK工程管理（待补充）
4. [Petalinux工程管理](git_petalinux_prj.md)