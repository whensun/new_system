.globl machine_to_supervisor

machine_to_supervisor:
li t0, 3 << 11
csrrc x0, mstatus, t0
li t0, 1 << 11
csrrs x0, mstatus, t0
la t0, branch_supervisor
csrw mepc, t0
li t0, 0
mret

branch_supervisor:
ret