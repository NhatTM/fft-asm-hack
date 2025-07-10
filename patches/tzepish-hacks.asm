#-----------------------------------------------------------------------------------
$-name:Zodiac Compatibility Rewrite
$-uuid:zodiac-rewrite-secondadvent-tzepish
$-description:
* Zodiac Compatibility Rewrite by SecondAdvent, ported to PSP by Tzepish and modified to add the reversal accessory.
* The thresholds below are in fractions of 100, so 100% = 100 = 0x64. So figure out the percentage you want, then convert to hex.
* For example, if you want Best compatibility to deal 150% damage (as in vanilla), 150 = 0x96.
$-overwrites:none
$-requires:none
$-define:
    #%best,0x96                #Vanilla: 150%
    #%good,0x7D                #Vanilla: 125%
    #%bad,0x4B                 #Vanilla:  75%
    #%worst,0x32               #Vanilla:  50%
     %best,0x82                #New: 130%
     %good,0x73                #New: 115%
     %bad,0x55                 #New:  85%
     %worst,0x46               #New:  70%
     %accessoryid,0x13b        #New: Item ID for the Zodiac Glove (reversal accessory)
$-file:boot.bin
$-type:ram
$-offset:088a4300                       #Zodiac Calculation for XA
            lui a3,0x092e
            lw v0,0x5c44(a3)                #Load Attacker Data Pointer
            lw v1,0x5c48(a3)                #Load Target Data Pointer
            lhu t0,0x001e(v0)               #Load Attacker Accessory ID
            lhu t2,0x001e(v1)               #Load Target Accessory ID (Note: t1 is not safe to use!)
            ori at,zero,0x000c              #at = 0c (Serpentarius)
            lbu a1,0x0009(v0)               #Load Attacker Zodiac
            srl a1,a1,0x04                  #a1 = Attacker Zodiac
            lbu a0,0x0009(v1)               #Load Target Zodiac
            beq a1,at,DONE                  #Branch if Attacker is Serpentarius
            srl a0,a0,0x04                  #a0 = Target Zodiac
            beq a0,at,DONE                  #Branch if Target is Serpentarius
            sltu a2,a0,a1
            ori t9,zero,0x0064              #t9 = 64h (100%)
            ori t8,zero,%accessoryid        #t8 = Accessory ID (for Reversal)
            bne zero,a2,LOAD_XA             #Branch if Target Zodiac < Attacker Zodiac
            subu at,a1,a0                   #at = AZ - TZ ^
            subu at,a0,a1                   #at = TZ - AZ
LOAD_XA:    lh a1,0x5c5c(a3)                #Load XA
            lui a2,0x08a7
            addiu a2,a2,0x4ff8              #Zodiac Compatibility Pointer Address
            addu a2,a2,at                   #Add offset to Compatibility Pointer
            lbu a2,0x0000(a2)               #Load Compatibility Modifier
            ori at,zero,0x0003              #at = 3 (Opposing)
            lbu v0,0x0006(v0)               #Load Attacker Gender byte
            lbu v1,0x0006(v1)               #Load Target Gender byte
            bne a2,at,CHECK_GOOD            #Branch to CHECK_GOOD if Compatibility Mod is not Opposing
            or a0,v1,v0
            andi a0,a0,0x0020
            bne a0,zero,SET_BAD             #Branch to SET_BAD if either is a Monster
            andi v0,v0,0x00c0               #v0 = Attacker Gender
            andi v1,v1,0x00c0               #v1 = Target Gender
            bne v1,v0,SET_BEST              #Branch to SET_BEST if Genders are Different
            noop
            j SET_WORST                     #Jump to SET_WORST
CHECK_GOOD: ori v0,zero,0x0002              #v0 = 2 (Good)
            beq v0,a2,SET_GOOD              #Branch to SET_GOOD if they have Good compat
            noop
CHECK_BAD:  ori v1,zero,0x0001              #v1 = 1 (Bad)
            bne v1,a2,DONE                  #Branch to DONE if they have Neutral compat
            noop
SET_BAD:    beql t0,t8,DO_BONUS             #Branch to beneficial mod if Attacker has Reversal Accessory (likely)
            ori at,zero,%good               #at = good modifier ^
            j DO_MALUS                      #Else Jump to harmful mod
            ori at,zero,%bad                #at = bad modifier ^
SET_GOOD:   beql t2,t8,DO_MALUS             #Branch to harmful mod if Target has Reversal Accessory (likely)
            ori at,zero,%bad                #at = bad modifier ^
            j DO_BONUS                      #Else Jump to beneficial mod
            ori at,zero,%good               #at = good modifier ^
SET_WORST:  beql t2,t8,DO_BONUS             #Branch to beneficial mod if Target has Reversal Accessory (likely)
            ori at,zero,%best               #at = best modifier ^
            j DO_MALUS                      #Else Jump to beneficial mod
            ori at,zero,%worst              #at = worst modifier ^
SET_BEST:   beql t0,t8,DO_MALUS             #Branch to harmful mod if Attacker has Reversal Accessory (likely)
            ori at,zero,%worst              #at = worst modifier ^
            ori at,zero,%best               #Else at = best modifier
DO_BONUS:   multu at,a1
            mflo a1                         #a1 = XA * (Chosen modifier)
            j DIVIDE
            addiu a1,a1,0x0063              #Round up for BONUS
DO_MALUS:   multu at,a1
            mflo a1                         #a1 = XA * (Chosen modifier)
DIVIDE:     divu a1,t9
            mflo a1                         #a1 = XA * (Chosen modifier)/100
            bgtz a1,STORE_XA                #Branch to STORE_XA if XA is positive
            noop
            ori a1,zero,0x0001              #Else, XA = 1
STORE_XA:   sh a1,0x5c5c(a3)                #Store XA
DONE:       jr ra
            noop
            noop*74                         #Free space (088a4418 - 088a453c)
#-----------------------------------------------------------------------------------
$-name:Equip X abilities allow for more equipment types + gender equality
$-uuid:equipx-rewrite-tzepish
$-description:
* Rewrites the Equip X code to save space and allow for easier editing of which equipment types are enabled by which Equip X abilities.
* Also allows for assigning equipment based on secondary slot and character ID.
* Removes "Women Only" equipment (instead, enables the Tynar Rouge for Agrias only).
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088c51dc
          lbu a1,0x0099(a0)          #Load Support Abilities 1 (Equip X)
          lbu t1,0x0052(a0)          #Load Equippable Items 1
          lbu t2,0x0053(a0)          #Load Equippable Items 2
          lbu t3,0x0054(a0)          #Load Equippable Items 3
          lbu t4,0x0055(a0)          #Load Equippable Items 4
          lbu t5,0x0056(a0)          #Load Equippable Items 5
          andi at,a1,0x0080          #Check for Armor Lore
          bne at,zero,ARMOR          #Branch to ARMOR if so
          andi at,a1,0x0040          #Check for Knife Lore
          bne at,zero,KNIFE          #Branch to KNIFE if so
          andi at,a1,0x0020          #Check for Sword Lore
          bne at,zero,SWORD          #Branch to SWORD if so
          andi at,a1,0x0010          #Check for Greatsword Lore
          bne at,zero,GREAT          #Branch to GREAT if so
          andi at,a1,0x0008          #Check for Bow Lore
          bne at,zero,BOW            #Branch to BOW if so
          andi at,a1,0x0004          #Check for Polearm Lore
          bne at,zero,SPEAR          #Branch to SPEAR if so
          andi at,a1,0x0002          #Check for Axe Lore
          bne at,zero,AXE            #Branch to AXE if so
          andi at,a1,0x0001          #Check for Gun Lore
          beq at,zero,SKILLS         #Branch to SKILLS if NOT
          noop
GUN:      j SKILLS                   #Jump to SKILLS check
          ori t2,t2,0x0020           #Enable Guns ^
ARMOR:    ori t3,t3,0x001f           #Enable Shields/Helms/Hats/Armor/HairAdornments
          j SKILLS                   #Jump to SKILLS check
          ori t4,t4,0x00c0           #Enable Clothes/Robes ^
KNIFE:    j SKILLS                   #Jump to SKILLS check
          ori t1,t1,0x0060           #Enable Knives/NinjaBlades ^
SWORD:    j SKILLS                   #Jump to SKILLS check
          ori t1,t1,0x0014           #Enable Swords/Katana ^
GREAT:    ori t1,t1,0x0008           #Enable Knightswords
          j SKILLS                   #Jump to SKILLS check
          ori t5,t5,0x0010           #Enable Fellswords ^
BOW:      j SKILLS                   #Jump to SKILLS check
          ori t2,t2,0x0018           #Enable Bows/Crossbows ^
SPEAR:    ori t2,t2,0x0001           #Enable Polearms
          j SKILLS                   #Jump to SKILLS check
          ori t3,t3,0x0080           #Enable Poles ^
AXE:      ori t1,t1,0x0002           #Enable Axes
          ori t2,t2,0x0040           #Enable Flails
SKILLS:   lbu v1,0x0013(a0)          #Load Secondary Skillset
          addiu at,zero,0x0028       #Check for Holy Sword (Agrias)
          beq at,v1,SWDSKILL         #Branch to SWDSKILL if so
          addiu at,zero,0x0021       #Check for Holy Sword (Guest Agrias)
          beq at,v1,SWDSKILL         #Branch to SWDSKILL if so
          addiu at,zero,0x004A       #Check for Swordplay (Orlandeau)
          beq at,v1,SWDSKILL         #Branch to SWDSKILL if so
          addiu at,zero,0x0043       #Check for Unyielding Blade (Meliadoul)
          beq at,v1,SWDSKILL         #Branch to SWDSKILL if so
          addiu at,zero,0x0045       #Check for Spellblade (Beowulf)
          beq at,v1,SWDSKILL         #Branch to SWDSKILL if so
          addiu at,zero,0x0029       #Check for Limit Break (Cloud)
          beql at,v1,CHARID          #Branch to CHARID if so (likely)
SWDSKILL: ori t1,t1,0x0010           #Enable Swords for Sword-using Skillsets
CHARID:   lbu v1,0x0000(a0)          #Load Character ID
          addiu at,zero,0x001e       #Check for Agrias
          beql at,v1,DONE            #Branch to DONE if so (likely)
AGRIAS:   ori t5,t5,0x0008           #Enable Lip Rouge for Agrias ^
          addiu at,zero,0x0016       #Check for Mustadio
          beq at,v1,MUSTADIO         #Branch to MUSTADIO if so
          addiu at,zero,0x0022       #Check for Guest Mustadio
          beql at,v1,DONE            #Branch to DONE if so (likely)
MUSTADIO: ori t2,t2,0x0020           #Enable Guns for Mustadio ^
DONE:     sb t1,0x0052(a0)           #Store Equippable Items 1
          sb t2,0x0053(a0)           #Store Equippable Items 2
          sb t3,0x0054(a0)           #Store Equippable Items 3
          sb t4,0x0055(a0)           #Store Equippable Items 4
          sb t5,0x0056(a0)           #Store Equippable Items 5
          jr ra                      #Return
          noop*2
$-offset:088c2f04
      #jal 0x088c5200             #Old address
       jal 0x088c51dc             #Redirect to new address
$-offset:088c3184
      #jal 0x088c5200             #Old address
       jal 0x088c51dc             #Redirect to new address
$-offset:088c6a60
      #jal 0x088c5200             #Old address
       jal 0x088c51dc             #Redirect to new address
$-offset:0898a778                   #Update list of ability IDs that force an equip change
      #bnel v0,zero,0x0898a798          #Vanilla: Branch if NOT Support Ability
       bnel v0,zero,0x0898a7c4          #New:     Branch to new location if NOT Support Ability
$-offset:0898a7c4                   #Update list of ability IDs that force an equip change
       addiu v0,zero,0x0028             #v0 = Check for Holy Sword (Agrias)
       beq v1,v0,FORCE                  #If Holy Sword, force equip change
       addiu v0,zero,0x0021             #v0 = Check for Holy Sword (Guest Agrias)
       beq v1,v0,FORCE                  #If Holy Sword, force equip change
       addiu v0,zero,0x004A             #v0 = Check for Swordplay (Orlandeau)
       beq v1,v0,FORCE                  #If Swordplay, force equip change
       addiu v0,zero,0x0029             #v0 = Check for Limit Break (Cloud)
       beq v1,v0,FORCE                  #If Limit Break, force equip change
       addiu v0,zero,0x0043             #v0 = Check for Unyielding Blade (Meliadoul)
       beq v1,v0,FORCE                  #If Unyielding Blade, force equip change
       addiu v0,zero,0x0045             #v0 = Check for Spellblade (Beowulf)
       bnel v1,v0,0x0898a7bc            #If NOT Spellblade, DONT force equip change
       addiu v0,zero,0x0000             #v0 = 0 (dont force equip change) ^
FORCE: j 0x0898a7bc                     #Jump to end
       addiu v0,zero,0x0001             #v0 = 1 (do force equip change) ^
#-----------------------------------------------------------------------------------
$-name:Add a Men Only counterpart item to Minerva Bustier
$-uuid:new-menonly-item-tzepish
$-description:
* Adds support for a Men Only item, similar to the Minerva Bustier.
* Also allows you to change item IDs for the men only or women only item.
* This is for gender-equality in WOTL Tweak. All gender-specific items are gone except these two.
$-overwrites:none
$-requires:none
$-define:
     %item_female,0x012e        #Vanilla is 0x012e (Minerva Bustier)
     %item_male,0x0132          #New (Escort Guard in WOTL Tweak)
$-file:boot.bin
$-type:ram
$-offset:08a18d80               #Rewrite Minerva Bustier checker
       andi v1,a0,0xffff             #v1 = Current item ID
FEM:   addiu v0,zero,%item_female    #v0 = Female item ID
       addiu t9,zero,0x0040          #t9 = Preferred gender (Female)
       beql v1,v0,DONE               #Branch if current item is a match
       addiu v0,zero,0x0001           #v0 = 1 (its a match) ^
MALE:  addiu v0,zero,%item_male      #v0 = Male item ID
       addiu t9,zero,0x0080          #t9 = Preferred gender (Male)
       beql v1,v0,DONE               #Branch if current item is a match
       addiu v0,zero,0x0001           #v0 = 1 (its a match) ^
       addu v0,zero,zero             #v0 = 0 (else, its not a match)
DONE:  jr ra                         #Return
       noop*5
$-offset:0898fd20
     #andi v0,v0,0x0040             #Vanilla: Check for Female
      and v0,v0,t9                  #New:     Check for preferred gender based on item
$-offset:089a23a8
     #andi v0,v0,0x0040             #Vanilla: Check for Female
      and v0,v0,t9                  #New:     Check for preferred gender based on item
#-----------------------------------------------------------------------------------
$-name:Weapon Base Damage Rewrite
$-uuid:weapon-base-rewrite-tzepish
$-description:
* Rewrite of the weapon base damage calculation that allows for easier editing of weapon formulas and weapon type formula assignments.
* WOTLTweak already makes use of this to adjust and reassign several formulas (see the readme).
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a54d4
                 lui v0,0x092e
                 lw v1,0x5c44(v0)               #Load Attacker Data
                 lbu s2,0x003e(v1)              #Load PA -> s2
                 lbu s1,0x003f(v1)              #Load MA -> s1
                 lbu t3,0x0040(v1)              #Load Speed -> t3
                 lbu s0,0x002b(v1)              #Load Brave -> s0
                 lbu t5,0x002d(v1)              #Load Faith -> t5
                 andi t1,s2,0x00ff              #t1 = Power
                 andi t2,s1,0x00ff              #t2 = Magick
                 andi t3,t3,0x00ff              #t3 = Speed
                 andi t4,s0,0x00ff              #t4 = Brave
                 andi t5,t5,0x00ff              #t5 = Faith
                 lbu t0,0x0006(v1)              #t0 = Gender
                 jal 0x08a18600                 #Get Equipment Data Address
                 lhu a0,0x5c66(v0)              #Load used weapon ID ^
                 lbu v1,0x0005(v0)              #Load used weapon type
                 lui v0,0x092e
                 beq v1,zero,FORMULA_UNARMED    #Branch to Unarmed if no weapon
                 ori t9,zero,0x0064             #t9 = 64h (100)
WEAPON_FORMULAS: lbu a0,0x5c91(v0)              #Load WP -> a0
                 sh a0,0x5c5e(v0)               #YA = Weapon Power
                 addiu at,zero,0x0001           #Check weapon type 1 (Knife)
                 beq v1,at,FORMULA_PA_SP        #Branch to Knife Formula
                 addiu at,zero,0x0002           #Check weapon type 2 (Ninja Blade)
                 beq v1,at,FORMULA_PA_SP        #Branch to Ninja Blade Formula
                 addiu at,zero,0x0003           #Check weapon type 3 (Sword)
                 beq v1,at,FORMULA_PA           #Branch to Sword Formula
                 addiu at,zero,0x0004           #Check weapon type 4 (Knight Sword)
                 beq v1,at,FORMULA_PA_BR        #Branch to Knight Sword Formula
                 addiu at,zero,0x0005           #Check weapon type 5 (Katana)
                 beq v1,at,FORMULA_PA_BR        #Branch to Katana Formula
                 addiu at,zero,0x0006           #Check weapon type 6 (Axe)
                 beq v1,at,FORMULA_PA_RA        #Branch to Axe Formula
                 addiu at,zero,0x0007           #Check weapon type 7 (Rod)
                 beq v1,at,FORMULA_MA           #Branch to Rod Formula
                 addiu at,zero,0x0008           #Check weapon type 8 (Staff)
                 beq v1,at,FORMULA_MA           #Branch to Staff Formula
                 addiu at,zero,0x0009           #Check weapon type 9 (Flail)
                 beq v1,at,FORMULA_PA_RA        #Branch to Flail Formula
                 addiu at,zero,0x000a           #Check weapon type a (Gun)
                 beq v1,at,FORMULA_WP           #Branch to Gun Formula
                 addiu at,zero,0x000b           #Check weapon type b (Crossbow)
                 beq v1,at,FORMULA_SP           #Branch to Crossbow Formula
                 addiu at,zero,0x000c           #Check weapon type c (Bow)
                 beq v1,at,FORMULA_PA_SP        #Branch to Bow Formula
                 addiu at,zero,0x000d           #Check weapon type d (Instrument)
                 beq v1,at,FORMULA_PA_MA        #Branch to Instrument Formula
                 addiu at,zero,0x000e           #Check weapon type e (Book)
                 beq v1,at,FORMULA_PA_MA        #Branch to Book Formula
                 addiu at,zero,0x000f           #Check weapon type f (Polearm)
                 beq v1,at,FORMULA_PA           #Branch to Polearm Formula
                 addiu at,zero,0x0010           #Check weapon type 10 (Pole)
                 beq v1,at,FORMULA_PA_MA        #Branch to Pole Formula
                 addiu at,zero,0x0011           #Check weapon type 11 (Bag)
                 beq v1,at,FORMULA_PA_RA        #Branch to Bag Formula
                 addiu at,zero,0x0012           #Check weapon type 12 (Cloth)
                 beq v1,at,FORMULA_PA_MA        #Branch to Cloth Formula
                 addiu at,zero,0x0023           #Check weapon type 23 (Fell Sword)
                 beq v1,at,FORMULA_PA_FA        #Branch to Fell Sword Formula
FORMULA_UNARMED: andi at,t0,0x0020              #Check if Monster
                 bnel at,zero,UNARMED_YA        #Branch if Monster (likely)
                 sh t1,0x5c5c(v0)               #XA = Power if monster ^
                 sh t3,0x5c5c(v0)               #XA = Speed if not monster
                 sltiu at,t4,0x0032             #Check if Brave is less than 50
                 bnel at,zero,UNARMED_YA        #Branch if Brave is less than 50 (likely)
                 ori t4,zero,0x0032             #Use 50 instead of Brave if its less than 50 ^
UNARMED_YA:      mult t1,t4                     
                 mflo a0                        #a0 = PA * Brave
                 divu a0,t9                     
                 mflo a0                        #a0 = PA * Brave / 100
                 bgtz a0,END                    #Branch to end if a0 is greater than zero
                 sh a0,0x5c5e(v0)               #YA = Power * Brave / 100 (if human, min Brave = 50)
                 ori a0,zero,0x0001             #a0 = 1
                 j END                          #Jump to end
                 sh a0,0x5c5e(v0)               #YA = Minimum 1 ^
FORMULA_PA:      j END                          #Jump to end
                 sh t1,0x5c5c(v0)               #XA = Power ^
FORMULA_MA:      j END                          #Jump to end
                 sh t2,0x5c5c(v0)               #XA = Magick ^
FORMULA_SP:      j END                          #Jump to end
                 sh t3,0x5c5c(v0)               #XA = Speed ^
FORMULA_WP:      j END                          #Jump to end
                 sh a0,0x5c5c(v0)               #XA = Weapon Power ^
FORMULA_PA_MA:   j DIVIDE_2                     #Jump to division by 2
                 addu a0,t1,t2                  #a0 = Power + Magick ^
FORMULA_PA_SP:   addu a0,t1,t3                  #a0 = Power + Speed
DIVIDE_2:        addiu a0,a0,0x0001             #Round up
                 srl a0,a0,0x01                 #Divide by two
                 j END                          #Jump to end
                 sh a0,0x5c5c(v0)               #XA = (Power + Magick or Speed)/2 Round up ^
FORMULA_PA_RA:   jal 0x088b9d40                 #RandomResult -> v0
                 noop
                 slti at,v0,0x4000              #at = 1 if we rolled low
                 andi t1,s2,0x00ff              #t1 = Power
                 addu a3,t1,at                  #Round up if we rolled low
                 sra a3,a3,0x01                 #a3 = PA/2
                 mult t1,v0
                 mflo a0                        #a0 = Power * RandomResult
                 bltzl a0,SCALE                 #Branch if Power * RandomResult < 0 (likely)
                 addiu a0,a0,0x7fff              #Make result positive ^
SCALE:           addiu a0,a0,0x4000             #Rounding
                 sra a0,a0,0x0f                 #a0 = Scale down to Random(0->PA)
                 addu a0,a0,a3                  #a0 = Random(0->PA) + PA/2
                 lui v0,0x092e
                 j END                          #Jump to end
                 sh a0,0x5c5c(v0)               #XA = Power * Random(50%->150%) ^
FORMULA_PA_BR:   addiu t4,t4,0x0032             #Use Brave+50 instead of just Brave
                 mult t1,t4
                 j DIVIDE_100                   #Jump to division by 100
                 mflo a0                        #a0 = PA * (Brave + 50) ^
FORMULA_PA_FA:   addiu at,zero,0x0096           #at = 150
                 subu t5,at,t5                  #Use 150-Faith instead of just Faith
                 mult t1,t5
                 mflo a0                        #a0 = PA * (150 - Faith)
DIVIDE_100:      addiu a0,a0,0x0032             #Rounding
                 divu a0,t9
                 mflo a0                        #a0 = PA * Brave or Faith scale determined above
                 sh a0,0x5c5c(v0)               #XA = a0
END:             lw ra,0x000c(sp)               #End XA Calculation
                 lw s2,0x0008(sp)
                 lw s1,0x0004(sp)
                 lw s0,0x0000(sp)
                 jr ra
                 addiu sp,sp,0x0010
                 noop*63                        #Free space (088a56c4 - 088a57bc)
