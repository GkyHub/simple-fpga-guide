# 搭建Xilinx FPGA开发环境
未注明时，本文默认工作环境为Linux(Ubuntu/CentOS/...)系统。在开始安装环境之前，建议[注册Xilinx官方账号](https://china.xilinx.com/registration/create-account.html)，方便下载相应文件。

Xilinx FPGA开发中主要用到以下几个软件：
- **Vivado**：Xilinx的官方集成开发环境，完整版包含RTL/Block Design/HLS等开发方式，且包含仿真/综合/布局布线工具等。
- **Petalinux(可选)**：用于制作FPGA SoC的linux系统内核的工具。使用Micro Blaze软核或Zynq系列的芯片时，需要运行linux系统则必备。仅限Linux系统安装。
- **第三方仿真软件(可选)**：Vivado支持联合第三方仿真软件来进行系统仿真，诸如ModelSim/Synopsys VCS等软件都可以提供较好的仿真体验。当需要使用Xilinx的IP进行联合仿真时，需要通过Vivado预先编译好用于第三方软件的仿真库。
- **第三方综合软件（可选）**：Vivado支持使用第三方综合软件来生成网表，如symplify。
- **辅助软件以及驱动**

## 安装Vivado
1. 下载所需版本的Vivado安装文件。官方下载地址: [https://china.xilinx.com/support/download.html](https://china.xilinx.com/support/download.html)
2. 获取license(请各凭本事)。如果从官方购买了板卡，官方通常会提供一份license。
3. 运行安装程序，安装过程中根据需要选择版本以及所需组件(在硬盘空间不紧缺的情况下，建议选择System Edition版本，组件用默认选项即可)。安装时间较长。
4. 安装完成后，会自动进入Vivado License Manager(如果不小心关掉了，可以之后打开vivado，通过Help->License Manager进入)。选择Load License项，选择license文件。之后选择View License Status，看到可用的IP列表，即表示加载成功。
5. 在命令行执行以下命令将vivado添加到路径中，同时建议将该命令添加到~/.bashrc文件中以便命令行启动时自动添加该路径：
    ```bash
    source <path-to-vivado>/settings64.sh
    ```
6. 在命令行中运行以下命令开启Vivado:
   ```bash
   vivado &
   ```

注意：不同版本的Vivado并不冲突，只需要设置相应的路径即可完成切换。具有充足空间的服务器可以考虑保留多个版本的Vivado方便兼容不同的工程。

## 安装petalinux
参考资料：[UG1144](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug1144-petalinux-tools-reference-guide.pdf)
1. 下载所需版本的petalinux。petalinux的版本需要和Vivado的版本对应。官方下载地址: [https://china.xilinx.com/support/download/index.html/content/xilinx/zh/downloadNav/embedded-design-tools.html](https://china.xilinx.com/support/download/index.html/content/xilinx/zh/downloadNav/embedded-design-tools.html)
2. 根据UG1144中的说明安装所需的库。手册中会给出对应操作系统所需要运行的命令行代码。例如对于ubuntu：
   ```bash
   sudo apt-get install -y gcc git make net-tools libncurses5-dev tftpd zlib1g-dev libssl-dev flex bison libselinux1 gnupg wget diffstat chrpath socat xterm autoconf libtool tar unzip texinfo gcc-multilib build-essential zlib1g:i386 screen pax gzip
   ```
3. 直接运行下载后的文件，在命令行中指定安装位置。注意：不能使用sudo权限或以root身份安装；安装的位置需要在当前用户的权限范围内。
   ```bash
   ./petalinux-v{xxxx.x}-final-installer.run <install-path>
   ```
4. 在命令行执行以下命令将petalinux添加到路径中，同时建议将该命令添加到~/.bashrc文件中以便命令行启动时自动添加该路径：
    ```bash
    source <path-to-petalinux>/settings.sh
    ```
5. 运行以下命令验证配置是否成功，正确时返回安装路径：
   ```bash
   echo $PETALINUX
   ```

## 辅助软件及驱动
* [CP210x USB转串口](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers)：用于通过串口连接ZCU102开发板。
* [SD卡镜像烧写软件(Windows)](https://www.balena.io/etcher/)：烧写完整img格式镜像至SD卡。
* SD卡分区软件(Linux)：SD卡格式化及分区。可以直接安装：
  ```bash
  sudo apt-get install gparted
  ```

## Trouble Shooting

官方手册一般会给一些trouble shooting的内容，但是还可能出现一些漏洞，这里给出一些补充：

1. Vivado的卸载
2. Petalinux安装问题：无法找到zlib1g:i386。原因：主机是amd64架构，默认镜像不包含i386的包，需要单独添加。解决方法：
    ``` bash
    sudo dpkg --add-architecture i386
    sudo apt-get update
    ```
3. Petalinux安装问题：awk(bad read address)。原因：缺少gawk库。解决方法：
    ``` bash
    sudo apt-get install gawk
    ```
4. 由于Petalinux环境配置导致bash启动慢。原因：settings.sh会监测系统环境是否符合petalinux要求。解决方法：注释掉settings.sh的最后一行。
5. Petalinux的卸载：直接删除文件夹


