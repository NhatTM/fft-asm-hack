#-----------------------------------------------------------------------------------
$-name:Unlocked jobs v2
$-uuid:global-jobs-req-001
$-description:
Removes all non level requirements for jobs.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08a1cd80
@calculate_unlocked_jobs:
      andi at,a1,0x0020                 #a0 must be a unit pointer
      bnel at,zero,UJED                 #Exit if monster.
      addu v1,zero,zero
      lui t7,0x0080                     #Start with base job.
      lui t5,0x08a8
      addu v0,t7,zero
      addu t3,zero,zero
      addiu t5,t5,0xb030                #Req.
UJLP: srl t7,t7,0x01
      addu t6,zero,zero
      addu t8,zero,zero
      addu t4,a0,zero
UJIL: addu v1,t5,t8
      lbu a3,0x0000(v1)
      lbu a2,0x0000(t4)
      andi t1,a3,0x00f0
      andi v1,a2,0x00f0
      slt at,v1,t1
      beql at,zero,UJS1
      andi t1,a3,0x000f
      beq zero,zero,UJS2
      addiu t6,zero,0x0001
UJS1: andi v1,a2,0x000f
      sltu at,v1,t1
      beql at,zero,UJS3
      addiu t8,t8,0x0001
      beq zero,zero,UJS2
      addiu t6,zero,0x0001
UJS3: sltiu v1,t8,0x000c
      bne v1,zero,UJIL
      addiu t4,t4,0x0001
UJS2: bnel t6,zero,UJS4
      addiu t3,t3,0x0001
      or v0,v0,t7
      addiu t3,t3,0x0001
UJS4: sltiu v1,t3,0x0016                #22 jobs. There is a 23.
      bne v1,zero,UJLP
      addiu t5,t5,0x000c
      lui v1,0x00ff
      andi at,a1,0x0080
      bnel at,zero,UJED
      ori v1,v1,0xffdf
      ori v1,v1,0xffbf
UJED: jr ra
      and v0,v0,v1
      noop*19
$-offset:088c7040
@space_for_more_job_req:
      noop*96                   #Tzepish: Claimed by new Attack Up and Equip Lore code (see tzepish-hacks)
#-----------------------------------------------------------------------------------
$-name:Battle jobs list
$-uuid:battle-status-jobs-001
$-description:
Fix what status jobs list show in battle.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:089a4dc0
@battle_jobs_check:
      addiu sp,sp,0xffe0
      sw ra,0x001c(sp)
      sw s4,0x0018(sp)
      sw s3,0x0014(sp)
      sw s2,0x0010(sp)
      sw s1,0x000c(sp)
      andi s1,a0,0x00ff
      sll v1,s1,0x02
      lui v0,0x0945
      sw s0,0x0008(sp)
      addiu v0,v0,0x2108
      addu s0,v0,v1
      lw v0,0x0000(s0)
      addu s4,a1,zero
      jal 0x089a4ac0
      addiu a0,v0,0x0008
      lw v1,0x0000(s0)
      lbu a0,0x0007(v1)
      addiu v0,zero,0x0081
      beql a0,v0,BJS1
      addiu a0,zero,0x004a
      addiu v0,zero,0x0080
      beql a0,v0,BJS1
      addiu a0,zero,0x004a
      addiu v0,zero,0x0082
      beql a0,v0,BJS1
      lh a0,0x0000(v1)
BJS1: sh a0,0x0000(s4)
      lw a0,0x0000(s0)
      lh v1,0x0000(a0)
      slti v0,v1,0x003c
      addu a1,zero,zero
      bne v0,zero,BJS2
      slti v0,v1,0x0090
      slti at,v1,0x004a
      addu a1,zero,at
BJS2: bne v0,zero,BJS3
      slti at,v1,0x009b
      addu a1,zero,at
BJS3: bnel a1,zero,BJE2
      addiu v0,zero,0xffff
      lbu v1,0x0007(a0)
      addiu v0,zero,0x0082
      bnel v1,v0,BJS4
      addiu a0,zero,0x0001
      addiu v0,zero,0xffff
BJE2: sh v0,0x0002(s4)
      beq zero,zero,BJED
      addiu v0,zero,0x0001
BJS4: jal @check_unlocked_jobs
      addiu s2,zero,0x0001
      addu s3,s2,zero
      addiu s1,s4,0x0002
BJLP: jal @check_unlocked_jobs
      addiu a0,zero,0x0001
      beq v0,zero,BJS5
      addiu v1,s3,0x004a
      slti at,s3,0x0014
      beql at,zero,BJS6
      addiu v1,s3,0x008c
BJS6: sh v1,0x0000(s1)
      addiu s1,s1,0x0002
      addiu s2,s2,0x0001
BJS5: addiu s3,s3,0x0001
      slti v0,s3,0x0016
      bne v0,zero,BJLP
      sll v0,s2,0x01
      addiu v1,zero,0xffff
      addu v0,s4,v0
      sh v1,0x0000(v0)
      addu v0,s2,zero
BJED: lw ra,0x001c(sp)
      lw s4,0x0018(sp)
      lw s3,0x0014(sp)
      lw s2,0x0010(sp)
      lw s1,0x000c(sp)
      lw s0,0x0008(sp)
      jr ra
      addiu sp,sp,0x0020
      noop*33                   #Tzepish: Claimed by new Guests keep their stats code (see tzepish-hacks)
$-offset:089a4b00
@check_unlocked_jobs:
      beql a0,zero,UCED
      addu v0,zero,zero
      lui t0,0x08ae
      lui t1,0x0945
      lbu v0,0x2048(t1)
      beql v0,zero,UCS1
      addu v1,a0,zero
      addiu t2,zero,0x0007
      sw t2,0x2cc4(t0)
      sb zero,0x2048(t1)
      addu v1,a0,zero
UCS1: addu v0,zero,zero
      beq v1,zero,UCED
      addiu a0,a0,0xffff
      addiu t4,zero,0x0001
UCLP: lw t2,0x204c(t1)
      lw t3,0x2cc4(t0)
      lbu t5,0x0000(t2)
      addiu t2,t3,0xffff
      sllv t3,t4,t3
      and t3,t5,t3
      beq t3,zero,UCS2
      sw t2,0x2cc4(t0)
      sllv t3,t4,a0
      or v0,v0,t3
UCS2: bgezl t2,UCS3
      addu t2,a0,zero
      addiu t2,zero,0x0007
      sw t2,0x2cc4(t0)
      lw t2,0x204c(t1)
      addiu t2,t2,0x0001
      sw t2,0x204c(t1)
      addu t2,a0,zero
UCS3: bne t2,zero,UCLP
      addiu a0,a0,0xffff
UCED: jr ra
      noop
      noop*11
#-----------------------------------------------------------------------------------
$-name:Abilities in Arith skillset can be reflected
$-uuid:battle-arith-reflect-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088b71cc
      noop
#-----------------------------------------------------------------------------------
$-name:Null slps file in fftpack
$-uuid:clean-space-fftackbin-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:none
$-file:fftpack.bin
$-type:NULL_FILE
$-offset:0014&INDEXED
#-----------------------------------------------------------------------------------
$-name:Replace TEST.EVT file
$-uuid:replace-testevt-file-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:none
$-file:fftpack.bin
$-type:files/test-evt/test-evt.bin
$-offset:005c&INDEXED
#-----------------------------------------------------------------------------------
$-name:Treasure Hunter 9-bit rare items
$-uuid:th-9b-items-001
$-description:
Enables all items to be obtained with Treasure Hunter ability (rare).
Edit TH table using the 2nd flag as the extra bit for the rare item.
RIH = (2nd flag << 8) + RIB.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08865604
      lhu a1,0x51c4(v0)
$-offset:0886564c
      lhu a1,0x51c4(v0)
$-offset:08865678
      lhu a1,0x51c4(v0)
$-offset:088bc5a0
@new_88bc5c0:
      addiu sp,sp,0xfff0
      sw ra,0x000c(sp)
      sw s0,0x0008(sp)
      addu s0,a0,zero
      lbu v0,0x0051(s0)
      lbu a0,0x004f(a0)
      lbu a1,0x0050(s0)
      sll v0,v0,0x18
      jal 0x088bc680
      srl a2,v0,0x1f
      lbu v1,0x002b(s0)
      addu s0,v0,zero
      addiu a0,zero,0x0064
@treasure_rare_min_brave:
      addu a1,a0,zero
      jal 0x088c7680
      subu a1,a1,v1
      lbu v1,0x0001(s0)
      sll v1,v1,0x02
      lui a0,0x092f
      addu v1,a0,v1
      lbu v1,0x8521(v1)
      bnel v0,zero,TIS1
      lbu v1,0x0003(s0)
      ext at,v1,0x06,0x01
      sll at,at,0x08
      lbu v1,0x0002(s0)
      or v1,v1,at
TIS1: sh v1,0x84f0(a0)
      jal 0x08922540
      addiu a0,zero,0x0033
      lbu a1,0x0001(s0)
      addu a0,v0,zero
      jal 0x088bc940
      addiu a2,zero,0x0001
      lui v0,0x092f
      addiu v0,v0,0x84ec
      sw zero,0x0000(v0)
      lw ra,0x000c(sp)
      lw s0,0x0008(sp)
      jr ra
      addiu sp,sp,0x0010
      noop*15