#-----------------------------------------------------------------------------------
$-name:Modify Attack Damage Rewrite
$-uuid:attack-damage-rewrite-tzepish
$-description:
* Rewrite of attack damage modifiers, allowing easy editing of how much various abilities and status will affect attack damage.
* In WOTL Tweak, the damage bonuses from these abilities are reduced, but Equip X abilities now also grant the Attack Up bonus.
* Also adds "Weapon Weakness" system. Floating Eyes are weak to Bows and Treants are weak to Axes.
* Also adds support for Lusos new Hunters Mark ability, which deals extra damage to monsters when using Knives, Spears, or Bows.
* Also adds support for Beowulfs new Censure ability, which deals extra damage to enemies with status effects.
* Also adds support for the Mystics new Combat Casting ability, which reduces damage taken while charging.
* Note: the Monk skills are handled in separate hacks, below.
* Note: this uses the free space created by the Slowdown fix v2 (in default-core-hacks) and Unlocked jobs v2 (in default-cust-hacks).
$-overwrites:graphics-battle-fix-001&global-jobs-req-001
$-define:
    #%atk_doublehand,0xcb      #Vanilla: 200%
    #%atk_dualwield,0x64       #Vanilla: 100%
    #%atk_brawler,0x96         #Vanilla: 150%
    #%atk_attackup,0x85        #Vanilla: 133%
    #%atk_vehemence,0x96       #Vanilla: 150%
    #%atk_berserk,0x96         #Vanilla: 150%
     %atk_doublehand,0xa0      #New:     160%
     %atk_dualwield,0x46       #New:      70%
     %atk_brawler,0x96         #New:     150%
     %atk_attackup,0x78        #New:     120%
     %atk_vehemence,0x96       #New:     150%
     %atk_berserk,0x96         #New:     150%
     %atk_weaponweak,0x96      #New:     150%
     %atk_huntermark,0x8c      #New:     140%
     %atk_censure,0xa0         #New:     160%
    #%tar_defenseup,0x42       #Vanilla:  66%
    #%tar_vehemence,0x94       #Vanilla: 150%
    #%tar_protect,0x42         #Vanilla:  66%
    #%tar_sleep,0x96           #Vanilla: 150%
    #%tar_charging,0x96        #Vanilla: 150%
    #%tar_chickentoad,0x96     #Vanilla: 150%
     %tar_defenseup,0x42       #New:      66%
     %tar_vehemence,0x94       #New:     150%
     %tar_protect,0x42         #New:      66%
     %tar_sleep,0x96           #New:     150%
     %tar_charging,0x96        #New:     150%
     %tar_combatcast,0x32      #New:      50%
     %tar_chickentoad,0x96     #New:     150%
$-file:boot.bin
$-type:ram
$-offset:088a7580                           #Modify Attack Damage
                 lui v0,0x092e
ATTACKER:        lw v1,0x5c44(v0)              #Load Attacker Data
                 lbu a0,0x5c8e(v0)             #Load weapon characteristics
                 ori t1,zero,0x64              #t1 = Damage divisor (100)
ATK_2H:          andi at,a0,0x0001             #Check weapon forced two hands
                 bne at,zero,ATK_ATTACKUP      #Branch way ahead if weapon forces two hands
                 andi at,a0,0x0004             #Check weapon two hands allowed
                 beq at,zero,ATK_DW            #Branch if weapon cannot two hands
                 lbu at,0x5c68(v0)             #Load if both hands are occupied
                 bnel at,zero,WEAPON_MOD       #Branch if both hands ARE otherwise occupied (likely)
                 ori a2,zero,%atk_doublehand   #Doublehand damage ^
ATK_DW:          ori a0,zero,0x00ff            #a0 = FF for comparison
                 lhu at,0x0020(v1)             #Load RH Weapon
                 beq at,a0,ATK_DW_FISTS        #Branch if attacker has no RH Weapon
                 lhu at,0x0024(v1)             #Load LH Weapon
                 bnel at,a0,WEAPON_MOD         #Branch if attacker has two weapons (likely)
                 ori a2,zero,%atk_dualwield    #Dual Wield damage ^
                 j ATK_ATTACKUP                #Jump ahead (attacker has only a RH weapon)
                 noop
ATK_DW_FISTS:    bne at,a0,ATK_ATTACKUP        #Branch if attacker has only a LH Weapon
                 lhu at,0x0022(v1)             #Load RH Shield
                 bne at,a0,ATK_BRAWLER         #Branch if attacker has a RH Shield and no weapons
                 lhu at,0x0026(v1)             #Load LH Shield
                 bne at,a0,ATK_BRAWLER         #Branch if attacker has a LH Shield and no weapons
                 lbu at,0x009b(v1)             #Load Support Abilities 3
                 andi at,at,0x0001             #Dual Wield
                 bnel at,zero,WEAPON_MOD       #Branch if attacker has Dual Wield (likely)
                 ori a2,zero,%atk_dualwield    #Dual Wield damage (attacker is dual wielding fists) ^
                 j ATK_BRAWLER                 #Jump ahead (attacker is attacking with one fist)
                 noop
WEAPON_MOD:      lh a1,0x5c5c(v0)              #Load XA
                 multu a2,a1
                 mflo a1                       #a1 = XA * XXX
                 addiu a1,a1,0x0032            #Rounding
                 divu a1,t1
                 mflo a1                       #a1 = XA * XXX/100
                 sh a1,0x5c5c(v0)              #Store a1 as updated XA
ATK_BRAWLER:     lbu at,0x009b(v1)             #Load Support Abilities 3
                 andi at,at,0x0020             #Brawler
                 beq at,zero,ATK_ATTACKUP      #Branch if attacker does NOT have Brawler
                 lhu at,0x5c66(v0)             #Load used weapon ID
                 bne at,zero,ATK_ATTACKUP      #Branch if a weapon is equipped
                 lh a1,0x5c5c(v0)              #Load XA
                 ori a2,zero,%atk_brawler      #Brawler damage
                 multu a2,a1
                 mflo a1                       #a1 = XA * XXX
                 addiu a1,a1,0x0032            #Rounding
                 divu a1,t1
                 mflo a1                       #a1 = (XA * XXX)/100
                 sh a1,0x5c5c(v0)              #Store a1 as updated XA 
ATK_ATTACKUP:    lbu a2,0x009a(v1)             #Load Support Abilities 2
                 addiu t9,ra,0x0000            #Backup ra
                 jal 0x088c7040                #Jump to new check for Attack Up and Equipment Lore (below)
                 andi a2,a2,0x0010             #a2 = 0 if not Attack Up ^
                 lui v0,0x092e
                 lw v1,0x5c44(v0)              #Load Attacker Data
                 addiu ra,t9,0x0000            #Restore ra
ATK_VEHEMENCE:   lbu at,0x009c(v1)             #Load Support Abilities 4
                 andi at,at,0x0001             #Vehemence
                 beq at,zero,ATK_BERSERK       #Branch if attacker does NOT have Vehemence
                 lh a1,0x5c5c(v0)              #Load XA
                 ori a2,zero,%atk_vehemence    #Vehemence damage
                 multu a2,a1
                 mflo a1                       #a1 = XA * XXX
                 addiu a1,a1,0x0032            #Rounding
                 divu a1,t1
                 mflo a1                       #a1 = (XA * XXX)/100
                 sh a1,0x5c5c(v0)              #Store a1 as updated XA
ATK_BERSERK:     lbu at,0x0064(v1)             #Load Current Status 3
                 andi at,at,0x0008             #Berserk
                 beq at,zero,ATK_TOAD          #Branch if attacker does NOT have Berserk
                 lh a1,0x5c5c(v0)              #Load XA
                 ori a2,zero,%atk_berserk      #Berserk damage
                 multu a2,a1
                 mflo a1                       #a1 = XA * XXX
                 addiu a1,a1,0x0032            #Rounding
                 divu a1,t1
                 mflo a1                       #a1 = (XA * XXX)/100
                 sh a1,0x5c5c(v0)              #Store a1 as updated XA
ATK_TOAD:        lbu at,0x0064(v1)             #Load Current Status 3
                 andi at,at,0x0002             #Toad
                 beq at,zero,TARGET            #Branch if attacker is not a Toad
                 noop
                 ori a1,zero,0x0001            #a1 = 1
                 sh a1,0x5c5c(v0)              #XA = 1 (Toads deal terrible damage)
TARGET:          lw v1,0x5c48(v0)              #Load Target Data
TAR_DEFENSEUP:   lbu at,0x009a(v1)             #Load Support Abilities 2
                 andi at,at,0x0008             #Defense Up
                 beq at,zero,TAR_VEHEMENCE     #Branch if target does NOT have Defense Up
                 lh a1,0x5c5c(v0)              #Load XA
                 ori a2,zero,%tar_defenseup    #Defense Up damage
                 multu a2,a1
                 mflo a1                       #a1 = XA * XXX
                 divu a1,t1
                 mflo a1                       #a1 = (XA * XXX)/100 Round down
                 sh a1,0x5c5c(v0)              #Store a1 as updated XA
TAR_VEHEMENCE:   lbu at,0x009c(v1)             #Load Support Abilities 4
                 andi at,at,0x0001             #Vehemence
                 beq at,zero,TAR_PROTECT       #Branch if target does NOT have Vehemence
                 lh a1,0x5c5c(v0)              #Load XA
                 ori a2,zero,%tar_vehemence    #Vehemence damage
                 multu a2,a1
                 mflo a1                       #a1 = XA * XXX
                 addiu a1,a1,0x0063            #Round up
                 divu a1,t1
                 mflo a1                       #a1 = (XA * XXX)/100 Round up
                 sh a1,0x5c5c(v0)              #Store a1 as updated XA
TAR_PROTECT:     lbu at,0x0065(v1)             #Load Current Status 4
                 andi at,at,0x0020             #Protect
                 beq at,zero,TAR_SLEEP         #Branch if target does NOT have Protect
                 lh a1,0x5c5c(v0)              #Load XA
                 ori a2,zero,%tar_protect      #Protect damage
                 multu a2,a1
                 mflo a1                       #a1 = XA * XXX
                 divu a1,t1
                 mflo a1                       #a1 = (XA * XXX)/100 Round down
                 sh a1,0x5c5c(v0)              #Store a1 as updated XA
TAR_SLEEP:       lbu at,0x0066(v1)             #Load Current Status 5
                 andi at,at,0x0010             #Sleep
                 bnel at,zero,DMG_CHARGING     #Branch if target is asleep
                 ori a2,zero,%tar_sleep        #Sleep damage ^
TAR_CHARGING:    lbu at,0x0062(v1)             #Load Current Status 1
                 andi at,at,0x0008             #Charging
                 beq at,zero,TAR_CHICKENTOAD   #Branch if Target is NOT Charging
TAR_COMBATCAST:  lbu at,0x009a(v1)             #Load Support Abilities 2
                 andi at,at,0x0040             #Combat Casting (was JP Boost)
                 bnel at,zero,DMG_CHARGING     #Branch if target has Combat Casting (likely)
                 ori a2,zero,%tar_combatcast   #If so, Combat Casting damage ^
                 ori a2,zero,%tar_charging     #Else, normal Charging damage
DMG_CHARGING:    lh a1,0x5c5c(v0)              #Load XA
                 multu a2,a1
                 mflo a1                       #a1 = XA * XXX
                 addiu a1,a1,0x0063            #Round up
                 divu a1,t1
                 mflo a1                       #a1 = (XA * XXX)/100 Round up
                 sh a1,0x5c5c(v0)              #Store a1 as updated XA
TAR_CHICKENTOAD: lbu at,0x0064(v1)             #Load Current Status 3
                 andi at,at,0x0006             #Chicken or Toad
                 beq at,zero,MIN_DAMAGE        #Branch if target is NOT a Chicken or a Toad
                 lh a1,0x5c5c(v0)              #Load XA
                 ori a2,zero,%tar_chickentoad  #Chicken or Toad damage
                 multu a2,a1
                 mflo a1                       #a1 = XA * XXX
                 addiu a1,a1,0x0063            #Round up
                 divu a1,t1
                 mflo a1                       #a1 = (XA * XXX)/100 Round up
                 sh a1,0x5c5c(v0)              #Store a1 as updated XA
MIN_DAMAGE:      bgtz a1,DONE                  #Branch if XA is greater than zero
                 ori a1,zero,0x0001            #a1 = 1
                 sh a1,0x5c5c(v0)              #XA = 1 (ensure above zero)
DONE:            j 0x088a4300                  #Do Zodiac Compatibility
                 noop
                 noop*16                       #Free Space (088a77e0 to 088a781c)
$-offset:088c7040                       #New Attack Up / Equip Lore Code (uses free space from Unlocked jobs v2)
             lbu t6,0x0099(v1)                #Load Support Abilities 1
             addiu t8,ra,0x0000               #Backup ra
             jal 0x08a18600                   #Get Equipment Data Address
             lhu a0,0x5c66(v0)                #Load used weapon ID ^
             lbu t7,0x0005(v0)                #t7 = Load used weapon type (get it early to save space later)
             addiu ra,t8,0x0000               #Restore ra
             bne a2,zero,BONUS_DMG            #Branch to BONUS_DMG if Attack Up
             andi at,t6,0x0040                #Check Knife Lore
             bne at,zero,CHECK_KNIFE          #Branch to CHECK_KNIFE if so
             andi at,t6,0x0020                #Check Sword Lore
             bne at,zero,CHECK_SWORD          #Branch to CHECK_SWORD if so
             andi at,t6,0x0010                #Check Greatsword Lore
             bne at,zero,CHECK_GREAT          #Branch to CHECK_GREAT if so
             andi at,t6,0x0008                #Check Bow Lore
             bne at,zero,CHECK_BOW            #Branch to CHECK_BOW if so
             andi at,t6,0x0004                #Check Polearm Lore
             bne at,zero,CHECK_SPEAR          #Branch to CHECK_SPEAR if so
             andi at,t6,0x0002                #Check Axe Lore
             bne at,zero,CHECK_AXE            #Branch to CHECK_AXE if so
             andi at,t6,0x0001                #Check Gun Lore
             beq at,zero,NORMAL_DMG           #Branch to NORMAL_DMG if NOT
CHECK_GUN:   addiu at,zero,0x000a             #Check for Gun
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Gun equipped
             noop
             j NORMAL_DMG                     #Else Jump to NORMAL_DMG
CHECK_KNIFE: addiu at,zero,0x0001             #Check for Knife
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Knife equipped
             addiu at,zero,0x0002             #Check for Ninja Blade
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Ninja Blade equipped
             noop
             j NORMAL_DMG                     #Else Jump to NORMAL_DMG
CHECK_SWORD: addiu at,zero,0x0003             #Check for Sword
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Sword equipped
             addiu at,zero,0x0005             #Check for Katana
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Katana equipped
             noop
             j NORMAL_DMG                     #Else Jump to NORMAL_DMG
CHECK_GREAT: addiu at,zero,0x0004             #Check for Knight Sword
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Knight Sword equipped
             addiu at,zero,0x0023             #Check for Fell Sword
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Fell Sword equipped
             noop
             j NORMAL_DMG                     #Else Jump to NORMAL_DMG
CHECK_BOW:   addiu at,zero,0x000c             #Check for Bow
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Bow equipped
             addiu at,zero,0x000b             #Check for Crossbow
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Crossbow equipped
             noop
             j NORMAL_DMG                     #Else Jump to NORMAL_DMG
CHECK_SPEAR: addiu at,zero,0x000f             #Check for Spear
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Spear equipped
             addiu at,zero,0x0010             #Check for Pole
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Pole equipped
             noop
             j NORMAL_DMG                     #Else Jump to NORMAL_DMG
CHECK_AXE:   addiu at,zero,0x0006             #Check for Axe
             beq t7,at,BONUS_DMG              #Branch to BONUS_DMG if Axe equipped
             addiu at,zero,0x0009             #Check for Flail
             bne t7,at,NORMAL_DMG             #Branch to NORMAL_DMG if Flail NOT equipped
BONUS_DMG:   lui v0,0x092e
             lh a1,0x5c5c(v0)                 #Load XA
             ori a2,zero,%atk_attackup        #Attack Up damage
             multu a2,a1
             mflo a2                          #a2 = XA * XXX
             ori t1,zero,0x64                 #t1 = Damage divisor (100)
             divu a2,t1
             mflo a2                          #a2 = (XA * XXX)/100
             beql a2,a1,STORE_NEWXA           #Did the above result in no increase?
             addiu a2,a1,0x0001               #If so, XA+1 ^
STORE_NEWXA: sh a2,0x5c5c(v0)                 #Store a2 as updated XA
NORMAL_DMG:  j 0x08a0f02c                     #Jump to Weapon Type Weakness / Hunters Mark / Censure checks (below)
             noop*25                          #Free space (088c715c - 088c71bc)
$-offset:08a0f02c                       #New Weapon Type Weakness / Hunters Mark / Censure checks (uses free space from Slowdown fix v2)
                 lui v0,0x092e
                 lw v1,0x5c44(v0)               #Load Attacker Data
                 lw a1,0x5c48(v0)               #Load Target Data
                 lbu at,0x0006(a1)              #Load Target Gender
                 andi at,at,0x0020              #Monster
                 beq at,zero,CHECK_CENSURE      #Skip Weapon Weakness and Hunters Mark checks if target is not a Monster
                 lbu a1,0x0180(a1)              #Load character graphic
                 addiu at,zero,0x0008           #Check Floating Eye
                 beql a1,at,CHECK_WPN_WEAK      #Branch if target is a Floating Eye (likely)
                 addiu a1,zero,0x000c           #Desired Weapon Type = Bow ^
                 addiu at,zero,0x000b           #Check Treant
                 bne a1,at,CHECK_HUNTER         #Branch if target is NOT a Treant
                 addiu a1,zero,0x0006           #Desired Weapon Type = Axe
CHECK_WPN_WEAK:  bne t7,a1,CHECK_HUNTER         #Branch if weapon type is NOT the desired type
YES_WPN_WEAK:    lh a1,0x5c5c(v0)               #Load XA
                 ori a2,zero,%atk_weaponweak    #Weapon Type Weakness Damage
                 multu a2,a1
                 mflo a1                        #a1 = XA * XXX
                 addiu a1,a1,0x0032             #Rounding
                 divu a1,t1                     #Divide by 100
                 mflo a1                        #a1 = (XA * XXX)/100
                 sh a1,0x5c5c(v0)               #Store a1 as updated XA
CHECK_HUNTER:    lw v1,0x5c44(v0)               #Load Attacker Data
                 lbu at,0x009c(v1)              #Load Attacker Support Abilities 4
                 andi at,at,0x0080              #Hunters Mark (was Beastmaster)
                 beq at,zero,CHECK_CENSURE      #Branch if attacker does NOT have Hunters Mark
                 addiu at,zero,0x0001           #Check Weapon Type = Knife
                 beq t7,at,YES_BONUS_DMG        #Branch if weapon type is Knife
                 ori a2,zero,%atk_huntermark    #Hunters Mark damage
                 addiu at,zero,0x0003           #Check Weapon Type = Sword
                 beq t7,at,YES_BONUS_DMG        #Branch if weapon type is Sword
                 addiu at,zero,0x000f           #Check Weapon Type = Spear
                 beq t7,at,YES_BONUS_DMG        #Branch if weapon type is Spear
                 addiu at,zero,0x000b           #Check Weapon Type = Crossbow
                 beq t7,at,YES_BONUS_DMG        #Branch if weapon type is Crossbow
                 addiu at,zero,0x000c           #Check Weapon Type = Bow
                 beq t7,at,YES_BONUS_DMG        #Branch if weapon type is Bow
CHECK_CENSURE:   lbu at,0x009c(v1)              #Load Attacker Support Abilities 4
                 andi at,at,0x0010              #Censure (was unused)
                 beq at,zero,NO_BONUS_DMG       #Branch if attacker does NOT have Censure
                 lw a1,0x5c48(v0)               #Load Target Data
                 lbu at,0x0066(a1)              #Load Target Current Status 5
                 bne at,zero,YES_BONUS_DMG      #Branch if target has any Status 5 effects
                 ori a2,zero,%atk_censure       #Censure damage
                 lbu at,0x0065(a1)              #Load Target Current Status 4
                 bne at,zero,YES_BONUS_DMG      #Branch if target has any Status 4 effects
                 lbu at,0x0064(a1)              #Load Target Current Status 3
                 andi at,at,0x00fe              #Any but Critical
                 lbu t7,0x005a(a1)              #Load Target Innate Status 3
                 andi t7,t7,0x0040              #Float
                 xor at,t7,at                   #Filter out innate Float from Current Status 3
                 bne at,zero,YES_BONUS_DMG      #Branch if target has any Status 3 effects except Critical (ignoring innate Float)
                 lbu at,0x0063(a1)              #Load Target Current Status 2
                 bne at,zero,YES_BONUS_DMG      #Branch if target has any Status 2 effects
                 lbu at,0x0062(a1)              #Load Target Current Status 1
                 lbu t7,0x0058(a1)              #Load Target Innate Status 1
                 xor at,t7,at                   #Get statuses are current but not innate
                 andi at,at,0x0010              #Undead (we want Undead status, but not Undead creatures)
                 beq at,zero,NO_BONUS_DMG       #Branch if target does NOT have Undead (or is an undead creature)
YES_BONUS_DMG:   lh a1,0x5c5c(v0)               #Load XA
                 multu a2,a1
                 mflo a1                        #a1 = XA * XXX
                 addiu a1,a1,0x0032             #Rounding
                 divu a1,t1                     #Divide by 100
                 mflo a1                        #a1 = (XA * XXX)/100
                 sh a1,0x5c5c(v0)               #Store a1 as updated XA
NO_BONUS_DMG:    jr ra                          #Return
                 lh a1,0x5c5c(v0)               #a1 = Load XA (Note: it must end with a1 = XA!) ^
                 noop*3
$-offset:088a92c8               #Replace Attack Up in shared Physical Routine for Hit% abilities
      noop*10                       #Wipe out original calculation
      lui v0,0x092e
      lw v1,0x5c44(v0)              #Load Attacker Data
      lbu a2,0x009a(v1)             #Load Support Abilities 2
      addiu t9,ra,0x0000            #Backup ra (if it exists)
      jal 0x088c7040                #New Attack Up and Equipment Lore code
      andi a2,a2,0x0010             #a2 = 0 if not Attack Up ^
      addiu ra,t9,0x0000            #Restore ra
$-offset:088ae5fc               #Replace Attack Up in Formula 28 (Steal EXP)
      noop*7                        #Wipe out original calculation
      lui v0,0x092e
      lw v1,0x5c44(v0)              #Load Attacker Data
      lbu a2,0x009a(v1)             #Load Support Abilities 2
      addiu t9,ra,0x0000            #Backup ra (if it exists)
      jal 0x088c7040                #New Attack Up and Equipment Lore code
      andi a2,a2,0x0010             #a2 = 0 if not Attack Up ^
      addiu ra,t9,0x0000            #Restore ra
$-offset:088b08fc               #Replace Attack Up in Formula 37 (Rush & Throw Stone)
      noop*7                        #Wipe out original calculation
      lui v0,0x092e
      lw v1,0x5c44(v0)              #Load Attacker Data
      lbu a2,0x009a(v1)             #Load Support Abilities 2
      addiu t9,ra,0x0000            #Backup ra (if it exists)
      jal 0x088c7040                #New Attack Up and Equipment Lore code
      andi a2,a2,0x0010             #a2 = 0 if not Attack Up ^
      addiu ra,t9,0x0000            #Restore ra
$-offset:088a9884               #Add Equipment Lore to Formula 4 (Magic Guns)
      noop*5                        #Wipe out original calculation
      lui v0,0x092e
      lw v1,0x5c44(v0)              #Load Attacker Data
      lbu a2,0x009a(v1)             #Load Support Abilities 2
      addiu t9,ra,0x0000            #Backup ra (if it exists)
      jal 0x088c7040                #New Attack Up and Equipment Lore code
      andi a2,a2,0x0014             #a2 = 0 if not Attack Up or Magic Attack Up ^
      addiu ra,t9,0x0000            #Restore ra
      lui v0,0x092e
      lw a1,0x5c44(v0)              #a1 = Load Attacker Data (for compat with code below this)
      noop
$-offset:088ae7d8                   #Additional checks for Sleep/Charging/Combat Casting (Formula 28 - Steal EXP)
               bnel a0,zero,DMG_CHARGING2    #Branch if Target is asleep (likely)
               ori a1,zero,%tar_sleep        #Sleep damage ^
               lbu at,0x0062(v1)             #Load Current Status 1
               andi at,at,0x0008             #Charging
               beq at,zero,0x088ae818        #Branch if Target is NOT Charging
               lbu at,0x009a(v1)             #Load Support Abilities 2
               andi at,at,0x0040             #Combat Casting (was JP Boost)
               bnel at,zero,DMG_CHARGING2    #Branch if target has Combat Casting (likely)
               ori a1,zero,%tar_combatcast   #If so, Combat Casting damage ^
               ori a1,zero,%tar_charging     #Else, normal Charging damage
DMG_CHARGING2: jal 0x08a21ad0                #Use new helper function (below) to apply damage
               noop*5
