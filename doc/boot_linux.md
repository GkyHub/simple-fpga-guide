# 在Zynq MPSoC开发板上烧写FPGA逻辑并启动Linux

本教程参考内容包括：
- [https://blog.csdn.net/jiangjiali66/article/details/46897505](https://blog.csdn.net/jiangjiali66/article/details/46897505)
- [https://blog.csdn.net/lulugay/article/details/83867655](https://blog.csdn.net/lulugay/article/details/83867655)
- [https://blog.csdn.net/lulugay/article/details/83240981](https://blog.csdn.net/lulugay/article/details/83240981)

在最后一部分，我们会对流程中的细节和具体发生了什么事情进行说明。

## 准备FPGA部分
1. 进入Vivado工程，运行Generate bitstream
2. 导出工程至SDK，```File->Export->Export Hardware...```。选择路径时可以选择local to project或任意位置。选择include bitstream。

以上步骤完成后，会在导出位置生成xxx.hdf文件。

```
注意：确保镜像能正确启动的关键是工程中的Zynq MPSoC这个IP的配置要和板卡一致！对于开发板，通常在工程中选择板卡类型后，Vivado可以提供一组预设值。对于定制的板卡，需要根据原理图配置DDR和I/O的部分。
```

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

3. 编译（第一次时间较长，10-30分钟，以后可以增量编译）
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

## 配置文件系统

经过以上几步，已经可以在FPGA板卡上启动linux，但是一些基本的功能很可能还不全。在FPGA板卡上安装一些基本程序会比较麻烦。因此，可以参考[https://blog.csdn.net/telantan/article/details/73928695](https://blog.csdn.net/telantan/article/details/73928695)，在文件系统放到SD卡上之前预先进行一些配置。

## Note

1. Vivado导出的hdf文件决定了：
    - Zynq上CPU的I/O配置
    - CPU和FPGA的通信方式，包括AXI和中断
    - FPGA上的逻辑
   第一项决定了CPU能不能正确启动，第二和第三项决定了CPU和FPGA能否正确通信。如果只是想启动板卡，做简单的boot测试，可以只建立一个包含单一Zynq MPSoC IP的工程。

2. petalinux建立工程时，选择template相当于空工程。选择BSP则是导入一个已有的工程。BSP可以包含一些预置的配置，以便在不同的项目之间复用。

3. ```--get-hw-description```的配置和```-c kernel```可以认为是独立的，不具有先后顺序。前者会觉得设备树、启动方式等；后者是决定内核中包含哪些驱动。

4. SD卡启动时，会从第一个分区里面找image.ub和BOOT.bin，然后根据配置的启动参数挂载根目录。文件系统和BOOT分区里面的东西关系不大，大多数时候可以随意替换ROOTFS，但需要时针对ARM编译的。

5. 拷贝文件系统时，为了把软链接也正确复制过去，不能使用cp。