$-offset:088655e0
      jal @new_88bc5c0
#-----------------------------------------------------------------------------------
$-name:ENTD 9-bit equipment items
$-uuid:entd-9b-items-001
$-description:
Enables all items to be equipped via ENTD.
Edit ENTD table using the 5 most significant bits from palette byte as
the extra bit for each gear slot.
RHH = (PB&0x80 << 1) + RHB.
LHH = (PB&0x40 << 2) + LHB.
HeH = (PB&0x20 << 3) + HeB.
BoH = (PB&0x10 << 4) + BoB.
AcH = (PB&0x08 << 5) + AcB.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088c33bc
@new_88c33c0:
      addiu sp,sp,0xffe0
      sw ra,0x001c(sp)
      sw s4,0x0018(sp)
      sw s3,0x0014(sp)
      sw s2,0x0010(sp)
      sw s1,0x000c(sp)
      sw s0,0x0008(sp)
      lbu v1,0x0017(a1)
      andi v1,v1,0x0007
$-offset:088c2f90
      jal @new_88c33c0
$-offset:088c4c80
@load_entd_items:
      addiu sp,sp,0xffe0
      sw ra,0x001c(sp)
      sw s4,0x0018(sp)
      sw s3,0x0014(sp)
      sw s2,0x0010(sp)
      sw s1,0x000c(sp)
      sw s0,0x0008(sp)
      lbu v1,0x0006(a0)
      addu s2,a1,zero
      andi v1,v1,0x0020
      beq v1,zero,EISR
      addu s3,a0,zero
      lbu v1,0x0015(s2)
      addiu a0,zero,0x00ff
      sh v1,0x0020(s3)
      sh a0,0x0022(s3)
      lbu v1,0x0016(s2)
      sh v1,0x0024(s3)
      sh a0,0x0026(s3)
      lbu v1,0x0012(s2)
      sh v1,0x001a(s3)
      lbu v1,0x0013(s2)
      sh v1,0x001c(s3)
      lbu v1,0x0014(s2)
      beq zero,zero,EIED
      sh v1,0x001e(s3)
EISR: lbu s4,0x0017(s2)
      andi at,s4,0x0080
      sll at,at,0x01
      lbu s1,0x0015(s2)
      or s1,s1,at
      lbu s0,0x009b(s3)
      jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIR1
      andi v0,s0,0x0002
      beq v0,zero,EIR1
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addiu a2,zero,0x0004
      jal 0x088c5e80
      addiu a3,zero,0x00ff
      andi s1,v0,0x00ff
EIR1: jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIR2
      andi v0,s0,0x0001
      beq v0,zero,EIR2
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addiu a2,zero,0x0008
      jal 0x088c5e80
      addiu a3,zero,0x00ff
      andi s1,v0,0x00ff
EIR2: lbu s0,0x0099(s3)
      jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIR3
      andi v0,s0,0x0020
      beq v0,zero,EIR3
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addu a2,zero,zero
      jal 0x088c5e80
      addiu a3,zero,0x0003
      andi s1,v0,0x00ff
EIR3: jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIR4
      andi v0,s0,0x0010
      beq v0,zero,EIR4
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addu a2,zero,zero
      jal 0x088c5e80
      addiu a3,zero,0x0005
      andi s1,v0,0x00ff
EIR4: jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIR5
      andi v0,s0,0x0008
      beq v0,zero,EIR5
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addu a2,zero,zero
      jal 0x088c5e80
      addiu a3,zero,0x000b
      andi s1,v0,0x00ff
EIR5: jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIR6
      andi v0,s0,0x0004
      beq v0,zero,EIR6
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addu a2,zero,zero
      jal 0x088c5e80
      addiu a3,zero,0x000f
      andi s1,v0,0x00ff
EIR6: jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIR7
      andi v0,s0,0x0002
      beq v0,zero,EIR7
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addu a2,zero,zero
      jal 0x088c5e80
      addiu a3,zero,0x0006
      andi s1,v0,0x00ff
EIR7: jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIR8
      andi v0,s0,0x0001
      beq v0,zero,EIR8
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addu a2,zero,zero
      jal 0x088c5e80
      addiu a3,zero,0x000a
      andi s1,v0,0x00ff
EIR8: jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIR9
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addu a2,zero,zero
      jal 0x088c5e80
      addiu a3,zero,0x00ff
      andi s1,v0,0x00ff
EIR9: jal 0x08a18c80
      addu a0,s1,zero
      bnel v0,zero,EIR0
      addiu s1,zero,0x00ff
EIR0: jal 0x08a18600
      addu a0,s1,zero
      lbu v0,0x0003(v0)
      andi v0,v0,0x0040
      sh s1,0x0020(s3)
      addiu at,zero,0x00ff
      beql v0,zero,EISL
      sh at,0x0022(s3)
      sh s1,0x0022(s3)
      sh at,0x0020(s3)
EISL: andi at,s4,0x0040
      sll at,at,0x02
      lbu s1,0x0020(s3)
      lbu s0,0x0016(s2)
      or s0,s0,at
      jal 0x08a18c00
      addu a0,s1,zero
      bne v0,zero,EIL1
      addu a0,s1,zero
      jal 0x08a18680
      lbu s1,0x009b(s3)
      lbu v0,0x0001(v0)
      andi v0,v0,0x0001
      bnel v0,zero,EIL1
      addiu s0,zero,0x00ff
      andi v0,s1,0x0002
      bnel v0,zero,EIL1
      addiu s0,zero,0x00ff
EIL1: lbu s1,0x009b(s3)
      jal 0x08a18c80
      addu a0,s0,zero
      beq v0,zero,EIL2
      andi v0,s1,0x0001
      beq v0,zero,EIL2
      addu a0,s3,zero
      addiu a1,zero,0x0080
      addiu a2,zero,0x0008
      jal 0x088c5e80
      addiu a3,zero,0x00ff
      andi s0,v0,0x00ff
EIL2: lbu s1,0x0054(s3)
      jal 0x08a18c80
      addu a0,s0,zero
      beq v0,zero,EIL3
      andi v0,s1,0x0010
      beql v0,zero,EIL3
      addiu s0,zero,0x00ff
      addu a0,s3,zero
      addiu a1,zero,0x0040
      addu a2,zero,zero
      jal 0x088c5e80
      addiu a3,zero,0x00ff
      andi s0,v0,0x00ff
EIL3: jal 0x08a18600
      addu a0,s0,zero
      lbu v0,0x0003(v0)
      andi v0,v0,0x0080
      sh s0,0x0026(s3)
      addiu at,zero,0x00ff
      beql v0,zero,EISH
      sh at,0x0024(s3)
      sh s0,0x0024(s3)
      sh at,0x0026(s3)
EISH: andi at,s4,0x0020
      sll at,at,0x03
      lbu s1,0x0012(s2)
      or s1,s1,at
      lbu s0,0x0099(s3)
      jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIH1
      andi v0,s0,0x0080
      beq v0,zero,EIH1
      addu a2,zero,zero
      addu a0,s3,zero
      addiu a1,zero,0x0020
      jal 0x088c5e80
      addiu a3,zero,0x0014
      andi s1,v0,0x00ff
EIH1: jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIH2
      addu a2,zero,zero
      addu a0,s3,zero
      addiu a1,zero,0x0020
      jal 0x088c5e80
      addiu a3,zero,0x00ff
      andi s1,v0,0x00ff
EIH2: jal 0x08a18c80
      addu a0,s1,zero
      bnel v0,zero,EIH3
      addiu s1,zero,0x00ff
EIH3: sh s1,0x001a(s3)
      andi at,s4,0x0010
      sll at,at,0x04
      lbu s1,0x0013(s2)
      or s1,s1,at
      jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIB1
      andi v0,s0,0x0040
      beq v0,zero,EIB1
      addu a2,zero,zero
      addu a0,s3,zero
      addiu a1,zero,0x0010
      jal 0x088c5e80
      addiu a3,zero,0x0017
      andi s1,v0,0x00ff
EIB1: jal 0x08a18c80
      addu a0,s1,zero
      beq v0,zero,EIB2
      addu a2,zero,zero
      addu a0,s3,zero
      addiu a1,zero,0x0010
      jal 0x088c5e80
      addiu a3,zero,0x00ff
      andi s1,v0,0x00ff
EIB2: jal 0x08a18c80
      addu a0,s1,zero
      bnel v0,zero,EIB3
      addiu s1,zero,0x00ff
EIB3: sh s1,0x001c(s3)
      andi at,s4,0x0008
      sll at,at,0x05
      lbu s0,0x0014(s2)
      or s0,s0,at
      jal 0x08a18c80
      addu a0,s0,zero
      beq v0,zero,EIA1
      addu a2,zero,zero
      addu a0,s3,zero
      addiu a1,zero,0x0008
      jal 0x088c5e80
      addiu a3,zero,0x00ff
      andi s0,v0,0x00ff
