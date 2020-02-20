# 使用Git来管理FPGA工程

代码开发过程中实行版本管理是非常必要的。Git作为目前较为主流的版本管理工具，在程序员中非常普及。个人用户也可以在GitHub上享受到免费的仓库服务。但是对于FPGA项目，项目文件中非文本文件多，且体积大，因此不适合直接采用Git维护所有文件。因此在维护时需要采用一些辅助手段。

## Vivado工程

参考内容：http://xilinx.eetrend.com/content/2020/100047180.html

Vivado工程中通常包含大量的非文本文件，如例化的IP以及Block Design等。这些文件或是工程本身都可以通过tcl脚本来自动生成，因此我们可以采用维护tcl脚本辅助的方式来维护工程。维护工程的核心思路是分开管理项目、源文件以及脚本。项目的基本结构如下：

```
project_folder
  |
  |--prj        // 存放vivado工程，该文件夹下的内容通过tcl脚本自动生成
  |--scripts    // 存放维护工程的脚本
  |--src        // 存放工程源文件
``` 

我们在prj文件夹下新建一个工程project_1，进入vivado IDE界面后我们在Tcl Console中输入如下指令：

``` tcl
write_project_tcl {../scripts/create_prj.tcl}
```

## petalinux工程

## HLS工程