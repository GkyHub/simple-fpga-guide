# 使用Git管理petalinux工程
参考内容：[UG1144](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug1144-petalinux-tools-reference-guide.pdf)，官方目前正在完善版本管理流程，以下内容仅供参考。

1. 建立petalinux工程并初始化
   ``` bash
   petalinux-create -t project --name <prj-name> --template zynqMP # or any way you like
   cd <prj-name>
   git init
   ```
2. petalinux已经默认提供了.gitignore文件，内容如下：
   ```
   */*/config.old
   */*/rootfs_config.old
   build/
   images/linux/
   pre-built/linux/
   .petalinux/*
   !.petalinux/metadata
   *.o
   *.jou
   *.log
   project-spec/meta-plnx-generated/
   /components/plnx_workspace
   ```
3. 在git commit之前，使用如下命令清理工作区。但是这可能会导致下一次petalinux-build的时间大幅增加，所以目前应该避免频繁提交。
   ``` bash
   petalinux-build -x mrproper
   ```