$-offset:088b3da8                   #Additional checks for Sleep/Charging/Combat Casting (Formula 63 - Throw)
               bnel a0,zero,DMG_CHARGING3    #Branch if Target is asleep (likely)
               ori a1,zero,%tar_sleep        #Sleep damage ^
               lbu at,0x0062(v1)             #Load Current Status 1
               andi at,at,0x0008             #Charging
               beq at,zero,0x088b3de8        #Branch if Target is NOT Charging
               lbu at,0x009a(v1)             #Load Support Abilities 2
               andi at,at,0x0040             #Combat Casting (was JP Boost)
               bnel at,zero,DMG_CHARGING3    #Branch if target has Combat Casting (likely)
               ori a1,zero,%tar_combatcast   #If so, Combat Casting damage ^
               ori a1,zero,%tar_charging     #Else, normal Charging damage
DMG_CHARGING3: jal 0x08a21ad0                #Use new helper function (below) to apply damage
               noop*5
$-offset:088b4228                   #Additional checks for Sleep/Charging/Combat Casting (Formula 64 - Jump)
               bnel a0,zero,DMG_CHARGING4    #Branch if Target is asleep (likely)
               ori a1,zero,%tar_sleep        #Sleep damage ^
               lbu at,0x0062(v1)             #Load Current Status 1
               andi at,at,0x0008             #Charging
               beq at,zero,0x088b4268        #Branch if Target is NOT Charging
               lbu at,0x009a(v1)             #Load Support Abilities 2
               andi at,at,0x0040             #Combat Casting (was JP Boost)
               bnel at,zero,DMG_CHARGING4    #Branch if target has Combat Casting (likely)
               ori a1,zero,%tar_combatcast   #If so, Combat Casting damage ^
               ori a1,zero,%tar_charging     #Else, normal Charging damage
DMG_CHARGING4: jal 0x08a21ad0                #Use new helper function (below) to apply damage
               noop*5
$-offset:08a21ad0                   #Helper function for handling the Charge/Sleep damage multiplication
             lui a0,0x092e
             lh a2,0x5c5c(a0)                 #a2 = Load XA
             multu a1,a2
             mflo a1                          #a1 = XA * XXX
             ori t1,zero,0x64                 #t1 = Damage divisor (100)
             addiu a1,a1,0x0063               #Round up
             divu a1,t1
             mflo a1                          #a1 = (XA * XXX)/100
             jr ra                            #Return
             sh a1,0x5c5c(a0)                 #Store a1 as updated XA ^
#-----------------------------------------------------------------------------------
$-name:Nerf Arcane Strength
$-uuid:arcane-strength-tzepish
$-description:
* Reduces the damage bonus from Arcane Strength from 33% to 20%.
* This is for consistency with the Attack Boost nerf (above).
* Replaces the code in 16 individual places where its checked!
* Magic Guns are not handled here - they are handled above (WOTL Tweak treats them more like weapons than magic).
$-overwrites:none
$-requires:none
$-define:
    #%atk_arcanestr,0x85            #Vanilla: 133%
     %atk_arcanestr,0x78            #New:     120%
$-file:boot.bin
$-type:ram
$-offset:08a22708                   #Helper function for handling the Arcane Strength damage multiplication
             lui a0,0x092e
             lh a2,0x5c5c(a0)                 #a2 = Load XA
             multu a1,a2
             mflo a1                          #a1 = XA * XXX
             ori t1,zero,0x64                 #t1 = Damage divisor (100)
             divu a1,t1
             mflo a1                          #a1 = (XA * XXX)/100 Round down
             beql a1,a2,DONE                  #Did the above result in no increase?
             addiu a1,a2,0x0001               #If so, XA+1 ^
DONE:        jr ra                            #Return
             sh a1,0x5c5c(a0)                 #Store a1 as updated XA ^
$-offset:088a7de0                   #Update Formula 0b (Helpful Status)
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v0,0x092e
             lw a1,0x5c44(v0)                 #Load Attacker Data (for compat with code below this)
$-offset:088a80bc                   #Update Formula 14 (Golem)
             noop*6                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v0,0x092e
             lw a2,0x5c44(v0)                 #Load Attacker Data (for compat with code below this)
$-offset:088a836c                   #Update Truth/Formula 5E-5F Magical damage
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v0,0x092e
             lw a1,0x5c44(v0)                 #Load Attacker Data (for compat with code below this)
$-offset:088a87fc                   #Update Calculate Magical Hit Rate
             noop*6                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v0,0x092e
             lw a2,0x5c44(v0)                 #Load Attacker Data (for compat with code below this)
$-offset:088a8bf8                   #Update Formula 0a (Inflict Status)
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v1,0x092e
             lw v0,0x5c44(v1)                 #Load Attacker Data (for compat with code below this)
$-offset:088a8ff8                   #Update Unknown formula
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v1,0x092e
             lw v0,0x5c44(v1)                 #Load Attacker Data (for compat with code below this)
$-offset:088aa3a0                   #Update Formula 08 (Attack Magic)
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v1,0x092e
             lw v0,0x5c44(v1)                 #Load Attacker Data (for compat with code below this)
$-offset:088ab038                   #Update Formula 0c (Healing Magic)
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui a0,0x092e
             lw v1,0x5c44(a0)                 #Load Attacker Data (for compat with code below this)
$-offset:088ab640                   #Update Formula 0e (Death)
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui a0,0x092e
             lw v1,0x5c44(a0)                 #Load Attacker Data (for compat with code below this)
$-offset:088ac9d8                   #Update #Formula 1a (Blade of Ruin - Powersap, Magicksap, etc.)
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui a0,0x092e
             lw v1,0x5c44(a0)                 #Load Attacker Data (for compat with code below this)
$-offset:088ad5f8                   #Update Formula 1f (Nether Mantra)
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v1,0x092e
             lw v0,0x5c44(v1)                 #Load Attacker Data (for compat with code below this)
$-offset:088adcd8                   #Update Formula 21 (Iaido - MA*Y MP. Osafune)
             noop*6                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v1,0x092e
             lw a3,0x5c44(v1)                 #Load Attacker Data (for compat with code below this)
$-offset:088b17bc                   #Update Formula 4c (Choco Cure)
             noop*6                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v1,0x092e
             lw a3,0x5c44(v1)                 #Load Attacker Data (for compat with code below this)
$-offset:088b1db8                   #Update Formula 51 (Choco Esuna)
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui a0,0x092e
             lw v1,0x5c44(a0)                 #Load Attacker Data (for compat with code below this)
$-offset:088b253c                   #Update Formula 54 (Heal MP - Magic Spirit)
             noop*6                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui v1,0x092e
             lw a3,0x5c44(v1)                 #Load Attacker Data (for compat with code below this)
$-offset:088b2cb8                   #Update Formula 58 (Marlboro Virus)
             noop*7                           #Wipe out original calculation
             jal 0x08a22708                   #Use new helper function (above) to apply damage
             ori a1,zero,%atk_arcanestr       #Magic Attack Up damage ^
             lui a0,0x092e
             lw v1,0x5c44(a0)                 #Load Attacker Data (for compat with code below this)
#-----------------------------------------------------------------------------------
$-name:Monk Physical Skills use both Power and Speed/2
$-uuid:monk-physical-skills-tzepish
$-description:
* For WOTL Tweak, unarmed attacks use a combination of Speed and Power instead of just Power alone. This updates Monk attack skills to do the same.
* This also handles "Equipment Lore" for these abilities, and the damage nerf to Martial Strength.
* This also buffs the damage formula for Pummel so that it isnt always such a disappointment.
$-overwrites:none
$-requires:attack-damage-rewrite-tzepish
$-file:boot.bin
$-type:ram
$-offset:088af668                   #Formula 31 (Cyclone, Aurablast, Shockwave) - Use Power and Speed/2
        lbu a0,0x003e(a1)                   #a0 = Power
        lbu v1,0x0006(a1)                   #Load Gender
        andi v1,v1,0x0020                   #Check if Monster
        bnel v1,zero,F31_XA                 #Branch if Monster (likely)
        lbu v1,0x003e(a1)                   #v1 = Power if Monster ^
        lbu v1,0x0040(a1)                   #v1 = Speed if not Monster
F31_XA: sh a0,0x5c5c(v0)                    #XA = Power
        lbu v0,0x5c89(v0)                   #Load Y
        addu v0,v1,v0                       #Y + Power (if Monster) or Speed (if not Monster)
$-offset:088af6d8                   #Formula 31 (Cyclone, Aurablast, Shockwave) - New Attack Up
        noop*8                              #Wipe out original calculation
        lui v0,0x092e
        lw v1,0x5c44(v0)                    #Load Attacker Data
        lbu a2,0x009a(v1)                   #Load Support Abilities 2
        addiu t9,ra,0x0000                  #Backup ra (if it exists)
        jal 0x088c7040                      #New Attack Up and Equipment Lore code
        andi a2,a2,0x0010                   #a2 = 0 if not Attack Up ^
        addiu ra,t9,0x0000                  #Restore ra
$-offset:088afcd8                   #Formula 32 (Pummel) - New base formula and Attack Up
         lui v0,0x092e
         lw v1,0x5c44(v0)                   #Load Attacker Data
         lbu a0,0x003e(v1)                  #a0 = Power
         lbu a1,0x0040(v1)                  #a1 = Speed
         lbu at,0x0006(v1)                  #Load Gender
         andi at,at,0x0020                  #Check if Monster
         bnel at,zero,BRAVE                 #Branch if Monster (likely)
         sh a0,0x5c5c(v0)                   #XA = Power if monster ^
         sh a1,0x5c5c(v0)                   #XA = Speed if not monster
BRAVE:   lbu a1,0x002b(v1)                  #a1 = Brave
         sltiu at,a1,0x0032                 #Check if Brave is less than 50
         bnel at,zero,F32_YA                #Branch if Brave is less than 50 (likely)
         ori a1,zero,0x0032                 #Use 50 instead of Brave if its less than 50 ^
F32_YA:  ori at,zero,0x0064                 #Divisor (100)
         mult a0,a1                     
         mflo a2                            #a2 = PA * Brave
         divu a2,at                     
         mflo a2                            #a2 = PA * Brave / 100
         bgtz a2,ATK_UP                     #Branch if a2 is greater than zero
         sh a2,0x5c5e(v0)                   #YA = Power * Brave / 100 (if human, min Brave = 50)
         ori a2,zero,0x0001                 #a2 = 1
         sh a2,0x5c5e(v0)                   #YA = Minimum 1 ^
ATK_UP:  lbu a2,0x009a(v1)                  #Load Support Abilities 2
         addiu t9,ra,0x0000                 #Backup ra (if it exists)
         jal 0x088c7040                     #New Attack Up and Equipment Lore code
         andi a2,a2,0x0010                  #a2 = 0 if not Attack Up ^
         addiu ra,t9,0x0000                 #Restore ra
         noop*2
$-offset:088b0008                   #Formula 32 (Pummel) - New end of formula
         lui v0,0x092e
         lh a0,0x5c5c(v0)                   #Load XA
         lh v1,0x5c5e(v0)                   #Load YA
         lw v0,0x5c10(v0)                   #Load Current Action Data
         mult v1,a0                         #XA*YA
         mflo v1                            #v1 = XA*YA
         jal 0x088b9d40                     #Do RandomResult -> v0
         sh v1,0x0006(v0)                    #Store v1 as HPDamage ^
         slti at,v0,0x4000                  #at = 1 if we rolled low
         lui v1,0x092e
         lw a3,0x5c10(v1)                   #Load Current Action Data
         lh a2,0x0006(a3)                   #Load HPdamage
         mult a2,v0                         #HPDamage * RandomResult
         mflo a0                            #a0 = HPDamage * RandomResult
         bltzl a0,SCALE                     #Branch if less than zero (likely)
         addiu a0,a0,0x7fff                  #Make RandomResult positive ^
SCALE:   addiu a0,a0,0x4000                 #Rounding
         sra a0,a0,0x0f                     #Scale down to Random(0..HPDamage)
         sb a0,0x5c79(v1)                   #Store RandomDamage
         addu a2,a2,at                      #Round up if we rolled low
         sra a2,a2,0x01                     #a2 = Half original HP damage
         addu a1,a2,a0                      #a1 = Random(1..XA*YA)+(XA*YA)/2
         sh a1,0x0006(a3)                   #Store final HP damage
         addiu at,zero,0x0080               #a0 = 80 (Attack Type = HP Damage)
         sb at,0x0027(a3)                   #Store Attack Type = 80 (HP Damage)
         lw ra,0x000c(sp)
         jr ra
         addiu sp,sp,0x0010
         noop*25                            #Free space (from 0x088b0078 to 0x088b00d8)
$-offset:088afcd0                   #Formula 32 (Pummel) - Redirect a branch
        #bnel v0,zero,0x088b00d4            #Vanilla: Branch to OLD end if missed
         bnel v0,zero,0x088b0070            #New:     Branch to NEW end if missed
#-----------------------------------------------------------------------------------
$-name:Monk Magical Skills use the higher of Power or Magick
$-uuid:monk-magical-skills-tzepish
$-description:
* These skills were ambiguous as to whether they worked with Magick or Power. So, why not allow both?
* This also handles "Equipment Lore" for these abilities, and the damage nerf to Martial/Arcane Strength.
$-overwrites:none
$-requires:attack-damage-rewrite-tzepish
$-file:boot.bin
$-type:ram
$-offset:088b0110               #Formula 33 (Purification)
        lbu a1,0x003e(a2)                   #Load Power
        lbu a0,0x003f(a2)                   #Load Magick
        sltu at,a0,a1                       #Set if Magick is lower than Power
        bnel at,zero,F33_X                  #Branch if Magick is lower (likely)
        sh a1,0x5c5c(v0)                    #XA = Power ^
        sh a0,0x5c5c(v0)                    #XA = Magick
F33_X:  lbu a0,0x5c88(v0)                   #Load X
        sh a0,0x5c5e(v0)                    #Store YA = X
        noop*7                              #Wipe out original Attack Up calculation
        lw v1,0x5c44(v0)                    #Load Attacker Data
        lbu a2,0x009a(v1)                   #Load Support Abilities 2
        addiu t9,ra,0x0000                  #Backup ra (if it exists)
        jal 0x088c7040                      #New Attack Up and Equipment Lore code
        andi a2,a2,0x0014                   #a2 = 0 if not Attack Up or Magic Attack Up ^
        addiu ra,t9,0x0000                  #Restore ra
$-offset:088b03d0               #Formula 34 (Chakra)
        lbu a1,0x003e(a2)                   #Load Power
        lbu a0,0x003f(a2)                   #Load Magick
        sltu at,a0,a1                       #Set if Magick is lower than Power
        bnel at,zero,F34_Y                  #Branch if Magick is lower (likely)
        sh a1,0x5c5c(v0)                    #XA = Power ^
        sh a0,0x5c5c(v0)                    #XA = Magick
F34_Y:  lbu a0,0x5c89(v0)                   #Load Y
        sh a0,0x5c5e(v0)                    #Store YA = Y
        noop*7                              #Wipe out original Attack Up calculation
        lw v1,0x5c44(v0)                    #Load Attacker Data
        lbu a2,0x009a(v1)                   #Load Support Abilities 2
        addiu t9,ra,0x0000                  #Backup ra (if it exists)
        jal 0x088c7040                      #New Attack Up and Equipment Lore code
        andi a2,a2,0x0014                   #a2 = 0 if not Attack Up or Magic Attack Up ^
        addiu ra,t9,0x0000                  #Restore ra
$-offset:088b0590               #Formula 35 (Revive)
        lbu a1,0x003e(a2)                   #Load Power
        lbu a0,0x003f(a2)                   #Load Magick
        sltu at,a0,a1                       #Set if Magick is lower than Power
        bnel at,zero,F35_X                  #Branch if Magick is lower (likely)
        sh a1,0x5c5c(v0)                    #XA = Power ^
        sh a0,0x5c5c(v0)                    #XA = Magick
F35_X:  lbu a0,0x5c88(v0)                   #Load X
        sh a0,0x5c5e(v0)                    #Store YA = X
        noop*7                              #Wipe out original calculation
        lw v1,0x5c44(v0)                    #Load Attacker Data
        lbu a2,0x009a(v1)                   #Load Support Abilities 2
        addiu t9,ra,0x0000                  #Backup ra (if it exists)
        jal 0x088c7040                      #New Attack Up and Equipment Lore code
        andi a2,a2,0x0014                   #a2 = 0 if not Attack Up or Magic Attack Up ^
        addiu ra,t9,0x0000                  #Restore ra
$-offset:088b1cd0               #Formula 50 (Doom Fist)
        bne v0,zero,END                     #Branch to end if attack is evaded
        lui v0,0x092e
        lw a2,0x5c44(v0)                    #Load Attacker Data
        lbu a1,0x003e(a2)                   #Load Power
        lbu a0,0x003f(a2)                   #Load Magick
        sltu at,a0,a1                       #Set if Magick is lower than Power
        bnel at,zero,F50_X                  #Branch if Magick is lower (likely)
        sh a1,0x5c5c(v0)                    #XA = Power ^
        sh a0,0x5c5c(v0)                    #XA = Magick
F50_X:  lbu a0,0x5c88(v0)                   #Load X
        jal 0x088a9294                      #Do Physical Routine for Hit% abilities (alternate - below)
        sh a0,0x5c5e(v0)                    #Store YA = X
        bne v0,zero,END                     #Branch to end if attack missed
        noop
        jal 0x088a6c00                      #Formula 38 (apply status to action)
        noop
END:    lw ra,0x000c(sp)
        jr ra
        addiu sp,sp,0x0010
$-offset:088a9294               #Physical Routine for Hit% abilities (new alternate entry)
        addiu sp,sp,0xfff0
        sw ra,0x000c(sp)
        lui v0,0x092e
        lw v1,0x5c44(v0)                    #Load Attacker Data
        lbu a2,0x009a(v1)                   #Load Support Abilities 2
        addiu t9,ra,0x0000                  #Backup ra (if it exists)
        jal 0x088c7040                      #New Attack Up and Equipment Lore code
        andi a2,a2,0x0014                   #a2 = 0 if not Attack Up or Magic Attack Up ^
        addiu ra,t9,0x0000                  #Restore ra
        j 0x088a930c                        #Hard jump back to where we are supposed to be
        noop
#-----------------------------------------------------------------------------------
$-name:Chakra recovers fewer MP
$-uuid:monk-chakra-nerf-tzepish
$-description:
Chakra now uses HP/4 instead of HP/2 for MP Recovery.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088b0550
     #sra v1,a0,0x01                #Vanilla: Divide HP Recovery by two
      sra v1,a0,0x02                #New:     Divide HP Recovery by four
$-offset:088b0558
     #sra v1,v1,0x01                #Vanilla: Divide HP Recovery by two
      sra v1,v1,0x02                #New:     Divide HP Recovery by four
#-----------------------------------------------------------------------------------
$-name:New Magic Guns formula
$-uuid:magic-gun-formula-tzepish
$-description:
* Changes the percent chance for Magic Guns to choose tier1/tier2/tier3 from 60%/30%/10% to 25%/50%/25%.
* Uses scaled weapon attack power based on spell tier chosen instead of using the literal spell power (set as X in spell data).
* Scales 50% to 150% based on Attacker Faith only (instead of 0% to 100% based on both Attacker and Target Faith).
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a64a0
     #slti at,v0,0x000a             #Vanilla: RandomResult < 10 (10% chance) -> Firaga
      slti at,v0,0x0019             #New:     RandomResult < 25 (25% chance) -> Firaga
$-offset:088a64a8
     #slti at,v0,0x0028             #Vanilla: RandomResult < 40 (30% chance) -> Fira
      slti at,v0,0x004b             #New:     RandomResult < 75 (50% chance) -> Fira
$-offset:088a64d0
     #slti at,v0,0x000a             #Vanilla: RandomResult < 10 (10% chance) -> Thundaga
      slti at,v0,0x0019             #New:     RandomResult < 25 (25% chance) -> Thundaga
$-offset:088a64d8
     #slti at,v0,0x0028             #Vanilla: RandomResult < 40 (30% chance) -> Thundara
      slti at,v0,0x004b             #New:     RandomResult < 75 (50% chance) -> Thundara
$-offset:088a64f4
     #slti at,v0,0x000a             #Vanilla: RandomResult < 10 (10% chance) -> Blizzaga
      slti at,v0,0x0019             #New:     RandomResult < 25 (25% chance) -> Blizzaga
$-offset:088a64fc
     #slti at,v0,0x0028             #Vanilla: RandomResult < 40 (30% chance) -> Blizzara
      slti at,v0,0x004b             #New:     RandomResult < 75 (50% chance) -> Blizzara
$-offset:088a981c
     #lbu v1,0x5c89(v0)             #Vanilla: Load Y (chosen spell power)
      lbu v1,0x5c88(v0)             #New:     Load X (chosen spell Magic Gun power) (Set in FFTPatcher spell data)
$-offset:088a9b94
      noop*10                       #Wipe out the Target Faith or Atheist status code
      addiu at,zero,0x0064          #at = 100
      sb at,0x5c60(a0)              #Force Target Faith = 100 for this attack (so it has no effect on the result)
      lbu at,0x5c61(a0)             #Load Attacker Effective Faith
      addiu at,at,0x0032            #Add 50 to it
      sb at,0x5c61(a0)              #Store Attacker Faith + 50 for this attack
#-----------------------------------------------------------------------------------
$-name:More consistent weather effects
$-uuid:weather-rain-snow-tzepish
$-description:
* Ice/Lightning magic will always be enhanced if it is snowing/raining (in vanilla, these effects applied only for *heavy* snow/rain).
* Note the fix for Dorter at the bottom. Instead of defaulting to Rain off and then showing stronger weather later, WOTL Tweak defaults to Rain ON and sets weaker weather at the beginning (in the event script).
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a853c                   #Truth/Formula 5E-5F Magical damage
      addiu v1,v0,0xfffe                #Weather - 2 (Rain+)
      sltiu at,v1,0x0003                #Set if Weather = Rain, Thunderstorm, or Heavy Thunderstorm
      beq at,zero,0x088a85c0            #Branch if not Rain, Thunderstorm, or Heavy Thunderstorm
      noop
$-offset:088a85c0                   #Truth/Formula 5E-5F Magical damage
      addiu v0,v0,0xfffb                #Weather - 5 (Snow+)
      sltiu at,v0,0x0003                #Set if weather = Snow, Snowstorm, or Heavy Snowstorm
      beq at,zero,0x088a860c
      noop
$-offset:088a9a64                   #Formula 04 (Magic Gun)
      addiu v1,v0,0xfffe                #Weather - 2 (Rain+)
      sltiu at,v1,0x0003                #Set if Weather = Rain, Thunderstorm, or Heavy Thunderstorm
      beq at,zero,0x088a9ae8            #Branch if not Rain, Thunderstorm, or Heavy Thunderstorm
      noop
$-offset:088a9ae8                   #Formula 04 (Magic Gun)
      addiu v0,v0,0xfffb                #Weather - 5 (Snow+)
      sltiu at,v0,0x0003                #Set if weather = Snow, Snowstorm, or Heavy Snowstorm
      beq at,zero,0x088a9b34
      noop
$-offset:088aa570                   #Formula 08 (Magic spell damage)
      addiu v1,v0,0xfffe                #Weather - 2 (Rain+)
      sltiu at,v1,0x0003                #Set if Weather = Rain, Thunderstorm, or Heavy Thunderstorm
      beq at,zero,0x088aa5f4            #Branch if not Rain, Thunderstorm, or Heavy Thunderstorm
      noop
$-offset:088aa5f4                   #Formula 08 (Magic spell damage)
      addiu v0,v0,0xfffb                #Weather - 5 (Snow+)
      sltiu at,v0,0x0003                #Set if weather = Snow, Snowstorm, or Heavy Snowstorm
      beq at,zero,0x088aa640
      noop
$-offset:088aaaa8                   #Formula 09 (Gravity / Fractional damage)
      addiu v1,v0,0xfffe                #Weather - 2 (Rain+)
      sltiu at,v1,0x0003                #Set if Weather = Rain, Thunderstorm, or Heavy Thunderstorm
      beq at,zero,0x088aab2c            #Branch if not Rain, Thunderstorm, or Heavy Thunderstorm
      noop
$-offset:088aab2c                   #Formula 09 (Gravity / Fractional damage)
      addiu v0,v0,0xfffb                #Weather - 5 (Snow+)
      sltiu at,v0,0x0003                #Set if weather = Snow, Snowstorm, or Heavy Snowstorm
      beq at,zero,0x088aab78
      noop
