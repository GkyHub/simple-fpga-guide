# 在Zynq MPSoC开发板上烧写FPGA逻辑并启动Linux

本教程参考内容包括：
- [https://blog.csdn.net/jiangjiali66/article/details/46897505](https://blog.csdn.net/jiangjiali66/article/details/46897505)
- [https://blog.csdn.net/lulugay/article/details/83867655](https://blog.csdn.net/lulugay/article/details/83867655)
- [https://blog.csdn.net/lulugay/article/details/83240981](https://blog.csdn.net/lulugay/article/details/83240981)

## 准备FPGA部分
1. 进入Vivado工程，运行Generate bitstream
2. 导出工程至SDK，```File->Export->Export Hardware...```。选择路径时可以选择local to project或任意位置。选择include bitstream。

以上步骤完成后，会在导出位置生成xxx.hdf文件。

## 准备镜像部分
1. 建立工程
   ```bash
   petalinux-create -t project --name <project-name> --template zynqMP
   ```
   如果有板卡的BSP，可以采用BSP建立工程
   ```bash
   petalinux-create -t project -s <path-to-bsp>
   ```
   工程建立之后，会在当前路径下建立一个包含工程的文件夹。

2. 配置硬件及kernel（开发板可以选用默认选项不配置）
   ``` bash
   cd <path-to-project>
   petalinux-config --get-hw-descroption <path-to-folder-of-hdf>
   ```
   petalinux默认的启动方式是initramfs，即将文件系统加载到内存中运行，而不会从SD卡中读取文件系统。因此需要单独配置启动方式。运行上面一条指令后会默认进入配置界面，需要配置以下内容：
   - 取消勾选```DTG Settings->Kernel Bootargs->generate boot args automatically```
   - 设置boot args为：```console=ttyPS0,115200 root=/dev/mmcblk0p2 rw earlyprintk rootfstype=ext4 rootwait```
   - 设置```Image Packaging Configurations->Root filesystem type```为```SD Card```

   如果需要对内核进行其他配置，请根据[UG1144](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug1144-petalinux-tools-reference-guide.pdf)执行。一些常用的配置可以参考Xilinx wiki提供的一个[教程](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841937/Zynq+UltraScale+MPSoC+Ubuntu+part+2+-+Building+and+Running+the+Ubuntu+Desktop+From+Sources)。

3. 编译（通常时间较长10-30分钟）
   ``` bash
   petalinux-build
   ```
   该过程会生成一系列文件，在```<path-to-project>/images/linux```文件夹内。

4. 打包镜像
   ``` bash
   petalinux-package --boot --format BIN \
       --fsbl   ./images/linux/zynqmp_fsbl.elf \
       --u-boot ./images/linux/u-boot.elf \
       --pmufw  ./images/linux/pmufw.elf \
       --fpga   ./images/linux/*.bit \
       --force
   ```

## 准备SD卡

1. 第一使用SD卡时需要对SD卡进行格式化和分区。启动gparted，将SD卡分为两个分区：
   - BOOT分区：格式为FAT32，大小自定义，通常为几百MB，够用即可
   - ROOTFS分区：格式为EXT4，分配全部剩余空间即可

2. 将BOOT必要的文件拷贝到SD卡中
   ```bash
   cd <path-to-petalinux-project>/images/linux
   cp BOOT.BIN image.ub <path-to-BOOT-of-SDCARD>
   ```

3. 拷贝文件系统。可以使用```<path-to-petalinux-project>/images/linux```下的rootfs.tar.gz，也可以自己下载文件系统，例如从：[https://rcn-ee.com/rootfs/eewiki/minfs/](https://rcn-ee.com/rootfs/eewiki/minfs/)。之后将文件系统解压缩，运行如下命令：
   ```bash
   cd <path-to-rootfs>
   # 将文件系统复制到ROOTFS分区中，注意不可以使用cp
   sudo rsync -av ./ <path-to-ROOTFS-of-SDCARD>
   # 清空缓冲区，确保文件写入SD卡
   sync
   # 修改权限，否则启动以后会出问题
   sudo chown root:root <path-to-ROOTFS-of-SDCARD>
   sudo chmod 755 <path-to-ROOTFS-of-SDCARD>
   ```

## 启动板卡

1. 板卡根据需要调节为从SD卡启动的模式
2. 连接板卡至主机。如果通过串口，可能需要串口驱动。第一次启动时无法通过网络连接，需要设置IP后才可以。有相应接口的板卡也可以直接接显示器和鼠标键盘来独立启动。
3. 插入SD卡，启动板卡。
4. 通过串口或SSH连接硬件。



