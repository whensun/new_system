
bootloader/bootloader:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
.section .text
.global _entry

_entry:
la sp, bl_stack
    80000000:	00000117          	auipc	sp,0x0
    80000004:	49010113          	addi	sp,sp,1168 # 80000490 <bl_stack>
li a0, 4096
    80000008:	6505                	lui	a0,0x1
csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
mul a0, a0, a1
    80000010:	9d4d                	mul	a0,a0,a1
add sp, sp, a0
    80000012:	912a                	add	sp,sp,a0
call start
    80000014:	00000097          	auipc	ra,0x0
    80000018:	014080e7          	jalr	20(ra) # 80000028 <start>

000000008000001c <spin>:

spin:
    8000001c:	a001                	j	8000001c <spin>

000000008000001e <panic>:
extern void _entry(void);
extern void test_start(void);
extern void trap_vector(void);

void panic(char *s)
{
    8000001e:	1141                	addi	sp,sp,-16
    80000020:	e406                	sd	ra,8(sp)
    80000022:	e022                	sd	s0,0(sp)
    80000024:	0800                	addi	s0,sp,16
  for(;;)
    80000026:	a001                	j	80000026 <panic+0x8>

0000000080000028 <start>:
    ;
}

// entry.S jumps here in machine mode on stack0.
void start()
{
    80000028:	1141                	addi	sp,sp,-16
    8000002a:	e406                	sd	ra,8(sp)
    8000002c:	e022                	sd	s0,0(sp)
    8000002e:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000030:	f14027f3          	csrr	a5,mhartid
    // keep each CPU's hartid in its tp register, for cpuid().
    int id = r_mhartid();
    w_tp(id);
    80000034:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    80000036:	823e                	mv	tp,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000038:	300027f3          	csrr	a5,mstatus
    
    // Enable floating-point extension (set FS field to Initial state)
    x |= (1UL << 13); // FS[1] = 1, FS[0] = 0 (Initial state)
    
    // Enable vector extension (set VS field to Initial state)
    x |= (1UL << 10); // VS[1] = 1, VS[0] = 0 (Initial state)
    8000003c:	6711                	lui	a4,0x4
    8000003e:	c0070713          	addi	a4,a4,-1024 # 3c00 <_entry-0x7fffc400>
    80000042:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000044:	30079073          	csrw	mstatus,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000048:	4781                	li	a5,0
    8000004a:	18079073          	csrw	satp,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    8000004e:	2b601793          	bseti	a5,zero,0x36
    80000052:	17fd                	addi	a5,a5,-1
    80000054:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80000058:	47bd                	li	a5,15
    8000005a:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    8000005e:	00000797          	auipc	a5,0x0
    80000062:	04278793          	addi	a5,a5,66 # 800000a0 <test_start>
    80000066:	34179073          	csrw	mepc,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000006a:	67c1                	lui	a5,0x10
    8000006c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000006e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000072:	104027f3          	csrr	a5,sie
    w_mepc((uint64) test_start);
    
    // delegate all interrupts and exceptions to supervisor mode.
    // w_medeleg(0xffff);
    w_mideleg(0xffff);
    w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000076:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000007a:	10479073          	csrw	sie,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000007e:	00000797          	auipc	a5,0x0
    80000082:	18278793          	addi	a5,a5,386 # 80000200 <trap_vector>
    80000086:	30579073          	csrw	mtvec,a5
    w_mtvec((uint64)trap_vector);
    
    // return address fix
    uint64 addr = (uint64) panic;
    asm volatile("mv ra, %0" : : "r" (addr));
    8000008a:	00000797          	auipc	a5,0x0
    8000008e:	f9478793          	addi	a5,a5,-108 # 8000001e <panic>
    80000092:	80be                	mv	ra,a5
    
    // switch to supervisor mode and jump to main().
    asm volatile("mret");
    80000094:	30200073          	mret
    80000098:	60a2                	ld	ra,8(sp)
    8000009a:	6402                	ld	s0,0(sp)
    8000009c:	0141                	addi	sp,sp,16
    8000009e:	8082                	ret

00000000800000a0 <test_start>:
.globl test_start

test_start:
li x0, 0
    800000a0:	00000013          	nop
li x1, 0
    800000a4:	4081                	li	ra,0
li x2, 0
    800000a6:	4101                	li	sp,0
li x3, 0
    800000a8:	4181                	li	gp,0
li x4, 0
    800000aa:	4201                	li	tp,0
li x5, 0
    800000ac:	4281                	li	t0,0
li x6, 0
    800000ae:	4301                	li	t1,0
li x7, 0
    800000b0:	4381                	li	t2,0
li x8, 0
    800000b2:	4401                	li	s0,0
li x9, 0
    800000b4:	4481                	li	s1,0
li x10, 0
    800000b6:	4501                	li	a0,0
li x11, 0
    800000b8:	4581                	li	a1,0
li x12, 0
    800000ba:	4601                	li	a2,0
li x13, 0
    800000bc:	4681                	li	a3,0
li x14, 0
    800000be:	4701                	li	a4,0
li x15, 0
    800000c0:	4781                	li	a5,0
li x16, 0
    800000c2:	4801                	li	a6,0
li x17, 0
    800000c4:	4881                	li	a7,0
li x18, 0
    800000c6:	4901                	li	s2,0
li x19, 0
    800000c8:	4981                	li	s3,0
li x20, 0
    800000ca:	4a01                	li	s4,0
li x21, 0
    800000cc:	4a81                	li	s5,0
li x22, 0
    800000ce:	4b01                	li	s6,0
li x23, 0
    800000d0:	4b81                	li	s7,0
li x24, 0
    800000d2:	4c01                	li	s8,0
li x25, 0
    800000d4:	4c81                	li	s9,0
li x26, 0
    800000d6:	4d01                	li	s10,0
li x27, 0
    800000d8:	4d81                	li	s11,0
li x28, 0
    800000da:	4e01                	li	t3,0
li x29, 0
    800000dc:	4e81                	li	t4,0
li x30, 0
    800000de:	4f01                	li	t5,0
li x31, 0
    800000e0:	4f81                	li	t6,0
fmv.d.x f0, x0
    800000e2:	f2000053          	fmv.d.x	ft0,zero
fmv.d.x f1, x0
    800000e6:	f20000d3          	fmv.d.x	ft1,zero
fmv.d.x f2, x0
    800000ea:	f2000153          	fmv.d.x	ft2,zero
fmv.d.x f3, x0
    800000ee:	f20001d3          	fmv.d.x	ft3,zero
fmv.d.x f4, x0
    800000f2:	f2000253          	fmv.d.x	ft4,zero
fmv.d.x f5, x0
    800000f6:	f20002d3          	fmv.d.x	ft5,zero
fmv.d.x f6, x0
    800000fa:	f2000353          	fmv.d.x	ft6,zero
fmv.d.x f7, x0
    800000fe:	f20003d3          	fmv.d.x	ft7,zero
fmv.d.x f8, x0
    80000102:	f2000453          	fmv.d.x	fs0,zero
fmv.d.x f9, x0
    80000106:	f20004d3          	fmv.d.x	fs1,zero
fmv.d.x f10, x0
    8000010a:	f2000553          	fmv.d.x	fa0,zero
fmv.d.x f11, x0
    8000010e:	f20005d3          	fmv.d.x	fa1,zero
fmv.d.x f12, x0
    80000112:	f2000653          	fmv.d.x	fa2,zero
fmv.d.x f13, x0
    80000116:	f20006d3          	fmv.d.x	fa3,zero
fmv.d.x f14, x0
    8000011a:	f2000753          	fmv.d.x	fa4,zero
fmv.d.x f15, x0
    8000011e:	f20007d3          	fmv.d.x	fa5,zero
fmv.d.x f16, x0
    80000122:	f2000853          	fmv.d.x	fa6,zero
fmv.d.x f17, x0
    80000126:	f20008d3          	fmv.d.x	fa7,zero
fmv.d.x f18, x0
    8000012a:	f2000953          	fmv.d.x	fs2,zero
fmv.d.x f19, x0
    8000012e:	f20009d3          	fmv.d.x	fs3,zero
fmv.d.x f20, x0
    80000132:	f2000a53          	fmv.d.x	fs4,zero
fmv.d.x f21, x0
    80000136:	f2000ad3          	fmv.d.x	fs5,zero
fmv.d.x f22, x0
    8000013a:	f2000b53          	fmv.d.x	fs6,zero
fmv.d.x f23, x0
    8000013e:	f2000bd3          	fmv.d.x	fs7,zero
fmv.d.x f24, x0
    80000142:	f2000c53          	fmv.d.x	fs8,zero
fmv.d.x f25, x0
    80000146:	f2000cd3          	fmv.d.x	fs9,zero
fmv.d.x f26, x0
    8000014a:	f2000d53          	fmv.d.x	fs10,zero
fmv.d.x f27, x0
    8000014e:	f2000dd3          	fmv.d.x	fs11,zero
fmv.d.x f28, x0
    80000152:	f2000e53          	fmv.d.x	ft8,zero
fmv.d.x f29, x0
    80000156:	f2000ed3          	fmv.d.x	ft9,zero
fmv.d.x f30, x0
    8000015a:	f2000f53          	fmv.d.x	ft10,zero
fmv.d.x f31, x0
    8000015e:	f2000fd3          	fmv.d.x	ft11,zero
vsetvli x0, x0, e32, m1, ta, ma
    80000162:	0d007057          	vsetvli	zero,zero,e32,m1,ta,ma
vmv.v.i v0, 0
    80000166:	5e003057          	vmv.v.i	v0,0
vmv.v.i v1, 0
    8000016a:	5e0030d7          	vmv.v.i	v1,0
vmv.v.i v2, 0
    8000016e:	5e003157          	vmv.v.i	v2,0
vmv.v.i v3, 0
    80000172:	5e0031d7          	vmv.v.i	v3,0
vmv.v.i v4, 0
    80000176:	5e003257          	vmv.v.i	v4,0
vmv.v.i v5, 0
    8000017a:	5e0032d7          	vmv.v.i	v5,0
vmv.v.i v6, 0
    8000017e:	5e003357          	vmv.v.i	v6,0
vmv.v.i v7, 0
    80000182:	5e0033d7          	vmv.v.i	v7,0
vmv.v.i v8, 0
    80000186:	5e003457          	vmv.v.i	v8,0
vmv.v.i v9, 0
    8000018a:	5e0034d7          	vmv.v.i	v9,0
vmv.v.i v10, 0
    8000018e:	5e003557          	vmv.v.i	v10,0
vmv.v.i v11, 0
    80000192:	5e0035d7          	vmv.v.i	v11,0
vmv.v.i v12, 0
    80000196:	5e003657          	vmv.v.i	v12,0
vmv.v.i v13, 0
    8000019a:	5e0036d7          	vmv.v.i	v13,0
vmv.v.i v14, 0
    8000019e:	5e003757          	vmv.v.i	v14,0
vmv.v.i v15, 0
    800001a2:	5e0037d7          	vmv.v.i	v15,0
vmv.v.i v16, 0
    800001a6:	5e003857          	vmv.v.i	v16,0
vmv.v.i v17, 0
    800001aa:	5e0038d7          	vmv.v.i	v17,0
vmv.v.i v18, 0
    800001ae:	5e003957          	vmv.v.i	v18,0
vmv.v.i v19, 0
    800001b2:	5e0039d7          	vmv.v.i	v19,0
vmv.v.i v20, 0
    800001b6:	5e003a57          	vmv.v.i	v20,0
vmv.v.i v21, 0
    800001ba:	5e003ad7          	vmv.v.i	v21,0
vmv.v.i v22, 0
    800001be:	5e003b57          	vmv.v.i	v22,0
vmv.v.i v23, 0
    800001c2:	5e003bd7          	vmv.v.i	v23,0
vmv.v.i v24, 0
    800001c6:	5e003c57          	vmv.v.i	v24,0
vmv.v.i v25, 0
    800001ca:	5e003cd7          	vmv.v.i	v25,0
vmv.v.i v26, 0
    800001ce:	5e003d57          	vmv.v.i	v26,0
vmv.v.i v27, 0
    800001d2:	5e003dd7          	vmv.v.i	v27,0
vmv.v.i v28, 0
    800001d6:	5e003e57          	vmv.v.i	v28,0
vmv.v.i v29, 0
    800001da:	5e003ed7          	vmv.v.i	v29,0
vmv.v.i v30, 0
    800001de:	5e003f57          	vmv.v.i	v30,0
vmv.v.i v31, 0
    800001e2:	5e003fd7          	vmv.v.i	v31,0

# 69 # Extension Must Be Active: NONE
csrr a0, mstatus
    800001e6:	30002573          	csrr	a0,mstatus
li t0, 0x4000000000
    800001ea:	0010029b          	addiw	t0,zero,1
    800001ee:	129a                	slli	t0,t0,0x26
and a0, a0, t0
    800001f0:	00557533          	and	a0,a0,t0

00000000800001f4 <test_end>:
# Result: a0 = 0x0 | a0 = 0x4000000000

test_end:
j test_end
    800001f4:	a001                	j	800001f4 <test_end>
    800001f6:	0001                	nop
    800001f8:	00000013          	nop
    800001fc:	00000013          	nop

0000000080000200 <trap_vector>:

.global trap_vector
.align 4

trap_vector:
    80000200:	a001                	j	80000200 <trap_vector>
    80000202:	0001                	nop
    80000204:	00000013          	nop
    80000208:	00000013          	nop
    8000020c:	00000013          	nop

0000000080000210 <kernel_copy>:
#include "layout.h"
#include "buf.h"

/* In-built function to load NORMAL/RECOVERY kernels */
void kernel_copy(enum kernel ktype, struct buf *b)
{
    80000210:	1101                	addi	sp,sp,-32
    80000212:	ec06                	sd	ra,24(sp)
    80000214:	e822                	sd	s0,16(sp)
    80000216:	e426                	sd	s1,8(sp)
    80000218:	e04a                	sd	s2,0(sp)
    8000021a:	1000                	addi	s0,sp,32
    8000021c:	892a                	mv	s2,a0
    8000021e:	84ae                	mv	s1,a1
  if(b->blockno >= FSSIZE)
    80000220:	45d8                	lw	a4,12(a1)
    80000222:	7cf00793          	li	a5,1999
    80000226:	02e7ed63          	bltu	a5,a4,80000260 <kernel_copy+0x50>
    panic("ramdiskrw: blockno too big");

  uint64 diskaddr = b->blockno * BSIZE;
    8000022a:	44dc                	lw	a5,12(s1)
    8000022c:	00a7979b          	slliw	a5,a5,0xa
    80000230:	1782                	slli	a5,a5,0x20
    80000232:	9381                	srli	a5,a5,0x20
  char* addr = 0x0; 
  
  if (ktype == NORMAL)
    80000234:	02091f63          	bnez	s2,80000272 <kernel_copy+0x62>
    addr = (char *)RAMDISK + diskaddr;
    80000238:	02100593          	li	a1,33
    8000023c:	05ea                	slli	a1,a1,0x1a
    8000023e:	95be                	add	a1,a1,a5
  else if (ktype == RECOVERY)
    addr = (char *)RECOVERYDISK + diskaddr;

  memmove(b->data, addr, BSIZE);
    80000240:	40000613          	li	a2,1024
    80000244:	02848513          	addi	a0,s1,40
    80000248:	00000097          	auipc	ra,0x0
    8000024c:	096080e7          	jalr	150(ra) # 800002de <memmove>
  b->valid = 1;
    80000250:	4785                	li	a5,1
    80000252:	c09c                	sw	a5,0(s1)
    80000254:	60e2                	ld	ra,24(sp)
    80000256:	6442                	ld	s0,16(sp)
    80000258:	64a2                	ld	s1,8(sp)
    8000025a:	6902                	ld	s2,0(sp)
    8000025c:	6105                	addi	sp,sp,32
    8000025e:	8082                	ret
    panic("ramdiskrw: blockno too big");
    80000260:	00000517          	auipc	a0,0x0
    80000264:	21050513          	addi	a0,a0,528 # 80000470 <ecode+0x4>
    80000268:	00000097          	auipc	ra,0x0
    8000026c:	db6080e7          	jalr	-586(ra) # 8000001e <panic>
    80000270:	bf6d                	j	8000022a <kernel_copy+0x1a>
  else if (ktype == RECOVERY)
    80000272:	4705                	li	a4,1
  char* addr = 0x0; 
    80000274:	4581                	li	a1,0
  else if (ktype == RECOVERY)
    80000276:	fce915e3          	bne	s2,a4,80000240 <kernel_copy+0x30>
    addr = (char *)RECOVERYDISK + diskaddr;
    8000027a:	008455b7          	lui	a1,0x845
    8000027e:	05a2                	slli	a1,a1,0x8
    80000280:	95be                	add	a1,a1,a5
    80000282:	bf7d                	j	80000240 <kernel_copy+0x30>

0000000080000284 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000284:	1141                	addi	sp,sp,-16
    80000286:	e406                	sd	ra,8(sp)
    80000288:	e022                	sd	s0,0(sp)
    8000028a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000028c:	ca11                	beqz	a2,800002a0 <memset+0x1c>
    8000028e:	87aa                	mv	a5,a0
    80000290:	1602                	slli	a2,a2,0x20
    80000292:	9201                	srli	a2,a2,0x20
    80000294:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000298:	8b8c                	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    8000029a:	0785                	addi	a5,a5,1
    8000029c:	fee79ee3          	bne	a5,a4,80000298 <memset+0x14>
  }
  return dst;
}
    800002a0:	60a2                	ld	ra,8(sp)
    800002a2:	6402                	ld	s0,0(sp)
    800002a4:	0141                	addi	sp,sp,16
    800002a6:	8082                	ret