$-offset:088ad7c8                   #Formula 1f (Nether Mantra)
      addiu v1,v0,0xfffe                #Weather - 2 (Rain+)
      sltiu at,v1,0x0003                #Set if Weather = Rain, Thunderstorm, or Heavy Thunderstorm
      beq at,zero,0x088ad84c            #Branch if not Rain, Thunderstorm, or Heavy Thunderstorm
      noop
$-offset:088ad84c                   #Formula 1f (Nether Mantra)
      addiu v0,v0,0xfffb                #Weather - 5 (Snow+)
      sltiu at,v0,0x0003                #Set if weather = Snow, Snowstorm, or Heavy Snowstorm
      beq at,zero,0x088ad898
      noop
$-offset:088afa44                   #Formula 31 (Monk Skills - Cyclone, Aurablast, Shockwave) (Some monster attacks)
      addiu v1,v0,0xfffe                #Weather - 2 (Rain+)
      sltiu at,v1,0x0003                #Set if Weather = Rain, Thunderstorm, or Heavy Thunderstorm
      beq at,zero,0x088afac8            #Branch if not Rain, Thunderstorm, or Heavy Thunderstorm
      noop
$-offset:088afac8                   #Formula 31 (Monk Skills - Cyclone, Aurablast, Shockwave) (Some monster attacks)
      addiu v0,v0,0xfffb                #Weather - 5 (Snow+)
      sltiu at,v0,0x0003                #Set if weather = Snow, Snowstorm, or Heavy Snowstorm
      beq at,zero,0x088afb14
      noop
$-offset:088b22a8                   #Formula 53 (Fractional Damage - Tri-Breath)
      addiu v1,v0,0xfffe                #Weather - 2 (Rain+)
      sltiu at,v1,0x0003                #Set if Weather = Rain, Thunderstorm, or Heavy Thunderstorm
      beq at,zero,0x088b232c            #Branch if not Rain, Thunderstorm, or Heavy Thunderstorm
      noop
$-offset:088b232c                   #Formula 53 (Fractional Damage - Tri-Breath)
      addiu v0,v0,0xfffb                #Weather - 5 (Snow+)
      sltiu at,v0,0x0003                #Set if weather = Snow, Snowstorm, or Heavy Snowstorm
      beq at,zero,0x088b2378
      noop
$-offset:08af2460                   #Fix for Dorter Rain strength
     #01200021                          #Vanilla: Weather strength = 1
      02200021                          #New:     Weather strength = 2
#-----------------------------------------------------------------------------------
$-name:Default weapon proc rate is 25% instead of 19%
$-uuid:default-weapon-proc-tzepish
$-description:
* Makes things a bit spicier by having weapons proc their status hits more often.
* You can modify the number below to increase/decrease the default rate, if desired.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a7a54
       #addiu a1,zero,0x0013          #Vanilla: Default proc rate = 19% (0x13)
        addiu a1,zero,0x0019          #New:     Default proc rate = 25% (0x19)
#-----------------------------------------------------------------------------------
$-name:Critical hits always deal 50% bonus damage & Chance increased by status effects & accessory
$-uuid:critical-status-accessory-tzepish
$-description:
* Critical hit rate increased from 4% to 5% by default.
* Critical hits always deal 50% bonus damage instead of randomly 0% to 100%.
* Invisible and Critical (low HP) status on the attacker increase the odds of landing a critical hit.
* If the specified accessory is equipped, quadruple the critical chance.
$-overwrites:none
$-requires:none
$-define:
    #%defaultrate,0x04          #Vanilla Default: 04%
     %defaultrate,0x05          #New Default:     05%
     %enhancedrate,0x19         #Enhanced:        25%
     %critaccessory,0xd8        #Accessory:       Genji Glove
$-file:boot.bin
$-type:ram
$-offset:088a7b38
       lui v0,0x092e
       lw v0,0x5c44(v0)              #Load Attacker Data
       lbu at,0x0064(v0)             #Load Current Status 3
       andi at,at,0x0011             #Invisible or Critical (low HP)
       bnel at,zero,GENJI            #Branch ahead if so (likely)
       addiu a1,zero,%enhancedrate   #a1 = Enhanced Critical hit chance if so ^
       addiu a1,zero,%defaultrate    #Else, a1 = Default Critical hit chance if not
GENJI: lhu v0,0x001e(v0)             #Load Attacker Accessory ID
       addiu at,zero,%critaccessory  #at = Critical Accessory specified above
       beql at,v0,RAND               #Branch ahead if Accessory is equipped (likely)
       sll a1,a1,0x02                 #Quadruple the critical chance if so! ^
RAND:  jal 0x088b9d80                #Random Process (a1/a0 chance, returns v0 = 0 or 1)
       addiu a0,zero,0x0064          #a0 = 100 (denominator) ^
       bne v0,zero,0x088a7ba4        #Branch if critical did not occur
CRIT:  lui v1,0x092e                 #(Critical damage starts here) (0x088a7b70)
       lw v0,0x5c10(v1)              #Load current action
       addiu at,zero,0x0001
       sb at,0x0001(v0)              #Store Critical Hit Flag
       lh v1,0x5c5c(v1)              #Load XA
       addiu v1,v1,0x0001            #Round up
       sra a0,v1,0x01                #XA/2 instead of XA * RandomResult
$-offset:088a7b20
       beq v1,v0,0x088a7b70          #Update a branch
$-offset:088a7b34
       beq v0,v1,0x088a7b70          #Update a branch
#-----------------------------------------------------------------------------------
$-name:New MP Regeneration Accessory
$-uuid:mpregen-accessory-tzepish
$-description:
* Adds a check for an equipped accessory before applying 1/8th MaxMP regen to MP every turn.
* Used in WOTL Tweak for the new Rune Armlet.
$-overwrites:none
$-requires:none
$-define:
     %mpaccessory,0x13a         #New: Item ID for the Rune Armlet (MP regen accessory)
$-file:boot.bin
$-type:ram
$-offset:088b7e44               #New MP Recovery Routine (formerly free space)
      ori at,zero,%mpaccessory      #at = Accessory ID (for MP Regen)
      lhu v1,0x001e(s0)             #Load Equipped Accessory ID
      bne v1,at,DONE                #Branch to DONE if not wearing the MP Regen accessory
      lw v0,0x5c10(v0)              #Load Current Action Data
      lhu v1,0x0036(s0)             #Load MaxMP
      srl v1,v1,0x03                #v1 = MaxMP / 8
      sh v1,0x000c(v0)              #Store MP Recovery (Current Action Data)
      ori v1,zero,0x0010            #r2 = 10 (Attack Type = MP Recovery)
      sb v1,0x0027(v0)              #Store Attack Type = MP Recovery
DONE: jr ra
      noop*5
$-offset:088b7b14               #Rewrite some Poison and Regen for space
      bne v0,zero,0x088b7b9c        #Branch to end if Crystal, Dead, etc.
      addu v0,zero,zero             #v0 = 0 ^
      jal 0x088b7d80                #Do Set Action Target Variables
      addu a0,s0,zero               #a0 = s0 ^
      jal 0x088b7e44                #Jump to new MP Recovery Routine (above)
      lui v0,0x092e
#-----------------------------------------------------------------------------------
$-name:Start at 0 MP and recover some MP each turn
$-uuid:mpregen-start0-tzepish
$-description:
* An optional feature that is turned off by default in WOTL Tweak. It can be turned on in blacklist.asm.
* Everyone starts battle with 0 MP and recovers 1/8th every turn.
* The Rune Armlet accessory now doubles this MP recovery. Its up to you to change the description text of the item though.
$-overwrites:mpregen-accessory-tzepish
$-requires:mpregen-accessory-tzepish
$-define:
     %mpaccessory,0x13a         #New: Item ID for the Rune Armlet (MP regen accessory)
$-file:boot.bin
$-type:ram
$-offset:088c5854               #Load battle start data
      #sh v1,0x0034(a0)              #Vanilla: Store Max MP as Current MP
       sh zero,0x0034(a0)            #New:     Store Zero MP as Current MP
$-offset:088b7e44               #New MP Recovery Routine (formerly free space)
       lhu v1,0x0006(s0)             #Load Gender
       andi at,v1,0x0020             #Monster
       bne at,zero,DONE              #Branch to DONE if we are a monster (no MP regen)
       ori at,zero,%mpaccessory      #at = Accessory ID (for MP Regen)
       lhu v1,0x001e(s0)             #Load Equipped Accessory ID
       lhu a0,0x0036(s0)             #Load MaxMP
       bnel v1,at,REGEN              #Branch to REGEN if not wearing the MP Regen accessory (likely)
       srl v1,a0,0x03                #v1 = MaxMP / 8 if we are NOT wearing it ^
       srl v1,a0,0x02                #Else, v1 = MaxMP / 4 if we ARE wearing it
REGEN: lw v0,0x5c10(v0)              #Load Current Action Data
       sh v1,0x000c(v0)              #Store MP Recovery (Current Action Data)
       ori v1,zero,0x0010            #r2 = 10 (Attack Type = MP Recovery)
       sb v1,0x0027(v0)              #Store Attack Type = MP Recovery
DONE:  jr ra
       noop
#-----------------------------------------------------------------------------------
$-name:Increase Poison damage
$-uuid:poison-damage-tzepish
$-description:
* Doubles the damage Poison inflicts every turn.
* Regen is unchanged, but included here for easy changing if you want.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088b7b48               #Poison
       #srl a0,v1,0x03                #Vanilla: Damage = MaxHP/8
        srl a0,v1,0x02                #New    : Damage = MaxHP/4
$-offset:088b7b78               #Regen
       #srl a0,v1,0x03                #Vanilla: Recovery = MaxHP/8
        srl a0,v1,0x03                #New    : Recovery = MaxHP/8 (Unchanged)
#-----------------------------------------------------------------------------------
$-name:Increase Blind and Confuse miss rates
$-uuid:blind-confuse-missrate-tzepish
$-description:
* Makes Blind a more powerful status effect by increasing its hit penalty.
* Confuse uses the same penalty, which is fine by me.
* Unlike the above Poison and Regen hack, the two offsets below actually both need to match.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a731c
       #srl v1,v1,0x01                #Vanilla: Divide hit rate by 2
        srl v1,v1,0x02                #New:     Divide hit rate by 4
$-offset:088a9ce4
       #srl v1,v1,0x01                #Vanilla: Divide hit rate by 2
        srl v1,v1,0x02                #New:     Divide hit rate by 4
#-----------------------------------------------------------------------------------
$-name:Blind enemies are easier to hit
$-uuid:blind-evasion-nullify-tzepish
$-description:
* Adds Blind to the list of status effects that nullify evasion.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a73c8
       #andi v0,v0,0x0010             #Vanilla: Confused
        andi v0,v0,0x0030             #New:     Confused or Blind
#-----------------------------------------------------------------------------------
$-name:Increase Defend and Invisible evasion rate
$-uuid:defend-invisibile-evasion-tzepish
$-description:
* Adds Invisible to the list of status effects that increase evasion (normally only Defend).
* Increase Defend / Invisible evade bonus.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a7408
        lw a0,0x5c48(v0)              #a0 = Target Data
        lbu v1,0x5c6b(v0)             #v1 = Base Hit Rate
DEFEND: lbu at,0x0062(a0)             #Load Current Status 1
        andi at,at,0x0002             #Defending
        bnel at,zero,INVIS            #Branch if Defending
        srl v1,v1,0x02                 #Divide hit rate by 4 if Defending ^
INVIS:  lbu at,0x0064(a0)             #Load Current Status 3
        andi at,at,0x0010             #Invisible
        bnel at,zero,DONE             #Branch if Invisible
        srl v1,v1,0x02                 #Divide hit rate by 4 if Invisible ^
DONE:   sb v1,0x5c6b(v0)              #Store Updated Hit Rate
#-----------------------------------------------------------------------------------
$-name:Gravity & Drain deal half damage to Lucavi
$-uuid:gravity-drain-lucavi-tzepish
$-description:
* Makes Gravity and spells like it deal half damage to monsters with hidden stats display (like Lucavi)
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088aaed0                   #Helper function for checking if the target has Hidden Stats
         lui v0,0x092e
         lw at,0x5c48(v0)              #Load Target Data
         lbu at,0x0006(at)             #Load Target Gender
         andi at,at,0x0004             #Hidden Stats
         bnel at,zero,DONE             #Proceed if Hidden Stats
         srl a1,a1,0x01                 #Divide Damage in half if Hidden Stats ^
DONE:    lw at,0x5c10(v0)              #Load Current Action Data
         addu t9,at,t9                 #Apply offset for HP or MP damage
         jr ra
         sh a1,0x0000(t9)              #Store HP or MP Damage ^
$-offset:088aaa84                   #Formula 09 (Gravity)
         jal 0x088aaed0                #Go to helper function above
         addiu t9,zero,0x0006           #Offset for HP Damage ^
         lw a0,0x5c10(v0)
$-offset:088abcc0                   #Formula 0f (Drain MP)
         jal 0x088aaed0                #Go to helper function above
         addiu t9,zero,0x000a           #Offset for MP Damage ^
         lw a1,0x5c10(v0)
$-offset:088abf78                   #Formula 10 (Drain HP)
         addu a1,a0,a1                 #Use a1 instead of a0
         jal 0x088aaed0                #Go to helper function above
         addiu t9,zero,0x0006           #Offset for HP Damage ^
#-----------------------------------------------------------------------------------
$-name:Undead always reanimate
$-uuid:undead-revive-tzepish
$-description:
* Makes undead creatures always come back to life (instead of 50% chance).
* WOTL Tweak has this turned off by default. You can enable it in blacklist.asm.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088c011c
       beq v0,zero,0x088c017c        #Branch if not undead
       noop
      #andi v0,s0,0x0001             #Vanilla: Set if random number previously generated was odd
       addiu v0,zero,0x0001          #New:     Set always instead
       beq v0,zero,0x088c017c        #Branch if not reviving
       noop
#-----------------------------------------------------------------------------------
$-name:Focus increases both PA and MA
$-uuid:battle-formula-036-tzepish
$-description:
* Apply the bonus from Focus to both PA and MA (instead of just PA). Replaces the stock Valhalla script that doesnt work.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a5a08
      lw v1,0x5c10(v1)              #Load current action data
      ori a1,a0,0x0080
      addiu a0,zero,0x0001
      sb a1,0x0016(v1)              #Store Y+Bonus flag as PA Boost
      sb a1,0x0017(v1)              #Store Y+Bonus flag as MA Boost
#-----------------------------------------------------------------------------------
$-name:Vengeance, Blade Beam, and Manaburn formulas accept a multiplier
$-uuid:battle-formulas-43-44-tzepish
$-description:
* You can now specify a percentage in the X parameter (in FFTPatcher) for Vengeance (both versions), Blade Beam, Manaburn, Almagest, and Karma.
* Use 100 if you want the damage to remain unchanged.
* This new parameter is now mandatory! (Unless you want the attack to deal 0% damage)
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a5f80           #Formula 43: Damage = Caster damage * X% (Vengeance, Blade Beam)
      lui v1,0x092e
      lw a0,0x5c44(v1)          #Load Attacker Data
      lbu a1,0x5c88(v1)         #Load Ability X
      lhu a2,0x0030(a0)         #Load Target Current HP
      lhu a3,0x0032(a0)         #Load Target Max HP
      subu a2,a3,a2             #MaxHP - CurrentHP
      mult a1,a2                #Result * X
      mflo a1                   #a1 = X * (MaxHP - CurrentHP)
      addiu a3,zero,0x0064      #a3 = 100
      divu a1,a3                #Divide by 100
      mflo a1                   #Damage = X% * (MaxHP - CurrentHP)
      lw v1,0x5c10(v1)          #Load Current Action Data
      sh a1,0x0006(v1)          #Store result as HP Damage
      addiu a0,zero,0x0080      #HP Damage (Attack Type)
      jr ra
      sb a0,0x0027(v1)          #Store Attack Type as HP Damage
$-offset:088a5fc0           #Formula 44: Damage = Target MP * X% (Manaburn)
      lui v1,0x092e
      lw a0,0x5c48(v1)          #Load Target Data
      lbu a1,0x5c88(v1)         #Load Ability X
      lhu a2,0x0034(a0)         #Load Target Current MP
      mult a1,a2                #MP * X
      mflo a1                   #a1 = MP * X
      addiu a3,zero,0x0064      #a3 = 100
      divu a1,a3                #Divide by 100
      mflo a1                   #Damage = MP * X%
      lw v1,0x5c10(v1)          #Load Current Action Data
      sh a1,0x0006(v1)          #Store result as HP Damage
      addiu a0,zero,0x0080      #HP Damage (Attack Type)
      jr ra
      sb a0,0x0027(v1)          #Store Attack Type as HP Damage
      noop*2
#-----------------------------------------------------------------------------------
$-name:JP Boost always applies
$-uuid:jpboost-innate-always-tzepish
$-description:
* Removes the check that JP Boost is equipped before applying its JP bonus.
* You probably dont want to turn this off in WOTL Tweak, since the JP Boost ability has been replaced with the new Combat Casting ability. So if you remove this hack, Combat Casting will suddenly award more JP.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088b87a0
     #andi v0,v0,0x0040             #Vanilla: v0 = 1 if JP Boost is equipped
      addiu v0,zero,0x0001          #New:     v0 = 1 always instead
$-offset:088d5708
     #andi v0,v0,0x0040             #Vanilla: v0 = 1 if JP Boost is equipped
      addiu v0,zero,0x0001          #New:     v0 = 1 always instead
#-----------------------------------------------------------------------------------
$-name:Remove permanent Brave and Faith alterations
$-uuid:remove-permanent-brave-faith-tzepish
$-description:
* Set Brave/Faith back to its original value instead of upgrading it after battle.
* Also increases the potency of Steel, Praise, and Preach, so that these skills are worth using still.
* Turned off by default in WOTL Tweak, but can be turned on in blacklist.asm.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:0894a1d8
     #addu v0,v0,a0                 #Vanilla: v0 = New permanent Brave
      lbu v0,0x002a(s0)             #New:     v0 = Load original Brave instead
$-offset:0894a220
     #addu s4,a2,v1                 #Vanilla: s4 = New permanent Faith
      lbu s4,0x002c(s0)             #New:     s4 = Load original Faith instead
$-offset:088a5d28               #Praise
      sll a0,a0,0x02                #Multiply original Brave gain by four
$-offset:088a5d60               #Preach
      sll a0,a0,0x02                #Multiply original Faith gain by four
$-offset:088a5dc8               #Steel
      sll a0,a0,0x02                #Multiply original Brave gain by four
#-----------------------------------------------------------------------------------
$-name:Modify Faith and Brave desertion thresholds
$-uuid:modify-desertion-brave-faith-tzepish
$-description:
* Allows easy tuning of Brave/Faith values that cause desertion threats and actual desertion. Modifies every place in the code where these numbers are checked.
* Set Brave values to 1 higher than you want! Its a quirk of how the code works (so a value of 6 means desertion happens at 5).
* Set Faith values to exactly what you want (so a value of 95 means desertion happens at 95).
* See the next hack if you want to turn Desertion off entirely.
$-overwrites:none
$-requires:none
$-define:
    #%brave_threat,0x10        #Vanilla: 16
    #%brave_desert,0x06        #Vanilla: 06
    #%faith_threat,0x55        #Vanilla: 85
    #%faith_desert,0x5f        #Vanilla: 95
     %brave_threat,0x0a        #New:     10
     %brave_desert,0x05        #New:     05
     %faith_threat,0x5b        #New:     91
     %faith_desert,0x60        #New:     96
$-file:boot.bin
$-type:ram
$-offset:0894a6ec
      slti at,a0,%brave_desert      #Desert if Brave is less than specified desertion threshold
$-offset:0894a8b4
      slti at,a1,%faith_desert      #Do not desert if Faith is less than specified desertion threshold
$-offset:0894a25c
      slti a0,v0,%brave_desert      #Do not threaten if Brave is below desertion threshold (desert instead)
$-offset:0894a26c
      slti a0,v0,%brave_desert      #Do not threaten if Brave is below desertion threshold (desert instead)
$-offset:0894a274
      slti v0,s4,%faith_threat      #Do not threaten if Faith is below threaten threshold
      slti at,v0,%brave_threat      #Threaten if Brave is below threaten threshold
$-offset:0894a418
      slti v0,s4,%faith_threat      #Do not threaten if Faith is below threaten threshold
$-offset:0894a424
      slti at,s4,%faith_desert      #Threaten if Faith is below desertion threshold (else desert)
#-----------------------------------------------------------------------------------
$-name:Remove Brave and Faith desertion
$-uuid:remove-desertion-brave-faith-tzepish
$-description:
* Units will not desert the team after battle if their Brave gets too low or Faith too high.
* Turned off by default in WOTL Tweak, but can be turned on in blacklist.asm.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:0894a230
     #slti at,v1,0x0018             #Vanilla: No desertion threat (at = 0) if Guest character
      addu at,zero,zero             #New:     No desertion threat (at = 0) always instead
$-offset:0894a6b0
     #slti at,v1,0x0018             #Vanilla: No desertion (at = 0) if Guest character
      addu at,zero,zero             #New:     No desertion (at = 0) always instead
#-----------------------------------------------------------------------------------
$-name:Poachers Den opens in Chapter 2
$-uuid:poachers-den-open-tzepish
$-description:
* Changes the flag used for determining if the Poachers Den is open.
* This is a better method than changing event data because it is backwards compatible.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:0890b400
       #addiu a0,zero,0x0090          #Vanilla: Poachers Den open flag (Chapter 3)
        addiu a0,zero,0x0091          #New:     Propositions open flag (Chapter 2)
       #addiu a0,zero,0x006e          #Alt:     Story Progress flag (Chapter 1)
#-----------------------------------------------------------------------------------
$-name:Poach rare item chance increase
$-uuid:poach-rare-chance-tzepish
$-description:
* Allows easy tuning for the Poach rare item chance.
* Input value will be divided by 256 for the resulting chance. For example, for 50%, input 0x80 (128)
$-overwrites:none
$-requires:none
$-define:
    #%poachrarechance,0x1f              #Vanilla: 12.1%
     %poachrarechance,0x80              #New:     50%
$-file:boot.bin
$-type:ram
$-offset:088b63f4
       #addiu a1,zero,0x001f              #Vanilla: Rare item chance = 31/256 = 12.1%
        addiu a1,zero,%poachrarechance    #New:     Rare item chance = XX/256
#-----------------------------------------------------------------------------------
$-name:Broken/Stolen/Thrown equipment items are added to Poachers Den
$-uuid:lost-equipment-poachersden-tzepish
$-description:
* Equipment that is permanently lost after being broken, stolen, or thrown will appear in the Poachers Den, allowing the player to buy them back.
* Make sure to give everything a price in FFTPatcher.
* This also changes Crush attacks to break equipment OR deal damage (not both), replacing the stock Valhalla script.
* Note the Refund Katanas code is the same as the Catch code. So if you Catch an item that is currently being sold in the Poachers Den, the Poachers Den quantity will go down by 1. I dont mind this.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a82c4           #Helper function for Rend, Crush, and Steal (needs a0 = Item ID & v1 = 0x092e0000)
       lw at,0x5c48(v1)         #Load Target Data
       lbu at,0x01e0(at)        #Load Target modified ENTD flags
       andi at,at,0x30		    #Result will be 0 if Player Team
       bne at,zero,DONE         #Branch to DONE if Target is NOT Player Team
       lui v1,0x092f
       addu v1,v1,a0            #Add item ID to be added to Poachers Den
       lbu a0,0xaa64(v1)        #Load Poachers Den inventory for this item
       addiu at,zero,0x00ff     #at = 0xff (256)
       beq a0,at,DONE           #Branch to DONE if Poachers Den has 256 of these
       addiu a0,a0,0x0001       #Increment Poachers Den inventory quantity
       sb a0,0xaa64(v1)         #Store Poachers Den inventory for this item ^
DONE:  jr ra                    #Return
       noop
$-offset:088ae3c8           #End of Formula 25 (Rend)
     lui v1,0x092e
     lw a0,0x5c10(v1)           #a0 = Load Current Action Data
     lbu at,0x0000(a0)          #Load hit flag
     beq at,zero,END            #Branch to END if attack missed
     addiu at,zero,0x0004       #Break equipment special flag
     sh at,0x0012(a0)           #Store special flag (mark item for break)
     lw at,0x5b9c(v1)           #Load Current Action State
     bne at,zero,END            #Branch to END if action state is NOT 0 (executing)
     noop
     jal 0x088a82c4             #Jump to new Poachers Den helper function
     lhu a0,0x0004(a0)          #a0 = Load item flagged for removal
