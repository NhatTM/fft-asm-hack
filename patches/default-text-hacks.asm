#-----------------------------------------------------------------------------------
$-name:Remove dupe font data
$-uuid:clean-space-bootbin-001
$-description:
Remove dupe font data, since it is not needed (psp has more ram).
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:089d8d10
      lui a0,0x08a8
      addiu a0,a0,0xf7b8
$-offset:089c99dc
      lui v1,0x08a9
      addiu v1,v1,0x7eec
$-offset:089cac08
      lui v0,0x08a9
      addiu v0,v0,0x7eec
$-offset:089cd084
      lui v0,0x08a9
$-offset:089cd094
      addiu v0,v0,0x7eec
$-offset:089cd230
      lui v0,0x08a9
$-offset:089cd240
      addiu v0,v0,0x7eec
$-offset:089dd098
      lui v1,0x08a9
      addiu v1,v1,0x7eec
$-offset:089dd140
      lui a0,0x08a9
      addiu a0,a0,0x7eec
$-offset:089e3a1c
      lui v0,0x08a9
      addiu v0,v0,0x7eec
$-offset:089e5a50
      lui v0,0x08a9
$-offset:089e5a60
      addiu v0,v0,0x7eec
$-offset:089e5bb4
      lui v0,0x08a9
$-offset:089e5bc4
      addiu v0,v0,0x7eec
#-----------------------------------------------------------------------------------
$-name:Replace font file ENG version
$-uuid:replace-font-eng-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:clean-space-bootbin-001
$-file:boot.bin
$-type:files/psp-font-eng.bin
$-offset:0027b80c
#-----------------------------------------------------------------------------------
$-name:Replace font width file ENG version
$-uuid:replace-fontw-eng-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:clean-space-bootbin-001
$-file:boot.bin
$-type:files/psp-fontw-eng.bin
$-offset:00293f40
#-----------------------------------------------------------------------------------
$-name:Replace spell.mes file
$-uuid:replace-spellmes-file-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:replace-font-eng-001&replace-fontw-eng-001
$-file:fftpack.bin
$-type:files/spell-mes/spell-mes-0.bin
$-offset:00ac&INDEXED
#-----------------------------------------------------------------------------------
$-name:Replace snplmes.bin file
$-uuid:replace-snplmes-file-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:replace-font-eng-001&replace-fontw-eng-001
$-file:fftpack.bin
$-type:files/snpl-mes/snpl-mes-0.bin
$-offset:0c1c&INDEXED
#-----------------------------------------------------------------------------------
$-name:Replace wldmes.bin file
$-uuid:replace-wldmes-file-001
$-description:Self-explanatory.
$-overwrites:none
$-requires:replace-font-eng-001&replace-fontw-eng-001
$-file:fftpack.bin
$-type:files/wld-mes/wld-mes-0.bin
$-offset:0c14&INDEXED
#-----------------------------------------------------------------------------------
$-name:Replace all tutoX.mes files
$-uuid:replace-tutomes-file-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:replace-font-eng-001&replace-fontw-eng-001
$-file:fftpack.bin
$-type:files/tuto-mes/tuto-mes-1.bin
$-offset:0bd4&INDEXED
$-type:files/tuto-mes/tuto-mes-2.bin
$-offset:0bdc&INDEXED
$-type:files/tuto-mes/tuto-mes-3.bin
$-offset:0be4&INDEXED
$-type:files/tuto-mes/tuto-mes-4.bin
$-offset:0bec&INDEXED
$-type:files/tuto-mes/tuto-mes-5.bin
$-offset:0bf4&INDEXED
$-type:files/tuto-mes/tuto-mes-6.bin
$-offset:0bfc&INDEXED
$-type:files/tuto-mes/tuto-mes-7.bin
$-offset:0c04&INDEXED
#-----------------------------------------------------------------------------------
$-name:Rewrite all quick access text
$-uuid:replace-quick-text-001
$-description:
Rearrange all text pointers in the game, avoid messing around.
$-overwrites:none
$-requires:replace-font-eng-001&replace-fontw-eng-001
$-define:
      %file01h_h,0x08b2
      %file02h_h,0x08b2
      %file03h_h,0x08b2
      %file04h_h,0x08b2
      %file05h_h,0x08b2
      %file06h_h,0x08b2
      %file07h_h,0x08b2
      %file08h_h,0x08b2
      %file09h_h,0x08b2
      %file10h_h,0x08b2
      %file11h_h,0x08b2
      %file12h_h,0x08b2
      %file13h_h,0x08b2
      %file14h_h,0x08b2
      %file15h_h,0x08b2
      %file16h_h,0x08b2
      %file17h_h,0x08b2
      %file18h_h,0x08b2
      %file19h_h,0x08b2
      %file20h_h,0x08b2
      %file21h_h,0x08b2
      %file22h_h,0x08b2
      %file23h_h,0x08b2
      %file24h_h,0x08b2
      %file25h_h,0x08b2
      %file01h_l,0x1b2c
      %file02h_l,0x1bac
      %file03h_l,0x1c2c
      %file04h_l,0x1cac
      %file05h_l,0x1d2c
      %file06h_l,0x1dac
      %file07h_l,0x1e2c
      %file08h_l,0x1eac
      %file09h_l,0x1f2c
      %file10h_l,0x1f30
      %file11h_l,0x1f34
      %file12h_l,0x1f38
      %file13h_l,0x1f3c
      %file14h_l,0x1f40
      %file15h_l,0x1f44
      %file16h_l,0x1f48
      %file17h_l,0x1f4c
      %file18h_l,0x1f50
      %file19h_l,0x1f54
      %file20h_l,0x1f58
      %file21h_l,0x1f5c
      %file22h_l,0x1f60
      %file23h_l,0x1f64
      %file24h_l,0x1f68
      %file25h_l,0x1f6c
