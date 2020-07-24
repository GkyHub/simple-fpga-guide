# 例程

这里给出了一些例程，大部分还有待完善和验证，目前仅供参考

| 模块名称 | 描述 |
| --- | --- |
| [adder_tree](../sample/adder_tree.v) | 采用堆的方式实现的参数化的加法二叉树 |
| [axis_register](../sample/axis_register.v) | 在可阻塞的流水线中插入寄存器的模块，可以降低流水线上ready信号的扇出 |
| [axis_split4](../sample/axis_split4.v) | 将AXI Stream根据dest信号分成4个流 |
| [axis_line_buffer](../sample/axis_line_buffer.v) | 可阻塞的行缓存，实现滑窗功能，窗的大小和图像行宽可配置 |