00000000800002a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800002a8:	1141                	addi	sp,sp,-16
    800002aa:	e406                	sd	ra,8(sp)
    800002ac:	e022                	sd	s0,0(sp)
    800002ae:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800002b0:	c60d                	beqz	a2,800002da <memcmp+0x32>
    800002b2:	1602                	slli	a2,a2,0x20
    800002b4:	9201                	srli	a2,a2,0x20
    800002b6:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    800002ba:	811c                	lbu	a5,0(a0)
    800002bc:	8198                	lbu	a4,0(a1)
    800002be:	00e79863          	bne	a5,a4,800002ce <memcmp+0x26>
      return *s1 - *s2;
    s1++, s2++;
    800002c2:	0505                	addi	a0,a0,1
    800002c4:	0585                	addi	a1,a1,1 # 845001 <_entry-0x7f7bafff>
  while(n-- > 0){
    800002c6:	fed51ae3          	bne	a0,a3,800002ba <memcmp+0x12>
  }

  return 0;
    800002ca:	4501                	li	a0,0
    800002cc:	a019                	j	800002d2 <memcmp+0x2a>
      return *s1 - *s2;
    800002ce:	40e7853b          	subw	a0,a5,a4
}
    800002d2:	60a2                	ld	ra,8(sp)
    800002d4:	6402                	ld	s0,0(sp)
    800002d6:	0141                	addi	sp,sp,16
    800002d8:	8082                	ret
  return 0;
    800002da:	4501                	li	a0,0
    800002dc:	bfdd                	j	800002d2 <memcmp+0x2a>

