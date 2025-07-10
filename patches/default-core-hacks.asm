#-----------------------------------------------------------------------------------
$-name:Slowdown fix v2
$-uuid:graphics-battle-fix-001
$-description:
Similar to already known slowdown fix.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08a0ef00
@plot_routine:
      addiu sp,sp,0xffe0
      sw s2,0x0010(sp)
      sw ra,0x000c(sp)
      sw s1,0x0008(sp)
      sw s0,0x0004(sp)
      lui s2,0x08a7
      lw s0,0x3c0c(s2)
      addu s1,a0,zero
      jal 0x08833a80
      addu a0,zero,zero
      ori t0,zero,0x0001
      beq s0,t0,SFS1
      lui s0,0x0927
      lui at,0x093e
      lw v1,0x184c(at)
      ori at,zero,0x0033
      beq v1,at,SFS2
      ori at,zero,0x002d
      bnel v1,at,SFS3
      lw a0,0x3c0c(s2)
SFS2: lw v0,0x5218(s0)
      sllv a1,t0,t0                     #a1=2.
      beql v0,zero,SFS4
      addu a1,a1,zero                   #Use t0 if issues appear.
      subu v1,v0,t0
      sw v1,0x5218(s0)
SFS4: lw a0,0x5224(s0)
      slt at,a1,a0
      beql at,zero,SFS3
      addu a0,a1,zero
      beql a0,t0,SFS3
SFS1: addu a0,zero,zero
SFS3: jal 0x0882b800
      lui s2,0x0928
      lw a0,0x520c(s0)
      addu s0,v0,zero
      sll v1,a0,0x02
      addu v1,v1,a0
      addiu v0,s2,0x0c60
      sll v1,v1,0x02
      jal 0x08833700
      addu a0,v0,v1
      lui at,0x0927
      lw a0,0x520c(at)
      sll v1,a0,0x01
      addu v1,v1,a0
      sll v1,v1,0x03
      subu v1,v1,a0
      addiu v0,s2,0x0c88
      sll v1,v1,0x02
      jal 0x08833800
      addu a0,v0,v1
      jal 0x0882c140
      addu a0,s1,zero
      jal 0x08833c00
      addiu a0,zero,0xffff
      jal 0x08a08e80
      lw s2,0x0010(sp)
      addu v0,s0,zero
      lw ra,0x000c(sp)
      lw s0,0x0004(sp)
      lw s1,0x0008(sp)
      jr ra
      addiu sp,sp,0x0020
@sub_plot_routine:
      addiu sp,sp,0xffe0
      sw s2,0x0010(sp)
      sw ra,0x000c(sp)
      sw s1,0x0008(sp)
      sw s0,0x0004(sp)
      addu s1,a0,zero
      jal 0x08833a80
      addu a0,zero,zero
      beq zero,zero,SFS1
      lui s0,0x0927
      noop*70                   #Tzepish: Claimed by new Hunters Marl and Censure code (see tzepish-hacks)
$-offset:08875364
      jal @sub_plot_routine
$-offset:088756f8
      jal @sub_plot_routine
$-offset:0887581c
      jal @sub_plot_routine
#-----------------------------------------------------------------------------------
$-name:Add spell quotes back to the game
$-uuid:text-battle-fix-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08929b28
@spell_quote_checker_and_more:
      addiu sp,sp,0xffe0
      sw ra,0x000c(sp)
      sw s2,0x0008(sp)
      sw s1,0x0004(sp)
      sw s0,0x0000(sp)
      lh v0,0x0002(a0)
      addu s2,a0,zero
      addu s1,a1,zero
      addu s0,a2,zero
      addiu a1,sp,0x001c
      addiu a2,sp,0x0018
      jal 0x088c2c40
      andi a0,v0,0x01ff
      jal 0x088bd240
      addu a0,s1,zero
      lbu a2,0x0001(s2)
      beq a2,zero,SQS1
      addiu t0,zero,0x0001
      andi a1,a2,0x00ff
      lui a3,0x08aa
      addiu a3,a3,0xa88c
      addiu v1,zero,0x00ff
SQL1: lbu a0,0x0000(a3)
      beql a0,v1,SQS1
      addu t0,zero,zero
      bnel a0,a1,SQL1
      addiu a3,a3,0x0001
SQS1: lbu v1,0x0012(v0)
      bne a1,v1,SQS2
      lbu a0,0x0051(v0)
      ext at,a0,0x05,0x01
      bnel at,zero,SQS2
      addiu t0,zero,0x0001
SQS2: lbu v1,0x0013(v0)
      bne a1,v1,SQS3
      ext at,a0,0x04,0x01
      bnel at,zero,SQS3
      addu t0,v1,zero
SQS3: bne t0,zero,SQS4
      lui v1,0x0938                     #fixed.
      lh a1,0x0002(s2)
      lw a0,0x44c0(v1)                  #fixed.
      andi v1,a1,0x01ff
@spell_quote_checker:
      beq v1,a0,SQS4
      lbu a0,0x0003(v0)
      addiu v1,zero,0x005a
      beq a0,v1,SQS4
      addiu v1,zero,0x005d
      beq a0,v1,SQS4
      slti at,a1,0x0170
      beq at,zero,SQS4
      lw v1,0x0018(sp)
      lbu v1,0x0005(v1)
      andi v1,v1,0x0002
      beq v1,zero,SQS4
      lbu v0,0x0064(v0)
      andi v0,v0,0x0012
      bne v0,zero,SQS4
      lui v0,0x08ae
      lbu v0,0xee72(v0)                 #fixed.
      ext v0,v0,0x01,0x01
      bne v0,zero,SQS4
      noop
      jal 0x08922540                    #done. Some sort of random.
      addiu a0,zero,0x0021