EIA1: jal 0x08a18c80
      addu a0,s0,zero
      bnel v0,zero,EIA2
      addiu s0,zero,0x00ff
EIA2: sh s0,0x001e(s3)
      addu s0,zero,zero
EILP: jal 0x08a18c40
      lhu a0,0x001a(s3)
      beq v0,zero,EIS1
      addiu s0,s0,0x0001
      addiu v1,zero,0x00ff
      sh v1,0x001a(s3)
EIS1: slti v1,s0,0x0007
      bne v1,zero,EILP
      addiu s3,s3,0x0002
EIED: lw ra,0x001c(sp)
      lw s4,0x0018(sp)
      lw s3,0x0014(sp)
      lw s2,0x0010(sp)
      lw s1,0x000c(sp)
      lw s0,0x0008(sp)
      jr ra
      addiu sp,sp,0x0020
      noop*60                   #Tzepish: Claimed by new ENTD Load Formation backup transform code  (see tzepish-hacks)
#-----------------------------------------------------------------------------------
$-name:Poach 9-bit items
$-uuid:poach-9b-items-001
$-description:
Enables all items to be obtained via poaching.
Use the 96 bits table as the extra bit for each poach entry.
$-overwrites:none
$-requires:none
$-define:
      %pis9b_h,0x088b
      %pis9b_l,0x6358
$-file:boot.bin
$-type:ram
$-offset:088b6358
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
      writeBits;00000000
$-offset:088b6364
@new_88b6380:
      addiu sp,sp,0xfff0
      sw ra,0x000c(sp)
      sw s0,0x0008(sp)
      lui v1,0x092e
      lw v0,0x5b9c(v1)
      bnel v0,zero,PIED
      addu v0,zero,zero
      lw v0,0x5c10(v1)
      lhu v0,0x0012(v0)
      andi v0,v0,0x0020
      beql v0,zero,PIED
      addu v0,zero,zero
      lw v0,0x5c48(v1)
      lbu v1,0x0003(v0)
      slti v0,v1,0x005e
      bnel v0,zero,PIED
      addu v0,zero,zero
      slti at,v1,0x008e
      beql at,zero,PIED
      addu v0,zero,zero
      addiu s0,v1,0xffa2
      addiu a0,zero,0x0100
      jal 0x088c7680
      addiu a1,zero,0x001f
      bne v0,zero,PIS1
      lui v0,0x08a8
      addiu v0,v0,0x0001
PIS1: sll v1,s0,0x01
      addu v0,v0,v1
      lbu t0,0xafd0(v0)
      lui v0,%pis9b_h
      srl at,s0,0x03
      addu v0,at,v0
      lbu v0,%pis9b_l(v0)
      andi v1,s0,0x0007
      beq v1,zero,PIS2
      addiu at,zero,0x0080
      srlv at,at,v1
PIS2: and v0,v0,at
      bnel v0,zero,PIS3
      addiu t0,t0,0x0100
PIS3: jal 0x08a21a80
      addu s0,t0,zero
      andi v0,v0,0x00ff
      bne v0,zero,PIED
      addiu v0,zero,0x0001
      lui at,0x092f
      addu a0,at,s0
      lbu v1,0xaa64(a0)
      sltiu at,v1,0x00ff
      addu v1,v1,at
      sb v1,0xaa64(a0)
PIED: lw ra,0x000c(sp)
      lw s0,0x0008(sp)
      jr ra
      addiu sp,sp,0x0010
      noop*15
$-offset:088b5f10
      jal @new_88b6380
#-----------------------------------------------------------------------------------
$-name:Balthier gets no hardcoded ENTD items
$-uuid:baltheir-normal-entd-001
$-description:
Removes the hardcoding for Balthier initial equipment, so that his ENTD entry is obeyed.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088bbafc
      noop*16
$-offset:08a56058
      noop*4
#-----------------------------------------------------------------------------------
$-name:Onion items can be equipped if lip rouge flag
$-uuid:onion-items-liprouge-001
$-description:
Any job can equip onion items if it has the lip rouge flag set.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:0898fcb8
      lui v0,0x08a7
      addiu at,zero,0x0031
      multu at,v1
      mflo at
      addu v0,v0,at
      lbu v0,0x7995(v0)
      andi v0,v0,0x0008
      srl v0,v0,0x02
      beq zero,zero,0x0898fdb0
      addiu v0,v0,0xffff
      noop*3
$-offset:089a2340
      lui v0,0x08a7
      addiu at,zero,0x0031
      multu at,v1
      mflo at
      addu v0,v0,at
      lbu v0,0x7995(v0)
      andi v0,v0,0x0008
      srl v0,v0,0x02
      beq zero,zero,0x089a2438
      addiu v0,v0,0xffff
      noop*3
#-----------------------------------------------------------------------------------
$-name:Treasure Hunter edit rare minimum brave
$-uuid:th-rare-min-001
$-description:
Sets the amount of Brave to get the rare item. Set to 64 (100%) for always.
$-overwrites:none
$-requires:th-9b-items-001
$-file:boot.bin
$-type:ram
$-offset:@treasure_rare_min_brave
      addiu a1,a0,0x0064
#-----------------------------------------------------------------------------------
$-name:Treasure Hunter is Player only
$-uuid:th-player-only-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088bc20c
      lbu v1,0x0000(v0)
      lbu a0,0x0005(s2)
      beq s0,zero,MPSS
      andi at,v1,0x0001
      beq at,zero,MPSS
      andi at,a0,0x0030
      beql at,zero,0x088bc24c
      ori s1,s1,0x0004
MPSS: andi v1,v1,0x0002
      noop
#-----------------------------------------------------------------------------------
$-name:Arithmeticks supports up to 20 skillsets
$-uuid:arith-20-ss-001
$-description:
Use ssYssX labels to set which skillset will be read by Arithmeticks.
Use MaxSS to set the amount of valid skillsets. Do not set more than 79 Arithmetick
abilities. In theory it could work up to 109, but it was never tested beyond 70. It is
not recommended to use skillsets that have non-action abilities as action abilities.
$-overwrites:none
$-requires:none
$-define:
      %MaxSS,0x0004
      %ss02ss01,0x0b0a
      %ss04ss03,0x100c
      %ss06ss05,0x0000
      %ss08ss07,0x0000
      %ss10ss09,0x0000
      %ss12ss11,0x0000
      %ss14ss13,0x0000
      %ss16ss15,0x0000
      %ss18ss17,0x0000
      %ss20ss19,0x0000
$-file:boot.bin
$-type:ram
$-offset:088bed00
      addiu sp,sp,0xff50
      sw ra,0x001c(sp)
      sw s4,0x0018(sp)
      sw s3,0x0014(sp)
      sw s2,0x0010(sp)
      sw s1,0x000c(sp)
      sw s0,0x0008(sp)
      addu s4,a0,zero
      addu s3,a2,zero
      addu s1,zero,zero
      lui v0,%ss04ss03
      ori v0,v0,%ss02ss01
      sw v0,0x0028(sp)
      lui v0,%ss08ss07
      ori v0,v0,%ss06ss05
      sw v0,0x002c(sp)
      lui v0,%ss12ss11
      ori v0,v0,%ss10ss09
      sw v0,0x0030(sp)
      lui v0,%ss16ss15
      ori v0,v0,%ss14ss13
      sw v0,0x0034(sp)
      lui v0,%ss20ss19
      ori v0,v0,%ss18ss17
      sw v0,0x0038(sp)
      sltiu at,s4,0x0015
      beq at,zero,ASED
      addu v0,zero,zero
      sll v0,s4,0x04
      subu v0,v0,s4
      sll v0,v0,0x02
      addu v0,v0,s4
      sll v1,v0,0x03
      lui v0,0x092e
      addiu v0,v0,0x5cb4
      addu a0,v0,v1
      lbu v1,0x0001(a0)
      addiu v0,zero,0x00ff
      beq v1,v0,ASED
      addu v0,zero,zero
      andi v1,a1,0x00ff
      addiu v0,zero,0x0015
      addiu s0,sp,0x0028
      beql v1,v0,ASLP
      addu s2,zero,zero
      addiu v0,zero,0xffff
      sh v0,0x0000(s3)
      beq zero,zero,ASED
      addu v0,zero,zero
ASLP: lbu a1,0x0000(s0)
      addu a0,s4,zero
      addiu a2,sp,0x008c
      addiu a3,sp,0x0078
      addiu t0,sp,0x0064
      addiu t1,zero,0x0001
      addiu t2,sp,0x0050
      jal 0x088be340
      addiu t3,sp,0x003c
      beql v0,zero,ASS1
      addiu s2,s2,0x0001
      blez v0,ASS2
      addu a3,zero,zero
      lui a0,0x08a7
      addiu a2,sp,0x008c
      addiu a0,a0,0x64c0
ASIL: lh a1,0x0000(a2)
      sll v1,a1,0x03
      subu v1,v1,a1
      sll v1,v1,0x01
      addu v1,a0,v1
      lbu v1,0x0005(v1)
      andi v1,v1,0x0040
      beql v1,zero,ASS3
      addiu a3,a3,0x0001
      sh a1,0x0000(s3)
      addiu s3,s3,0x0002
      addiu s1,s1,0x0001
      addiu a3,a3,0x0001
