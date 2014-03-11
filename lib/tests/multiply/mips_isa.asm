addi $30,$0,512
nop
nop
nop
nop
addi $2,$0,2
nop
nop
nop
nop
sw $2,0($30)
nop
nop
nop
nop
lw $2,0($30)
nop
nop
nop
nop
addi $3,$2,3
nop
nop
nop
nop
lw $2,0($30)
nop
nop
nop
nop
and $7,$7,$0
nop
nop
nop
nop
addi $1,$0,1
nop
nop
nop
nop
beq $0,$2,65
nop
nop
nop
nop
add $7,$7,$3
nop
nop
nop
nop
sub $2,$2,$1
nop
nop
nop
nop
beq $0,$2,70
nop
nop
nop
nop
beq $0,$0,45
nop
nop
nop
nop
add $2,$0,$0
nop
nop
nop
nop
add $2,$7,$0
nop
nop
nop
nop
sw $2,4($30)
nop
nop
nop
nop
halt
