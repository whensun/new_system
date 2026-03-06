.globl machine_to_user

machine_to_user:
li t0, 3 << 11
csrrc x0, mstatus, t0
la t0, branch_user
csrw mepc, t0
li t0, 0
mret

branch_user:
ret