ASS3: slt v1,a3,v0
      bne v1,zero,ASIL
      addiu a2,a2,0x0002
ASS2: addiu s2,s2,0x0001
ASS1: slti v0,s2,%MaxSS
      bne v0,zero,ASLP
      addiu s0,s0,0x0001
      addiu v1,zero,0xffff
      addu v0,s1,zero
      sh v1,0x0000(s3)
ASED: lw ra,0x001c(sp)
      lw s4,0x0018(sp)
      lw s3,0x0014(sp)
      lw s2,0x0010(sp)
      lw s1,0x000c(sp)
      lw s0,0x0008(sp)
      jr ra
      addiu sp,sp,0x00b0
      noop*3
#-----------------------------------------------------------------------------------
$-name:Party Roster Extension (PRE)
$-uuid:p-r-e-001
$-description:
Extends party roster limit to 25. Requires more testing.
$-overwrites:none
$-requires:none
$-define:
      %pr_size,0x001A
$-file:boot.bin
$-type:file
$-offset:2da1c7
      01050c19
$-type:ram
$-offset:0883e6bc
      slti v0,s0,%pr_size               #Calls 08a179f8, compares unique value.
$-offset:0883f31c
      slti v0,s0,%pr_size               #Calls 08a179f8 too.
#$-offset:088b93f0
#      slti v0,s3,%pr_size               #Divs s3 by 8, to be removed.
#$-offset:088b9514
#      slti v0,s4,%pr_size               #Divs s4 by 8 too.
#$-offset:088bcd8c
#      slti v0,s5,%pr_size               #Divs s5 by 8 too.
$-offset:088c1c28
      slti v0,a0,%pr_size               #Good.
$-offset:088c1cd4
      slti v0,s0,%pr_size               #Seems ok, stores at 0x01.
$-offset:088c2108
      slti v0,s0,%pr_size               #Find empty slot?
$-offset:088c269c
      slti v0,a1,%pr_size               #Good.
#$-offset:088c2ba4
#      slti v0,s4,%pr_size               #Big routine, seems not ok.
#$-offset:088c2bb4
#      slti at,s3,%pr_size               #Same.
#$-offset:088c2bd8
#      slti v0,s3,%pr_size               #Same.
#$-offset:088c3a98
#      slti at,v0,%pr_size               #Good.
#$-offset:088c62ec
#      slti v1,s3,%pr_size               #Divs s3 by 8 too.
#$-offset:088e27ac
#      slti v0,s1,%pr_size               #Calls 089d75c0, not ok.
#$-offset:088eb000
#      slti v0,s4,%pr_size               #Calls 089d75c0 too.
$-offset:088f3204
      slti v0,s0,%pr_size               #Good, has get pty pointer.
$-offset:088f3284
      slti v0,s0,%pr_size               #Same.
$-offset:088f3344
      slti v0,s0,%pr_size               #Same.
$-offset:088f3404
      slti v0,s0,%pr_size               #Same.
#$-offset:088f34e0
#      slti v0,s3,%pr_size               #Calls 089d75c0 too.
#$-offset:088f8520
#      slti v0,s0,%pr_size               #Calls 089d7700, similar to 089d75c0.
#$-offset:088fd570
#      slti v0,s1,%pr_size               #Good.
#$-offset:088fefe4
#      slti v0,s1,%pr_size               #Good.
$-offset:0894ac20
      slti v0,a0,%pr_size               #Good, for end of battle.
#$-offset:08953aac
#      slti v0,v1,%pr_size               #Good.
#$-offset:08962728
#      slti v0,a3,%pr_size               #Used to stop loop of halves, not ok.
$-offset:08962854
      slti v0,s3,%pr_size               #For jobs, ok.
$-offset:08970d94
      slti at,v0,%pr_size               #Good for shop.
#$-offset:0898b8e8
#      slti v0,v1,%pr_size               #Not sure, but seems ok.
$-offset:0898bc94
      slti v0,v0,%pr_size               #Good. Guest on World.
#$-offset:0898dd74
#      slti v0,a3,%pr_size               #Used to stop loop of halves, not ok.
$-offset:0898df48
      slti v0,s1,%pr_size               #For jobs, ok.
#$-offset:089a50e8
#      slti v0,a3,%pr_size               #Used to stop loop of halves, not ok.
$-offset:089a51f8
      slti v0,s3,%pr_size               #For jobs, ok.
$-offset:089bee88
      slti at,s2,%pr_size               #Good for battle start.
$-offset:089c5be0
      slti v0,s5,%pr_size               #Good for battle start.
$-offset:089c66c4
      slti at,s2,%pr_size               #Ok as 089bee88.
$-offset:089c6a04
      slti v0,s2,%pr_size               #Good as before.
#$-offset:08a00720
#      slti v0,v1,%pr_size               #Dunno.
#$-offset:08a009c0
#      slti v0,s3,%pr_size               #Similar as before, but bigger.
#$-offset:08a0f65c
#      slti v0,s0,%pr_size               #Dunno, may not be ok.
#$-offset:08a1cf1c
#      slti v0,s2,%pr_size               #Seems ok, almost good.
#$-offset:08a1cf24
#      slti v0,s2,%pr_size               #Same.
#$-offset:08a1cf30
#      slti v0,s2,%pr_size               #Same.
#$-offset:08a2b450
#      slti v0,s1,%pr_size               #Good.
#$-offset:08a2b8f8
#      slti v0,s1,%pr_size               #Good.
#$-offset:08a2bae8
#      slti v0,s2,%pr_size               #Good.
#$-offset:0894a230
#      slti at,v1,%pr_size               #Seems ok, almost good.
#$-offset:0894a6b0
#      slti at,v1,%pr_size               #Same as before.
#$-offset:0894c5bc
#      slti at,s1,%pr_size               #Good.
#$-offset:0898b940
#      slti v1,a0,%pr_size               #Dunno.
#$-offset:08a00b4c
#      slti v0,s4,%pr_size               #Dunno.
#$-offset:08a0206c
#      slti at,v1,%pr_size               #It doesnt seem to be ok.
#$-offset:0880e20c
#      slti v0,a0,%pr_size               #Dunno.
$-offset:088c1ec0
@party_slot_handler:
      addiu sp,sp,0xff90
      sb zero,0x0000(a1)
      lui a1,0x092f
      addu a2,zero,zero
      addiu a1,a1,0xacdc
      addiu v1,sp,0x0000
PSL1: slti v0,a2,0x001c
      bnel v0,zero,PSS1
      addu v0,a1,zero
PSS1: sw v0,0x0000(v1)
      addiu a2,a2,0x0001
      slti v0,a2,0x001c
      addiu a1,a1,0x0100
      bne v0,zero,PSL1
      addiu v1,v1,0x0004
      addu v0,zero,zero
      beql a0,zero,PSSS
      addiu a2,zero,%pr_size
      addiu v0,zero,%pr_size
      addiu a2,zero,0x001c
PSSS: slt at,v0,a2
      beql at,zero,PSED
      addiu v0,zero,0xffff
      sll v1,v0,0x02
      addu v1,v1,sp
      addiu a1,v1,0x0000
      addiu a0,zero,0x00ff
PSL2: lw v1,0x0000(a1)
      lbu v1,0x0001(v1)
      bnel v1,a0,PSS2
      addiu v0,v0,0x0001
      beq zero,zero,PSED
PSS2: slt v1,v0,a2
      bne v1,zero,PSL2
      addiu a1,a1,0x0004
      addiu v0,zero,0xffff
PSED: jr ra
      addiu sp,sp,0x0070
@place_egg_handler:
      noop*10
#-----------------------------------------------------------------------------------
$-name:Switch formation and absorb
$-uuid:switch-formation-absorb-001
$-description:
Switch units with L1/R1 buttons in the formation screen, only if sorted by number.
Directional inputs reworked in the formation screen, Left/Right/Up/Down now behave
like old L1/R1. Regain learned abilities and total job points of any non monster unit
that leaves permanently the party roster by placing any other non monster unit on the
same roster number of the unit lost.
$-overwrites:none
$-requires:p-r-e-001
$-define:
      %pr_-2*size+1,0xffcf
$-file:boot.bin
$-type:ram
$-offset:08982af8
      addu a0,s2,zero
      lui a1,0x0945
      lbu a2,0xf3ec(a1)
      lbu a3,0xf04c(a1)
      addu t0,a3,zero
      addu t1,a2,zero
      ori t5,zero,0x0024
      jal @switch_units_absorb
      lui t6,0x092f
$-offset:0897dac8
@switch_units_absorb:
      addiu sp,sp,0xffe0
