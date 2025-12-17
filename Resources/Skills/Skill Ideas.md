# Skill Tree

## 🗡️ COMBAT SKILLS

### 1. **Basic Training**
- **XP Cost**: 10
- **Description**: "Increases your base attack damage by 10%"
- **Unlock Type**: Attack Damage
- **Unlock Value**: 10
- **Prerequisites**: None

### 2. **Critical Strikes**
- **XP Cost**: 20
- **Description**: "10% chance to deal double damage"
- **Unlock Type**: Custom (implement crit system)
- **Unlock Value**: 10
- **Prerequisites**: ["combat_basic_training"]

### 3. **Combat Reflexes**
- **XP Cost**: 15
- **Description**: "Increases attack speed by 15%"
- **Unlock Type**: Custom (implement attack speed modifier)
- **Unlock Value**: 15
- **Prerequisites**: ["combat_basic_training"]


### 4. **Battle Hardened**
- **XP Cost**: 20
- **Description**: "Reduces damage taken by 15%"
- **Unlock Type**: Custom (implement damage reduction)
- **Unlock Value**: 15
- **Prerequisites**: ["combat_basic_training"]

### 5. **Combat Regeneration**
- **XP Cost**: 25
- **Description**: "Slowly regenerate health during combat (1 HP per 5 seconds)"
- **Unlock Type**: Custom (implement combat regen)
- **Unlock Value**: 1
- **Prerequisites**: ["combat_battle_hardened"]

### 6. **Executioner**
- **XP Cost**: 30
- **Description**: "Deal 50% more damage to enemies below 30% health"
- **Unlock Type**: Custom (implement execution damage)
- **Unlock Value**: 50
- **Prerequisites**: ["combat_critical_strikes", "combat_combat_reflexes"]

## 🗺️ EXPLORATION SKILLS

### 1. **Double Jump**
- **XP Cost**: 15
- **Description**: "Gain the ability to jump a second time while in the air"
- **Unlock Type**: Double Jump
- **Unlock Value**: 0
- **Prerequisites**: None

### 2. **Swift Feet**
- **XP Cost**: 10
- **Description**: "Increases movement speed by 10%"
- **Unlock Type**: Movement Speed
- **Unlock Value**: 10
- **Prerequisites**: None

### 3. **Enhanced Sprint**
- **XP Cost**: 15
- **Description**: "Sprint duration increased by 50% and uses 20% less energy"
- **Unlock Type**: Custom (implement sprint improvements)
- **Unlock Value**: 50
- **Prerequisites**: ["exploration_swift_feet"]

### 4. **Mountain Goat**
- **XP Cost**: 20
- **Description**: "Jump height increased by 30% and reduced fall damage by 50%"
- **Unlock Type**: Custom (implement jump/fall improvements)
- **Unlock Value**: 30
- **Prerequisites**: ["exploration_double_jump"]


## 🏕️ SURVIVAL SKILLS

### 1. **Extra Pockets**
- **XP Cost**: 10
- **Description**: "Unlocks 5 additional inventory slots"
- **Unlock Type**: Inventory Slots
- **Unlock Value**: 5
- **Prerequisites**: None

### 2. **Pack Mule**
- **XP Cost**: 15
- **Description**: "Unlocks 10 more inventory slots"
- **Unlock Type**: Inventory Slots
- **Unlock Value**: 10
- **Prerequisites**: ["survival_extra_pockets"]

### 3. **Vitality Boost**
- **XP Cost**: 15
- **Description**: "Increases maximum health by 20"
- **Unlock Type**: Health Bonus
- **Unlock Value**: 20
- **Prerequisites**: None

### 4. **Endurance Training**
- **XP Cost**: 15
- **Description**: "Increases maximum energy by 30"
- **Unlock Type**: Energy Bonus
- **Unlock Value**: 30
- **Prerequisites**: None

### 5. **Natural Regeneration**
- **XP Cost**: 30
- **Description**: "Slowly regenerate health over time when not in combat (1 HP per 10 seconds)"
- **Unlock Type**: Custom (implement passive regen)
- **Unlock Value**: 1
- **Prerequisites**: ["survival_efficient_rest", "survival_hardy_constitution"]


## 🔨 CRAFTING SKILLS

### 1. **Efficient Crafting**
- **XP Cost**: 15
- **Description**: "Crafting uses 15% fewer materials"
- **Unlock Type**: Custom (implement material efficiency)
- **Unlock Value**: 15
- **Prerequisites**: ["crafting_basic_crafting"]

### 2. **Quick Hands**
- **XP Cost**: 15
- **Description**: "Crafting is 25% faster"
- **Unlock Type**: Custom (implement crafting speed)
- **Unlock Value**: 25
- **Prerequisites**: ["crafting_basic_crafting"]


## 🔨 SKILL RESOURCE PARAMETERS

1. Skill Key
Purpose: Unique identifier (string) used in code to reference this skill
Example: survival_vitality_boost
Usage: Check if unlocked, set prerequisites, apply effects
Format: "[category]_[skill_name]" (e.g., combat_basic_training)

2. Position (x, y)
Purpose: Coordinates on the skill tree canvas where the node appears
Type: Vector2
Example: Vector2(600, 200) = 600 pixels right, 200 pixels down
Usage: Defines layout and connection lines between skills
Tip: Space nodes 200–300 pixels apart

3. Prerequisites
Purpose: Array of skill keys that must be unlocked first
Type: Array[String]
Example: ["combat_basic_training"] or [] for starting skills
Usage: Blocks unlocking until prerequisites are met
Creates skill tree progression paths

4. Unlock Value
Purpose: Numerical value for the unlock effect
Type: Integer
Examples:
Health Bonus: 20 = +20 max health
Attack Damage: 10 = +10% damage
Inventory Slots: 5 = +5 slots
Movement Speed: 10 = +10% speed
Usage: Passed to the effect handler

5. Unlock Data
Purpose: Optional string for additional data
Type: String
Usage: For complex unlocks (e.g., recipe keys, item keys)
Example: Recipe unlock might use "tier_2_recipes"