00000000800002de <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800002de:	1141                	addi	sp,sp,-16
    800002e0:	e406                	sd	ra,8(sp)
    800002e2:	e022                	sd	s0,0(sp)
    800002e4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800002e6:	c205                	beqz	a2,80000306 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800002e8:	02a5e363          	bltu	a1,a0,8000030e <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800002ec:	1602                	slli	a2,a2,0x20
    800002ee:	9201                	srli	a2,a2,0x20
    800002f0:	00c587b3          	add	a5,a1,a2
{
    800002f4:	872a                	mv	a4,a0
      *d++ = *s++;
    800002f6:	0585                	addi	a1,a1,1
    800002f8:	0705                	addi	a4,a4,1
    800002fa:	fff5c683          	lbu	a3,-1(a1)
    800002fe:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000302:	feb79ae3          	bne	a5,a1,800002f6 <memmove+0x18>

  return dst;
}
    80000306:	60a2                	ld	ra,8(sp)
    80000308:	6402                	ld	s0,0(sp)
    8000030a:	0141                	addi	sp,sp,16
    8000030c:	8082                	ret
  if(s < d && s + n > d){
    8000030e:	02061693          	slli	a3,a2,0x20
    80000312:	9281                	srli	a3,a3,0x20
    80000314:	00d58733          	add	a4,a1,a3
    80000318:	fce57ae3          	bgeu	a0,a4,800002ec <memmove+0xe>
    d += n;
    8000031c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000031e:	fff6079b          	addiw	a5,a2,-1
    80000322:	1782                	slli	a5,a5,0x20
    80000324:	9381                	srli	a5,a5,0x20
    80000326:	9ff5                	not	a5,a5
    80000328:	97ba                	add	a5,a5,a4
      *--d = *--s;
    8000032a:	177d                	addi	a4,a4,-1
    8000032c:	16fd                	addi	a3,a3,-1
    8000032e:	8310                	lbu	a2,0(a4)
    80000330:	8a90                	sb	a2,0(a3)
    while(n-- > 0)
    80000332:	fee79ce3          	bne	a5,a4,8000032a <memmove+0x4c>
    80000336:	bfc1                	j	80000306 <memmove+0x28>

0000000080000338 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000338:	1141                	addi	sp,sp,-16
    8000033a:	e406                	sd	ra,8(sp)
    8000033c:	e022                	sd	s0,0(sp)
    8000033e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f9e080e7          	jalr	-98(ra) # 800002de <memmove>
}
    80000348:	60a2                	ld	ra,8(sp)
    8000034a:	6402                	ld	s0,0(sp)
    8000034c:	0141                	addi	sp,sp,16
    8000034e:	8082                	ret

