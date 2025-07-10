#
### Note: a pound sign preceding the uuid means the script is turned ON! Delete the leading pound sign to disable a script.
#
#
#
#############################################
### tzepish-hacks --- ASM I wrote myself
#############################################
#
# Zodiac Compatibility Rewrite:
#$-uuid:zodiac-rewrite-secondadvent-tzepish
#
# Equip X abilities allow for more equipment types + gender equality:
#$-uuid:equipx-rewrite-tzepish
#
# Add a Men Only counterpart item to Minerva Bustier:
#$-uuid:new-menonly-item-tzepish
#
# Weapon Base Damage Rewrite
#$-uuid:weapon-base-rewrite-tzepish
#
# Modify Attack Damage Rewrite:
#$-uuid:attack-damage-rewrite-tzepish
#
# Nerf Arcane Strength:
#$-uuid:arcane-strength-tzepish
#
# Monk Physical Skills use both Power and Speed/2:
#$-uuid:monk-physical-skills-tzepish
#
# Monk Magical Skills use the higher of Power or Magick:
#$-uuid:monk-magical-skills-tzepish
#
# Chakra recovers fewer MP:
#$-uuid:monk-chakra-nerf-tzepish
#
# New Magic Guns formula:
#$-uuid:magic-gun-formula-tzepish
#
# More consistent weather effects:
#$-uuid:weather-rain-snow-tzepish
#
# Default weapon proc rate is 25% instead of 19%:
#$-uuid:default-weapon-proc-tzepish
#
# Critical hits always deal 50% bonus damage & Chance increased by status effects & accessory:
#$-uuid:critical-status-accessory-tzepish
# ^ Replaces the stock version that comes with Valhalla, because I added new functionality to it.
#
# New MP Regeneration Accessory:
#$-uuid:mpregen-accessory-tzepish
#
# Start at 0 MP and recover some MP each turn:
$-uuid:mpregen-start0-tzepish
# ^ Turned off by default in WOTL Tweak, but you can turn it on here.
#
# Increase Poison damage:
#$-uuid:poison-damage-tzepish
#
# Increase Blind and Confuse miss rates:
#$-uuid:blind-confuse-missrate-tzepish
#
# Blind enemies are easier to hit:
#$-uuid:blind-evasion-nullify-tzepish
#
# Increase Defend and Invisible evasion rate:
#$-uuid:defend-invisibile-evasion-tzepish
#
# Gravity & Drain deal half damage to Lucavi:
#$-uuid:gravity-drain-lucavi-tzepish
#
# Undead always reanimate:
#$-uuid:undead-revive-tzepish
# ^ Turned off by default in WOTL Tweak, but you can turn it on here.
#
# Focus increases both PA and MA:
#$-uuid:battle-formula-036-tzepish
# ^ Replaces the stock version that comes with Valhalla, which doesnt seem to work.
#
# Vengeance, Blade Beam, and Manaburn formulas accept a multiplier:
#$-uuid:battle-formulas-43-44-tzepish
#
# JP Boost always applies:
#$-uuid:jpboost-innate-always-tzepish
#
# Remove permanent Brave and Faith alterations:
$-uuid:remove-permanent-brave-faith-tzepish
# ^ Turned off by default in WOTL Tweak, but you can turn it on here.
#
# Modify Faith and Brave desertion thresholds:
#$-uuid:modify-desertion-brave-faith-tzepish
#
# Remove permanent Brave and Faith desertion:
#$-uuid:remove-desertion-brave-faith-tzepish
# ^ Turned off by default in WOTL Tweak, but you can turn it on here.
#
# Poachers Den opens in Chapter 2:
#$-uuid:poachers-den-open-tzepish
#
# Poach rare item chance increase:
#$-uuid:poach-rare-chance-tzepish
#
# Broken/Stolen/Thrown equipment items are added to Poachers Den:
#$-uuid:lost-equipment-poachersden-tzepish
#
# Modify Katana break chance with Iaido:
#$-uuid:katana-break-chance-tzepish
#
# Swiftness AI fixes
#$-uuid:swiftness-ai-fixes-tzepish
#
# Beast Tamer = Combine Beastmaster, Beast Tongue, & Tame:
#$-uuid:combine-beast-abilities-tzepish
#
# Beast Tamer works at any range:
#$-uuid:beasttamer-range-tzepish
#
# Update disallowed innate support abilities
#$-uuid:update-disallowed-innates-tzepish
#
# Weapon evasion always applies & Parry buff:
#$-uuid:wpn-evade-always-tzepish
#
# HP Boost increase:
#$-uuid:hpboost-increase-tzepish
#
# Replace MateriaBlade flag with AnyWeapon flag & Sword Skills now work with a Katana:
#$-uuid:weapon-sword-flags-tzepish
#
# Revised Nether Mantra hits table:
#$-uuid:nether-mantra-hits-tzepish
#
# Nether Mantra Faith/Atheist Swap Bugfix:
#$-uuid:nether-mantra-faith-tzepish
#
# Marach reverses Faith calculations for ALL magic when casting:
#$-uuid:marach-faith-reversal-tzepish
#
# New Luso and Balthier skills cause hitreact animations:
$-uuid:luso-balthier-hitreact-tzepish
#
# Dragons Gift works on non-dragons and heals double on dragons:
#$-uuid:dragons-gift-tzepish
#
# Dragons Might works on non-dragons and buffs double on dragons:
#$-uuid:dragons-might-tzepish
#
# Dragons Quickness works on non-dragons with a fail chance:
#$-uuid:dragons-quick-tzepish
#
# Dragons Charm works on non-dragons with a fail chance:
#$-uuid:dragons-charm-tzepish
#
# Barrage works with Dual Wield and Doublehand:
#$-uuid:barrage-dualwield-doublehand-tzepish
#
# Prevent Knockback if there are attacks remaining:
#$-uuid:multiattacks-prevent-knockback-tzepish
#
# Special characters can go on Errands + Mustadio not needed for sidequests:
#$-uuid:errands-special-characters-tzepish
#
# Can rename human characters in the Warriors Guild:
#$-uuid:warriors-guild-rename-tzepish
#
# Improved human character base stats - gender equality & removed randomization:
#$-uuid:base-stats-improvement-tzepish
#
# Warriors Guild and Initial Ramza Improvement:
#$-uuid:warrior-guild-ramza-improvement-tzepish
#
# Player team characters always crystalize (never treasurize) on death:
#$-uuid:player-always-crystal-tzepish
#
# ENTD Load Formation backup:
#$-uuid:entd-loadformation-backup-tzepish
#
# ENTD Load Formation backup transform:
#$-uuid:entd-loadformation-transform-tzepish
#
# Agrias/Mustadio/Rapha keep their stats:
#$-uuid:agrias-mustadio-rapha-tzepish
#
# ENTD Characters can have Fury, Magick Boost, Adrenaline, or Vanish assigned:
#$-uuid:entd-reactions-bugfix-tzepish
#
# Random Unit Equipment is more selective:
#$-uuid:random-equipment-bugfix-glain-tzepish
#
# ENTD Characters have extra job levels:
#$-uuid:entd-joblevels-tzepish
#
# Display Earned JP/EXP only for player team:
#$-uuid:enemy-expjp-display-tzepish
#
# Skip the world map if the next story battle is triggered by leaving:
#$-uuid:fix-stuck-storybattles-tzepish
#
# Better battle music for Luso and Balthier battles:
#$-uuid:luso-balthier-battlemusic-tzepish
#
# Nelveska Battle Transition Fix:
#$-uuid:nelveska-battle-transition-tzepish
#
# List North Wall above South Wall in Fort Besselat Menu:
#$-uuid:fort-besselat-choice-tzepish
#
# Sidequest rumors appear in more towns:
#$-uuid:sidequest-rumors-tzepish
#
# Final set of sidequests can be activated earlier:
#$-uuid:sidequests-final-tzepish
#
# Agrias Birthday sidequest is easier to activate:
#$-uuid:agrias-bday-easier-tzepish
#
# Item Battle Graphics Changes:
#$-uuid:item-battle-gfx-tzepish
#
#
#
######################
### default-core-hacks
######################
#
# Slowdown fix v2:
#$-uuid:graphics-battle-fix-001
#
# Add spell quotes back to the game:
#$-uuid:text-battle-fix-001
#
# Spell quotes always play:
#$-uuid:text-battle-fix-002
#
# Unlock sound novels:
#$-uuid:world-menu-novels-001
#
# Smart Encounters:
#$-uuid:world-map-encounters-001
# ^ Turned off by default in WOTL Tweak, but you can turn it on here.
#
# Battle Initial Camera v2:
$-uuid:battle-camera-fix-001
# ^ Turned off because it seems buggy. Seems camera controls eventually stop working.
#
# Fix gil amount needed for the lip rouge quest:
#$-uuid:fix-gil-quest-001
#
#
#
######################
### default-cust-hacks
######################
#
# Unlocked jobs v2 (Removes nonlevel reqs for jobs):
#$-uuid:global-jobs-req-001
#
# Battle jobs list:
#$-uuid:battle-status-jobs-001
# ^ I dont know what this does! But it doesnt seem to be harming anything.
#
# Abilities in Arith skillset can be reflected:
#$-uuid:battle-arith-reflect-001
#
# Null slps file in fftpack:
#$-uuid:clean-space-fftackbin-001
# ^ I dont know what this does! Opens up free space for use in other scripts maybe?
#
# Replace TEST.EVT file (Needed to encode event changes):
#$-uuid:replace-testevt-file-001
#
# Treasure Hunter 9-bit rare items:
#$-uuid:th-9b-items-001
#
# ENTD 9-bit equipment items:
#$-uuid:entd-9b-items-001
#
# Poach 9-bit items:
$-uuid:poach-9b-items-001
# ^ Turned off because all MP items are single-instance in this mod.
#
# Balthier gets no hardcoded ENTD items:
#$-uuid:baltheir-normal-entd-001
#
# Onion items can be equipped if lip rouge flag:
$-uuid:onion-items-liprouge-001
#
# Treasure Hunter edit rare minimum brave:
#$-uuid:th-rare-min-001
#
# Treasure Hunter is Player only:
#$-uuid:th-player-only-001
#
# Arithmeticks supports up to 20 skillsets:
$-uuid:arith-20-ss-001
#
# Party Roster Extension (PRE):
#$-uuid:p-r-e-001
#
# Switch formation and absorb:
$-uuid:switch-formation-absorb-001
#
# Monster eggs in last roster slot only:
$-uuid:eggs-last-slot-001
# ^ These three are disabled because they are buggy. Oddities appear in skill lists after battle. Otherwise, I am definitely interested in them (except absorb).
#
# Level cap:
#$-uuid:level-cap-p-001
#
# Monster do not count as Casualties nor Injured:
#$-uuid:monster-no-ci-001           
# ^ Unadvertised feature
#
#
#
######################
### default-data-hacks
######################
#
# Replace all data files:
$-uuid:replace-data-files-001
# ^ Turned off because I dont use Valhalla for data editing, I use FFTPatcher.
#
#
#
######################
### default-expe-hacks
######################
#
# Test entd 9b items:
$-uuid:test-entd-9b-001
# ^ I dont know what this does!
#
#
#
######################
### default-text-hacks
######################
#
# All are turned on because this mod makes extensive text changes.
#$-uuid:clean-space-bootbin-001
#$-uuid:replace-font-eng-001
#$-uuid:replace-fontw-eng-001
#$-uuid:replace-spellmes-file-001
#$-uuid:replace-snplmes-file-001
#$-uuid:replace-wldmes-file-001
#$-uuid:replace-tutomes-file-001
#$-uuid:replace-quick-text-001
#$-uuid:change-tuto-snames-001
#
#