$-file:boot.bin
$-type:ram
$-offset:08938bbc
@load_fh1_f01:
      lui a0,%file01h_h
      addiu a0,a0,%file01h_l
@load_fh1:
      lui a1,0x0939
FH1L: lw v0,0x0000(a0)
      sw v0,0xabc0(a1)
      addiu a1,a1,0x0004
      andi v0,a1,0x00ff
      slti v0,v0,0x0080
      bne v0,zero,FH1L
      addiu a0,a0,0x0004
      jr ra
@load_fh2:
      lui a1,0x0975
FH2L: lw v1,0x0000(a0)
      sw v1,0xa0c4(a1)
      addiu a1,a1,0x0004
      andi v1,a1,0x00ff
      slti v1,v1,0x0080
      bne v1,zero,FH2L
      addiu a0,a0,0x0004
      jr ra
@load_ph1:
      lw v0,0x0000(a1)
      sw v0,0xabc4(a0)
      lw v0,0x0004(a1)
      sw v0,0xabc8(a0)
      lw v0,0x0008(a1)
      sw v0,0xabcc(a0)
      lw v0,0x000c(a1)
      jr ra
      sw v0,0xabd8(a0)
      noop*4
$-offset:089ced40
      noop*43
$-offset:089db6e8
      noop*54
$-offset:08a1d0d8
      noop*26
$-offset:08918a68
      noop*54
$-offset:089c65f8
      noop*22
$-offset:08956b00
      noop*192
$-offset:08917e4c
      jal @load_fh1_f01
$-offset:089268c0
      jal @load_fh1_f01
$-offset:08929858
      jal @load_fh1_f01
$-offset:0894ae90
      lui a1,%file02h_h
      addiu a1,a1,%file02h_l
      jal @load_ph1
      lui a0,0x0939
      noop*18
$-offset:0894b07c
      lui a1,%file02h_h
      addiu a1,a1,%file02h_l
      jal @load_ph1
      lui a0,0x0939
      jal 0x089bac40
      noop
      noop*17
$-offset:0894d18c
      lui v1,0x08aa
      sw v0,0x0034(sp)
      addiu v1,v1,0x09a8
      lui a0,0x0939
      sw v1,0xabac(a0)
      lui a1,%file02h_h
      jal @load_ph1
      addiu a1,a1,%file02h_l
      jal 0x08951740
      noop
      noop*17
$-offset:08955c40
      lui a1,%file03h_h
      addiu a1,a1,%file03h_l
      lui a0,0x0939
      lw v0,0x0000(a1)
      sw v0,0xabe0(a0)
      lw v0,0x0004(a1)
      sw v0,0xabd8(a0)
      lw v0,0xac18(a0)
      sw v0,0xabc8(a0)
      addiu a0,zero,0x0039
      j 0x08922680
      addu a1,zero,zero
      noop*7