END: lw ra,0x000c(sp)           #0x088ae3f4
     jr ra
     addiu sp,sp,0x0010
$-offset:088ae328               #Update Rend jumps to new ending offset
    beq zero,zero,0x088ae3f8
$-offset:088ae338               #Update Rend jumps to new ending offset
    bne v0,zero,0x088ae3f4
$-offset:088ae384               #Update Rend jumps to new ending offset
    beq zero,zero,0x088ae3f4
$-offset:088ae504           #End of Formula 26 (Steal)
     lui v1,0x092e
     lw a0,0x5c10(v1)           #a0 = Load Current Action Data
     lbu at,0x0000(a0)          #Load hit flag
     beq at,zero,END            #Branch to END if attack missed
     addiu at,zero,0x0010       #Steal equipment special flag
     sh at,0x0012(a0)           #Store special flag (mark item for steal)
     lw at,0x5b9c(v1)           #Load Current Action State
     bne at,zero,END            #Branch to END if action state is NOT 0 (executing)
     noop
     jal 0x088a82c4             #Jump to new Poachers Den helper function
     lhu a0,0x0004(a0)          #a0 = Load item flagged for removal
END: lw ra,0x000c(sp)           #0x088ae530
     jr ra
     addiu sp,sp,0x0010
$-offset:088ae47c               #Update Steal jumps to new ending offset
    beq zero,zero,0x088ae530
$-offset:088ae48c               #Update Steal jumps to new ending offset
    bnel v0,zero,0x088ae534
$-offset:088ae4bc               #Update Steal jumps to new ending offset
    bne v0,zero,0x088ae530
$-offset:088af2e0           #Middle of Formula 2e (Crush)
    lbu at,0x0000(a0)           #Load Hit flag
    beq at,zero,0x088af4d8      #Branch to end if attack missed
    addiu at,zero,0x0004
    beq zero,zero,0x088ae3e0    #This is a huge hack. Branching to the end of formula 25 instead. Registers happen to line up.
    sh at,0x0012(a0)
$-offset:088d1ff0           #Decrement item quantity code (handles Throw and Iaido)
    andi at,s1,0xffff           #at = Item ID
    sltiu at,at,0x007a          #Check if its a weapon (ID lower than 7a) (Note: MP items not supported)
    beql at,zero,END_DEC        #Branch to END_DEC if its not a weapon (dont add these to Poachers Den)
    addu v0,zero,zero           #Clear v0 for some reason (I think downstream code needs this) ^
    lbu at,0xfec4(a0)           #Load item quantity in Poachers Den (manually computed address based on inventory address)
    addiu v0,zero,0x00ff        #v0 = 0xff (256)
    beq v0,at,END_DEC           #Branch to END_DEC if Poachers Den has 256 of these (dont add more)
    addu v0,zero,zero           #Clear v0 for some reason (I think downstream code needs this)
    addiu at,at,0x0001          #Increment Poachers Den inventory quantity
    sb at,0xfec4(a0)            #Store Poachers Den inventory for this item (manually computed address)
END_DEC: lw ra,0x000c(sp)       #0x088d2018
         lw s1,0x0008(sp)
         lw s0,0x0004(sp)
         jr ra
         addiu sp,sp,0x0010
$-offset:088d1f50               #Update Decrement jumps to new ending offset
    beq zero,zero,0x088d2018
    addu v0,zero,zero
$-offset:088d1f6c               #Update Decrement jumps to new ending offset
    beq zero,zero,0x088d2018
    addiu v0,zero,0xffff
$-offset:088d1f74               #Update Decrement jumps to new ending offset
    beql s0,zero,0x088d2018
    addu v0,zero,zero
$-offset:088d1f98               #Update Decrement jumps to new ending offset
    beq zero,zero,0x088d2018
    noop
$-offset:088d1fa8               #Update Decrement jumps to new ending offset
    beq zero,zero,0x088d2018
    addu v0,zero,zero
$-offset:088d1fc8               #Update Decrement jumps to new ending offset
    beq zero,zero,0x088d2018
    addiu v0,zero,0xffff
$-offset:088d1fd0               #Update Decrement jumps to new ending offset
    beql s0,zero,0x088d2018
    addu v0,zero,zero
$-offset:088d1fe0               #Update Decrement jumps to new ending offset
    bne v0,zero,0x088d2018
    addu v0,zero,zero
$-offset:088b96f0           #Refund Katanas code (v1 = item ID to refund, v0 = 0x092f0000)
    addu a0,v0,v1               #Offset by item ID
    lbu at,0xaba0(a0)           #Load item quantity in inventory
    addiu at,at,0x0001          #Increment inventory quantity for this item
    sb at,0xaba0(a0)            #Store new item quantity
    lbu at,0xaa64(a0)           #Load item quantity in Poachers Den
    beq at,zero,END_REFUND      #Branch to end if Poachers Den quantity is 0
    addu v0,zero,zero           #Clear v0 for some reason (I think downstream code needs this)
    addiu at,at,0xffff          #Decrement Poachers Den inventory quantity
    sb at,0xaa64(a0)            #Store Poachers Den inventory for this item
END_REFUND: lw ra,0x000c(sp)    #0x088b9714
            lw s2,0x0008(sp)
            lw s1,0x0004(sp)
            lw s0,0x0000(sp)
            jr ra
            addiu sp,sp,0x0010
$-offset:088b95ec               #Update Refund jumps to new ending offset
    beq zero,zero,0x088b9714
$-offset:088b95fc               #Update Refund jumps to new ending offset
    bnel v0,zero,0x088b9714
$-offset:088b9618               #Update Refund jumps to new ending offset
    beq zero,zero,0x088b9714
$-offset:088b9654               #Update Refund jumps to new ending offset
    beq zero,zero,0x088b9714
$-offset:088b9668               #Update Refund jumps to new ending offset
    beq zero,zero,0x088b9714
$-offset:088b9678               #Update Refund jumps to new ending offset
    beq zero,zero,0x088b9714
$-offset:088b96e4               #Update Refund jumps to new ending offset
    beq zero,zero,0x088b9714
#-----------------------------------------------------------------------------------
$-name:Modify Katana break chance with Iaido
$-uuid:katana-break-chance-tzepish
$-description:
* Changes the chance that Iaido will break the katana from WP% to 2*WP%.
* This is to offset the attack power reductions in WOTL Tweak.
* If you dont like it, blacklist or modify this script. But IMO, its more fun this way, now that broken items can be bought again in the Poachers Den.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088adb64           #Formula 20 (Iaido - MA*Y. Most Katanas)
      lui v0,0x092e
      lbu a1,0x5c91(v0)             #Load WP
      sll a1,a1,0x01                #Double it (break chance = 2*WP)
$-offset:088adc64           #Formula 21 (Iaido - MA*Y MP. Osafune)
      lui v1,0x092e
      lbu a1,0x5c91(v1)             #Load WP
      sll a1,a1,0x01                #Double it (break chance = 2*WP)
$-offset:088adee4           #Formula 22 (Iaido - Hit 100% Status. Kiyomori, Masamune)
      lui v0,0x092e
      lbu a1,0x5c91(v0)             #Load WP
      sll a1,a1,0x01                #Double it (break chance = 2*WP)
$-offset:088adfa4           #Formula 23 (Iaido - MA*Y Heal. Murasame)
      lui v1,0x092e
      lbu a1,0x5c91(v1)             #Load WP
      sll a1,a1,0x01                #Double it (break chance = 2*WP)
#-----------------------------------------------------------------------------------
$-name:Swiftness AI fixes
$-uuid:swiftness-ai-fixes-tzepish
$-description: Fixes bugs that prevent the AI from taking full advantage of Swiftness and Instant Cast. Instead they were looking for the wrong abilities, causing funky behavior.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:089b1cd4
     #andi v0,v1,0x0080             #Vanilla: Check for Beastmaster (This is a bug)
      andi v0,v1,0x0008             #New:     Check for Swiftness (fixed!)
      beq v0,zero,0x089b1cf0        #Branch if not Swiftness
      lbu v0,0x0001(s3)             #Load CT
      addiu v0,v0,0x0001            #Round up (Fixes a bug - original forgot to round up)
$-offset:089b1cf0
     #andi v0,v1,0x0040             #Vanilla: Check for Defend (This is a bug)
      andi v0,v1,0x0004             #New:     Check for Instant Cast (fixed!)
#-----------------------------------------------------------------------------------
$-name:Beast Tamer = Combine Beastmaster, Beast Tongue, & Tame
$-uuid:combine-beast-abilities-tzepish
$-description:
* Beastmaster, Beast Tongue, and Tame are combined into one ability (called "Beast Tamer" in WOTL Tweak).
* Dragon Tamer is Beast Tamer, but only for dragons and hydras (for Reis).
* Speechcraft works on monsters without Beast Tongue, but at lower success rate (X = 50%).
* Earplug now blocks enemy Speechcraft entirely instead of merely reducing the hit chance.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088aeb88                   #Rewrite start of Speechcraft Formula (2a)
         lui v0,0x092e
         lw a1,0x5c44(v0)              #a1 = Load Attacker Data
         lw a2,0x5c48(v0)              #a2 = Load Target Data
         lbu t8,0x5c88(v0)             #t8 = Load X
         lbu t9,0x003f(a1)             #t9 = Load MA
         lbu a0,0x0066(a2)             #Check Target Current Status 5
         andi at,a0,0x0010             #Sleep
         bne at,zero,MISS              #Branch if target is asleep
         lbu a0,0x0006(a2)             #Check Target Gender
         andi at,a0,0x0020             #Monster
         beq at,zero,0x088aec20        #Branch if Target is not a Monster
         lbu a0,0x009b(a1)             #Check Attacker Support Abilities 3
         andi at,a0,0x0080             #Beast Tamer
         bnel at,zero,0x088aec20       #Branch if Attacker has Beast Tamer (likely)
         sll t9,t9,1                   #Double effective MA if Beast Tamer applies ^
         andi at,a0,0x0010             #Dragon Tamer
         beql at,zero,0x088aec20       #Branch if Attacker does NOT have Dragon Tamer (likely)
         srl t8,t8,1                   #Halve X if monster & no Tamer ability ^
         lbu a0,0x0180(a2)             #Load Target character graphic
         addiu at,zero,0x000f          #Dragon
         beql at,a0,0x088aec20         #Branch if Target is a Dragon (likely)
         sll t9,t9,1                   #Double effective MA if Dragon Tamer applies ^
         addiu at,zero,0x0010          #Hydra
         beql at,a0,0x088aec20         #Branch if Target is a Hydra (likely)
         sll t9,t9,1                   #Double effective MA if Dragon Tamer applies ^
         j 0x088aec20                  #Proceed
         srl t8,t8,1                   #Else, halve X if monster & no Tamer ability ^
MISS:    lw a0,0x5c10(v0)              #Load Current Action Data
         addiu a1,zero,0x0007          #a1 = 7 (Miss text)
         sb zero,0x0000(a0)            #Guaranteed miss
         lw a0,0x5c10(v0)              #Load Current Action Data
         sb a1,0x0002(a0)              #Store if attack was blocked or missed (7 = Miss)
         lw a0,0x5c10(v0)              #Load Current Action Data
         sh zero,0x002c(a0)            #0% chance to hit
         noop*4                        #Free Space
$-offset:088aed08
     #sh a2,0x5c5c(a0)              #Vanilla: XA = MA
      sh t9,0x5c5c(a0)              #New:     XA = 2*MA if monster & Beast Tamer, else MA
$-offset:088aed14
     #sh a1,0x5c5e(v1)              #Vanilla: YA = X
      sh t8,0x5c5e(v1)              #New:     YA = X/2 if monster & no Beast Tamer, else X
#$-offset:088aec78
#     #sh a1,0x002c(a0)              #Vanilla: Earplug Hit% = 100 - Brave
#      sh zero,0x002c(a0)            #New:     Earplug Hit% = 0
$-offset:088aec50                #Earplug section
      lbu at,0x0098(a0)             #Load Reaction Abilities 4
      andi at,at,0x0020             #Earplug
      beq at,zero,0x088aecdc        #Branch ahead if no Earplug
      lbu at,0x01e0(a0)             #Load Target Modified ENTD flags
      andi at,at,0x0030             #at = Target Team
      lw a1,0x5c44(v1)              #Load Attacker Data
      lbu a2,0x01e0(a1)             #Load Attacker Modified ENTD flags
      andi a2,a2,0x0030             #a2 = Attacker Team
      beq at,a2,0x088aecdc          #Branch ahead if teams are the same (Earplug does not apply)
      lw a0,0x5c10(v1)              #Load Current Action Data
      sh zero,0x002c(a0)            #Speechcraft Hit% = 0 if Earplug applies
$-offset:088a6b90
     #beq v1,zero,0x088a6be8        #Vanilla: Branch ahead if attacker does NOT have Tame
      beq v1,zero,0x088a70c8        #New:     Branch to Dragon Tamer check if attacker does NOT have Beast Tamer
$-offset:088a70c8 #New Tame check location for Dragon Tamer (claim some free space)
         lui t9,0x092e
         lw v1,0x5c44(t9)              #t8 = Load Attacker Data
         lbu v1,0x009b(v1)             #t8 = Load Attacker Support Abilities 3
         andi v1,v1,0x0010             #Dragon Tamer
         beq v1,zero,0x088a6be8        #Branch ahead if attacker does NOT have Dragon Tamer (oh well)
         lw t9,0x5c48(t9)              #t9 = Load Target Data
         lbu t9,0x0180(t9)             #t9 = Load Target character graphic
         addiu at,zero,0x000f          #Check if Dragon
         beq t9,at,0x088a6b98          #Branch back if Dragon (yay!)
         addiu at,zero,0x0010          #Check if Hydra
         beq t9,at,0x088a6b98          #Branch back if Hydra (yay!)
         noop
         beq zero,zero,0x088a6be8      #Branch ahead if target is NOT a Dragon or Hydra (oh well)
         noop                          #Literally zero free space left after here
#-----------------------------------------------------------------------------------
$-name:Beast Tamer works at any range
$-uuid:beasttamer-range-tzepish
$-description:
* Allows Beast Tamer / Dragon Tamer to work at any range and any height. Allied monsters will always have the extra ability as long as the unit with Beast Tamer is present in the battle (and not afflicted by a status that disables action).
* Also adapts the AI to know the difference between Beast Tamer & Dragon Tamer, and to no longer care about the distance requirement.
* Note AI monsters still wont use the extra ability if its an attack unless they are next to the ally with Beast Tamer (non-attacks work fine, and both types work fine if the monster is player-controlled).
* Note that there is a ton of code down there thats rewritten exactly as it is in the base game, but just shifted up a bit. This was an attempt to squeeze in a little bit of extra functionality without optimizing the whole thing.
$-overwrites:none
$-requires:combine-beast-abilities-tzepish
$-file:boot.bin
$-type:ram
$-offset:088bf300
             addiu sp,sp,0xffd0            #Check for Beastmaster valid (for menus)
             sw ra,0x0018(sp)
             sw s4,0x0014(sp)              #s4 = 0x0090 if dragon/hydra, 0x0080 if normal monster
             sw s3,0x0010(sp)              #s3 = Number of loops
             sw s2,0x000c(sp)              #s2 = Unit we are checking for Beast Tamer / Dragon Tamer
             sw s1,0x0008(sp)
             lui s2,0x092e
             sw s0,0x0004(sp)
             andi s1,a0,0x00ff
             andi s0,a3,0x00ff
             addu s3,zero,zero             #Initialize loop counter to zero
             addiu s2,s2,0x5cb4            #Unit data pointer
             addiu at,zero,0x000f          #Check if Dragon
             beql a1,at,LOOP_START         #Branch if Dragon (likely)
             ori s4,zero,0x0090            #Allow Dragon Tamer or Beast Tamer ^
             addiu at,zero,0x0010          #Check if Hydra
             beql a1,at,LOOP_START         #Branch if Hydra (likely)
             ori s4,zero,0x0090            #Allow Dragon Tamer or Beast Tamer ^
             ori s4,zero,0x0080            #Else, only allow Beast Tamer
LOOP_START:  lbu v1,0x0001(s2)             #Load next unit to check
             addiu v0,zero,0x00ff
             beq v1,v0,LOOP_END            #Branch if unit does NOT exist
             lbu v0,0x009b(s2)             #Load Support Abilities 3
             and v0,v0,s4                  #Beast Tamer (or Dragon Tamer if dragon/hydra)
             beq v0,zero,LOOP_END          #Branch if ability is NOT equipped
             noop
             jal 0x088b67c0                #Do Status checks that prevent action
             addu a0,s2,zero
             bne v0,zero,LOOP_END          #Branch if unable to act due to status
             lbu v0,0x0005(s2)             #Load ENTD?
             xor v0,v0,s1
             andi v0,v0,0x0030             #v0 = 0 if player team
             andi v0,v0,0x00ff
             bne v0,zero,LOOP_END          #Branch if not player team
             noop
             addiu a0,sp,0x0028
             lbu v0,0x002e(sp)
             subu v1,s0,v0
             slti v0,v1,0xfffb
             bne v0,zero,LOOP_END
             noop
             slti at,v1,0x0006
             beq at,zero,LOOP_END
             noop
             beq zero,zero,LOOP_DONE
             addiu v0,zero,0x0001          #v0 = 1 (Beast ability valid) ^
LOOP_END:    addiu s3,s3,0x0001            #Increment loop counter
             slti v0,s3,0x0015             #Have we checked every unit?
             bne v0,zero,LOOP_START        #Loop back if not
             addiu s2,s2,0x01e8            #Check next unit ^
             addu v0,zero,zero             #v0 = 0 (Beast ability NOT valid)
LOOP_DONE:   lw ra,0x0018(sp)
             lw s4,0x0014(sp)
             lw s3,0x0010(sp)
             lw s2,0x000c(sp)
             lw s1,0x0008(sp)
             lw s0,0x0004(sp)
             jr ra
             addiu sp,sp,0x0030
             noop*22                       #Free Space (088bf3ec - 088bf440)
$-offset:088bf248
     #lbu s4,0x004f(s3)         #Vanilla: Load map X coordinate
      lbu s4,0x0180(s3)         #New:     Load monster graphic instead
$-offset:088bf258
     #addiu a1,s4,0xffff        #Vanilla: a1 = X coordinate - 1 tile
      addu a1,s4,zero           #New:     a1 = Monster graphic instead
$-offset:088bf278
     #jal 0x088bf300            #Vanilla: Check for Beastmaster valid 2
      noop                      #New:     Additional checks are no longer needed!
$-offset:088bf290
     #jal 0x088bf300            #Vanilla: Check for Beastmaster valid 3
      noop                      #New:     Additional checks are no longer needed!
$-offset:088bf2a8
     #jal 0x088bf300            #Vanilla: Check for Beastmaster valid 4
      noop                      #New:     Additional checks are no longer needed!
$-offset:089b3f0c #AI Beastmaster Use Check
                lw a0,0x17f8(s0)               #a0 = Acting Unit data pointer
                addiu s1,s1,0x5cb4             #s1 = Unit Pointer Address
                lbu a0,0x0180(a0)              #a0 = Load monster graphic
                addiu at,zero,0x000f           #Check if Dragon
                beql a0,at,AI_LOOP1_START      #Branch if Dragon (likely)
                ori t9,zero,0x0090             #Allow Dragon Tamer or Beast Tamer ^
                addiu at,zero,0x0010           #Check if Hydra
                beql a0,at,AI_LOOP1_START      #Branch if Hydra (likely)
                ori t9,zero,0x0090             #Allow Dragon Tamer or Beast Tamer ^
                ori t9,zero,0x0080             #Else, only allow Beast Tamer
AI_LOOP1_START: lbu v1,0x0001(s1)              #Load next Unit ID to check (Start of loop)
                addiu v0,zero,0x00ff
                beq v1,v0,AI_LOOP1_END         #Branch to end loop if unit does NOT exist
                noop
                lbu v0,0x009b(s1)              #Load Support Abilities 3
                and v0,v0,t9                   #Beast Tamer (or Dragon Tamer)
                beq v0,zero,AI_LOOP1_END       #Branch to end loop if not Beastmaster
                noop
                lbu v1,0x01e0(s1)              #Load modified ENTD flags
                lbu v0,0x0e39(s0)
                andi v1,v1,0x0030              #v1 = 0 if player team
                bne v1,v0,AI_LOOP1_END         #Branch to end loop if Unit is not player team
                noop
                addu a0,s1,zero
                jal 0x088c7880                 #Status Checks
                addiu a1,zero,0x0004           #Can the unit react
                bne v0,zero,AI_LOOP1_END       #Branch to end loop if not
                noop
                beql zero,zero,089b3fd8        #Else, Beast ability is valid, so stop looping (likely)
                addiu v0,zero,0x0001           #v0 = 1 (Beast ability valid) ^
AI_LOOP1_END:   addiu s2,s2,0x0001             #Increment loop counter
                slti v0,s2,0x0015              #Have we checked every unit?
                bne v0,zero,AI_LOOP1_START     #Loop back if not
                addiu s1,s1,0x01e8             #Next unit address
                addu v0,zero,zero              #v0 = 0 (Beast ability NOT valid)
                noop*16                        #Free Space (089b3f98 - 089b3fd4) (AI Routine ends at 089b3fd8)
$-offset:089b514c 
     #jal 0x089b5640                #Vanilla Address for AI Routine 2
      jal 0x089b5624                #New: Move up a bit for some extra space
$-offset:089b5624 #AI Routine 2:
                addiu sp,sp,0xfff0
                sw ra,0x000c(sp)
                sw s2,0x0008(sp)
                lui s2,0x0973
                sw s1,0x0004(sp)
                addiu s2,s2,0x9c20
                sw s0,0x0000(sp)
                addu a1,zero,zero
                addu a0,s2,zero
MINOR_LOOP:     sh zero,0x0b4c(a0)
                sh zero,0x0b70(a0)
                sh zero,0x0b4e(a0)
                sh zero,0x0b72(a0)
                sh zero,0x0b50(a0)
                sh zero,0x0b74(a0)
                sh zero,0x0b52(a0)
                sh zero,0x0b76(a0)
                sh zero,0x0b54(a0)
                sh zero,0x0b78(a0)
                sh zero,0x0b56(a0)
                addiu a1,a1,0x0006
                sh zero,0x0b7a(a0)
                slti v1,a1,0x0012
                bne v1,zero,MINOR_LOOP         #Minor Loop back
                addiu a0,a0,0x000c             #Increment unit by c ^
                lui s0,0x092e
                addu s1,zero,zero
                lw a0,0x17f8(s2)               #a0 = Acting Unit data pointer
                addiu s0,s0,0x5cb4             #s0 = Unit Pointer address
                lbu a0,0x0180(a0)              #a0 = Load monster graphic
                addiu at,zero,0x000f           #Check if Dragon
                beql a0,at,0x089b56b8          #Branch if Dragon (likely)
                ori t9,zero,0x0090             #Allow Dragon Tamer or Beast Tamer ^
                addiu at,zero,0x0010           #Check if Hydra
                beql a0,at,0x089b56b8          #Branch if Hydra (likely)
                ori t9,zero,0x0090             #Allow Dragon Tamer or Beast Tamer ^
                ori t9,zero,0x0080             #Else, only allow Beast Tamer
                lbu a0,0x0001(s0)              #Load next Unit ID to check (Start of loop)
                addiu v1,zero,0x00ff
                beql a0,v1,0x089b57f0          #Branch to end loop if unit does NOT exist (likely)
                addiu s1,s1,0x0001             #Increment loop counter ^
                lbu v1,0x009b(s0)              #Load Support Abilities 3
                and v1,v1,t9                   #Beast Tamer (or Dragon Tamer)
                beq v1,zero,0x089b57ec         #Branch to end loop if no Tamer ability
                lbu a0,0x01e0(s0)              #Load modified ENTD flags
                lbu v1,0x0e39(s2)              #Load acting unit team?
                andi a0,a0,0x0030              #a0 = 0 if player team
                bne a0,v1,0x089b57ec           #Branch to end loop if unit is player team
$-offset:089b57f4
           #bne v1,zero,0x089b56b0         #Vanilla: Loop back
            bne v1,zero,0x089b56b8         #New:     Loop back
$-offset:089b5750
           #bltzl t4,0x089b57e0            #Vanilla: Branch to end loop if... something related to distance
           #addiu a2,a2,0x0001             #Vanilla: Increment loop counter
            noop*2                         #New:     Pretty sure we dont want this!