SULP: andi t7,a0,0x0008                 #Check if R1 is pressed.
      bne t7,zero,SUS2
      addiu v0,t0,0x0001
      andi t7,a0,0x2000                 #Check if right is pressed.
      bne t7,zero,SUS3
      andi t7,a0,0x0004                 #Check if L1 is pressed.
      bne t7,zero,SUS2
      addiu v0,t0,0xffff
      andi t7,a0,0x8000                 #Check if left is pressed.
      bne t7,zero,SUS3
      addiu t7,a2,0xfffc
      blez t7,SUS1                      #Branch if a2 is less than or equal 4.
      addiu v1,zero,0x0001
      addiu v1,zero,0x0005
      divu a2,v1
      mflo a2
      sll at,a2,0x02
      addu a2,a2,at
      addiu a2,a2,0x0004                #More inst than psx cuz 5 instead of 4.
SUS1: andi t7,a0,0x4000                 #Check if down is pressed.
      bne t7,zero,SUS3
      addu v0,t0,v1
      andi t7,a0,0x1000                 #Check if up is pressed.
      bne t7,zero,SUS3
      subu v0,t0,v1
SUAE: beq zero,zero,SUED                #End of checking inputs. Abnormal end.
      or v0,a3,zero                     #Dont move the cursor.
SUS2: bne s7,zero,SUAE                  #Only in party roster menu.
      sll t7,t0,0x02                    #Switching code from here to SUS3.
      lbu t8,0xf410(a1)
      addu t7,a1,t7
      lw t7,0x19f4(t7)
      subu t4,v0,t0
      lhu t0,0x002c(t7)                 #Current UnitIndex.
      bne t8,zero,SUAE                  #If not sorted by number, exit. t8 is now zero.
      addu t1,t0,t4                     #Destination UnitIndex.
      addu t7,t0,t1
      addiu v1,t7,0xffff                #Check if sum of both UnitIndex less than or equal 1
      blez v1,SUAE
      addiu v1,t7,%pr_-2*size+1         #Check if sum of both UnitIndex greater than or equal 49
      bgez v1,SUAE
      sll t2,t0,0x08
      sll t3,t1,0x08
      addu t2,t2,t6                     #Set party slot pointer for current index.
      addu t3,t3,t6                     #Set party slot pointer for destination index.
      ori v1,zero,0x0100
      lbu t4,0xace0(t2)
SUPS: beq t4,t5,SUAE                    #If an egg is selected or if at destination is an egg, exit.
      lbu t4,0xacdd(t3)
      bne t8,zero,SUIL                  #Prevent loop.
      ori t8,zero,0x00ff
      bne t4,t8,SUPS                    #Branch if unit was not dismissed.
      lbu t4,0xace0(t3)
      lbu t6,0xace0(t2)
      ori t0,zero,0x00ff                #If it was, keep it like that.
      or t6,t6,t4                       #Logic or for both genders, only if destination was dismissed.
      or v0,a3,zero                     #Dont move the cursor.
SUIL: addiu v1,v1,0xfffe                #Swap data.
      lhu t5,0xacdc(t2)
      lhu t4,0xacdc(t3)
      bne t0,t8,SUIS                    #Branch if destination was not dismissed.
      sh t4,0xacdc(t2)                  #Absorb code:
      addiu at,v1,0xff74
      sltiu at,at,0x0044
      bne at,zero,AUS1                  #Branch if Unlocked Jobs or Abilities Learned.
      or t7,t4,t5                       #Logic or for both UJ or AL.
      addiu at,v1,0xffdd
      sltiu at,at,0x002e
      beq at,zero,SUIS                  #Branch if not (UJ or AL) or not Total Job Points.
      sh t5,0xacdc(t2)                  #Keep data for better portrait transition.
      sltu at,t4,t5
      or t7,t5,zero                     #Store original.
AUS1: bne at,zero,AUS2                  #Branch if not bigger or if UJ or AL.
      andi at,t6,0x0020                 #Logic and for both genders with monster gender.
      or t7,t4,zero                     #If bigger store destination.
AUS2: bne at,zero,SUIS                  #Branch if at least there is a monster.
      sh zero,0xacdc(t2)                #Always store zero in original for UJ or AL.
      or t5,t7,zero                     #Prepare value for destination.
SUIS: sh t5,0xacdc(t3)
      addiu t2,t2,0x0002
      bgtz v1,SUIL
      addiu t3,t3,0x0002
      sb t0,0xabdd(t2)
      sb t1,0xabdd(t3)
      sw ra,0x0018(sp)                  #This is for the jal's.
      sw v0,0x0010(sp)
      jal 0x08959880                    #Update portrait and name.
      sw a3,0x0014(sp)
      lui t7,0x0945
      jal 0x08980340                    #Update most graphic data. Kills a lot of visual effects.
      sb zero,0xf0ba(t7)
      lw v0,0x0010(sp)                  #Recover from jal's.
      lw a3,0x0014(sp)
      beq zero,zero,SUNE                #Normal end.
      lw ra,0x0018(sp)
SUS3: bltz v0,SUS4                      #Check if destination pos is less than zero.
      subu t7,v0,a2                     #Temporally subtract from destination pos the number of units.
      bgez t7,SUS5                      #If its non negative branch and store subtraction.
      or v0,t7,zero                     #If previous branch is false, then next addition will fix the subtraction.
SUS4: addu v0,v0,a2                     #Add to destination pos the number of units.
SUS5: subu t7,v0,t1                     #Subtract original a2 from destination pos. 
      bgez t7,SULP                      #If its greater than or equal zero it means prohibited pos.
      or t0,v0,zero                     #This will simulate a second press if previous branch is true.
SUNE: beq v0,a3,SUED                    #Normal end.
      lui t7,0x0945
      ori t6,zero,0x0003
      sb t6,0xf0b8(t7)                  #??? for visual effect.
SUED: jr ra                             #End.
      addiu sp,sp,0x0020
$-offset:0896851c
      lui t2,0x093d
      addu a0,s0,zero
      lui a1,0x0003
      lbu a2,0xe2a8(t2)
      lbu a3,0xe1c4(t2)
      addu t0,a3,zero
      jal @online_no_switch_units
      addu t1,a2,zero
      noop*2
$-offset:089662d4
@online_no_switch_units:
ONLP: andi t7,a0,0x2008                 #Check if right or R1 is pressed.
      bne t7,zero,ONS2
      addiu v0,t0,0x0001
      andi t7,a0,0x8004                 #Check if left or L1 is pressed.
      bne t7,zero,ONS2
      addiu v0,t0,0xffff
      addiu t7,a2,0xfffc
      blez t7,ONS1                      #Branch if a2 is less than or equal 4.
      addiu v1,zero,0x0001
      addiu v1,zero,0x0005
      divu a2,v1
      mflo a2
      sll at,a2,0x02
      addu a2,a2,at
      addiu a2,a2,0x0004                #More inst than psx cuz 5 instead of 4.
ONS1: andi t7,a0,0x4000                 #Check if down is pressed
      bne t7,zero,ONS2
      addu v0,t0,v1
      andi t7,a0,0x1000                 #Check if up is pressed.
      beql t7,zero,ONNE                 #End of checking inputs. Abnormal end.
      or v0,a3,zero                     #Dont move the cursor.
      subu v0,t0,v1
ONS2: bltz v0,ONS3                      #Check if destination pos is less than zero.
      subu t7,v0,a2                     #Temporally subtract from destination pos the number of units.
      bgez t7,ONS4                      #If its non negative branch and store subtraction.
      or v0,t7,zero                     #If previous branch is false, then next addition will fix the subtraction.
ONS3: addu v0,v0,a2                     #Add to destination pos the number of units.
ONS4: subu t7,v0,t1                     #Subtract original a2 from destination pos. 
      bgez t7,ONLP                      #If its greater than or equal zero it means prohibited pos.
      or t0,v0,zero                     #This will simulate a second press if previous branch is true.
ONNE: beql v0,a3,ONED                   #Normal end.
      lbu a1,0xe334(t2)
ONED: jr ra                             #End.
      sb a1,0xe334(t2)                  #??? for visual effect.
      noop*73
$-offset:088c20f8
      jal @create_unit_world
$-offset:088c21dc
@logic_max_data:
LMLP: blez a2,LOED
      lbu a3,0x0000(a0)
      lbu v0,0x0000(a1)
      addiu a0,a0,0x0001
      sltu at,v0,a3
      beql at,zero,LMSS
      addu a3,v0,zero
LMSS: sb a3,0x0000(a1)
      addiu a1,a1,0x0001
      beq zero,zero,LMLP
      addiu a2,a2,0xffff
@logic_or_data:
LOLP: blez a2,LOED
      lbu a3,0x0000(a0)
      lbu v0,0x0000(a1)
      addiu a0,a0,0x0001
      or a3,a3,v0
      sb a3,0x0000(a1)
      addiu a1,a1,0x0001
      beq zero,zero,LOLP
      addiu a2,a2,0xffff
LOED: jr ra
@custom_random:
      lui v0,0x097a
      lbu v0,0x7144(v0)
      beq v0,zero,CRS1
      lui a0,0x08a8
      j 0x08a218c0
CRS1: addiu a0,a0,0xb1b4
      j 0x08a21b00
      addiu a1,zero,0x0106
