.globl test_start

test_start:
li x0, 0
li x1, 0
li x2, 0
li x3, 0
li x4, 0
li x5, 0
li x6, 0
li x7, 0
li x8, 0
li x9, 0
li x10, 0
li x11, 0
li x12, 0
li x13, 0
li x14, 0
li x15, 0
li x16, 0
li x17, 0
li x18, 0
li x19, 0
li x20, 0
li x21, 0
li x22, 0
li x23, 0
li x24, 0
li x25, 0
li x26, 0
li x27, 0
li x28, 0
li x29, 0
li x30, 0
li x31, 0
fmv.d.x f0, x0
fmv.d.x f1, x0
fmv.d.x f2, x0
fmv.d.x f3, x0
fmv.d.x f4, x0
fmv.d.x f5, x0
fmv.d.x f6, x0
fmv.d.x f7, x0
fmv.d.x f8, x0
fmv.d.x f9, x0
fmv.d.x f10, x0
fmv.d.x f11, x0
fmv.d.x f12, x0
fmv.d.x f13, x0
fmv.d.x f14, x0
fmv.d.x f15, x0
fmv.d.x f16, x0
fmv.d.x f17, x0
fmv.d.x f18, x0
fmv.d.x f19, x0
fmv.d.x f20, x0
fmv.d.x f21, x0
fmv.d.x f22, x0
fmv.d.x f23, x0
fmv.d.x f24, x0
fmv.d.x f25, x0
fmv.d.x f26, x0
fmv.d.x f27, x0
fmv.d.x f28, x0
fmv.d.x f29, x0
fmv.d.x f30, x0
fmv.d.x f31, x0
vsetvli x0, x0, e32, m1, ta, ma
vmv.v.i v0, 0
vmv.v.i v1, 0
vmv.v.i v2, 0
vmv.v.i v3, 0
vmv.v.i v4, 0
vmv.v.i v5, 0
vmv.v.i v6, 0
vmv.v.i v7, 0
vmv.v.i v8, 0
vmv.v.i v9, 0
vmv.v.i v10, 0
vmv.v.i v11, 0
vmv.v.i v12, 0
vmv.v.i v13, 0
vmv.v.i v14, 0
vmv.v.i v15, 0
vmv.v.i v16, 0
vmv.v.i v17, 0
vmv.v.i v18, 0
vmv.v.i v19, 0
vmv.v.i v20, 0
vmv.v.i v21, 0
vmv.v.i v22, 0
vmv.v.i v23, 0
vmv.v.i v24, 0
vmv.v.i v25, 0
vmv.v.i v26, 0
vmv.v.i v27, 0
vmv.v.i v28, 0
vmv.v.i v29, 0
vmv.v.i v30, 0
vmv.v.i v31, 0

# 20 # Extension Must Be Active: NONE
vsetvli t0, zero, e64, m1
li a0, 5
vmv.v.x v2, a0
vmsne.vi v0, v2, 0
vadc.vim v3, v2, 3, v0
vmv.x.s a2, v3
# Result: a2 = 8

test_end:
j test_end

.global trap_vector
.align 4

trap_vector:
j trap_vector