$-offset:089b5760
           #beq at,zero,0x089b57dc         #Vanilla: Branch to end loop if out of Beastmaster X range (1 tile)
            noop                           #New:     We dont care about this anymore!
$-offset:089b5774
           #bltz t1,0x089b57dc             #Vanilla: Branch to end loop if... something related to distance
            noop                           #New:     We dont care about this anymore!
$-offset:089b5784
           #beq at,zero,0x089b57dc         #Vanilla: Branch to end loop if out of Beastmaster Y range (1 tile)
            noop                           #New:     We dont care about this anymore!
$-offset:089b57b8
           #bne at,zero,0x089b57dc         #Vanilla: Branch to end loop if out of Beastmaster height range (2)
            noop                           #New:     We dont care about this anymore!
$-offset:089b57c4
           #beq at,zero,0x089b57dc         #Vanilla: Branch to end loop if out of Beastmaster height range (2)
            noop                           #New:     We dont care about this anymore!
#-----------------------------------------------------------------------------------
$-name:Update disallowed innate support abilities
$-uuid:update-disallowed-innates-tzepish
$-description:
* Replaces the hard-coded list of greyed out Support abilities per job (for example, Throw Item on Chemist)
* Instead it checks the innate abilities of the job and greys them out accordingly.
* Thus, it now works for special characters like Reis and Luso, and it will now adapt to changes made in FFTPatcher, including changes made in WOTL Tweak.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:0898e134               #Grey out Innate Support Abilities in menu
      sll v1,t5,0x03                #v1 = JobID*8
      subu t1,v1,t5                 #t1 = JobID*7
      sll v1,t1,0x03                #v1 = JobID*56
      subu t1,v1,t1                 #t1 = JobID*49
      lui v1,0x08a8
      lw v1,0xb148(v1)              #v1 = Job data pointer
      addu v1,v1,t1                 #v1 = JobID*49 + Job data pointer = Current job data pointer
      lbu t1,0x0001(v1)             #Load Innate Ability 1 byte 1
      ori t1,t1,0x0100               #byte 2 is always 0x01
      lbu t2,0x0003(v1)             #Load Innate Ability 2 byte 1
      ori t2,t2,0x0100               #byte 2 is always 0x01
      lbu t3,0x0005(v1)             #Load Innate Ability 3 byte 1
      ori t3,t3,0x0100               #byte 2 is always 0x01
      lbu t4,0x0007(v1)             #Load Innate Ability 4 byte 1
      ori t4,t4,0x0100               #byte 2 is always 0x01
      addu v1,s1,zero
      lh a0,0x0000(t7)              #a0 = Current Support to check
      beql a0,s1,0x0898e1c4         #I think this breaks out of the loop if all Supports have been checked
      noop
      beql a0,t1,0x0898e1b4         #If Current Support = Innate Ability 1
      ori a0,a0,0x4000               #Then grey it out ^
      beql a0,t2,0x0898e1b4         #If Current Support = Innate Ability 2
      ori a0,a0,0x4000               #Then grey it out ^
      beql a0,t3,0x0898e1b4         #If Current Support = Innate Ability 3
      ori a0,a0,0x4000               #Then grey it out ^
      beql a0,t4,0x0898e1b4         #If Current Support = Innate Ability 4
      ori a0,a0,0x4000               #Then grey it out ^
      noop*5
$-offset:0898e1cc                   #Gotta repoint a loop
      bnel a0,v1,0x0898e178         #Loop back to check next Support
$-offset:08990454               #Unequip innate support abilities on job switch
      lh a0,0x0024(a2)              #Load current Job ID
      lhu a1,0x0064(a2)             #Load current Support Ability
      sll v1,a0,0x03                #v1 = JobID*8
      subu a0,v1,a0                 #a0 = JobID*7
      sll v1,a0,0x03                #v1 = JobID*56
      subu a0,v1,a0                 #a0 = JobID*49
      lui v1,0x08a8
      lw v1,0xb148(v1)              #v1 = Job data pointer
      addu v1,v1,a0                 #v1 = JobID*49 + Job data pointer = Current job data pointer
      lbu at,0x0001(v1)             #Load Innate Ability 1 byte 1
      ori at,at,0x0100               #byte 2 is always 0x01
      beql at,a1,0x089904f0         #If support = Innate Ability 1
      sh zero,0x0064(a2)             #Then unequip it! ^
      lbu at,0x0003(v1)             #Load Innate Ability 2 byte 1
      ori at,at,0x0100               #byte 2 is always 0x01
      beql at,a1,0x089904f0         #If support = Innate Ability 2
      sh zero,0x0064(a2)             #Then unequip it! ^
      lbu at,0x0005(v1)             #Load Innate Ability 3 byte 1
      ori at,at,0x0100               #byte 2 is always 0x01
      beql at,a1,0x089904f0         #If support = Innate Ability 3
      sh zero,0x0064(a2)             #Then unequip it! ^
      lbu at,0x0007(v1)             #Load Innate Ability 4 byte 1
      ori at,at,0x0100               #byte 2 is always 0x01
      beql at,a1,0x089904f0         #If support = Innate Ability 4
      sh zero,0x0064(a2)             #Then unequip it! ^
      noop*14
#-----------------------------------------------------------------------------------
$-name:Weapon evasion always applies & Parry buff
$-uuid:wpn-evade-always-tzepish
$-description:
* Removes the check that Parry is equipped before applying the weapon evade bonus.
* Weapon evade is doubled if Parry is equipped.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a4a60
             beql v1,zero,VALID_CHECK      #Branch if Parry not equipped (likely)
             addu t9,zero,zero             #t9 = 0 (Parry not equipped) ^
             addiu t9,zero,0x0001          #t9 = 1 (Else, Parry equipped)
VALID_CHECK: jal 0x088bdd80                #Check if Parry invalidated by status, etc.
             noop
             beql v0,zero,INIT             #Branch if Parry is valid (v0 = 0) (likely)
             addiu s0,zero,0x0001          #s0 = 1 (Save Parry valid) ^
             addu s0,zero,zero             #s0 = 0 (Else, save Parry not valid)
INIT:        addiu a0,zero,0x0064          #a0 = 100
             lui v1,0x092e
             sb a0,0x5c6b(v1)              #Base Hit Rate = 100
             sb zero,0x5c6d(v1)            #Accessory Evade = 0
             sb zero,0x5c6e(v1)            #Weapon Evade = 0
             sb zero,0x5c6f(v1)            #Shield Evade = 0
             noop*3
$-offset:088a4b50
     #beq zero,zero,0x088a4b84      #Vanilla: Jump past RH Shield section
     #sb v1,0x5c6e(v0)              #Vanilla: Store RH Equipment Evade (redundant) ^
      beq zero,zero,0x088a4b80      #New:     Tweak the jump to make room for one more line
      sllv v1,v1,t9                 #New:     Double RH weapon evasion if Parry equipped ^
$-offset:088a4bd8
     #beq zero,zero,0x088a4c0c      #Vanilla: Jump past LH Shield section
     #sb a0,0x5c6f(v1)              #Vanilla: Store LH Equipment Evade (redundant) ^
      beq zero,zero,0x088a4c08      #New:     Tweak the jump to make room for one more line
      sllv a0,a0,t9                 #New:     Double LH weapon evasion if Parry equipped ^
#-----------------------------------------------------------------------------------
$-name:HP Boost increase
$-uuid:hpboost-increase-tzepish
$-description:
* Allows easy tuning of the amount of bonus HP granted by HP Boost.
* Note the bonus affects unarmored HP.
$-overwrites:none
$-requires:none
$-define:
    #%new_max_hp,0x78          #Vanilla Default: 120%
     %new_max_hp,0xc8          #New Default:     200%
$-file:boot.bin
$-type:ram
$-offset:088c469c
      ori t1,zero,%new_max_hp       #t1 = New Max HP percent
      multu t1,v1
      mflo v1                       #v1 = MaxHP * New Percent
      addiu v1,v1,0x0063            #Round up
      ori t1,zero,0x0064            #t1 = Divisor (100)
      divu v1,t1
      mflo v1                       #v1 = Final MaxHP
#-----------------------------------------------------------------------------------
$-name:Replace MateriaBlade flag with AnyWeapon flag & Sword Skills now work with a Katana
$-uuid:weapon-sword-flags-tzepish
$-description:
* Replaces the MateriaBlade flag with AnyWeapon (not Unarmed). Dark Knight uses this in WOTL Tweak.
* Skills that require a Sword equipped (such as Agrias and Orlandeau special sword skills) can now be used with a Katana as well.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088c5514
       lhu s4,0x001a(s2)             #Load Equipment ID
       jal 0x08a18600                #v0 = Get Equipment Data Address for a0
       addu a0,s4,zero               #a0 = Equipment ID ^
       lbu v1,0x0005(v0)             #v1 = Item type
       lbu v0,0x01a8(s5)             #v0 = Load Equipment Flags
       beq v1,zero,END               #Branch to END if item type is 0 (nothing)
       addiu at,zero,0x0003          #Check Sword
       beq v1,at,SWORD               #Branch to SWORD if item type is Sword (Sword Equipped)
       addiu at,zero,0x0004          #Check Knight Sword
       beq v1,at,SWORD               #Branch to SWORD if item type is Knight Sword (Sword Equipped)
       addiu at,zero,0x0005          #Check Katana
       beq v1,at,SWORD               #Branch to SWORD if item type is Katana (Sword Equipped)
       addiu at,zero,0x0023          #Check Fell Sword
       beq v1,at,SWORD               #Branch to SWORD if item type is Fell Sword (Sword Equipped)
       slti at,v1,0x0013             #Set if item type is less than 13 (Shield) (in other words, is it a weapon)
       beql at,zero,END              #Branch to END if NOT a weapon
       noop
       j END                         #Else, jump to the end with the weapon flag.
       ori v0,v0,0x0004              #Add Weapon Equipped Flag (but not Sword Equipped) ^
SWORD: ori v0,v0,0x000c              #Add both Weapon Equipped and Sword Equipped Flags
END:   sb v0,0x01a8(s5)              #Store Equipment Flags
       noop*4
#-----------------------------------------------------------------------------------
$-name:Revised Nether Mantra hits table
$-uuid:nether-mantra-hits-tzepish
$-description:
* Modifies the probability table for the number of hits Nether Mantra will do.
* It might also mess with Rapha and Holy Breath in vanilla, but they arent affected in WOTL Tweak because of other changes.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:file
$-offset:277244 #0x08a7b1f0
      05000000            #Chance for 4 hits, 3 hits, 2 hits, 1 hit
      03143214            #Chance for 8 hits, 7 hits, 6 hits, 5 hit
      00000101            #Always start with 0000. Chance for 10 hits, 9 hits
#-----------------------------------------------------------------------------------
$-name:Nether Mantra Faith/Atheist Swap Bugfix
$-uuid:nether-mantra-faith-tzepish
$-description:
* Fixes the bug that causes Faith and Atheism to NOT properly reverse when used with Nether Mantra.
* Nether Mantra is supposed to deal MORE damage to lower Faith targets, not less.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088ad8c4
     #andi a0,a0,0x0080             #Vanilla: Attacker Faith   = max damage
      andi a0,a0,0x0040             #New:     Attacker Atheist = max damage
$-offset:088ad8dc
     #andi a0,a0,0x0040             #Vanilla: Attacker Atheist = min damage
      andi a0,a0,0x0080             #New:     Attacker Faith   = min damage
$-offset:088ad904
     #andi a0,a0,0x0080             #Vanilla: Target Faith   = max damage
      andi a0,a0,0x0040             #New:     Target Atheist = max damage
$-offset:088ad91c
     #andi a0,a0,0x0040             #Vanilla: Target Atheist = min damage
      andi a0,a0,0x0080             #New:     Target Faith   = min damage
#-----------------------------------------------------------------------------------
$-name:Marach reverses Faith calculations for ALL magic when casting
$-uuid:marach-faith-reversal-tzepish
$-description:
* Reverses the Faith calculation for Marach when casting ANY magic (a new feature for WOTL Tweak).
* Does NOT change Magic Guns (since these have their own changes in WOTL Tweak) or Nether Mantra (which already does this).
$-overwrites:none
$-requires:none
$-define:
     %reverse_id,0x1a            #Marach = 1a (character ID that reverses Faith calculation)
$-file:boot.bin
$-type:ram
$-offset:088ac788                  #New Reversal Check
@Reversal:
         lui v0,0x092e
         lw a0,0x5c44(v0)                  #Load Attacker Data
         lbu a0,0x0000(a0)                 #Load Attacker Character ID
         addiu at,zero,%reverse_id         #Reversal character (Marach)
         bne a0,at,DONE                    #Branch to end if NOT the reversal character
         addiu at,zero,0x0064              #at = 100
         lbu a0,0x5c61(v0)                 #Load Attacker Effective Faith
         subu a0,at,a0                     #100 - Attacker Effective Faith
         sb a0,0x5c61(v0)                  #Store Attacker Effective Faith
         lbu a0,0x5c60(v0)                 #Load Target Effective Faith
         subu a0,at,a0                     #100 - Target Effective Faith
         sb a0,0x5c60(v0)                  #Store Target Effective Faith
DONE:    jr ra
         lui a0,0x092e                     #(For compatibility with downstream code)
$-offset:088a7f34                   #Update Formula 0b (Helpful Status)
         jal @Reversal                    #Check for Faith Reversal
         noop                             #(Push existing code down a line)
         lw a2,0x5c10(v0)                 #Load Current Action Data
$-offset:088a81c4                   #Update Formula 14 (Golem)
         jal @Reversal                    #Check for Faith Reversal
         noop                             #(Push existing code down a line)
         lw a1,0x5c10(v0)                 #Load Current Action Data
$-offset:088a8a3c                   #Update Calculate Magical Hit Rate
         jal @Reversal                    #Check for Faith Reversal
         noop                             #(Push existing code down a line)
         lw a2,0x5c10(v0)                 #Load Current Action Data
$-offset:088a8e3c                   #Update Formula 0a (Inflict Status)
         jal @Reversal                    #Check for Faith Reversal
         noop                             #(Push existing code down a line)
         lw a2,0x5c10(v0)                 #Load Current Action Data
$-offset:088aa6dc                   #Update Formula 08 (Attack Magic)
         jal @Reversal                    #Check for Faith Reversal
         noop                             #(Push existing code down a line)
         lbu a2,0x5c60(a0)                #Load Target Effective Faith
         lh a3,0x0006(v1)                 #Load current action HP damage
$-offset:088ab18c                   #Update Formula 0c (Healing Magic)
         jal @Reversal                    #Check for Faith Reversal
         lui v1,0x092e                    #(Push existing code down a line)
         lw a3,0x5c10(v1)                 #Load Current Action Data
$-offset:088ab894                   #Update Formula 0e (Death)
         jal @Reversal                    #Check for Faith Reversal
         lui v1,0x092e                    #(Push existing code down a line)
         lw a3,0x5c10(v1)                 #Load Current Action Data
$-offset:088acc1c                   #Update Formula 14 (Golem)
         jal @Reversal                    #Check for Faith Reversal
         lui v1,0x092e                    #(Push existing code down a line)
         lw a3,0x5c10(v1)                 #Load Current Action Data
#-----------------------------------------------------------------------------------
$-name:New Luso and Balthier skills cause hitreact animations
$-uuid:luso-balthier-hitreact-tzepish
$-description:
* In WOTL Tweak, Luso and Balthier have new skills that are similar to Mustadios Aimed Shot skills.
* This code makes these skill IDs inflict a hit reaction animation on the victim when hit (just liked the Aimed Shots do).
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:0884e7bc
      slti v1,a0,0x0166                 #Barrage
      bne v1,zero,0x0884e7d4            #Branch if ability used is less than Barrage
      noop
      slti at,a0,0x0160                 #Potion
      bne at,zero,0x0884e81c            #Do hitreact if ability used is Barrage, Frog Attack, or anything in between.
#-----------------------------------------------------------------------------------
$-name:Dragons Gift works on non-dragons and heals double on dragons
$-uuid:dragons-gift-tzepish
$-description:
* Reis can now use Dragons Gift on non-dragons.
* Using it on a dragon results in double the healing.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088b31e0
      addiu v1,zero,0x000f          #Check Dragon
      beql a0,v1,0x088b3220         #Branch if Dragon (likely)
      addiu t9,zero,0x0002          #Dragon will gain quadruple damage as HP ^
      addiu v1,zero,0x0010          #Check Hydra
      beql a0,v1,0x088b3220         #Branch if Hydra (likely)
      addiu t9,zero,0x0002          #Hydra will gain quadruple damage as HP ^
      addiu t9,zero,0x0001          #Everything else gets double damage as HP
      noop*9                        #Blank code thats no longer used
$-offset:088b32a8
     #sll a2,a2,0x01                #Vanilla: Double damage as healing on target
      sllv a2,a2,t9                 #New: Quadruple if dragon, double otherwise
#-----------------------------------------------------------------------------------
$-name:Dragons Might works on non-dragons and buffs double on dragons
$-uuid:dragons-might-tzepish
$-description:
* Reis can now use Dragons Might on non-dragons.
* Using it on a dragon results in double the buffs.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088b334c
      addiu v1,zero,0x000f          #Check Dragon
      beql a0,v1,0x088b338c         #Branch if Dragon (likely)
      addiu t9,zero,0x0001          #Dragon will gain double buffs ^
      addiu v1,zero,0x0010          #Check Hydra
      beql a0,v1,0x088b338c         #Branch if Hydra (likely)
      addiu t9,zero,0x0001          #Hydra will gain double buffs ^
      addiu t9,zero,0x0000          #Everything else gets normal buffs
      noop*9                        #Blank code thats no longer used
$-offset:088b33a0
      lui a0,0x092e                 #Use a0 instead of v1 to save space
      lbu a1,0x5c88(a0)             #Get X (to be used as Brave buff)
      sllv a1,a1,t9                 #Double X (Brave buff) if dragon
$-offset:088b33b4
      lbu a1,0x5c89(a0)             #Get Y (to be used as the rest of the stat buffs)
      sllv a1,a1,t9                 #Double Y (Stat buffs) if dragon
      lw a0,0x5c10(a0)              #Use a0 instead of v1 to save space
#-----------------------------------------------------------------------------------
$-name:Dragons Quickness works on non-dragons with a fail chance
$-uuid:dragons-quick-tzepish
$-description:
* Reis can now use Dragons Quickness on non-dragons.
* Using it on a non-dragon gives it a fail chance.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088b3424
      j 0x088ac000                  #Jump to formula 12 (Quick) if not a dragon
      noop*9                        #Blank code thats no longer used
#-----------------------------------------------------------------------------------
$-name:Dragons Charm works on non-dragons with a fail chance
$-uuid:dragons-charm-tzepish
$-description:
* Reis can now use Dragons Charm on non-dragons.
* Using it on a non-dragon gives it a fail chance.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088b316c
      jal 0x088aeb80                #Jump to formula 2A (Entice) if not a dragon
      noop*9                        #Blank code thats no longer used
#-----------------------------------------------------------------------------------
$-name:Barrage works with Dual Wield and Doublehand
$-uuid:barrage-dualwield-doublehand-tzepish
$-description:
* Using Barrage with Dual Wield will cause 8 hits.
* Using Barrage with Doublehand will honor the damage bonus.
* Opens up more builds for Balthier.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088b51c8                   #Barrage Section 1 (hands)
       beql v1,v0,0x088b52dc             #Branch to Doublehand check if using Barrage
       addiu s2,zero,0x006a              #Formula = 6a
$-offset:088b52d8                   #Doublehand Section
       lbu s2,0x0002(s0)                 #Load used weapon formula (only if not Barrage)
       lui v0,0x092e
       lbu v0,0x5c8e(v0)                 #Load weapon characteristics
       andi v0,v0,0x0004                 #Two hands allowed?
       beq v0,zero,0x088b537c            #Branch if not
$-offset:088d3968                   #Barrage Section 2 (number of hits)
       lui v1,0x092e
       addiu a0,zero,0x0004              #a0 = 4
       sb a0,0x5c4e(v1)                  #Store number of hits = 4
       beq zero,zero,0x088d39e8          #Jump to Dual Wield check
       lbu s0,0x009b(s3)                  #s0 = Load acting unit Support Abilities 3 ^
$-offset:088d3a4c                   #Dual Wield Section
       lui v1,0x092e
       lbu a0,0x5c4e(v1)                 #Load number of hits
       sll a0,a0,0x01                    #Double the number of hits (instead of setting to 2)
$-offset:088b4eec                   #Determine if we should alternate hands 1
       addiu at,zero,0x0004              #Check if number of hits is exactly 4 (Barrage hack - not enough room to check for Dual Wield legit)
       bne at,v0,0x088b4f04              #Branch if number of hits is anything but 4 (allow alternating hands)
$-offset:088b4f08                   #Alternate hands 1
       lbu v0,0x5c4f(v0)                 #Load strike counter
       andi at,v0,0x0001                 #Set if odd number
       bne at,zero,0x088b4f20            #Branch if number of strikes so far is an odd number (use secondary weapon)
$-offset:088b4ad4                   #Determine if we should alternate hands 2
       addiu at,zero,0x0004              #Check if number of hits is exactly 4 (Barrage hack - not enough room to check for Dual Wield legit)
       bne at,v0,0x088b4aec              #Branch if number of hits is anything but 4 (allow alternating hands)
$-offset:088b4aec                   #Alternate hands 2
       lbu v0,0x5c4f(v0)                 #Load strike counter
       andi at,v0,0x0001                 #Set if odd number
       bne at,zero,0x088b4b04            #Branch if number of strikes so far is an odd number (use secondary weapon)
$-offset:088b4c7c                   #Determine if we should alternate hands 3
       addiu at,zero,0x0004              #Check if number of hits is exactly 4 (Barrage hack - not enough room to check for Dual Wield legit)
       bne at,v0,0x088b4c94              #Branch if number of hits is anything but 4 (allow alternating hands)
$-offset:088b4c94                   #Alternate hands 3
       lbu v0,0x5c4f(v0)                 #Load strike counter
       andi at,v0,0x0001                 #Set if odd number
       bne at,zero,0x088b4cac            #Branch if number of strikes so far is an odd number (use secondary weapon)
#-----------------------------------------------------------------------------------
$-name:Prevent Knockback if there are attacks remaining
$-uuid:multiattacks-prevent-knockback-tzepish
$-description:
* This hack prevents knocking the target back unless its the last hit of a combo.
* In other words, you will not knock the target back on the first hit of Dual Wield and whiff the second hit.
* Especially useful with Barrage.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088a3e18               #Rewrite the beginning of Knockback Calculation for space
        lbu a2,0x5c4e(v1)                 #Load number of hits
        lbu a1,0x5c4f(v1)                 #Load strike counter
        addiu a1,a1,0x0001                #Add 1 to represent the current hit
        bne a1,a2,0x088a4020              #Branch to end if not the last hit (no knockback)
        lbu a0,0x5c7b(v1)                 #Load Current Ability Target counter
        addiu a1,zero,0x0001              #One (number of targets)
        bne a0,a1,0x088a4020              #Branch to end if there are multiple targets (no knockback)
        lw a2,0x5c48(v1)                  #Load Target Data
        lbu a0,0x0005(a2)                 #Load Target ENTD Flags
        andi a1,a0,0x0004                 #Immortal (entd)
        bne a1,zero,0x088a4020            #Branch to end if target is immortal (no knockback)
        lw a1,0x5c44(v1)                  #Load Attacker Data
        beq a2,a1,0x088a4020              #Branch to end if the attacker is the target (no knockback)
        lbu at,0x01a6(a2)                 #Load Mount Data
        bne at,zero,0x088a4020            #Branch to end if the target is mounted (no knockback)
        andi a0,a0,0x0003                 #Flags 1 and 2 (entd) (Ramza)
        addiu v1,zero,0x0003              #Flags 1 and 2 (entd) (Ramza)
        beq a0,v1,0x088a4020              #Branch to end if target is Ramza (no knockback)
        noop*3
#-----------------------------------------------------------------------------------
$-name:Special characters can go on Errands + Mustadio not needed for sidequests
$-uuid:errands-special-characters-tzepish
$-description:
* Allows special characters (except Guests and Ramza) to go on Errands.
* Also allows sidequest scenes to proceed even without Mustadio (unless he is on an errand).
* In WOTL Tweak, Chronicle text has been updated so if Mustadio dies, he is not really dead (just injured).
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08a1cfc0               #New location for Errand character filtering
        noop*12                       #Blank out all the special character filtering code
        slti v0,a0,0x0004             #Disallow if Ramza, allow otherwise
