BOOTSEG = 0x07c0
SETUPLEN = 2
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
	mov	   ax, #BOOTSEG
	mov    es, ax
	mov    bp, #msg1
	mov    ax, #0x1301        ! write string, move cursor
	int    0x10
							
load_setup:
	mov    dx, #0x0000			! drive 0, head 0
	mov	   cx, #0x0002			! sector 2, track 0
	mov	   bx, #0x0200			! address = 512, in INITSEG
	mov	   ax, #0x0200+SETUPLEN	! service 2, nr of sectors
	int	   0x13					! read it
	jnc	   ok_load_setup		! ok - continue
	mov	   dx, #0x0000
	mov	   ax, #0x0000			! reset the diskette
	int	   0x13
	j	   load_setup

ok_load_setup:
	jmpi	0, SETUPSEG

! msg1处放置字符串												
msg1:
	.byte 13,10            ! 换行+回车
	.ascii "BLMos is running..."
	.byte 13,10,13,10            ! 两对换行+回车

!设置引导扇区标记0xAA55
.org 510

boot_flag:
	.word 0xAA55            ! 必须有它，才能引导