$-offset:088edd0c
      lui a0,%file04h_h
      jal @load_fh2
      addiu a0,a0,%file04h_l
$-offset:088ee0c8
      lui a0,%file04h_h
      jal @load_fh2
      addiu a0,a0,%file04h_l
$-offset:089cb080
      lui a0,%file04h_h
      jal @load_fh2
      addiu a0,a0,%file04h_l
$-offset:089cb0b4
      lui a0,%file04h_h
      jal @load_fh2
      addiu a0,a0,%file04h_l
$-offset:08a2e074
      lui a0,%file04h_h
      jal @load_fh2
      addiu a0,a0,%file04h_l
$-offset:089bee10               #Battle tutorials?
      sw s0,0x0000(sp)
      lui a1,%file03h_h
      addiu a1,a1,%file03h_l
      lui a0,0x0939
      lw v0,0x0000(a1)
      sw v0,0xabe0(a0)
      lw v0,0x0004(a1)
      sw v0,0xabd8(a0)
      lw v0,0xac18(a0)
      sw v0,0xabc8(a0)
      lui s0,0x08af
      lw s1,0xabec(a0)
      addu s2,zero,zero
      lui v0,0x0973
      sw zero,0xb68c(v0)
      addiu s0,s0,0xf448
      noop*8
$-offset:089d88b0
      jal 0x089ce178
      noop
$-offset:089ce178
      addiu sp,sp,0xfff0
      sw ra,0x000c(sp)
      sw s1,0x0008(sp)
      sw s0,0x0004(sp)
      lui a0,%file01h_h
      jal @load_fh2
      addiu a0,a0,%file01h_l
$-offset:0893ffbc
      lui a1,%file05h_h
      addiu a1,a1,%file05h_l
      lui a0,0x0939
      lw v0,0x0004(a1)
      sw v0,0xabc4(a0)
      lw v0,0x0008(a1)
      sw v0,0xabc8(a0)
      lw v0,0x002c(a1)
      sw v0,0xabec(a0)
      lw v0,0x0030(a1)
      sw v0,0xabf0(a0)
      lw v0,0x0034(a1)
      sw v0,0xabf4(a0)
      lw v0,0x003c(a1)
      sw v0,0xabfc(a0)
      lw v0,0x004c(a1)
      sw v0,0xac0c(a0)
      lw v0,0x0050(a1)
      sw v0,0xac10(a0)
      lui a3,0x08aa
      addiu a0,a3,0xbc58
      addiu a1,a3,0xbc7c
      addiu a2,a3,0xbc8c
      jal 0x08918940
      addiu a3,a3,0xbc4c
      noop*26
$-offset:08941024
      addu s5,v0,v1
      lui a1,%file05h_h
      addiu a1,a1,%file05h_l
      lui a0,0x0939
      lw v0,0x0004(a1)
      sw v0,0xabc4(a0)
      lw v0,0x0008(a1)
      sw v0,0xabc8(a0)
      lw v0,0x002c(a1)
      sw v0,0xabec(a0)
      lw v0,0x0030(a1)
      sw v0,0xabf0(a0)
      lw v0,0x0034(a1)
      sw v0,0xabf4(a0)
      lw v0,0x003c(a1)
      sw v0,0xabfc(a0)
      lw v0,0x004c(a1)
      sw v0,0xac0c(a0)
      lw v0,0x0050(a1)
      sw v0,0xac10(a0)
      lui a3,0x08aa
      addiu a0,a3,0xbc58
      addiu a1,a3,0xbc7c
      addiu a2,a3,0xbc8c
      jal 0x08918940
      addiu a3,a3,0xbc4c
      noop*25
$-offset:08965950
      lui v0,%file05h_h
      addiu v0,v0,%file05h_l
$-offset:08965990
      jal @load_fh1
$-offset:08965c50
      lui v0,%file05h_h
      addiu v0,v0,%file05h_l
$-offset:08965c90
      jal @load_fh1
$-offset:0899d224
      lui v0,%file05h_h
      addiu v0,v0,%file05h_l
$-offset:0899d22c
      jal @load_fh1
$-offset:089a4410
      lui v0,%file05h_h
      addiu v0,v0,%file05h_l
$-offset:089a4434
      jal @load_fh1