0000000080000350 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000350:	1141                	addi	sp,sp,-16
    80000352:	e406                	sd	ra,8(sp)
    80000354:	e022                	sd	s0,0(sp)
    80000356:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000358:	ce01                	beqz	a2,80000370 <strncmp+0x20>
    8000035a:	811c                	lbu	a5,0(a0)
    8000035c:	cf81                	beqz	a5,80000374 <strncmp+0x24>
    8000035e:	8198                	lbu	a4,0(a1)
    80000360:	00f71a63          	bne	a4,a5,80000374 <strncmp+0x24>
    n--, p++, q++;
    80000364:	367d                	addiw	a2,a2,-1
    80000366:	0505                	addi	a0,a0,1
    80000368:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000036a:	fa65                	bnez	a2,8000035a <strncmp+0xa>
  if(n == 0)
    return 0;
    8000036c:	4501                	li	a0,0
    8000036e:	a031                	j	8000037a <strncmp+0x2a>
    80000370:	4501                	li	a0,0
    80000372:	a021                	j	8000037a <strncmp+0x2a>
  return (uchar)*p - (uchar)*q;
    80000374:	8108                	lbu	a0,0(a0)
    80000376:	819c                	lbu	a5,0(a1)
    80000378:	9d1d                	subw	a0,a0,a5
}
    8000037a:	60a2                	ld	ra,8(sp)
    8000037c:	6402                	ld	s0,0(sp)
    8000037e:	0141                	addi	sp,sp,16
    80000380:	8082                	ret