$-offset:088f251c               #World Conditional - rearrange to check for Errands first
        lbu v1,0x0000(v0)             #Load current party member Unit ID
        beq v1,s0,ERRAND              #Branch if Unit ID is the required Unit ID
        lbu v1,0x00ec(v0)             #Load current party member data Name ID (in case Unit ID isnt a match)
        bne v1,s0,0x088f2560          #Branch if Name ID does not equal the required Unit ID (move on to next character)
ERRAND: lbu v1,0x00ee(v0)             #Load current party member Proposition byte
        bne v1,zero,0x088f2588        #Branch if on an Errand (fail the condition - required character isnt available)
        lbu v1,0x00ed(v0)             #Load current party member data 00ed (whatever this is)
        bne v1,zero,0x088f2560        #Branch if data 00ed is not zero (move on to next character)
        lbu a0,0x0002(v0)             #Load current party member data Job ID
        addiu v1,zero,0x0082          #v1 = 0x0082 (Malboro) (if the character was transformed into a Malboro)
        bne a0,v1,0x088f2570          #Branch if Job is not Malboro (success)
        noop*5
$-offset:088f2580               #End of World Conditional - Create Mustadio exception
        addiu v1,zero,0x0016          #v1 = 0x0016 (Mustadio)
        beq v1,s0,0x088f2598          #Branch if the desired unit is Mustadio (allow scene to proceed even if Mustadio is dismissed or "dead")
        lui v1,0x0935                 #(Shift existing code downward)
        lw a0,0xd8ac(v1)
#-----------------------------------------------------------------------------------
$-name:Can rename human characters in the Warriors Guild
$-uuid:warriors-guild-rename-tzepish
$-description:
* Can rename humans (as well as monsters) in the Warriors Guild.
* Special character renames will not be reflected in story dialogue, but will show in all gameplay text.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:0898c27c                       #Rename screen filtering
           #bne v0,zero,0x0898c2d4        #Vanilla: Filter out of Renaming view if not a monster
            bne v0,zero,0x0898c10c        #New:     Do additional checks if not a monster
$-offset:0898c10c                       #Additional checks for Rename screen filtering
            lbu v1,0x0072(s2)             #v1 = Current Unit base class (Formation Screen Data)
            addiu at,zero,0x0080          #Check for generic male
            beq at,v1,0x0898c284          #Allow rename if its a generic male
            addiu at,zero,0x0081          #Check for generic female
            beq at,v1,0x0898c284          #Allow rename if its a generic female
            beq v1,zero,0x0898c2d4        #Disallow rename if character has a blank class (seems prudent)
            slti at,v1,0x0004             #Check for Ramza (less than class 04)
            bne at,zero,0x0898c284        #Allow rename if its Ramza
            noop
           #j 0x0898c2d4    #Comment the below line and uncomment this one to disallow special character renaming
            j 0x0898c284    #Comment the above line and uncomment this one to allow special character renaming
            noop
#-----------------------------------------------------------------------------------
$-name:Improved human character base stats - gender equality & removed randomization
$-uuid:base-stats-improvement-tzepish
$-description:
* Gender equality - male and female characters now have the same stats.
* Ramza stats further increased so that he is still special after gender equality.
* HP/MP randomization removed for human characters - instead, maximum result is added to base stats.
* Note the female starting Dagger is changed to Oak Staff because WOTL Tweak repurposes these stats for male AND female starting Mages (see the next hack below)
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08a751dc
         05061020        #Male pre-raw stats        #PA = 5,               Speed = 6,             MP = 16 (was 14),      HP = 32 (was 30)
         ffba9d05                                   #Accessory = none,     Body = ba,             Head = 9d,             MA = 5 (was 4)
         ffffff13                                   #LShield = none,       LWeapon = none,        RShield = none,        RWeapon = 13
         05061020        #Female pre-raw stats      #PA = 5 (was 4),       Speed = 6,             MP = 16 (was 15),      HP = 32 (was 28)
         ffba9d05                                   #Accessory = none,     Body = ba,             Head = 9d,             MA = 5
         ffffff3b                                   #LShield = none,       LWeapon = none,        RShield = none,        RWeapon = 3b (was 01)
         06061122        #Ramza pre-raw stats       #PA = 6 (was 5),       Speed = 6,             MP = 17 (was 15),      HP = 34 (was 30)
         d0ba9d06                                   #Accessory = d0,       Body = ba,             Head = 9d,             MA = 6 (was 5)
         ffffff13                                   #LShield = none,       LWeapon = none,        RShield = none,        RWeapon = 13
         05050823        #Monster pre-raw stats     #PA = 5,               Speed = 5,             MP = 8,                HP = 35
         ffffff05                                   #Accessory = none,     Body = none,           Head = none,           MA = 5
         ffffffff                                   #LShield = none,       LWeapon = none,        RShield = none,        RWeapon = none
         00000000        #Stat variance             #Male_PA = 0,          Male_Speed = 0,        Male_MP = 0 (was 1),   Male_HP = 0 (was 2)
         00000000        #Stat variance             #Female_Speed = 0,     Female_MP = 0 (was 1), Female_HP = 0 (was 2), Male_MA = 0
         00000000        #Stat variance             #Ramza_MP = 0 (was 1), Ramza_HP = 0 (was 2),  Female_MA = 0,         Female_PA = 0
         03000000        #Stat variance             #Monster_HP = 3,       Ramza_MA = 0,          Ramza_PA = 0,          Ramza_Speed = 0
         01010001        #Stat variance             #Monster_MA = 1,       Monster_PA = 1,        Monster_Speed = 0,     Monster_MP = 1
#-----------------------------------------------------------------------------------
$-name:Warriors Guild and Initial Ramza Improvement
$-uuid:warrior-guild-ramza-improvement-tzepish
$-description:
* Choose between Fighter or Mage (instead of male or female). Requires corresponding text changes.
* This change goes hand in hand with the gender equality changes in WOTL Tweak. Gender is now randomized in order to reduce the perception that there is a meaningful difference.
* Warrior types start at level 2 Squire, Mage types start at level 2 Chemist. Ramza gets both.
* Ramza now starts a New Game with a few extra skills unlocked.
* This is just to give a slight boost in the beginning, which needs it, but also because WOTL Tweak rearranges his ability list, so a change needed to happen here regardless (otherwise Ramzas initial Chant becomes an initial Tailwind).
* Ramza and new hires start with a bit more JP in every job.
* New hires start with Rush, Potion, and Phoenix Down.
$-overwrites:none
$-requires:base-stats-improvement-tzepish
$-file:boot.bin
$-type:ram
$-offset:088c20f8
          #jal 0x088c2200                    #Vanilla start location
           jal 0x088c21dc                    #New start location (gives us a bit more room)
$-offset:088c21dc
           addiu sp,sp,0xffd0
           sw ra,0x002c(sp)
           sw fp,0x0028(sp)
           sw s7,0x0024(sp)
           sw s6,0x0020(sp)
           sw s5,0x001c(sp)
           sw s4,0x0018(sp)
           sw s3,0x0014(sp)
           sw s2,0x0010(sp)
           sw s1,0x000c(sp)
           sw s0,0x0008(sp)
           addu s4,a1,zero                   #s4 = Menu selection (0 = fighter, 1 = mage)
           sb zero,0x00f1(a0)
           addu s5,a0,zero
           jal 0x088b9d40                    #RandomResult -> v0 (for job 1 or 2)
           addu t9,zero,zero                 #Initialize t9 to 0 to be super safe
           slti v0,v0,0x4000                 #50%
           beq s4,zero,FIGHTER               #Branch if we are making a Fighter
           addiu v1,zero,0x0001              #v1 = 1 (Mage)
           beq s4,v1,MAGE                    #Branch if we are making a Mage
           addiu v1,zero,0x0003              #v1 = 3 (Monster)
           beq s4,v1,MONSTER                 #Branch if we are making a Monster
RAMZA:     addiu v0,zero,0x0001              #v0 = 1 (Ramza)
           addiu s4,zero,0x0002              #s4 = 2 (Ramza)
           sb v0,0x0002(s5)                  #Store job = 01 (Squire Ramza)
           addiu a0,zero,0x0080              #Unlocked jobs 1-8 = Squire, Chemist
           addiu v1,zero,0x0080              #Gender = Male
           sb v1,0x0004(s5)                  #Store gender
           addiu s7,zero,0x4000              #Name Flags = 0x4000 (special names)
           j GEN_DONE                        #Proceed to Gender Done
           addu fp,zero,zero                 #Name Modifier = 0x0000 (Ramza)
FIGHTER:   beql v0,zero,JOB_DONE             #Branch if random result was low
           addiu t9,zero,0x004c              #Job = Knight (4c) if so
           addiu t9,zero,0x004d              #Job = Archer (4d) if not
           j JOB_DONE                        #Proceed to Job Done
           addiu t8,zero,0x004d              #Override weapon to Bowgun if Archer
MAGE:      beql v0,zero,JOB_DONE             #Branch if random result was low
           addiu t9,zero,0x004f              #Job = White Mage (4f) if so
           addiu t9,zero,0x0050              #Job = Black Mage (50) if not
           addiu t8,zero,0x0033              #Override weapon to Wooden Rod for Black Mage
JOB_DONE:  jal 0x088b9d40                    #RandomResult -> v0 (for male or female)
           sb t9,0x0002(s5)                  #Store job
           slti v0,v0,0x4000                 #50%
           beq v0,zero,GEN_MALE              #Branch to Male if random result was low
GEN_FEM:   addiu v0,zero,0x0081              #Sprite Set = Generic Female
           addiu v1,zero,0x0040              #Gender = Female
           addiu s7,zero,0x4200              #Name Flags = 0x4200 (female)
           j GEN_DONE                        #Proceed to Gender Done
           addiu fp,zero,0x0200              #Name Modifier = 0x0200 (female)
GEN_MALE:  addiu v0,zero,0x0080              #Sprite Set = Generic Male
           addiu v1,zero,0x0080              #Gender = Male
           addiu s7,zero,0x4100              #Name Flags = 0x4100 (male)
           j GEN_DONE                        #Proceed to Gender Done
           addiu fp,zero,0x0100              #Name Modifier = 0x0100 (male) ^
MONSTER:   addiu v0,zero,0x0082              #Sprite Set = Generic Monster
           addiu v1,zero,0x0020              #Gender = Monster
           addiu s7,zero,0x4300              #Name Flags = 0x4300 (monster)
           addiu fp,zero,0x0300              #Name Modifier = 0x0300 (monster)
           addu t8,zero,zero                 #No override weapon for monsters
GEN_DONE:  sb v0,0x0000(s5)                  #Store sprite set
           sb v1,0x0004(s5)                  #Store gender
$-offset:088c24cc
           sll v1,v0,0x02                    #Random * 4
           bgez v1,POS                       #Branch if result is positive
           sll v1,v1,0x04                    #Random * 64 (we do this in 2 lines because there are branch shenanigans above)
           addiu v1,v1,0x7fff                #Make result positive
POS:       sra v0,v1,0x0f                    #rand(0..63)
           addiu v0,v0,0x0088                #Starting JP for all jobs = 136 + rand(0..63) (a bit more JP)
           sb v0,0x00ae(s2)                  #Store Total JP for current job
           sb v0,0x0080(s2)                  #Store Current JP for current job
           noop*4
$-offset:088c26e0
           addiu v1,zero,0x00fa          #v1 = 3 (Monster)
           beq s4,s3,DONE                #Skip all the below crap if we are making a monster
           sb zero,0x00f0(s5)            #I dunno what this is, but its probably necessary
           addiu at,zero,0x0004          #at = 04 (sixth ability in list)
           sb at,0x0036(s5)              #Store Chemist abilities known 2 (unlock Phoenix Down)
           addiu at,zero,0x0080          #at = 80 (first ability in list)
           sb at,0x0032(s5)              #Store Squire abilities known 1 (unlock Rush)
           sb at,0x0035(s5)              #Store Chemist abilities known 1 (unlock Potion)
           beq s4,zero,FIG               #Branch if creating a fighter
           addiu v1,zero,0x00fa          #250 Total JP (for prerequisite classes)
MAG:       sb v1,0x00b0(s5)              #Store Chemist Total prereq JP for mages and Ramza
           sb at,0x0045(s5)              #Store Black Mage abilities known 2 (unlock Blizzard) for mages and Ramza
           addiu at,zero,0x0088          #at = 88 (first and fifth abilities in list)
           sb at,0x0044(s5)              #Store Black Mage abilities known 1 (unlock Fire and Thunder) for mages and Ramza
           addiu at,zero,0x0084          #at = 84 (first and sixth abilities in list)
           sb at,0x0041(s5)              #Store White Mage abilities known 1 (unlock Cure and Raise) for mages and Ramza
           addiu at,zero,0x0001          #Mage
           beq s4,at,WEAPON              #Branch if creating a mage
           addiu at,zero,0x0080          #at = 80 (first ability in list)
FIG:       sb v1,0x00ae(s5)              #Store Squire Total prereq JP for fighters and Ramza
           sb at,0x003b(s5)              #Store Archer abilities known 1 (unlock Aim+1) for fighters and Ramza
           addiu v1,zero,0x0002          #Ramza
           bne s4,v1,ARMOR               #Branch if not Ramza
RAM:       addiu at,zero,0x00a4          #at = a4 (Rush, Chant, & Tailwind - based on new order in FFTPatcher)
           j DONE
           sb at,0x0032(s5)              #Store Squire abilities known 1 for Ramza
ARMOR:     addiu at,zero,0x004c          #Knight
           bne at,t9,WEAPON              #Branch if not creating a Knight
           addiu at,zero,0x0090          #Leather Helm
           sh at,0x000e(s5)              #Override starting head slot to Leather Helm
           addiu at,zero,0x00ac          #Leather Armor
           j DONE
           sh at,0x0010(s5)              #Override starting body slot to Leather Armor
WEAPON:    addiu at,zero,0x004f          #White Mage
           bnel at,t9,DONE               #Branch if not creating a White Mage
           sh t8,0x0014(s5)               #Override starting weapon if Archer or Black Mage ^
DONE:      j 0x088c218c                  #Jump to new ending location
           noop*2
$-offset:088c218c                   #Move the ending to some nearby free space to create even more room
           lw ra,0x002c(sp)
           lw fp,0x0028(sp)
           lw s7,0x0024(sp)
           lw s6,0x0020(sp)
           lw s5,0x001c(sp)
           lw s4,0x0018(sp)
           lw s3,0x0014(sp)
           lw s2,0x0010(sp)
           lw s1,0x000c(sp)
           lw s0,0x0008(sp)
           jr ra
           addiu sp,sp,0x0030
           noop
$-offset:088c277c               #Move this section down to create space
           addiu a0,a0,0x0020
$-offset:088c2408               #Point to new location
           jal 0x088c277c
$-offset:08971a60
           addiu v0,zero,0x05dc      #Update display price for female recruit (now used for mages). Actual price is calculated from equipment.
#-----------------------------------------------------------------------------------
$-name:Player team characters always crystalize (never treasurize) on death
$-uuid:player-always-crystal-tzepish
$-description:
* Causes player units to always crystalize, never treasurize, when they die.
* Note that items are refunded when a unit crystalizes, but not when they treasurize, so this ensures you cannot lose important items for good via death.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088c0184
      bnel v0,zero,0x088c01a0       #Branch if player unit (likely)
      addiu v0,zero,0x0040           #v0 = 40 (Crystalize, not treasurize) ^
      addiu v0,zero,0x0010          #Else, 50% chance
#-----------------------------------------------------------------------------------
$-name:ENTD Load Formation backup
$-uuid:entd-loadformation-backup-tzepish
$-description:
* If an ENTD character has Load Formation checked, but that character is not in the party, then it will no longer create a glitchy blank character.
* First, it will try to load a backup character ID specified in Unknown 2. For example, if the character is Mustadio 16 and has 22 in its Unknown 2 field, it will attempt to load 22 if it doesnt find 16.
* Failing that, it will simply create the character on the spot based on its parameters in ENTD, as if Load Formation were not checked after all.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088c340c
      addu t0,zero,zero                  #t0 = 0 ^
      beql t0,zero,0x088c350c           #Branch ahead if unit exists in the party and has Load Formation
      addu t0,zero,zero                  #t0 = 0 ^
      and s3,s3,t0                      #Remove Load Formation flag from s3
      sb s3,0x0001(s0)                  #Store s3 = ENTD gender byte (remove Load Formation flag)
     #(The Ramza stuff below is rewritten just to shift it down - its not part of the hack)
      lbu v1,0x0000(s0)                 #Load ENTD Unit sprite set
      slti at,v1,0x0004
      beq at,zero,0x088c350c            #Branch if unit is not Ramza
      lbu v1,0x0004(s0)                 #Load ENTD birth month
      bne v1,zero,0x088c350c            #Branch if birth month is not = 0 (Ramza initialization)
$-offset:088c3400
      beq v1,zero,0x088c3420            #Gotta redirect a branch
$-offset:088c39a4
      beql a1,v0,0x088c3a0c             #Branch to backup check if unit not found in the party
      lbu t2,0x0027(s0)                  #Load ENTD Unit Unknown 2 (using here for backup ID) ^
$-offset:088c3a0c                   #Backup ID check
      beql t2,zero,0x088c39f4           #If t2 = 0, then there is no backup. Time to bail
      addiu t0,zero,0xf7                 #t0 = not 8 (not Load Formation) (thus, we will use ENTD settings to create the character) ^
      sb zero,0x0027(s0)                #Set ENTD Unit Unknown 2 back to zero so we dont loop endlessly
      addu a0,t2,zero                   #Next time compare to t2 instead of ENTD sprite
      j 0x088c395c                      #Loop again!
      addu a1,s0,zero                   #a1 = ENTD Data Pointer
#-----------------------------------------------------------------------------------
$-name:ENTD Load Formation backup transform
$-uuid:entd-loadformation-transform-tzepish
$-description:
* If an ENTD character used the backup ID (see Load Formation backup, above), then we transform that character into the original desired ID afterward. For example, if ENTD wants Mustadio 16 with a backup of 22, and the player had Mustadio 22, it will transform their Mustadio 22 into Mustadio 16.
* This makes the WOTL Tweak Agrias/Mustadio/Rapha ID swaps completely invisible to the user under the hood. It "just works".
* If the "Guest" version of the special job skillset is assigned to the secondary slot, this code will swap it to the real version.
$-overwrites:none
$-requires:entd-loadformation-backup-tzepish
$-file:boot.bin
$-type:ram
$-offset:088c39c8
      j 0x088c5110                      #Jump into new Transformation code
      noop
      lbu a0,0x0001(s0)                 #Load ENTD Gender
$-offset:088c5110               #New Transform code (also handles straggler secondary skillsets)
      lbu a0,0x0000(s1)                 #a0 = Load Unit sprite set (old sprite set)
      lbu t2,0x0000(s0)                 #t2 = Load ENTD Unit sprite set (new sprite set)
      beq a0,t2,DONE                    #Branch out of Transform code if they are the same (no transform necessary)
      noop
      sb t2,0x0000(s1)                  #Change Unit Spriteset to ENTD value
      lbu at,0x0003(s1)                 #Load Unit Current Job
      beql a0,at,SKL                    #Branch if current job = the old job
       sb t2,0x0003(s1)                  #Set current job = new job ^
SKL:  sll at,a0,0x03                    #at = Old JobID*8
      subu a0,at,a0                     #a0 = Old JobID*7
      sll at,a0,0x03                    #at = Old JobID*56
      subu a0,at,a0                     #a0 = Old JobID*49
      lui at,0x08a8
      lw at,0xb148(at)                  #at = Job data pointer (08a8b148)
      addu at,at,a0                     #at = Old JobID*49 + Job data pointer = Old job data pointer
      lbu a0,0x0000(at)                 #a0 = Old job skillset
      sll at,t2,0x03                    #at = New JobID*8
      subu t2,at,t2                     #t2 = New JobID*7
      sll at,t2,0x03                    #at = New JobID*56
      subu t2,at,t2                     #t2 = New JobID*49
      lui at,0x08a8
      lw at,0xb148(at)                  #at = Job data pointer (08a8b148)
      addu at,at,t2                     #at = New JobID*49 + Job data pointer = New job data pointer
      lbu t2,0x0000(at)                 #t2 = New job skillset
      sb t2,0x0184(s1)                  #Change Unit special skillset to new job skillset
PRI:  lbu at,0x0012(s1)                 #Load Unit Primary Skillset
      beql a0,at,SEC                   #Branch if old job skillset is equipped as Primary Skillset
       sb t2,0x0012(s1)                  #Set Unit Primary Skillset to new job skillset instead ^
SEC:  lbu at,0x0013(s1)                 #Load Unit Secondary Skillset
      beql a0,at,DONE                   #Branch if old job skillset is equipped as Secondary Skillset
       sb t2,0x0013(s1)                  #Set Unit Secondary Skillset to new job skillset instead ^
DONE: j 0x088c39d0                      #Jump back to where we belong
      noop
#-----------------------------------------------------------------------------------
$-name:Agrias/Mustadio/Rapha keep their stats
$-uuid:agrias-mustadio-rapha-tzepish
$-description:
* Modifies the formation screen to hide these characters if you are at the point of the story where they are gone temporarily.
* This is the exact same functionality that is already used for Reis when she gets kidnapped.
* The DismissUnit event commands need to be removed for these three. Then, this code takes over and simply hides them.
* Note: The functionality to hide Agrias and Rapha is commented out in order to make sure the player cannot screw themselves before the character rejoins in their "Protect Agrias/Rapha" battles. Uncomment the branch and comment the line after it if you want to hide them.
* Uses free space from battle-status-jobs-001 in default-cust-hacks.asm!
$-overwrites:battle-status-jobs-001
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:0898c190
      lbu t1,0x0000(v0)             #Get current character spriteset
      jal 0x089d75c0                #Do Check Event Flag (a0 = event flag, return v0)
      addiu a0,zero,0x006e           #Flag 0x6e (Story Progress) ^
      addiu v0,v0,0xffea            #Story Progress - 16 (check Agrias first)
      j 0x089a4efc                  #Jump to new character progress checker
      addiu at,zero,0x0034           #Check Agrias ^
      noop*2
$-offset:089a4efc
      beq t1,at,AGRI                #Branch if current character is Agrias
      addiu at,zero,0x0022          #Check Mustadio
      beq t1,at,MUST                #Branch if current character is Mustadio
      addiu at,zero,0x0019          #Check Rapha
      beq t1,at,RAPH                #Branch if current character is Rapha
      addiu at,zero,0x000f          #Check Reis
      bne t1,at,DONE                #Branch if current character is NOT Reis (we are done!)
      noop
REIS: jal 0x089d75c0                #Do Check Event Flag (a0 = event flag, return v0)
      addiu a0,zero,0x02f7           #Flag 2f7 (Flag - Reis Kidnapped) ^
      bne v0,zero,0x0898c2d4        #Branch if Reis is kidnapped (do not show her)
      noop
      j DONE                        #Else, show the character
AGRI: sltiu v0,v0,0x07              #Check if Story Progress is 16+ and before 1d
     #bne v0,zero,0x0898c2d4        #Branch if Agrias is with Draclau (do not show her)
      noop                          #Show her always (comment this line and uncomment the above if you want to hide her)
      noop
      j DONE                        #Else, show the character
MUST: addiu at,zero,0x0002          #Check if Story Progress = 18
      beq v0,at,0x0898c2d4          #Branch if Mustadio is in Goug (do not show him)
      noop
      j DONE                        #Else, show the character
RAPH: addiu at,zero,0x0012          #Check if Story Progress = 28
     #bne v0,at,DONE                #Branch if we are not at Riovanes Castle (show her)
      j DONE                        #Show her always (comment this line and uncomment the above if you want to hide her)
      noop
      jal 0x089d75c0                #Do Check Event Flag (a0 = event flag, return v0)
      addiu a0,zero,0x006f           #Flag 6f (Shop Availibility) (added to event script as a hack for this) ^
      addiu at,zero,0x000b          #Check if Shop Availability = 0b
      beq v0,at,0x0898c2d4          #Branch if Rapha left chasing after Marach (do not show her)
      noop
DONE: j 0x0898c1b0                  #Else, show the character
      noop*3