@create_unit_world:
      addiu sp,sp,0xffc8
      sw s2,0x0018(sp)
      addu s2,a0,zero                   #s2 = Party Data Pointer
      sw s5,0x0024(sp)
      addu s5,a1,zero                   #s5 = Unit Type
      sw ra,0x0034(sp)
      sw s7,0x002c(sp)
      sw s6,0x0028(sp)
      sw s4,0x0020(sp)
      sw s3,0x001c(sp)
      sw s1,0x0014(sp)
      sw s0,0x0010(sp)
      sb zero,0x00f1(s2)
      ori s7,zero,0x4100                #Name Flags = 0x4100
      ori s6,zero,0x0100                #Name Modifier = 0x0100
      ori t0,zero,0x004a
      ori v0,zero,0x0080                #Sprite Set = Generic Male (Gender = Male)
      beq s5,zero,CUS1                  #Branch if a male 
      sb v0,0x0000(s2)                  #Store Party Sprite Set
      ori v1,zero,0x0001
      ori s7,zero,0x4200                #Name Flags = 0x4200
      ori s6,zero,0x0200                #Name Modifier = 0x0200
      ori v0,zero,0x0081                #Sprite Set = Generic Female
      sb v0,0x0000(s2)                  #Store Party Sprite Set
      beq s5,v1,CUS1                    #Branch if a female
      ori v0,zero,0x0040                #Gender = Female
      ori v1,zero,0x0003
      ori s7,zero,0x4300                #Name Flags = 0x4300
      ori s6,zero,0x0300                #Name Modifier = 0x0300
      ori t0,zero,0x005e
      ori v0,zero,0x0082                #Sprite Set = Monster
      sb v0,0x0000(s2)                  #Store Party Sprite Set
      beq s5,v1,CUS1                    #Branch if a monster
      ori v0,zero,0x0020                #Gender = Monster
      ori s5,zero,0x0002                #Unit Type = Ramza
      ori s7,zero,0x4000                #Name Flags = 0x4000
      addu s6,zero,zero                 #Name Modifier = 0
      ori t0,zero,0x0001                #Sprite Set/Job ID = Chapter 1 Ramza
      ori v0,zero,0x0080                #Gender = Male
      sb t0,0x0000(s2)                  #Store Party Sprite Set
CUS1: lbu s3,0x0004(s2)                 #Get Gender Byte
      sb v0,0x0004(s2)                  #Store Party Gender Byte
      sb t0,0x0002(s2)
CUL1: jal @custom_random
      ori s0,zero,0x016d
      multu v0,s0
      mflo v0
      bltz v0,CUL1                      #Branch if Random is negative, reroll.
      sra s0,v0,0x0f                    #rand(0..364)
      addiu s0,s0,0x0001                #rand(0..364) + 1 (random birthday)
      addu s1,s0,zero                   #s1 = Birthday
      jal 0x088c7d80                    #Calculate Zodiac Symbol
      andi a0,s1,0xffff                 #a0 = Birthday
      sll v0,v0,0x04                    #Zodiac * 16
      andi s0,s0,0x0100                 #s0 = Birthday High Bit
      srl s0,s0,0x08                    #High Bit over 256
      addu s0,s0,v0                     #Zodiac + High Bit
      sb s1,0x0005(s2)                  #Store Party Birthday
      sb s0,0x0006(s2)                  #Store Party Zodiac
      addiu s0,zero,0x0001
      ori v0,zero,0x0046                #Brave/Faith = 70
      ori v1,zero,0x0002
      beq s5,v1,CUS2                    #Branch if Unit Type is Ramza
      sb v0,0x001e(s2)                  #Store Party Brave
CUL2: jal @custom_random                #Random Number Generator
      sb v0,0x001e(s2)                  #Store Party Brave
      sll v0,v0,0x05                    #Random * 32
      bltz v0,CUL2                      #Branch if Random is negative, reroll.
      sra v0,v0,0x0f                    #rand(0..31)
      addiu v0,v0,0x0027                #Brave = 39 + rand(0..31)
      bne s0,zero,CUL2
      addu s0,zero,zero
CUS2: sb v0,0x001f(s2)                  #Store Party Faith
      addiu a0,s2,0x0007                #a0 = Party Secondary Skillset Pointer
      jal 0x088c7e00                    #Data Nullifying
      ori a1,zero,0x0007                #Limit 7+7
      addiu a0,s2,0x0020                #a0 = Party Data Pointer
      jal 0x088c2780                    #Generate Unit's Base Raw Stats  Prep (Useless Prep)
      addu a1,s5,zero                   #a1 = Unit Type
      or at,zero,s3
      lbu s3,0x0004(s2)                 #Load Party Gender
      sb zero,0x001c(s2)                #Store Experience = 0
      ori v0,zero,0x0001                #Level
      sb v0,0x001d(s2)                  #Store Level
      or at,at,s3
      andi at,at,0x0020                 #Logic and for both genders with monster gender.
      beq at,zero,CUS3
      addiu a0,s2,0x002f                #a0 = Party Unlocked Jobs
      jal 0x088c7e00                    #Data Nullifying
      ori a1,zero,0x00ad                #Limit 2f+ad.
CUS3: andi v0,s3,0x00c0
      beq v0,zero,CUS4                  #Branch if monster
      addu s1,s2,zero                   #s1 = Party Data Pointer
CUL3: jal @custom_random                #Random Number Generator
      ori s3,zero,0x0064
      multu v0,s3
      mflo v0
      bltz v0,CUL3                      #Recast if random is negative.
      sra v0,v0,0x0f                    #rand(0..99)
      addiu v0,v0,0x0064                #JP = 100 + rand(0..99)
      lhu t0,0x00ae(s1)                 #Load Party Total JP
      sh v0,0x0080(s1)                  #Store Party Current JP
      sltu at,v0,t0
      beq at,zero,CUS5                  #Branch if not bigger
      sh v0,0x00ae(s1)                  #Store New Total JP
      sh t0,0x00ae(s1)                  #Store Old Total JP
CUS5: addiu s0,s0,0x0001                #Current Job ++
      slti v0,s0,0x0017
      bne v0,zero,CUL3                  #Branch if Current Job less than 0x17 (there is a 23 job)
      addiu s1,s1,0x0002                #JP Pointer += 2
      addiu a1,s2,0x0074
      jal 0x088c7440                    #Calculate Job levels
      addiu a0,s2,0x00ae
CUS4: lbu at,0x002f(s2)                 #Store Unlocked Jobs
      sll v0,s5,0x01
      ori at,at,0x0080                  #Unlocked Jobs = Base
      sb at,0x002f(s2)                  #Store Unlocked Jobs
      addu v0,v0,s5
      sll v1,v0,0x02
      lui v0,0x08a7
      addiu v0,v0,0x51e1
      addu a0,v0,v1
      lbu v1,0x0000(a0)
      sh v1,0x000e(s2)
      lbu v1,0x0001(a0)
      sh v1,0x0010(s2)
      lbu v1,0x0002(a0)
      sh v1,0x0012(s2)
      lbu v1,0x0003(a0)
      sh v1,0x0014(s2)
      lbu v1,0x0004(a0)
      sh v1,0x0016(s2)
      lbu v1,0x0005(a0)
      sh v1,0x0018(s2)
      lbu v1,0x0006(a0)
      sh v1,0x001a(s2)
      lbu a0,0x0000(s2)                 #Load Party Sprite Set
      ori v0,zero,0x0002
      srl at,a0,0x07                    #Sprite Set over 128
      subu at,zero,at                   #at = -(Sprite Set over 128)
      and s3,a0,at                      #Generic Name ID = Sprite Set AND (0xffff or 0x0000)
      srl v1,s6,0x08                    #v1 = Name Modifier over 256
      beq s5,v0,CUS6                    #Branch if Unit Type Ramza
      ori a1,zero,0x0001                #Chosen Name = 1 (Ramza)
      ori v0,zero,0x00ff                #v0 = FF
      sb v0,0x00ec(s2)                  #Store Unit's Name ID = Default (never used? )
      sb v1,0x00ed(s2)                  #Store Unit's Name ID high bit =  Name Mod / 256
CUL4: jal @custom_random                #Random Number Generator
      ori s4,zero,0x00ff                #s4 = FF
      sll v1,v0,0x08                    #Random * 256
      subu v0,v1,v0                     #Random * 255
      bltz v0,CUL4                      #Branch if Random is negative, reroll
      sra v0,v0,0x0f                    #rand(0..254)
      addu s0,zero,zero                 #Counter = 0
      addu a1,s6,v0                     #Chosen Name ID = Name Modifier +  rand(0..254)
      andi a2,a1,0xffff                 #a2 = Chosen Name ID
      lui a0,0x092f
      ori a0,a0,0xacdc                  #a0 = Party Data Pointer
CUL5: lbu v0,0x0001(a0)                 #Load Party ID
      lbu v1,0x0000(a0)                 #Load Party Sprite Set
      beq v0,s4,CUS7                    #Branch if unit doesn't exist
      srl v0,v1,0x07
      subu v0,zero,v0
      and v1,v1,v0                      #v1 = Generic Name ID
      bne v1,s3,CUS7                    #Branch if Generic Name ID's differ
      lbu v0,0x00ed(a0)                 #Load Party Name ID High Bit
      lbu v1,0x00ec(a0)                 #Load Party Name ID
      sll v0,v0,0x08                    #High Bit * 256
      or v1,v1,v0                       #v1 = Name ID
      beq v1,a2,CUL4                    #Branch if Chosen Name isn't  already used