0000000080000382 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000382:	1141                	addi	sp,sp,-16
    80000384:	e406                	sd	ra,8(sp)
    80000386:	e022                	sd	s0,0(sp)
    80000388:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000038a:	87aa                	mv	a5,a0
    8000038c:	a011                	j	80000390 <strncpy+0xe>
    8000038e:	8636                	mv	a2,a3
    80000390:	02c05763          	blez	a2,800003be <strncpy+0x3c>
    80000394:	fff6069b          	addiw	a3,a2,-1
    80000398:	8836                	mv	a6,a3
    8000039a:	0785                	addi	a5,a5,1
    8000039c:	8198                	lbu	a4,0(a1)
    8000039e:	fee78fa3          	sb	a4,-1(a5)
    800003a2:	0585                	addi	a1,a1,1
    800003a4:	f76d                	bnez	a4,8000038e <strncpy+0xc>
    ;
  while(n-- > 0)
    800003a6:	873e                	mv	a4,a5
    800003a8:	01005b63          	blez	a6,800003be <strncpy+0x3c>
    800003ac:	9fb1                	addw	a5,a5,a2
    800003ae:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    800003b0:	0705                	addi	a4,a4,1
    800003b2:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    800003b6:	40e786bb          	subw	a3,a5,a4
    800003ba:	fed04be3          	bgtz	a3,800003b0 <strncpy+0x2e>
  return os;
}
    800003be:	60a2                	ld	ra,8(sp)
    800003c0:	6402                	ld	s0,0(sp)
    800003c2:	0141                	addi	sp,sp,16
    800003c4:	8082                	ret

