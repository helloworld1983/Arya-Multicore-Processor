addi $30,$0,512
nop
nop
nop
nop
addi $2,$0,5
nop
nop
nop
nop
sw $2,8($30)
nop
nop
nop
nop
addi $2,$0,30
nop
nop
nop
nop
sw $2,16($30)
nop
nop
nop
nop
addi $2,$0,43
nop
nop
nop
nop
sw $2,20($30)
nop
nop
nop
nop
addi $2,$0,68
nop
nop
nop
nop
sw $2,24($30)
nop
nop
nop
nop
addi $2,$0,52
nop
nop
nop
nop
sw $2,28($30)
nop
nop
nop
nop
addi $2,$0,22
nop
nop
nop
nop
sw $2,32($30)
nop
nop
nop
nop
sw $0,0($30)
nop
nop
nop
nop
beq $0,$0,429
nop
nop
nop
nop
nop
sw $0,4($30)
nop
nop
nop
nop
beq $0,$0,378
nop
nop
nop
nop
nop
lw $2,4($30)
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
bne $1,$0,97
nop
nop
nop
nop
add $2,$30,$2
nop
nop
nop
nop
lw $3,16($2)
nop
nop
nop
nop
lw $2,4($30)
nop
nop
nop
nop
addi $2,$2,1
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
bne $1,$0,142
nop
nop
nop
nop
add $2,$30,$2
nop
nop
nop
nop
lw $2,16($2)
nop
nop
nop
nop
slt $2,$2,$3
nop
nop
nop
nop
beq $2,$0,363
nop
nop
nop
nop
nop
lw $2,4($30)
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
bne $1,$0,193
nop
nop
nop
nop
add $2,$30,$2
nop
nop
nop
nop
lw $2,16($2)
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
addi $2,$2,1
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
bne $1,$0,243
nop
nop
nop
nop
add $2,$30,$2
nop
nop
nop
nop
lw $3,16($2)
nop
nop
nop
nop
lw $2,4($30)
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
bne $1,$0,283
nop
nop
nop
nop
add $2,$30,$2
nop
nop
nop
nop
sw $3,16($2)
nop
nop
nop
nop
lw $2,4($30)
nop
nop
nop
nop
addi $2,$2,1
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
bne $1,$0,328
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
sw $3,16($2)
nop
nop
nop
nop
lw $2,4($30)
nop
nop
nop
nop
addi $2,$2,1
nop
nop
nop
nop
sw $2,4($30)
nop
nop
nop
nop
lw $3,8($30)
nop
nop
nop
nop
lw $2,0($30)
nop
nop
nop
nop
sub $2,$3,$2
nop
nop
nop
nop
addi $3,$2,-1
nop
nop
nop
nop
lw $2,4($30)
nop
nop
nop
nop
slt $2,$2,$3
nop
nop
nop
nop
bne $2,$0,87
nop
nop
nop
nop
nop
lw $2,0($30)
nop
nop
nop
nop
addi $2,$2,1
nop
nop
nop
nop
sw $2,0($30)
nop
nop
nop
nop
lw $2,8($30)
nop
nop
nop
nop
addi $3,$2,-1
nop
nop
nop
nop
lw $2,0($30)
nop
nop
nop
nop
slt $2,$2,$3
nop
nop
nop
nop
bne $2,$0,76
nop
nop
nop
nop
nop
halt