$-offset:089ea2f4
      addu s0,v0,v1
      lui a1,%file05h_h
      addiu a1,a1,%file05h_l
      lui a0,0x0975
      lw v0,0x0004(a1)
      sw v0,0xa0c8(a0)
      lw v0,0x0008(a1)
      sw v0,0xa0cc(a0)
      lw v0,0x002c(a1)
      sw v0,0xa0f0(a0)
      lw v0,0x0030(a1)
      sw v0,0xa0f4(a0)
      lw v0,0x0034(a1)
      sw v0,0xa0f8(a0)
      lw v0,0x003c(a1)
      sw v0,0xa100(a0)
      lw v0,0x004c(a1)
      sw v0,0xa110(a0)
      lw v0,0x0050(a1)
      sw v0,0xa114(a0)
      lui a3,0x08b1
      addiu a0,a3,0x7998
      addiu a1,a3,0x79bc
      addiu a2,a3,0x79cc
      jal 0x089cec00
      addiu a3,a3,0x798c
      noop*25
$-offset:08958d40
      lui v0,%file06h_h
      addiu v0,v0,%file06h_l
      lui at,%file25h_h
      sw v0,%file25h_l(at)
      noop
      lui a0,%file06h_h
      jal @load_fh2
      addiu a0,a0,%file06h_l
$-offset:089569bc
@new_89569c0:
      addiu sp,sp,0xfff0
      sw ra,0x000c(sp)
      jal 0x089d8d00
      noop
      lui v1,0x0888
      addiu v1,v1,0xed00
      lui v0,0x0975
      sw v1,0xa0b8(v0)
      lui v0,%file07h_h
      addiu v0,v0,%file07h_l
      lui at,%file25h_h
      jal 0x089d8dc0
      sw v0,%file25h_l(at)
      addiu a0,zero,0x01fe
      jal 0x089d7700
      addu a1,zero,zero
      lui v1,0x08aa
      addiu v1,v1,0x5164
      lui v0,0x0975
      sw v1,0xa0b0(v0)
      lui a0,%file07h_h
      jal @load_fh2
      addiu a0,a0,%file07h_l
@end_of_8956xxx:
      addiu a0,zero,0x01ff
      jal 0x089d7700
      addu a1,zero,zero
      addiu a0,zero,0x0034
      jal 0x089d7700
      addiu a1,zero,0x0001
      addiu a0,zero,0x0035
      jal 0x089d7700
      addu a1,zero,zero
      addiu a0,zero,0x0036
      jal 0x089d7700
      addiu a1,zero,0x0001
      lw ra,0x000c(sp)
      jr ra
      addiu sp,sp,0x0010
@new_8956b00:
      addiu sp,sp,0xfff0
      sw ra,0x000c(sp)
      jal 0x089d8d00
      noop
      jal 0x08956780
      addiu a0,zero,0x0001
      jal 0x089565c0
      noop
      jal 0x0895a240
      noop
      lui v1,0x0888
@end_8956bxx:
      addiu v1,v1,0xed00
      lui v0,0x0975
      sw v1,0xa0b8(v0)
      lui v0,%file06h_h
      addiu v0,v0,%file06h_l
      lui at,%file25h_h
      jal 0x089d8dc0
      sw v0,%file25h_l(at)
      addiu a0,zero,0x01fe
      jal 0x089d7700
      addu a1,zero,zero
      lui v1,0x08aa
      addiu v1,v1,0x5164
      lui v0,0x0975
      sw v1,0xa0b0(v0)
      lui a0,%file06h_h
      jal @load_fh2
      addiu a0,a0,%file06h_l
      lui v1,%file09h_h
      lw v1,%file09h_l(v1)
      lui v0,0x0975
      beq zero,zero,@end_of_8956xxx
      sw v1,0xa10c(v0)
@new_08956c80:
      addiu sp,sp,0xfff0
      sw ra,0x000c(sp)
      lui v0,0x0975
      jal 0x089d8d00
      sw zero,0xa0c0(v0)
      jal 0x08956780
      addu a0,zero,zero
      beq zero,zero,@end_8956bxx
      lui v1,0x0888
$-offset:088dec78
      jal @new_89569c0
$-offset:08956e38
      jal @new_8956b00
$-offset:088f8a08
      jal @new_8956b00
$-offset:08a49f2c
      jal @new_08956c80
$-offset:0888374c
      jal @new_08956c80
