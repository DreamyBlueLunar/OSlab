.globl begtext, begdata, begbss, endtext, enddata, endbss
.text
begtext:
.data
begdata:
.bss
begbss:
.text

BOOTSEG  = 0x07c0			! original address of boot-sector
INITSEG  = 0x9000			! we move boot here - out of the way
SETUPSEG = 0x9020			! setup starts here

entry _start
_start:

	! ds and es should be reset
	mov	ax,cs
	mov	ds,ax
	mov	es,ax

	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	
	mov	cx,#25
	mov	bx,#0x0007		! page 0, attribute 7 (normal)
	mov	bp,#msg1
	mov	ax,#0x1301		! write string, move cursor
	int	0x10

	!读入光标位置
	mov    ax,#INITSEG    
    mov    ds,ax 		!设置ds=0x9000
    mov    ah,#0x03    
    xor    bh,bh
    int    0x10        	!调用0x10中断
    mov    [0],dx       !将光标位置写入0x90000.

    !读入内存大小位置
    mov    ah,#0x88
    int    0x15
    mov    [2],ax

	!从0x41处拷贝16个字节（磁盘参数表）
    mov    ax,#0x0000
    mov    ds,ax
    lds    si,[4*0x41]
    mov    ax,#INITSEG
    mov    es,ax
    mov    di,#0x0004
    mov    cx,#0x10
    rep            !重复16次
    movsb

	! 前面修改了ds寄存器, 这里将其设置为0x9000
	mov ax,#INITSEG
	mov ds,ax
	mov ax,#SETUPSEG
	mov	es,ax  

	! Cursor POS: somewhere
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov	cx,#12
	mov	bx,#0x0007		! page 0, attribute 7 (normal)
	mov	bp,#cur
	mov	ax,#0x1301		! write string, move cursor
	int	0x10
	mov ax,[0]			! print cursor position
	call print_hex
	call print_nl

	! Memory SIZE: size
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov	cx,#13
	mov	bx,#0x0007		! page 0, attribute 7 (normal)
	mov	bp,#mem
	mov	ax,#0x1301		! write string, move cursor
	int	0x10
	mov ax,[2]			! print memory
	call print_hex
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov	cx,#2			! print "KB"
	mov	bx,#0x0007		! page 0, attribute 7 (normal)
	mov	bp,#kb
	mov	ax,#0x1301		! write string, move cursor
	int	0x10
	call print_nl

	! Cyls: cyl
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov	cx,#6
	mov	bx,#0x0007		! page 0, attribute 7 (normal)
	mov	bp,#cyl
	mov	ax,#0x1301		! write string, move cursor
	int	0x10
	mov ax,[0x04]
	call print_hex
	call print_nl

	! Heads: head
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov	cx,#7
	mov	bx,#0x0007		! page 0, attribute c 
	mov	bp,#head
	mov	ax,#0x1301		! write string, move cursor
	int	0x10
	mov ax,[0x04+0x02]
	call print_hex
	call print_nl

	! Sectors: 
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov	cx,#9
	mov	bx,#0x0007		! page 0, attribute c 
	mov	bp,#sect
	mov	ax,#0x1301		! write string, move cursor
	int	0x10
	mov ax,[0x04+0x0e]
	call print_hex
	call print_nl


inf_loop:
	jmp inf_loop

!以16进制方式打印栈顶的16位数
print_hex:
	mov    cx,#4         ! 4个十六进制数字
	mov    dx,ax     ! 将(bp)所指的值放入dx中，如果bp是指向栈顶的话

print_digit:
	rol    dx,#4        ! 循环以使低4比特用上 !! 取dx的高4比特移到低4比特处。
	mov    ax,#0xe0f     ! ah = 请求的功能值，al = 半字节(4个比特)掩码。
	and    al,dl         ! 取dl的低4比特值。
	add    al,#0x30     ! 给al数字加上十六进制0x30
	cmp    al,#0x3a
	jl    outp          !是一个不大于十的数字
	add    al,#0x07      !是a～f，要多加7

outp: 
	int    0x10
	loop    print_digit
	ret

!打印回车换行
print_nl:
	mov    ax,#0xe0d     ! CR
	int    0x10
	mov    al,#0xa     ! LF
	int    0x10
	ret

msg1:
	.byte 13,10
	.ascii "Now we are in SETUP"
	.byte 13,10,13,10

cur:
	.ascii "Cursor POS: "

mem:
	.ascii "Memory SIZE: "

kb:
	.ascii "KB"

cyl:
	.ascii "Cyls: "

head:
	.ascii "Heads: "

sect:
	.ascii "Sectors: "

.text
endtext:
.data
enddata:
.bss
endbss:
