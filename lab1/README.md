# lab1 操作系统的引导
## 实验结果
1. 更改的文件有 boot/bootsect.s boot/setup.s tools/build.c
2. 截图如下：![实验结果](lab1Res.png)

## 问题
1.  有时，继承传统意味着别手蹩脚。x86计算机为了向下兼容，导致启动过程比较复杂。请找出x86计算机启动过程中，被硬件强制，软件必须遵守的两个“多此一举”的步骤（多找几个也无妨），说说它们为什么多此一举，并设计更简洁的替代方案。 评分标准[编辑]

* 答：
1. 计算机上电，BIOS初始化中断向量表后，会将启动设备的第一个扇区（即引导扇区）读入内存地址0x7c00（31KB)处，并跳转到此处开始执行。而为了方便加载主模块，引导程序首先会将自己移动到内存相对靠后的位置，如linux0.11的bootsect程序先将自己移动到0x90000(576KB)处。这样先移动是多此一举的。<br>
* 解决方案：在保证可靠性的前提下尽量扩大实地址模式下BIOS可访问的内存的范围，如引导扇区加载到0x90000等内存高地址处而不是0x7c00。
 
2. 计算机上电后，ROM BIOS会在物理内存0处初始化中断向量表，其中有256个中断向量，每个中断向量占用4字节，共1KB，在物理内存地址0x000 - ox3ff处，这些中断向量供BIOS中断使用。这就导致了一个问题，如果操作系统的引导程序在加载操作系统时使用了BIOS中断来获取或者显示一些信息时，这1KB地址不能被覆盖。然而操作系统的主模块为了让其中代码地址等于实际的物理地址，需要将其加载到内存0x0000处。所以操作系统在加载时需要先将主模块加载到内存中不与BIOS中断向量表冲突的地方，之后可以覆盖中断向量表时才将其移动到内存起始处，如Linux0.11的System模块就是在bootsect程序中先加载到0x10000,之后在setup程序中移到0x0000处。 这样先加载到另外地方之后再移动到内存起始位置是多此一举的。
* 解决方案：可以将BIOS中断向量表放到实模式下能寻址内存的其他地方，操作系统引导程序直接将操作系统的主模块读到内存的起始处。