$-offset:089c6650
@new_89c6600:
      addiu sp,sp,0xffe0
      sw ra,0x001c(sp)
      sw s6,0x0018(sp)
      sw s5,0x0014(sp)
      sw s4,0x0010(sp)
      sw s3,0x000c(sp)
      sw s2,0x0008(sp)
      sw s1,0x0004(sp)
      lui s1,0x0973
      sw s0,0x0000(sp)
      addiu s1,s1,0xdcc0
      lui s6,%file08h_h
      addiu s6,s6,%file08h_l
      lui v1,0x0888
      addiu v1,v1,0xee00
      lui v0,0x0939
      jal 0x08918b40
      sw v1,0xabb4(v0)
      lui a0,%file08h_h
      jal @load_fh1
      addiu a0,a0,%file08h_l
$-offset:08924c80
      jal @new_89c6600
$-offset:0895714c
      lui a0,%file09h_h
      lw a0,%file09h_l(a0)
$-offset:08957a4c
      lui s0,%file09h_h
      lw s0,%file09h_l(s0)
$-offset:08957d0c
      addiu v1,v1,0x5164
      lui v0,0x0975
      sw v1,0xa0b0(v0)
      lui s0,%file09h_h
      lw s0,%file09h_l(s0)
$-offset:08957e80
      lui a0,%file09h_h
      lw a0,%file09h_l(a0)
$-offset:08957fd0
      lui s1,%file09h_h
      lw s1,%file09h_l(s1)
$-offset:08958348
      lui a0,%file09h_h
      lw a0,%file09h_l(a0)
$-offset:08958c58
      lui v1,%file09h_h
      lw v1,%file09h_l(v1)
$-offset:08958d14
      lui v1,%file09h_h
      lw v1,%file09h_l(v1)
$-offset:089667f4
      lui v1,%file10h_h
      lw v1,%file10h_l(v1)
$-offset:0896a044
      sh v0,0x003a(sp)
      lui a0,%file10h_h
      lw a0,%file10h_l(a0)
$-offset:0896a1a8
      sh v0,0x003a(sp)
      lui a0,%file10h_h
      lw a0,%file10h_l(a0)
$-offset:08971fd0
      lui a1,0x089e
      lui v1,%file11h_h
      lw v1,%file11h_l(v1)
$-offset:08972ce0
      lui v1,%file12h_h
      lw v1,%file12h_l(v1)
$-offset:089740f4
      lui v1,%file12h_h
      lw v1,%file12h_l(v1)
$-offset:08975f68
      lui v1,%file13h_h
      lw v1,%file13h_l(v1)
$-offset:0899bd4c
      lui a1,0x093d
      lui a0,%file13h_h
      lw a0,%file13h_l(a0)
$-offset:0899bfa4
      lui a1,0x093d
      lui a0,%file13h_h
      lw a0,%file13h_l(a0)
$-offset:0897f404
      lui a0,%file14h_h
      lw a0,%file14h_l(a0)
$-offset:08985570
      lui a1,0x0945
      lui v0,0x0945
      lh v0,0xf412(v0)
      addiu v1,v1,0x000e
      sh v1,0x001c(sp)
      addiu v0,v0,0x000e
      sh v0,0x001e(sp)
      lui v0,0x0945
      lh v1,0xf414(v0)
      lui a0,%file14h_h
      lw a0,%file14h_l(a0)
$-offset:089856f8
      lui a1,0x0945
      lui v0,0x0945
      lh v0,0xf412(v0)
      addiu v1,v1,0x000e
      sh v1,0x001c(sp)
      addiu v0,v0,0x000e
      sh v0,0x001e(sp)
      lui v0,0x0945
      lh v1,0xf414(v0)
      lui a0,%file14h_h
      lw a0,%file14h_l(a0)
$-offset:08995a04
      sw zero,0xfa24(v0)
      lui a0,%file14h_h
      lw a0,%file14h_l(a0)
$-offset:08996200
      lui a1,0x0945
      lui a0,%file14h_h
      lw a0,%file14h_l(a0)
$-offset:08996450
      lui a1,0x0945
      lui a0,%file14h_h
      lw a0,%file14h_l(a0)