00000000800003c6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800003c6:	1141                	addi	sp,sp,-16
    800003c8:	e406                	sd	ra,8(sp)
    800003ca:	e022                	sd	s0,0(sp)
    800003cc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800003ce:	02c05363          	blez	a2,800003f4 <safestrcpy+0x2e>
    800003d2:	fff6069b          	addiw	a3,a2,-1
    800003d6:	1682                	slli	a3,a3,0x20
    800003d8:	9281                	srli	a3,a3,0x20
    800003da:	96ae                	add	a3,a3,a1
    800003dc:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800003de:	00d58963          	beq	a1,a3,800003f0 <safestrcpy+0x2a>
    800003e2:	0585                	addi	a1,a1,1
    800003e4:	0785                	addi	a5,a5,1
    800003e6:	fff5c703          	lbu	a4,-1(a1)
    800003ea:	fee78fa3          	sb	a4,-1(a5)
    800003ee:	fb65                	bnez	a4,800003de <safestrcpy+0x18>
    ;
  *s = 0;
    800003f0:	00078023          	sb	zero,0(a5)
  return os;
}
    800003f4:	60a2                	ld	ra,8(sp)
    800003f6:	6402                	ld	s0,0(sp)
    800003f8:	0141                	addi	sp,sp,16
    800003fa:	8082                	ret