@spell_quote_checker2:
      andi v0,v0,0x000f
      slti at,v0,0x0004
      beq at,zero,SQS4
      lh v1,0x0002(s2)
      lui v0,0x0938                     #fixed.
      addu a2,s1,zero
      andi v1,v1,0x01ff
      addu t0,s0,zero
      addu t1,s2,zero
      sw v1,0x44c0(v0)                  #fixed.
      beq zero,zero,SQS5
      addiu a0,zero,0x0005
@sq_checker_end:
SQS4: lbu a1,0x0001(s2)
      beq a1,zero,SQS6
      lui a1,0x08aa
      addiu a1,a1,0xa88c
      addiu v0,zero,0x00ff
SQL2: lbu v1,0x0000(a1)
      beq v1,v0,SQS6
      noop
      bnel v1,a0,SQL2
      addiu a1,a1,0x0001
      beq zero,zero,SQS7
SQS6: lw v0,0x001c(sp)
      lbu v0,0x0003(v0)
      andi v0,v0,0x0040
      beq v0,zero,SQS7
      lui v0,0x08ae
      lbu v0,0xee72(v0)
      ext v0,v0,0x01,0x01
      beq v0,zero,SQS8
SQS7: addiu v0,zero,0x0006
      beq a0,v0,SQS8
      addiu v0,zero,0x0014
      addu t0,zero,zero
      bne a0,v0,SQS9
SQS8: addu a2,s1,zero
      addu t0,s0,zero
SQS9: addu t1,s2,zero
      addiu a0,zero,0x0007
SQS5: addu a1,zero,zero
      jal 0x08929e80
      addu a3,zero,zero
SQED: lw ra,0x000c(sp)
      lw s2,0x0008(sp)
      lw s1,0x0004(sp)
      lw s0,0x0000(sp)
      jr ra
      addiu sp,sp,0x0020
      noop*4
$-offset:088672e4
      jal @spell_quote_checker_and_more
$-offset:08867368
      jal @spell_quote_checker_and_more
$-offset:08867504
      jal @spell_quote_checker_and_more
$-offset:08929d60
      jal @spell_quote_checker_and_more
$-offset:08929a44
@new_08929b40:
      addiu sp,sp,0xfff0
      sw ra,0x000c(sp)
      sw s0,0x0008(sp)
      addu s0,a0,zero
      jal 0x088bd240
      addu a0,a1,zero
      sb s0,0x01df(v0)
      lui v1,0x0938
      lw v1,0x44c8(v1)
      sb v1,0x01de(v0)
      lw ra,0x000c(sp)
      lw s0,0x0008(sp)
      jr ra
      addiu sp,sp,0x0010
      noop
$-offset:08873de8
      jal @new_08929b40
#-----------------------------------------------------------------------------------
$-name:Spell quotes edit frequency
$-uuid:text-battle-fix-002
$-description:
Spell quotes will pop up more or less often on spells that have quotes.
$-overwrites:none
$-requires:text-battle-fix-001
$-file:boot.bin
$-type:ram
$-offset:@spell_quote_checker
      beq v1,zero,@sq_checker_end       #Even if it was the last one.
$-offset:@spell_quote_checker2
      andi v0,v0,0x0003                 #3 = 100 percent, f = 50 percent.
#-----------------------------------------------------------------------------------
$-name:Unlock sound novels
$-uuid:world-menu-novels-001
$-description:
Unlocks readable sound novels in the Chronicles menu.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:file
$-offset:27a191
      04030201
#-----------------------------------------------------------------------------------
$-name:Smart Encounters
$-uuid:world-map-encounters-001
$-description:
100% random encounter on destination, 0% otherwise. So you ONLY get random encounters when you want them.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08907100
      lui v1,0x0935
      lw v0,0xe0cc(v1)
      lw v1,0xe0d0(v1)
      bne v0,v1,0x089071ec
      addu v0,zero,zero
      addu v0,s2,s3
      noop*7
#-----------------------------------------------------------------------------------
$-name:Battle Initial Camera v2
$-uuid:battle-camera-fix-001
$-description:
* Set the initial camera zoom far and angle hi values.
* Tzepish note: Seems buggy. Camera controls stop working eventually
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08911bb4
      beq zero,zero,0x08911be8
$-offset:08911be4
      beq zero,zero,0x08911bac
      addiu a3,zero,0x1000
      addiu a1,s2,0x0001
      lui v1,0x08ae
      sw a1,0xee50(v1)
      lui v1,0x08a9
      lw a2,0x7e84(v1)
      jal 0x08860f80
      sw a3,0x0080(a2)
      addiu a0,zero,0x0001
      lui v1,0x08ae
      jal 0x08860d40
      sw a0,0xee4c(v1)
#-----------------------------------------------------------------------------------
$-name:Fix gil amount needed for the lip rouge quest
$-uuid:fix-gil-quest-001
$-description:
Set the amount to 50k instead of 500k.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088f2678
      jal 0x089d75c0
      addu s0,zero,a1
      noop*2
#-----------------------------------------------------------------------------------