CUS7: addiu s0,s0,0x0001                #Counter ++
      slti v0,s0,0x0010
      bne v0,zero,CUL5                  #Branch if Counter less than 0x10
      addiu a0,a0,0x0100                #Party Pointer += 0x100
CUS6: srl v0,a1,0x08                    #Chosen Name over 256
      andi a0,a1,0x00ff                 #a0 = Chosen Name
      addu a0,s7,a0                     #a0 = Name Flags + Chosen Name
      sb a1,0x00ec(s2)                  #Store Party Name ID
      jal 0x089cd480                    #Prep for Loading Text (world)
      sb v0,0x00ed(s2)                  #Store Party Name ID High Bit
      addu a0,v0,zero                   #a0 = Chosen Name
      addiu a1,s2,0x00dc                #a1 = Party Name Pointer
      jal 0x088c5dc0                    #Store X into Y (Unit's Name)
      ori a2,zero,0x0010                #Limit = 0x10
      ori v0,zero,0x0002                #v0 = 2
      lbu at,0x0032(s2)
      sb zero,0x00ee(s2)                #Store ? = 0
      bne s5,v0,CUED                    #Branch if Unit Type != Ramza
      sb zero,0x00f0(s2)                #Store ? = 0
      ori v0,at,0x0004                  #Known Abilities = Wish for vanilla is 4.
      sb v0,0x0032(s2)                  #Store Base Known Abilities
CUED: lw ra,0x0034(sp)
      lw s7,0x002c(sp)
      lw s6,0x0028(sp)
      lw s5,0x0024(sp)
      lw s4,0x0020(sp)
      lw s3,0x001c(sp)
      lw s2,0x0018(sp)
      lw s1,0x0014(sp)
      lw s0,0x0010(sp)
      jr ra
      addiu sp,sp,0x0038
      noop*130
$-offset:088c1d80
      addiu a1,s2,0x002f
      jal @logic_or_data
      addiu a2,zero,0x0003
      addiu a0,s3,0x00a3
      addiu a1,s2,0x0032
      jal @logic_or_data
      addiu a2,zero,0x0042
      addiu a0,s3,0x00f2
      addiu a1,s2,0x0080
      jal 0x088c7980
      addiu a2,zero,0x002e
      addiu a0,s3,0x0120
      addiu a1,s2,0x00ae
      jal @logic_max_data
      addiu a2,zero,0x002e
      addiu a1,s2,0x0074
      jal 0x088c7440
      addiu a0,s2,0x00ae
      noop
#-----------------------------------------------------------------------------------
$-name:Monster eggs in last roster slot only
$-uuid:eggs-last-slot-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:p-r-e-001&switch-formation-absorb-001
$-define:
      %last_roster_slot,0x0018
$-file:boot.bin
$-type:ram
$-offset:08991c3c
      jal @place_egg_handler
$-offset:@place_egg_handler
      addiu sp,sp,0xffe0
      sw ra,0x001c(sp)
      sw s3,0x0018(sp)
      sw s2,0x0014(sp)
      sw s1,0x0010(sp)
      sw s0,0x000c(sp)
      andi s1,a0,0x00ff
      andi s2,a1,0xffff
      andi s3,a2,0x00ff
      lui v0,0x092f
      addiu v0,v0,0xacdc
      ori v1,zero,%last_roster_slot
      sll at,v1,0x08
      addu s0,v0,at
      lbu v0,0x0001(s0)
      ori at,zero,0x00ff
      bne v0,at,CEED
      addiu v0,zero,0xffff
      sb v1,0x0001(s0)
      sb zero,0x0003(s0)
      addu a0,s0,zero
      jal @create_unit_world
      addiu a1,zero,0x0003
      lbu v0,0x0004(s0)
      slti v1,s2,0x016e
      ori v0,v0,0x0004
      sb v0,0x0004(s0)
      sb s1,0x0002(s0)
      bne v1,zero,CES1
      sb s3,0x00f0(s0)
      addiu s2,zero,0x0001
CES1: jal 0x088c7d80
      addu a0,s2,zero
      sb s2,0x0005(s0)
      andi v1,s2,0x0100
      andi v0,v0,0xffff
      sra v1,v1,0x08
      sll v0,v0,0x04
      addu v0,v0,v1
      sb v0,0x0006(s0)
      ori v0,zero,%last_roster_slot
CEED: lw ra,0x001c(sp)
      lw s3,0x0018(sp)
      lw s2,0x0014(sp)
      lw s1,0x0010(sp)
      lw s0,0x000c(sp)
      jr ra
      addiu sp,sp,0x0020
      noop*26
#-----------------------------------------------------------------------------------
$-name:Level cap
$-uuid:level-cap-p-001
$-description:
It caps all levels to an specific value, with some sort of progession with the event
progession byte, up to four time windows in the game, after that caps goes to 99.
$-overwrites:none
$-requires:none
$-define:
      %stage1_id,0x000f
$-description:
The first time window from 0x00 (new game) to 0x0f (end of chapter 1)
Higher byte. Maximum level achievable in the first time window (0x0a=10)
Lower byte. Progession byte substract offset in the first time window (0x00)
$-define:
      %stage1_lc,0x0a00
      %stage2_id,0x001f
$-description:
The second time window from first time window to 0x1f (end of chapter 2)
Higher byte. Maximum level achievable in the second time window (0x14=20)
Lower byte. Progession byte substract offset in the second time window (0x05=1_id-1_ic)
$-define:
      %stage2_lc,0x1405
      %stage3_id,0x0029 
$-description:
The third time window from second time window to 0x29 (end of chapter 3)
Higher byte. Maximum level achievable in the third time window (0x23=35)
Lower byte. Progession byte substract offset in the third time window (0x0b=2_id-2_ic)
$-define:
      %stage3_lc,0x230b
      %stage4_id,0x0035
$-description:
The fourth time window from third time window to 0x35 (chapter 4 - before orbonne)
Higher byte. Maximum level achievable in the fourth time window (0x32=50)
Lower byte. Progession byte substract offset in the fourth time window (0x06=3_id-3_ic)
$-define:
      %stage4_lc,0x3206
$-file:boot.bin
$-type:ram
$-offset:088c6bec
@check_level_cap:                       #Check Level Cap, t2= curr lvl, return v0.
      lui t3,0x0945
      lbu t3,0xb50c(t3)                 #t3 = curr stage id.
      ori t5,zero,0x63ff                #99 level cap by default.
CLS1: sltiu v0,t3,%stage4_id
      beq v0,zero,CLS2
      sltiu v0,t3,%stage3_id
      beq v0,zero,CLS2
      ori t5,zero,%stage4_lc
      sltiu v0,t3,%stage2_id
      beq v0,zero,CLS2
      ori t5,zero,%stage3_lc
      sltiu v0,t3,%stage1_id
      beq v0,zero,CLS2
      ori t5,zero,%stage2_lc
      ori t5,zero,%stage1_lc
CLS2: andi t4,t5,0x00ff
      subu t3,t3,t4
      sltu t4,t2,t3
      beq t4,zero,CLED
      addu v1,zero,t3
      srl v1,t5,0x08
CLED: jr ra
      sltu v0,t2,v1
@try_level_up:
      addiu sp,sp,0xfff0
      sw ra,0x000c(sp)
      sw s1,0x0008(sp)
      sw s0,0x0004(sp)
      addu s1,a0,zero
      lbu v0,0x0028(s1)                 #Load Unit's Exp.
      lbu s0,0x0029(s1)                 #Load Unit's Level.
      slti at,v0,0x0064
      bne at,zero,TLED                  #Branch if Exp less than 100.
      addu v0,zero,zero                 #v0 = 0 (no level up).
      jal @check_level_cap              #Check Level Cap.
      addu t2,s0,zero                   #Needed for Check Level cap. Current Level.
      ori v1,zero,0x0063                #v0 = 99.
      sb v1,0x0028(s1)                  #Store Exp = 99.
      beq v0,zero,TLED                  #Branch if hit Level Cap. 
      addu a0,s1,zero                   #a0 = Unit's Data Pointer.
      jal @level_up_down
      addu a1,zero,zero                 #a1 = 0 (Level Down Flag = False).
      addiu v0,s0,0x0001
      sb zero,0x0028(s1)                #Store Exp = 0.
      sb v0,0x0029(s1)                  #Store new Level.
      addiu v0,zero,0x0001
TLED: lw ra,0x000c(sp)
      lw s1,0x0008(sp)
      lw s0,0x0004(sp)
      jr ra
      addiu sp,sp,0x0010
@set_unit_level:
      addiu sp,sp,0xfff8
      sw ra,0x0010(sp)
      lbu v1,0x0002(a0)                 #Load Party Job ID
      addiu v0,zero,0x00a1
      bne v1,v0,SLS1
      addiu a3,a0,0x0020
      lbu v0,0x007e(a0)
      andi v0,v0,0x000f
      slti v0,v0,0x0008
      beql v0,zero,SLS1
      addiu v1,zero,0x00a4
