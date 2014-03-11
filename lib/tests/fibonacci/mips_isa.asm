addi $30,$0,512
nop
nop
nop
nop
sw $0,0($30)
nop
nop
nop
nop
addi $2,$0,1
nop
nop
nop
nop
sw $2,4($30)
nop
nop
nop
nop
sw $0,28($30)
nop
nop
nop
nop
sw $0,32($30)
nop
nop
nop
nop
sw $0,36($30)
nop
nop
nop
nop
sw $0,40($30)
nop
nop
nop
nop
sw $0,44($30)
nop
nop
nop
nop
sw $0,16($30)
nop
nop
nop
nop
addi $2,$0,5
nop
nop
nop
nop
sw $2,20($30)
nop
nop
nop
nop
addi $2,$0,1
nop
nop
nop
nop
sw $2,24($30)
nop
nop
nop
nop
sw $0,8($30)
nop
nop
nop
nop
beq $0,$0,233
nop
nop
nop
nop
nop
lw $3,8($30)
nop
nop
nop
nop
lw $2,24($30)
nop
nop
nop
nop
slt $2,$2,$3
nop
nop
nop
nop
bne $2,$0,118
nop
nop
nop
nop
nop
lw $2,8($30)
nop
nop
nop
nop
sw $2,12($30)
nop
nop
nop
nop
beq $0,$0,158
nop
nop
nop
nop
nop
lw $3,0($30)
nop
nop
nop
nop
lw $2,4($30)
nop
nop
nop
nop
add $2,$3,$2
nop
nop
nop
nop
sw $2,12($30)
nop
nop
nop
nop
lw $2,4($30)
nop
nop
nop
nop
sw $2,0($30)
nop
nop
nop
nop
lw $2,12($30)
nop
nop
nop
nop
sw $2,4($30)
nop
nop
nop
nop
lw $2,16($30)
nop
nop
nop
nop
addi $1,$0,2
nop
nop
nop
nop
sll $2,$2
nop
nop
nop
nop
add $2,$2,$0
nop
nop
nop
nop
addi $1,$1,-1
nop
nop
nop
nop
bne $1,$0,168
nop
nop
nop
nop
add $2,$30,$2
nop
nop
nop
nop
lw $3,12($30)
nop
nop
nop
nop
sw $3,28($2)
nop
nop
nop
nop
lw $2,16($30)
nop
nop
nop
nop
addi $2,$2,1
nop
nop
nop
nop
sw $2,16($30)
nop
nop
nop
nop
lw $2,8($30)
nop
nop
nop
nop
addi $2,$2,1
nop
nop
nop
nop
sw $2,8($30)
nop
nop
nop
nop
lw $3,8($30)
nop
nop
nop
nop
lw $2,20($30)
nop
nop
nop
nop
slt $2,$3,$2
nop
nop
nop
nop
bne $2,$0,81
nop
nop
nop
nop
nop
halt