00000000800003fc <strlen>:

int
strlen(const char *s)
{
    800003fc:	1141                	addi	sp,sp,-16
    800003fe:	e406                	sd	ra,8(sp)
    80000400:	e022                	sd	s0,0(sp)
    80000402:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000404:	811c                	lbu	a5,0(a0)
    80000406:	cf91                	beqz	a5,80000422 <strlen+0x26>
    80000408:	00150793          	addi	a5,a0,1
    8000040c:	86be                	mv	a3,a5
    8000040e:	0785                	addi	a5,a5,1
    80000410:	fff7c703          	lbu	a4,-1(a5)
    80000414:	ff65                	bnez	a4,8000040c <strlen+0x10>
    80000416:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    8000041a:	60a2                	ld	ra,8(sp)
    8000041c:	6402                	ld	s0,0(sp)
    8000041e:	0141                	addi	sp,sp,16
    80000420:	8082                	ret
  for(n = 0; s[n]; n++)
    80000422:	4501                	li	a0,0
  return n;
    80000424:	bfdd                	j	8000041a <strlen+0x1e>

0000000080000426 <machine_to_supervisor>:
.globl machine_to_supervisor

machine_to_supervisor:
li t0, 3 << 11
    80000426:	6289                	lui	t0,0x2
    80000428:	8002829b          	addiw	t0,t0,-2048 # 1800 <_entry-0x7fffe800>
csrrc x0, mstatus, t0
    8000042c:	3002b073          	csrc	mstatus,t0
li t0, 1 << 11
    80000430:	6285                	lui	t0,0x1
    80000432:	8002829b          	addiw	t0,t0,-2048 # 800 <_entry-0x7ffff800>
csrrs x0, mstatus, t0
    80000436:	3002a073          	csrs	mstatus,t0
la t0, branch_supervisor
    8000043a:	00000297          	auipc	t0,0x0
    8000043e:	01228293          	addi	t0,t0,18 # 8000044c <branch_supervisor>
csrw mepc, t0
    80000442:	34129073          	csrw	mepc,t0
li t0, 0
    80000446:	4281                	li	t0,0
mret
    80000448:	30200073          	mret

000000008000044c <branch_supervisor>:

branch_supervisor:
    8000044c:	8082                	ret

000000008000044e <machine_to_user>:
.globl machine_to_user

machine_to_user:
li t0, 3 << 11
    8000044e:	6289                	lui	t0,0x2
    80000450:	8002829b          	addiw	t0,t0,-2048 # 1800 <_entry-0x7fffe800>
csrrc x0, mstatus, t0
    80000454:	3002b073          	csrc	mstatus,t0
la t0, branch_user
    80000458:	00000297          	auipc	t0,0x0
    8000045c:	01228293          	addi	t0,t0,18 # 8000046a <branch_user>
csrw mepc, t0
    80000460:	34129073          	csrw	mepc,t0
li t0, 0
    80000464:	4281                	li	t0,0
mret
    80000466:	30200073          	mret

000000008000046a <branch_user>:

branch_user:
    8000046a:	8082                	ret
