/* These files have been taken from the open-source xv6 Operating System codebase (MIT License).  */

#include "types.h"
#include "param.h"
#include "layout.h"
#include "riscv.h"
#include "defs.h"
#include "buf.h"
#include <stdbool.h>

void main();
void timerinit();

/* entry.S needs one stack per CPU */
__attribute__ ((aligned (16))) char bl_stack[STSIZE * NCPU];

extern void _entry(void);
extern void test_start(void);
extern void trap_vector(void);

void panic(char *s)
{
  for(;;)
    ;
}

// entry.S jumps here in machine mode on stack0.
void start()
{
    // keep each CPU's hartid in its tp register, for cpuid().
    int id = r_mhartid();
    w_tp(id);
    
    // set M Previous Privilege mode to Supervisor, for mret.
    unsigned long x = r_mstatus();
    
    #if defined(MMODE)
    x &= ~MSTATUS_MPP_MASK;
    x |= MSTATUS_MPP_M;
    #endif
    
    #if defined(SMODE)
    x &= ~MSTATUS_MPP_MASK;
    x |= MSTATUS_MPP_S;
    #endif
    
    #if defined(UMODE)
    x &= ~MSTATUS_MPP_MASK;
    x |= MSTATUS_MPP_U;
    #endif

    // x &= ~MSTATUS_MPP_MASK;
    // x |= MSTATUS_MPP_S;
    
    w_mstatus(x);
    
    // loki();
    
    // disable paging
    w_satp(0);
    
    w_pmpaddr0(0x3fffffffffffffull);
    w_pmpcfg0(0xf);
    
    w_mepc((uint64) test_start);
    
    // delegate all interrupts and exceptions to supervisor mode.
    // w_medeleg(0xffff);
    w_mideleg(0xffff);
    w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    w_mtvec((uint64)trap_vector);
    
    // return address fix
    uint64 addr = (uint64) panic;
    asm volatile("mv ra, %0" : : "r" (addr));
    
    // switch to supervisor mode and jump to main().
    asm volatile("mret");
}
