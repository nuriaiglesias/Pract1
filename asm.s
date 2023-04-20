.text
.syntax unified 
.thumb
.cpu cortex-m0plus
.type My_Div, %function
.type My_Mod, %function
.global My_Div

My_Div:
    MOVs R2, #0 
    CMP R1, #0  
    BEQ error   
loop_div:
    CMP R0, R1
    BLT done
    SUBS R0, R0, R1
    ADDs R2, R2, #1
    B loop_div

done:
    MOVs R0, R2
    BX LR

error:
    MOVs R0, #0x10
    BX LR

My_Mod:
    MOVs R2, #0 
    CMP R1, #0  
    BEQ error_mod   
loop_mod:
    CMP R0, R1
    BLT done_mod
    SUBS R0, R0, R1
    ADDs R2, R2, #1
    B loop_mod

done_mod:
    MOVs R0, R2
    BX LR

error_mod:
    MOVs R0, #0x10
    BX LR

.end