#-----------------------------------------------------------------------------------
$-name:ENTD Characters can have Fury, Magick Boost, Adrenaline, or Vanish assigned
$-uuid:entd-reactions-bugfix-tzepish
$-description:
* Fixes the bug that prevents Fury, Magick Boost, Adrenaline Rush, and Vanish (or Power Boost, Magick Boost, Speed Boost, and Vanish as they are known in WOTL Tweak) from being picked as Reaction abilities when ENTD characters are being created.
* Note that Vanish actually does something for the AI now in WOTL Tweak (improved evasion and critical hit chance)
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088c6544
     #addiu v0,zero,0x01a9          #Vanilla: First illegal Reaction Ability ID = Vanish (bug)
      addiu v0,zero,0x01a5          #New:     First illegal Reaction Ability ID = Fury - 1 (Fixed)
#-----------------------------------------------------------------------------------
$-name:Random Unit Equipment is more selective
$-uuid:random-equipment-bugfix-glain-tzepish
$-description:
* Random unit equipment will now be more selective of secondary item types.
* Units will now randomly choose among the best of each item type, not just the best of the first item type and ANY of the remaining item types.
* In other words, you will no longer see lategame Knights wearing earlygame robes and using earlygame axes.
* This ASM originally written by Glain. Ported to PSP by Tzepish.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088c5fe0
       bne at,zero,STORE                 #Branch if Previous Level <= Item Level (if next item is an upgrade)
       addu s6,v1,zero                   #Previous Level = Item Level
       addiu s3,s3,0x0001                #Increment List Index for next item type (not an upgrade, must be a new type)
STORE: andi v0,s3,0x00ff                 #v0 = Current List Index
       addu v0,v0,sp                     #Update memory address for storing next candidate item
       sb s5,0x0030(v0)                  #Store item ID at designated memory address
       noop*3
$-offset:088c6014
       addiu s0,s3,0x0001                #s0 = s3 + 1 (instead of just s3)
       bne s6,zero,0x088c6028            #Branch if at least one item was chosen (Previous Level not 0)
#-----------------------------------------------------------------------------------
$-name:ENTD Characters have extra job levels
$-uuid:entd-joblevels-tzepish
$-description:
* Adds +1 to each job level when backfilling ENTD character job prerequisites.
* For example, if White Mage requires Chemist 2, then making an AI White Mage will grant them Chemist 3 instead.
* Also changes the starting JP from JPRequired+rand(0..99) to JPRequired*1.25+rand(0..47).
* These changes make up for the fact that job prerequisites and JP requirements were reduced to the PS1 values in WOTL Tweak.
* They allow the AI to retain roughly the JP they had before that change, so that the prerequisite reductions dont result in reduced AI variety.
* If you tweak these values, be careful that the maximum result doesnt overflow into the next job level. 49 is currently the highest safe random value.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:088c3c2c
      bnel v1,zero,0x088c3cb8        #Branch if Job Unlocked is NOT Base (likely)
      addiu a0,a0,0xffff             #Subtract 1 from Job Unlocked level (this is a kludge, but seems to work) ^
      j 0x088c3cb8                   #Jump back
      noop
$-offset:088c3cb0
      lbu a0,0x0009(s0)              #Load ENTDs Job Level
      j 0x088c3c2c                   #Jump to new section above
$-offset:088c3d38
      beq v1,zero,0x088c3d48         #Branch if Job Unlocked = Base
      noop
      addiu v0,t0,0x0001             #Low Nybble Job Level + 1
$-offset:088c3d50
      beq v1,zero,0x088c3d60         #Branch if Job Unlocked = Base
      noop
      addiu v0,t0,0x0010             #High Nybble Job Level + 1
$-offset:088c4904
      sra v1,a0,0x02                 #JP Requirement / 4
      addu a0,v1,a0                  #JP Requirement * 1.25
      sll v1,v0,0x01                 #Random JP * 2
      addu v0,v1,v0                  #Random JP * 3
      sll v1,v0,0x04                 #Random JP * 48
$-offset:088c4a24
      sra v1,a0,0x02                 #JP Requirement / 4
      addu a0,v1,a0                  #JP Requirement * 1.25
      sll v1,v0,0x01                 #Random JP * 2
      addu v0,v1,v0                  #Random JP * 3
      sll v1,v0,0x04                 #Random JP * 48
#-----------------------------------------------------------------------------------
$-name:Display Earned JP/EXP only for player team
$-uuid:enemy-expjp-display-tzepish
$-description:
* Hides JP and EXP gain for enemies if the option to display them is on.
* Also hides enemy celebrations for job levels.
* These characters are gonna die anyway, so lets not waste the players time.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08848e48               #Display Earned JP/EXP section
       jal @Enemy_Check_Show         #Jump to new code below
       lw v1,0x01c0(a0)              #Load Display flags
       lui v0,0x0200                 #Show EXP (display flag)
       and v0,v1,v0
       beq v0,zero,0x08848ea4        #Branch if not displaying earned EXP
       addiu t0,a0,0x02c4
       lbu a1,0x01b6(a0)             #Load earned EXP
       sh a1,0x0004(t0)
       addiu v0,zero,0x0040
       sh v0,0x0002(t0)
       addiu v0,zero,0x0001
       sb v0,0x0000(t0)
$-offset:08849cd4
@Enemy_Check_Show:
       lbu v0,0x013e(a0)        #Load Unit modified ENTD flags
       andi v0,v0,0x30          #Result will be 0 if Player Team
       beq v0,zero,DONE         #Branch to DONE if player team
       lui v0,0xf9ff            #NOT Show EXP & NOT Show JP (display flags)
       ori v0,v0,0xffff
       and v1,v1,v0
       sw v1,0x01c0(a0)         #Update Display Flags to disable showing EXP and JP
DONE:  jr ra
       noop
$-offset:08866bac           #Celebration animation section
       j @Enemy_Check_JobLevel   #Jump to new code below
$-offset:08866a50
@Enemy_Check_JobLevel:
       beq v0,zero,0x08866cf4    #No celebration if there was no job levelup
       noop
       lbu at,0x013e(s0)         #Load Unit modified ENTD flags
       andi at,at,0x30           #Result will be 0 if Player Team
       bne at,zero,0x08866cf4    #No celebration if enemy team
       noop
       j 0x08866bb4              #Yes celebration if player team
       noop
#-----------------------------------------------------------------------------------
$-name:Skip the world map if the next story battle is triggered by leaving
$-uuid:fix-stuck-storybattles-tzepish
$-description:
* Changes spots in the campaign where your next story battle happens when you step OFF your current node.
* Now the preceding event will advance to the next one automatically instead of dumping you on the world map in between.
* Prevents the player getting "stuck" if they save inbetween and end up unable to leave to levelup.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08af30d0       #Event A5: Mustadio and Ramza arrive at Goug
     #00000000            #Vanilla: Next event = None
     #00000080            #Vanilla: When done  = Return to World Map
      00a60000            #New:     Next event = A6
      00000081            #New:     When done  = Go directly to next event
$-offset:08af3658       #Event E0: Ramza meets with Zalbaag at Lesalia
     #00000001            #Vanilla: Next event = None
     #00000080            #Vanilla: When done  = Return to World Map
      00e10001            #New:     Next event = E1
      00000081            #New:     When done  = Go directly to next event
#-----------------------------------------------------------------------------------
$-name:Better battle music for Luso and Balthier battles
$-uuid:luso-balthier-battlemusic-tzepish
$-description:
* Play the music from the Luso cutscene in the Luso battle to make it feel more urgent and less like a random battle.
* Play the music from the Balthier cutscene in the Balthier battle because its a better fit.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08af4f9c       #Event 20D: Protect Luso!
     #03000500            #Vanilla: Music = 05 (A Chapel)
      03004d00            #New:     Music = 4d (Battle on the Bridge)
$-offset:08af4ef4       #Event 20A: Balthier Battle
     #02000300            #Vanilla: Music = 03 (Back Fire)
      02004c00            #New:     Music = 4c (Tension 1)
#-----------------------------------------------------------------------------------
$-name:Nelveska Battle Transition Fix
$-uuid:nelveska-battle-transition-tzepish
$-description:
* Plays a "battle" world map transition instead of a fade in.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08b235cc
     #000201e4            #Vanilla: Transition style = 02 (fade in)
      000101e4            #New:     Transition style = 01 (battle swirl)
#-----------------------------------------------------------------------------------
$-name:List North Wall above South Wall in Fort Besselat Menu
$-uuid:fort-besselat-choice-tzepish
$-description:
* Swaps the North Wall and South Wall selections so that North appears above South.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08b23434
      016a0043            #Fort Besselat - North Wall
      01670042            #Fort Besselat - South Wall
#-----------------------------------------------------------------------------------
$-name:Sidequest rumors appear in more towns
$-uuid:sidequest-rumors-tzepish
$-description:
* Makes Rumors that activate sidequests appear in more towns, making them easier to find.
* Note that this is in combination with text and event changes to make sidequests easier to activate in general in WOTL Tweak.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08b23858
    #00000040          #Vanilla: The Haunted Mine:             Gollund only
     00004060          #New:     The Haunted Mine:             Lesalia, Gollund, Dorter
     00000200          #Vanilla: The Cursed Isle of Nelveska:  Zeltennia only (changing this one is buggy)
    #00004140          #Vanilla: Rash of Thefts:               Lesalia, Gariland, Gollund
     00004140          #New:     Rash of Thefts:               Lesalia, Gariland, Gollund (Unchanged)
    #00000020          #Vanilla: A Call for Guards:            Dorter only
     00004140          #New:     A Call for Guards:            Lesalia, Gariland, Gollund (NOT Dorter, so the player doesnt get trapped)
    #00001100          #Vanilla: Disorder in the Order:        Eagrose, Gariland
     00003120          #New:     Disorder in the Order:        Riovanes, Eagrose, Gariland, Dorter
    #0000056a          #Vanilla: Lionels New Liege Lord:       Limberry, Gariland, Gollund, Dorter, Goug, Bervenia
     00000572          #New:     Lionels New Liege Lord:       Limberry, Gariland, Gollund, Dorter, Zaland, Bervenia
#-----------------------------------------------------------------------------------
$-name:Final set of sidequests can be activated earlier
$-uuid:sidequests-final-tzepish
$-description:
* Makes Lionels New Liege Lord sidequest playable after Limberry (instead of after Mullonde).
* Makes Disorder in the Order sidequest playable after Eagrose (instead of after Mullonde).
* Meliadouls bonus battle doesnt disappear until starting Mullonde (instead of starting Eagrose).
$-overwrites:none
$-requires:sidequest-rumors-tzepish
$-file:boot.bin
$-type:ram
$-offset:08b22bfc      #Lionels New Liege Lord
    #006f0002
    #00010010               #Vanilla: CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 10 (After Mullonde)
     006f0002
     0001000f               #New:     CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0f (After Limberry)
$-offset:08b2303c      #Meliadouls Bonus Battle
    #006e0001
    #00010033               #Vanilla: CheckFlagEqual (0100) StoryProgress (Flag 0x006e) == 33 (After Limberry)
     006f0001
     0001000f               #New:     CheckFlagEqual (0100) ShopAvailability (Flag 0x006f) == 0f (After Limberry)
$-offset:08b22d18      #Disorder in the Order - Zeltennia Scene (with Lavian and Alicia)
    #00020017
    #0010006f               #Vanilla: CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 10 (After Mullonde)
     00020017
     0034006e               #New:     CheckFlagGreaterEqual (0200) StoryProgress (Flag 0x006e) == 34 (After Eagrose)
$-offset:08b22d38      #Disorder in the Order - Zeltennia Scene (without Lavian and Alicia)
    #006f0002
    #00040010               #Vanilla: CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 10 (After Mullonde)
     006e0002
     00040034               #New:     CheckFlagGreaterEqual (0200) StoryProgress (Flag 0x006e) == 34 (After Eagrose)
$-offset:08b233c0      #Disorder in the Order - Brigands Den Battle
    #00020001
    #0010006f               #Vanilla: CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 10 (After Mullonde)
     00020001
     0034006e               #New:     CheckFlagGreaterEqual (0200) StoryProgress (Flag 0x006e) == 34 (After Eagrose)
#-----------------------------------------------------------------------------------
$-name:Agrias Birthday sidequest is easier to activate
$-uuid:agrias-bday-easier-tzepish
$-description:
* The event will trigger even if Lavian and Alicia are gone.
* Agrias will happily accept the gift on the day before or after her birthday as well.
* Had to copy for every city, lol.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08b22b60
         00020010       #Eagrose
         000d006f          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         001e0004          #RequireChar (0400) Agrias (1e 00)
         02f90001          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00040000
         000e0016          #RequireChar (0400) Mustadio (16 00)
         0010c350          #RequireGil (0e00) 50,000 (0xc350)
         00150006          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00060011
         00040017          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         0004001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         0019001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b22dfc
         00020001       #Gariland
         000d006f          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         001e0004          #RequireChar (0400) Agrias (1e 00)
         02f90001          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00040000
         000e0016          #RequireChar (0400) Mustadio (16 00)
         0010c350          #RequireGil (0e00) 50,000 (0xc350)
         00150006          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00060011
         00040017          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         0004001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         0019001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b23088
         006f0002       #Zaland
         0004000d          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         0001001e          #RequireChar (0400) Agrias (1e 00)
         000002f9          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00160004          #RequireChar (0400) Mustadio (16 00)
         c350000e          #RequireGil (0e00) 50,000 (0xc350)
         00060010
         00110015          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00170006          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         001e0004          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         001e0004          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b23200
         006f0002       #Goug
         0004000d          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         0001001e          #RequireChar (0400) Agrias (1e 00)
         000002f9          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00160004          #RequireChar (0400) Mustadio (16 00)
         c350000e          #RequireGil (0e00) 50,000 (0xc350)
         00060010
         00110015          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00170006          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         001e0004          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         001e0004          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b2328c
         00020016       #Warjilis
         000d006f          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         001e0004          #RequireChar (0400) Agrias (1e 00)
         02f90001          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00040000
         000e0016          #RequireChar (0400) Mustadio (16 00)
         0010c350          #RequireGil (0e00) 50,000 (0xc350)
         00150006          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00060011
         00040017          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         0004001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         0019001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b22e74
         00020000       #Gollund
         000d006f          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         001e0004          #RequireChar (0400) Agrias (1e 00)
         02f90001          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00040000
         000e0016          #RequireChar (0400) Mustadio (16 00)
         0010c350          #RequireGil (0e00) 50,000 (0xc350)
         00150006          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00060011
         00040017          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         0004001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         0019001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b228e0       #Lesalia
         006f0002
         0004000d          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         0001001e          #RequireChar (0400) Agrias (1e 00)
         000002f9          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00160004          #RequireChar (0400) Mustadio (16 00)
         c350000e          #RequireGil (0e00) 50,000 (0xc350)
         00060010
         00110015          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00170006          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         001e0004          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         001e0004          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b229f0       #Riovanes
         00020005
         000d006f          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         001e0004          #RequireChar (0400) Agrias (1e 00)
         02f90001          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00040000
         000e0016          #RequireChar (0400) Mustadio (16 00)
         0010c350          #RequireGil (0e00) 50,000 (0xc350)
         00150006          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00060011
         00040017          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         0004001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         0019001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b232cc
         006f0002       #Bervenia?
         0004000d          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         0001001e          #RequireChar (0400) Agrias (1e 00)
         000002f9          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00160004          #RequireChar (0400) Mustadio (16 00)
         c350000e          #RequireGil (0e00) 50,000 (0xc350)
         00060010
         00110015          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00170006          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         001e0004          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         001e0004          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b22dac
         00020002       #Zeltennia?
         000d006f          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         001e0004          #RequireChar (0400) Agrias (1e 00)
         02f90001          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00040000
         000e0016          #RequireChar (0400) Mustadio (16 00)
         0010c350          #RequireGil (0e00) 50,000 (0xc350)
         00150006          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00060011
         00040017          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         0004001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         0019001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b23338
         00020001       #Sal Ghidos
         000d006f          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         001e0004          #RequireChar (0400) Agrias (1e 00)
         02f90001          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00040000
         000e0016          #RequireChar (0400) Mustadio (16 00)
         0010c350          #RequireGil (0e00) 50,000 (0xc350)
         00150006          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00060011
         00040017          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         0004001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         0019001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
$-offset:08b22c44
         00020002       #Limberry
         000d006f          #CheckFlagGreaterEqual (0200) ShopAvailability (Flag 0x006f) >= 0d (Start of Chapter 4)
         001e0004          #RequireChar (0400) Agrias (1e 00)
         02f90001          #CheckFlagEqual (0100) AgriasBirthday (Flag 0x02f9) == 0 (not done yet)
         00040000
         000e0016          #RequireChar (0400) Mustadio (16 00)
         0010c350          #RequireGil (0e00) 50,000 (0xc350)
         00150006          #CurrentDateGreaterEqual (10 00) June (06 00) 21st (15 00)
         00060011
         00040017          #CurrentDateLessThanEqual (11 00) June (06 00) 23rd (17 00)
         0004001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Lavian (78 00)
         0019001e          #RequireChar (0400) Agrias (1e 00) (redundant) instead of Alicia (79 00)
#-----------------------------------------------------------------------------------
$-name:Item Battle Graphics Changes
$-uuid:item-battle-gfx-tzepish
$-description:
* WOTL Tweak makes changes to several weapon sprites to better match their icons.
* FFTPatcher only changes UI sprites - battle graphics are set here.
* An asterisk appears over items that are changed from vanilla. The rest of the data is reproduced here for convenience.
* Balmung, Orochi, Golden Axe, Dreamwaker, and Reverie Shield are hardcoded to use their own special palettes.
$-overwrites:none
$-requires:none
$-file:boot.bin
$-type:ram
$-offset:08b27ecc          #In battle item graphics data. (ZZXY. ZZ = Graphic, X = Palette, Y = Effect Palette)
         00e00000          #01: Dagger             00: 0000 (not weapon graphics data)
         04ea02f0          #03: Blind Knife*       02: Mythril Knife
         00d00634          #05: Platinum Dagger    04: Mage Masher*
         045b0261          #07: Orichalcum Dirk*   06: Main Gauche*
         0240064a          #09: Air Knife          08: Assassins Dagger*
         08990434          #0b: Hidden Blade*      0a: Zwill Straightblade*
         08d008e0          #0d: Kodachi*           0c: Kunai*
         084a0a34          #0f: Spellbinder*       0e: Ninja Longblade*
         0ad00ad0          #11: Iga Blade*         10: Sasukes Blade*
         00e00a61          #13: Broadsword         12: Koga Blade*
         043402e0          #15: Iron Sword*        14: Longsword
         046806f0          #17: Blood Sword*       16: Mythril Sword
         06840272          #19: Ancient Sword*     18: Coral Sword*
         06d000fa          #1b: Platinum Sword     1a: Sleep Blade*
         027e0084          #1d: Ice Brand*         1c: Diamond Sword*
         0283005b          #1f: Nagnarok*          1e: Rune Blade*
         0c840240          #21: Defender*          20: Materia Blade*
         0e840cf0          #23: Excalibur*         22: Save the Queen
         0c5b0ee0          #25: Valhalla*          24: Ragnarok
         12f010d0          #27: Kotetstu*          26: Ashura
         105b14d0          #29: Murasame*          28: Osafune
         14301240          #2b: Kiyomori           2a: Ama-no-Murakamo
         12e01068          #2d: Kiku-ichomonji     2c: Muramasa*
         10841230          #2f: Chirijiraden*      2e: Masamune*
         00cd00d0          #31: Francisca*         30: Battle Axe
         16ed00ea          #33: Wooden Rod*        32: Slasher*
         18481802          #35: Flame Rod*         34: Thunder Rod*
         169318ce          #37: Poison Rod*        36: Ice Rod*
         16a018fa          #39: Dragon Rod         38: Wizards Rod*
         1a441882          #3b: Oak Staff*         3a: Rod of Faith*
         1c7e1a70          #3d: Healing Staff*     3c: White Staff
         1c881ae0          #3f: Mages Staff*       3e: Serpent Staff
         1c5a1a22          #41: Zeus Mace*         40: Golden Staff*
         03f41cd0          #43: Iron Flail*        42: Staff of the Magi*
         03aa0381          #45: Morning Star*      44: Flame Mace*
         00d10333          #47: Romandan Pistol    46: Scorpion Tail*
         00e10071          #49: Stoneshooter       48: Mythril Gun*
         0268027e          #4b: Blaze Gun*         4a: Glacial Gun*
         00b002c2          #4d: Bowgun*            4c: Blaster*
         00a000fa          #4f: Recurve Crossbow   4e: Knightslayer*
         033003b3          #51: Hunting Crossbow   50: Poison Crossbow*
         00f003f0          #53: Longbow*           52: Gastrophetes
         00ee00a0          #55: Ice Bow*           54: Silver Bow*
         00300042          #57: Windslash Bow      56: Lightning Bow*
         03cb03e0          #59: Artemis Bow*       58: Mythril Bow
         03f003b0          #5b: Perseus Bow        5a: Yoichi Bow
         00680080          #5d: Bloodstring Harp*  5c: Lamias Harp
         00d000f0          #5f: Battle Folio       5e: Faerie Harp
         00a000e0          #61: Papyrus Codex      60: Bestiary
         02f000b0          #63: Javelin*           62: Omnilex
         004002d0          #65: Mythril Spear*     64: Spear
         000000c0          #67: Obelisk*           66: Partisan*
         02a00070          #69: Dragon Whisker*    68: Holy Lance*
         04c400c4          #6b: Cypress Pole       6a: Zodiac Spear*
         040004e4          #6d: Musk Pole*         6c: Battle Bamboo*
         06540444          #6f: Gokuu Pole*        6e: Iron Fan*
         067e069a          #71: Eight-fluted Pole* 70: Ivory Pole*
         00a40640          #73: Croakadile Bag*    72: Whale Whisker*
         00ba0094          #75: Pantherskin Bag*   74: Fallingstar Bag*
         00fa005b          #77: Damask Cloth*      76: Hydrascale Bag*
         009a00a4          #79: Wyrmweave Silk*    78: Cashmere*
         006800e0          #7b: Fuma Shuriken*     7a: Shuriken
         0068004b          #7d: Flameburst Bomb*   7c: Yagyu Darkstar*
         0082007e          #7f: Spark Bomb*        7e: Snowmelt Bomb*
         00e006b0          #81: Buckler            80: Escutcheon*
         00a00630          #83: Round Shield*      82: Bronze Shield*
         06c000f0          #85: Golden Shield*     84: Mythril Shield*
         00500070          #87: Flame Shield*      86: Ice Shield*
         06000060          #89: Diamond Shield*    88: Aegis Shield*
         06700000          #8b: Crystal Shield*    8a: Platinum Shield*
         06900060          #8d: Kaiser Shield*     8c: Genji Shield*
         064000c0          #8f: Zodiac Escutcheon* 8e: Venetian Shield*
$-offset:08a5b3c8          #Same, but for MP items. (ZZXY. ZZ = Graphic, X = Palette, Y = Effect Palette)
         0c9b0c4a          #101: Deathbringer*     100: Nightmare*
         0c7a0c7e          #103: Balmung*          102: Arondight*
         044e0c9b          #105: Moonblade*        104: Chaos Blade*
         004102a4          #107: Ras Algethi*      106: Onion Sword*
         004a0091          #109: Giants Axe*       108: Fomalhaut*
         0ad800d2          #10b: Orochi*           10a: Golden Axe*
         1c740a9b          #10d: Nirvana*          10c: Moonsilk Blade*
         18d01c7b          #10f: Stardust Rod*     10e: Dreamwaker*
         03f218fb          #111: Vesper*           110: Crown Scepter*
         0ed00380          #113: Durandal*         112: Sagittarius Bow*
         006200f0          #115: Gungnir*          114: Gae Bolg*
         004d069b          #117: Arbalest*         116: Cinqueda*
         0000035a          #119: (Unused Weapon)   118: Dhanusha*
         00000000          #11b: (Unused Weapon)   11a: (Unused Weapon)
         00000000          #11d: (Unused Weapon)   11c: (Unused Weapon)
         00000000          #11f: (Unused Weapon)   11e: (Unused Weapon)
         00a006a0          #121: Reverie Shield*   120: Onion Shield*
         00000000          #123: (Unused Shield)   122: (Unused Shield)
#-----------------------------------------------------------------------------------
