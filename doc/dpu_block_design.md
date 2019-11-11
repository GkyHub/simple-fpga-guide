# ARM和FPGA的协同工作：使用Xilinx DPU IP

使用Zynq的ARM核和FPGA协同工作对于制作demo和设计的实际部署非常便利。这里我们通过Xilinx提供的Deep Learning Processing Unit(DPU)及其参考设计了解一下如何实现ARM和FPGA的协同工作。

Xilinx官方的DPU设计提供了一个在FPGA上加速深度神经网络的解决方案。该方案包括硬件IP，DPU，以及软件DNNDK/AISDK。由于官方文档对DPU的使用并不十分详细，因此依然需要参照target reference design(TRD)来完成设计。这里对TRD中的一些细节进行补充说明。对DPU的总体说明以及TRD的下载，请参考[https://china.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge](https://china.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)

## 系统整体结构

DPU核心通过S_AXI接口接收软件的配置信息开始工作。开始工作后，DPU会通过M_AXI接口，根据配置的地址主动访问其需要的指令。之后，DPU会根据指令的描述，通过M_AXI接口访问数据并完成计算。完成计算后，DPU核心将返回一个中断信号。

因此，DPU和Zynq CPU的连接主要有：
1. S_AXI接口，接收配置信息，PS能够通访问到这一接口即可
2. M_AXI接口，包括数据和指令。数据接口需要提供充足的带宽，指令接口相对可以不提供很高的带宽。
3. 中断，直接接在PS端的中断口上
4. 时钟。DPU包含寄存器接口，DPU逻辑以及DSP计算核心三个不同时钟域的组件，因此需要提供三个时钟。其中，DSP计算核心的时钟必须是DPU逻辑时钟的两倍速度，详细配置参考[PG338]()。
5. 复位

满足以上连接关系的情况下，可以在系统中集成其他组件。

## Block Design配置细节补充


## 镜像配置细节补充
1. TRD中提供了petalinux工程的BSP文件。其中包含了一个DPU设备树的模板，需要加入到实际使用的petalinux工程中。内容如下：
    ```dts
    / {
        amba{
            dpu{
                #address-cells = <1>;
                #size-cells = <1>;
                compatible = "xilinx,dpu";
                // 基地址配置为S_AXI接口的地址
                base-addr = <0x8F000000>;

                dpucore {
                    compatible = "xilinx,dpucore";
                    interrupt-parent = <&gic>;
                    // 中断为3个数一组，中间的是中断地址，前后的0和1不变
                    // ZCU102上的中断是0x60-0x6F
                    // 每个核有一个中断
                    interrupts = <0x0 106 0x1 0x0 107 0x1>;
                    // 根据硬件设计配置核数
                    core-num = <0x2>;
                };

                // 硬件不带softmax单元时可删掉
                softmax {
                    compatible = "xilinx,smfc";
                    interrupt-parent = <&gic>;
                    // 同上需要配置一个中断
                    interrupts = <0x0 110 0x1>;
                    // 固定是1
                    core-num = <0x1>;
                };
            };
	    };
    };
    ```
2. TRD的工程中还提供了DPU的驱动，在petalinux中通过以下方式可以加入：
   ``` bash
    cd <PETALINUX_PROJECT>
    petalinux-create -t modules --name dpu --enable
    cp 
   ```
3. 

