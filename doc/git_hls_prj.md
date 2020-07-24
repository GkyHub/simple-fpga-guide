# 使用Git管理HLS工程

HLS本身采用C/C++进行开发，工程和C/C++的工程类似，但是也有一些区别。

## 文件夹结构
这里只给出一个参考，可以根据实际情况调整。
```
<项目名称>
  | （以下内容是必须的）
  |-- README.md     // 项目的基本信息：项目的基本功能，如何使用这个工程，一些基本的profiling等
  |-- .gitignore    // 不需要git维护的文件列在此处
  |-- src           // 所有的源文件：.c, .cpp, .h等等
  |-- doc           // 如果除了README.md还有需要详细说明的东西，放在这里
  |    |            // 可以在README.md里链接到此文件夹中的文件
  |    |-- img      // 如果markdown中画了一些图，可以在此处保存源文件以及导出的图片
  |
  |-- scripts       // 用于建立工程或实现特定功能的脚本，可以在HLS中导出，或者手写shell/tcl脚本
  |-- <solution>    // 解决方案文件夹
  |-- <as-you-like> // 其他需要维护的东西，比如Makefile
  |-- <项目名称>.app // 工程文件
```

## gitignore样例
```
Debug/
# 综合及仿真文件可以忽略，但是directive要保留，注意这里默认solution的名称为solution1,2...
solution*/csim
solution*/impl
solution*/sim
solution*/syn
solution*/.autopilot
solution*/.debug
solution*/.tcls
# 忽略所有log文件
*.log
```
