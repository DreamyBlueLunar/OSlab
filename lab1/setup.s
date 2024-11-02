BOOTSEG = 0x07c0                     
SETUPSEG = 0x07e0  

entry _start   
_start:
	! 首先读入光标位置
	mov    ah, #0x03        
	xor    bh, bh	
	int    0x10

	! 显示字符串“BLMos is running...”
	mov    cx, #25            ! 要显示的字符串长度
	mov    bx, #0x0007        ! page 0, attribute 7 (normal)
	mov    ax, #SETUPSEG
	mov    es, ax
	mov    bp, #msg2
	mov    ax, #0x1301        ! write string, move cursor
	int    0x10
		
load_param:
	mov    ax, #BOOTSEG    
	mov    ds, ax		!设置ds=0x7c00
	mov    ah, #0x03    	!读入光标位置
	xor    bh, bh
	int    0x10		!调用0x10中断
	mov    [0],dx       	!将光标位置写入0x7e00.
							
	!读入内存大小位置
	mov    ah, #0x88
	int    0x15
	mov    [2], ax
											
	!从0x41处拷贝16个字节（磁盘参数表）
	mov    ax, #0x0000
	mov    ds, ax
	lds    si, [4*0x41]
	mov    ax, #BOOTSEG
	mov    es, ax
	mov    di, #0x0004
	mov    cx, #0x10
	rep					!重复16次
	movsb

print_info:
	mov    ax, #BOOTSEG    
	mov    ds, ax		!设置ds=0x7c00
	mov    ax, #SETUPSEG
	mov    es, ax

	!显示 Cursor POS: 字符串
	mov	ah, #0x03		! read cursor pos
	xor	bh, bh
	int	0x10
	mov	cx, #11
	mov	bx, #0x0007		! page 0, attribute c 
	mov	bp, #cur
	mov	ax, #0x1301		! write string, move cursor
	int	0x10

	!调用 print_hex 显示具体信息
	mov ax, [0]
	call print_hex
	call print_nl

	!显示 Memory SIZE: 字符串
	mov	ah, #0x03		! read cursor pos
	xor	bh, bh
	int	0x10
	mov	cx, #12
	mov	bx, #0x0007		! page 0, attribute c 
	mov	bp, #mem
	mov	ax, #0x1301		! write string, move cursor
	int	0x10

	!显示 具体信息
	mov ax, [2]
	call print_hex

	!显示相应 提示信息
	mov	ah, #0x03		! read cursor pos
	xor	bh, bh
	int	0x10
	mov	cx, #25
	mov	bx, #0x0007		! page 0, attribute c 
	mov	bp, #cyl
	mov	ax, #0x1301		! write string, move cursor
	int	0x10

	!显示具体信息
	mov ax, [0x04]
	call print_hex
	call print_nl

	！显示 提示信息
	mov	ah, #0x03		! read cursor pos
	xor	bh, bh
	int	0x10
	mov	cx, #8
	mov	bx, #0x0007		! page 0, attribute c 
	mov	bp, #head
	mov	ax, #0x1301		! write string, move cursor
	int	0x10

	！显示 具体信息
	mov ax, [0x04+0x02]
	call print_hex
	call print_nl

	！显示 提示信息
	mov	ah, #0x03		! read cursor pos
	xor	bh, bh
	int	0x10
	mov	cx, #8
	mov	bx, #0x0007		! page 0, attribute c 
	mov	bp, #sect
	mov	ax, #0x1301		! write string, move cursor
	int	0x10

	！显示 具体信息
	mov ax, [0x04+0x0e]
	call print_hex
	call print_nl


inf_loop:
	jmp    inf_loop        ! 后面都不是正经代码了，得往回跳呀

!以16进制方式打印ax寄存器里的16位数
print_hex:
	mov cx, #4   ! 4个十六进制数字
	mov dx, ax   ! 将ax所指的值放入dx中，ax作为参数传递寄存器

print_digit:
	rol dx, #4  ! 循环以使低4比特用上 !! 取dx的高4比特移到低4比特处。
	mov ax, #0xe0f  ! ah = 请求的功能值,al = 半字节(4个比特)掩码。
	and al, dl ! 取dl的低4比特值。
	add al, #0x30  ! 给al数字加上十六进制0x30
	cmp al, #0x3a
	jl outp  !是一个不大于十的数字
	add al, #0x07  !是a~f,要多加7

outp:
	int 0x10
	loop print_digit
	ret
									
!打印回车换行
print_nl:
	mov ax, #0xe0d
	int 0x10
	mov al, #0xa
	int 0x10
	ret

! msg1处放置字符串												
msg2:
	.byte 13,10            ! 换行+回车
	.ascii "Now we are in SETUP"
	.byte 13,10,13,10            ! 两对换行+回车

cur:
	.ascii "Cursor POS:"
mem:
	.ascii "Memory SIZE:"
cyl:
	.ascii "KB"
	.byte 13,10,13,10
	.ascii "HD Info"
	.byte 13,10
	.ascii "Cylinders:"
head:
	.ascii "Headers:"
sect:
	.ascii "Secotrs:"

!设置引导扇区标记0xAA55
.org 510

boot_flag:
	.word 0xAA55            ! 必须有它，才能引导