$-offset:08a1d068
      lui v0,%file15h_h
      jr ra
      lw v0,%file15h_l(v0)
      lui v0,%file16h_h
      jr ra
      lw v0,%file16h_l(v0)
      lui v0,%file17h_h
      jr ra
      lw v0,%file17h_l(v0)
      lui v0,%file18h_h
      jr ra
      lw v0,%file18h_l(v0)
      lui v0,%file19h_h
      jr ra
      lw v0,%file19h_l(v0)
      lui v0,%file20h_h
      jr ra
      lw v0,%file20h_l(v0)
      lui v0,%file21h_h
      jr ra
      lw v0,%file21h_l(v0)
      lui v0,%file22h_h
      jr ra
      lw v0,%file22h_l(v0)
      lui v0,%file23h_h
      jr ra
      lw v0,%file23h_l(v0)
$-offset:089aa144
      sw ra,0x000c(sp)
      lui v1,%file24h_h
      lw v1,%file24h_l(v1)
      lui v0,0x0939
      sw v1,0xac2c(v0)
      lui v1,%file18h_h
      lw v1,%file18h_l(v1)
      lui v0,0x0939
      sw v1,0xac20(v0)
      lui v1,%file21h_h
      lw v1,%file21h_l(v1)
      lui v0,0x0939
      sw v1,0xac30(v0)
      lui v1,%file16h_h
      lw v1,%file16h_l(v1)
      lui v0,0x0939
      sw v1,0xabd8(v0)
$-offset:089abd78
      lui a0,%file16h_h
      lw a0,%file16h_l(a0)
$-offset:089abcd8
      lui a0,%file24h_h
      lw a0,%file24h_l(a0)
$-offset:089abdc0
      sb v0,0x0001(s0)
      lui a0,%file24h_h
      lw a0,%file24h_l(a0)
$-offset:089abe58
      lui a0,%file24h_h
      lw a0,%file24h_l(a0)
$-offset:08a0add8
      lui v1,%file24h_h
      lw v1,%file24h_l(v1)
$-offset:08a0cb58
      lui a0,%file24h_h
      lw a0,%file24h_l(a0)
$-offset:08a0cc48
      sb v0,0x0001(s0)
      lui a0,%file24h_h
      lw a0,%file24h_l(a0)
$-offset:08a0cce0
      lui a0,%file24h_h
      lw a0,%file24h_l(a0)
$-offset:08a4a000
      lui v1,%file24h_h
      lw v1,%file24h_l(v1)
$-offset:08958ce8
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:08958c2c
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:0895831c
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:08958028
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:08957fa4
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:08957e54
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:08957d50
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:08957ce8
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:08957aa4
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:08957a20
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-offset:08957120
      lui a0,%file25h_h
      jal @load_fh2
      lw a0,%file25h_l(a0)
$-type:NULL_FILE
$-offset:0028e5ec&22540
$-offset:00299024&14512
$-offset:0029e334&10932
$-offset:002d951c&100
$-offset:002da1d8&220
$-offset:002da4a4&140
$-offset:002da9c0&176
$-offset:002db614&540
$-offset:002eb4c0&10352
$-offset:002f73b8&99820
$-offset:0030fac0&2224
$-offset:0031db80&1428
$-offset:002a1630&220264
$-offset:00326f24&209824
$-type:files/rest-mes/rest-mes-0.bin
$-offset:0031db80
$-type:files/rest-mes/rest-mes-1.bin
$-offset:002a1630
$-type:files/rest-mes/rest-mes-2.bin
$-offset:00326f24
$-file:fftpack.bin
$-type:NULL_FILE
$-offset:00a8&INDEXED
$-offset:00b8&INDEXED
$-offset:00b4&INDEXED
#-----------------------------------------------------------------------------------
$-name:Change tutorial soldier names
$-uuid:change-tuto-snames-001
$-description:
Self-explanatory.
$-overwrites:none
$-requires:none
$-file:fftpack.bin
$-type:relative
$-offset:0c08&INDEXED&0542
      encodeText;Blaine{pad(254,16)}
$-offset:0c08&INDEXED&0622
      encodeText;Rand{pad(254,16)}
$-offset:0c08&INDEXED&0702
      encodeText;Tzepish{pad(254,16)}
$-offset:0c08&INDEXED&07e2
      encodeText;Xifanie{pad(254,16)}
$-offset:0c08&INDEXED&08c2
      encodeText;Glain{pad(254,16)}
$-offset:0c08&INDEXED&09a2
      encodeText;Archaemic{pad(254,16)}
$-offset:0c08&INDEXED&0a82
      encodeText;Talcall{pad(254,16)}
$-offset:0c08&INDEXED&0b62
      encodeText;Gizmo{pad(254,16)}
#-----------------------------------------------------------------------------------