SLS1: sll v0,v1,0x03
      subu v1,v0,v1
      sll v0,v1,0x03
      subu a2,v0,v1
      lui v0,0x08a8
      lw v0,0xb148(v0)
      lbu v1,0x001d(a0)
      addu v0,v0,a2
      addiu a2,v0,0x000e
      addu v0,v1,a1                     #Level = Party Level + Chosen Level
      jal @check_level_cap              #Check Level Cap.
      addiu t2,v0,0xffff                #Needed for Check Level cap. Current Level (Sort of).
      lw ra,0x0010(sp)
      beq v0,zero,SLS2                  #Branch if Level hit cap.
      addu t0,zero,zero
      addu v1,t2,zero                   #Level = Cap.
SLS2: lui v0,0x00ff
      ori t3,v0,0xffff
SLLP: addu t1,zero,zero
      addu a1,a3,zero
      addu v0,a2,zero
SLIL: lbu t5,0x0001(a1)
      lbu t2,0x0002(a1)
      lbu t4,0x0000(a1)
      sll t5,t5,0x08
      sll t2,t2,0x10
      addu t4,t4,t5
      addu t4,t4,t2
      lbu t2,0x0000(v0)
      lbu t6,0x001d(a0)
      beql t2,zero,SLS3
      addiu t2,t6,0x0001
      addu t2,t6,t2
SLS3: divu t4,t2
      lui at,0x0100
      mflo t2
      addu t4,t4,t2
      sltu at,t4,at
      beql at,zero,SLS4
      addu t4,t3,zero
SLS4: andi t2,t4,0xff00
      sb t4,0x0000(a1)
      srl t2,t2,0x08
      sb t2,0x0001(a1)
      srl t2,t4,0x10
      sb t2,0x0002(a1)
      addiu t1,t1,0x0001
      slti t2,t1,0x0005
      addiu a1,a1,0x0003
      bne t2,zero,SLIL
      addiu v0,v0,0x0002
      lbu a1,0x001d(a0)
      addiu t0,t0,0x0001
      slt v0,t0,v1
      addiu a1,a1,0x0001
      bne v0,zero,SLLP
      sb a1,0x001d(a0)
      lbu v0,0x001d(a0)
SLED: jr ra
      addiu sp,sp,0x0008
@level_up_down:
      addiu sp,sp,0xffc8
      sw ra,0x0010(sp)
      sw s3,0x0020(sp)
      sw s2,0x001c(sp)
      sw s1,0x0018(sp)
      sw s0,0x0014(sp)
      addu s0,a0,zero                   #s0 = Unit's Data Pointer
      addu s1,a1,zero                   #s1 = Level Down Flag
      addiu s2,s0,0x007c                #s2 = Unit's Raw Stat Pointer
      addiu s3,s0,0x008b                #s3 = Unit's Raw Growth Pointer
LULP: lui v0,0x097a                     #Random. Main loop.
      lbu v0,0x7144(v0)
      beq v0,zero,LUSS
      lui a0,0x08a8
      jal 0x08a218c0
LUSS: addiu a0,a0,0xb1b4
      jal 0x08a21b00
      addiu a1,zero,0x0106
      lbu t7,0x0029(s0)                 #Load Unit's Level
      lbu t1,0x0000(s3)                 #Load Stat Growth.
      lbu v1,0x0000(s2)                 #Load first byte of Raw Stat
      lbu t3,0x0001(s2)                 #Load second byte of Raw Stat
      lbu v0,0x0002(s2)                 #Load third byte of Raw Stat
      sll t3,t3,0x08                    #Raw Stat 2 * 100h
      addu v1,v1,t3                     #Raw Stat 2 * 100h + Raw Stat 1
      sll v0,v0,0x10                    #Raw Stat 3 * 10000h
      bne t1,zero,LUS1                  #Branch if Stat Growth != 0
      addu t2,v1,v0                     #t2 = Full Raw Stat
      ori t1,zero,0x0001                #v0 = 1 (Min 1 growth)
LUS1: addu t1,t1,t7                     #t1 = Stat Growth + Level
      divu t2,t1
      mflo v0                           #v0 = Raw Stat / (Stat Growth + Level)
      beq s1,zero,LUS2                  #Branch if not Leveling Down
      addu t0,t2,v0                     #Raw Stat += Raw Stat / (Stat Growth + Level)
      subu t0,t2,v0                     #Raw Stat -= Raw Stat / (Stat Growth + Level)
LUS2: lui v1,0x00ff
      ori v0,v1,0xffff                  #v0 = ffffff
      sltu v0,v0,t0
      beq v0,zero,LUS3                  #Branch if ffffff is greater ir equal than Raw Stat
      addiu s3,s3,0x0002                #Unit's Growth Pointer += 2
      ori t0,v1,0xffff                  #Raw Stat = ffffff
LUS3: srl v0,t0,0x08                    #Raw Stat / 100
      sb v0,0x0001(s2)                  #Store Raw Stat 2
      srl v0,t0,0x10                    #Raw Stat / 10000
      sb t0,0x0000(s2)                  #Store Raw Stat 1
      sb v0,0x0002(s2)                  #Store Raw Stat 3
      addiu s2,s2,0x0003                #Unit's Raw Stat Pointer += 3 
      slt v0,s2,s0
      bne v0,zero,LULP                  #Loop.
      addu a0,s0,zero                   #a0 = Unit's Data Pointer
      jal 0x088c68c0                    #Status Setting/Checking Prep (Not Initializing, Statuses set?)
      lhu s1,0x0032(s0)                 #Load Unit's Max HP
      lhu v0,0x0030(s0)                 #Load Unit's HP
      lhu s2,0x0036(s0)                 #Load Unit's Max MP
      lhu v1,0x0034(s0)                 #Load Unit's MP
      sltu v0,s1,v0
      beq v0,zero,LUS4                  #Branch if Max HP greater or equal Current HP
      sltu v1,s2,v1
      sh s1,0x0030(s0)                  #Store Current HP = Max HP
LUS4: beq v1,zero,LUED                  #Branch if Max MP greater or equal Current MP
      lw ra,0x0010(sp)
      sh s2,0x0034(s0)                  #Store Current MP = Max MP
LUED: lw s3,0x0020(sp)
      lw s2,0x001c(sp)
      lw s1,0x0018(sp)
      lw s0,0x0014(sp)
      jr ra
      addiu sp,sp,0x0038
      noop*40
$-offset:08991c80
      jal @set_unit_level
$-offset:08961188
      jal @level_up_down
$-offset:089612d0
      jal @level_up_down
$-offset:088b66a0
      lui v0,0x092e
      lw v0,0x5c48(v0)
      jal @check_level_cap              #Check Level Cap.
      lbu t2,0x0029(v0)                 #Load level, needed for Check Level cap.
      addu a0,t2,v0                     #Lvl = Lvl + 0 or 1.
      lui v0,0x092e
      lw v0,0x5c48(v0)
      beq zero,zero,0x088b66fc
      addiu v1,v0,0x0029
      noop*3
$-offset:088b6714
      jal @level_up_down
$-offset:088d5630
      jal @try_level_up
$-offset:088b988c
      jal @try_level_up
#-----------------------------------------------------------------------------------
$-name:Monster do not count as Casualties nor Injured
$-uuid:monster-no-ci-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088bf9a8
     jal @casualties_injured_handler
$-offset:088c7e94
@casualties_injured_handler:
      addiu sp,sp,0xfff0
      sw ra,0x000c(sp)
      sw s2,0x0008(sp)
      sw s1,0x0004(sp)
      sw s0,0x0000(sp)
      addu s2,a0,zero
      lbu v1,0x0006(s2)                 #Load Unit's Modified ENTD Flags
      lbu v0,0x01e0(s2)
      andi v1,v1,0x0020
      bne v1,zero,CISH
      andi v0,v0,0x0030
      sltiu at,v0,0x0001
      addiu s0,at,0x0061
      jal 0x08922540
      addu a0,s0,zero
      addu s1,v0,zero
      sltiu at,s1,0x270f
      jal 0x08a21a80
      addu s1,s1,at
      bne v0,zero,CISH                  #Online mode?
      addu a0,s0,zero
      jal 0x08922680
      addu a1,s1,zero
CISH: lbu a0,0x01e7(s2)                 #For killer unit death counter.
      addiu v1,zero,0x00ff
      beq a0,v1,CIED
      sll v1,a0,0x04
      subu v1,v1,a0
      sll v1,v1,0x02
      addu v1,v1,a0
      sll a0,v1,0x03
      lui v1,0x092e
      addiu v1,v1,0x5e9a
      addu a0,v1,a0
      lbu v1,0x0000(a0)
      slti at,v1,0x00ff
      beq at,zero,CIED
      addiu v1,v1,0x0001
      sb v1,0x0000(a0)
CIED: lw ra,0x000c(sp)
      lw s2,0x0008(sp)
      lw s1,0x0004(sp)
      lw s0,0x0000(sp)
      jr ra
      addiu sp,sp,0x0010
      noop*29
#-----------------------------------------------------------------------------------