# Health & Stamina System Deep Dive Analysis

## 📊 System Overview

### Core Manager: `PlayerStatsManager.gd`
- **Location**: `Scripts/Vitality/PlayerStatsManager.gd`
- **Type**: Autoload (Node)
- **Responsibilities**: Central authority for all health/stamina changes

### Initial Values
- `MAX_HEALTH = 100.0`
- `MAX_ENERGY = 100.0` (called "energy" but represents stamina)
- Both start at maximum capacity

---

## ❤️ HEALTH SYSTEM

### Health Decreases When:
1. **Animal Attacks** (`Animals.gd:156`)
   ```gdscript
   EventSystem.PLA_change_health.emit(-damage)
   ```
   - Default animal damage: `20.0` per hit
   - Triggers when player is in animal's `attack_hit_area` during attack animation

2. **Energy Depletion** (`PlayerStatsManager.gd:18-19`)
   ```gdscript
   if current_energy < 0:
       change_health(current_energy)  # ⚠️ POTENTIAL BUG
   ```
   - When stamina reaches 0 and continues to drain, excess negative energy converts to health damage
   - **Issue**: This can cause unexpected health loss

### Health Increases When:
1. **Consuming Items** (`EquippableConsumables.gd:7`)
   ```gdscript
   EventSystem.PLA_change_health.emit(consumable_item_resource.health_change)
   ```
   - Default: `+15.0` health per consumable
   - Defined in `ConsumableResource` (`Cosumables.gd:4`)

2. **Max Health Skills** (`PlayerStatsManager.gd:33-36`)
   ```gdscript
   func _on_increase_max_health(amount: int) -> void:
       MAX_HEALTH += amount
       current_health += amount  # Also increases current health
   ```
   - When unlocking health bonus skills, both max AND current health increase

### Health Updates UI:
- Signal: `EventSystem.PLA_health_updated.emit(MAX_HEALTH, current_health)`
- Receiver: `PlayerStatsContainer.gd:21-23` → Updates `health_bar` display

### Death Condition:
- When `current_health <= 0`:
  1. Freezes player
  2. Returns to main menu

---

## ⚡ STAMINA (ENERGY) SYSTEM

### Energy Decreases When:

1. **Movement** (`Player.gd:104-110`)
   ```gdscript
   func check_walking_energy_change(delta: float) -> void:
       if velocity.x or velocity.z:
           EventSystem.PLA_change_energy.emit(
               delta * walking_energy_change_per_1m * Vector2(velocity.x, velocity.z).length()
           )
   ```
   - Rate: `walking_energy_change_per_1m = -0.05` per meter
   - Consumes energy based on distance traveled (not speed-based)
   - **Note**: Sprinting consumes same energy per meter, just covers distance faster

2. **Weapon Usage** (`EquippableWeapons.gd:18-19`)
   ```gdscript
   func change_energy() -> void:
       EventSystem.PLA_change_energy.emit(weapon_resource.energy_change_per_use)
   ```
   - Defined per weapon in `WeaponResource`
   - Negative value = energy cost

### Energy Increases When:

1. **Consuming Items** (`EquippableConsumables.gd:8`)
   ```gdscript
   EventSystem.PLA_change_energy.emit(consumable_item_resource.energy_change)
   ```
   - Default: `+15.0` energy per consumable

2. **Max Energy Skills** (`PlayerStatsManager.gd:38-41`)
   ```gdscript
   func _on_increase_max_energy(amount: int) -> void:
       MAX_ENERGY += amount
       current_energy += amount  # Also increases current energy
   ```

### Energy Updates UI:
- Signal: `EventSystem.PLA_energy_updated.emit(MAX_ENERGY, current_energy)`
- Receiver: `PlayerStatsContainer.gd:17-19` → Updates `energy_bar` display

### Energy Depletion Behavior:
- When `current_energy < 0`:
  1. Energy is clamped to `0`
  2. **Excess negative energy is applied as health damage** (line 19)
   - **This means**: Running out of stamina can damage health

---

## 🔍 IDENTIFIED ISSUES

### 🐛 **CRITICAL: Energy-to-Health Damage Bug**
**Location**: `PlayerStatsManager.gd:18-19`

**Problem**:
```gdscript
if current_energy < 0:
    change_health(current_energy)  # If energy = -5, health -= 5
```

**Issues**:
1. Negative energy is ALREADY clamped to 0 (line 21), so `current_energy` will never be negative when this check runs
2. This logic seems intended but the order is wrong
3. **Actual behavior**: This check likely never triggers because clamping happens before it

**Expected Behavior** (if this was intentional):
- Should calculate excess damage BEFORE clamping
- Example: If player has 2 energy and needs to use 10 energy for an action:
  - Energy becomes -8
  - Health should take 8 damage
  - Energy clamped to 0

**Current Behavior**:
- Energy is clamped first, so the health damage never occurs

### ⚠️ **Missing Passive Regeneration**
**Status**: NOT IMPLEMENTED

**Skill Resources Exist For**:
1. `Skill_NaturalRegeneration.tres` - "Slowly regenerate health over time when not in combat (1 HP per 10 seconds)"
2. `Skill_CombatRegeneration.tres` - "Slowly regenerate health during combat (1 HP per 5 seconds)"

**Impact**:
- Players can only heal via consumables
- No stamina regeneration either
- Makes survival much harder than intended if skills are unlocked

### ⚠️ **Movement Energy Consumption**
**Issue**: Energy drains even when standing still with slight velocity

**Location**: `Player.gd:105`
```gdscript
if velocity.x or velocity.z:  # Any non-zero velocity triggers drain
```

**Problem**: Tiny velocity values (like 0.001) still drain energy, potentially causing constant micro-drain

**Suggested Fix**: Add threshold
```gdscript
var velocity_2d = Vector2(velocity.x, velocity.z)
if velocity_2d.length() > 0.1:  # Only drain if actually moving
    EventSystem.PLA_change_energy.emit(...)
```

### ⚠️ **No Sprint Energy Multiplier**
**Current**: Sprinting uses same energy per meter as walking
- Sprint speed: `5.0` units/second
- Walk speed: `3.0` units/second
- Sprint covers 1.67x distance in same time
- But energy drain is distance-based, not speed-based

**Result**: Sprinting is actually MORE energy-efficient than walking per second, but consumes same per meter

---

## ✅ WHAT'S WORKING CORRECTLY

1. ✅ Health increases with max health skills
2. ✅ Energy increases with max energy skills  
3. ✅ UI updates correctly via signals
4. ✅ Death handling works (freeze + return to menu)
5. ✅ Consumables restore both health and energy
6. ✅ Animal damage is applied correctly
7. ✅ Weapon energy costs are applied correctly
8. ✅ Signal-based architecture is clean and decoupled

---

## 🔧 RECOMMENDED FIXES

### Priority 1: Fix Energy-to-Health Damage Logic
```gdscript
func change_energy(energy_change: float) -> void:
    var new_energy = current_energy + energy_change
    
    # Check for excess negative energy BEFORE clamping
    if new_energy < 0:
        var excess_damage = -new_energy  # Amount that exceeds 0
        change_health(-excess_damage)  # Apply as health damage
        new_energy = 0
    
    current_energy = clampf(new_energy, 0, MAX_ENERGY)
    EventSystem.PLA_energy_updated.emit(MAX_HEALTH, current_energy)
```

### Priority 2: Add Movement Threshold
```gdscript
func check_walking_energy_change(delta: float) -> void:
    var velocity_2d = Vector2(velocity.x, velocity.z)
    var movement_length = velocity_2d.length()
    
    if movement_length > 0.1:  # Only drain if actually moving
        EventSystem.PLA_change_energy.emit(
            delta * walking_energy_change_per_1m * movement_length
        )
```

### Priority 3: Implement Passive Regeneration
- Add Timer-based regeneration system
- Check for combat/non-combat states
- Apply regeneration based on unlocked skills

### Priority 4: Add Sprint Energy Multiplier (Optional)
- Make sprinting consume more energy per meter (e.g., 1.5x)
- Or keep current system but document it as intentional

---

## 📝 SYSTEM FLOW DIAGRAMS

### Health Change Flow:
```
EventSystem.PLA_change_health.emit(value)
    ↓
PlayerStatsManager.change_health(value)
    ↓
current_health = clampf(current_health + value, 0, MAX_HEALTH)
    ↓
EventSystem.PLA_health_updated.emit(MAX_HEALTH, current_health)
    ↓
PlayerStatsContainer.health_updated(max, current)
    ↓
UI health_bar updated
```

### Energy Change Flow:
```
EventSystem.PLA_change_energy.emit(value)
    ↓
PlayerStatsManager.change_energy(value)
    ↓
current_energy += value
    ↓
[BROKEN] Check if < 0, damage health
    ↓
current_energy = clampf(current_energy, 0, MAX_ENERGY)
    ↓
EventSystem.PLA_energy_updated.emit(MAX_ENERGY, current_energy)
    ↓
PlayerStatsContainer.energy_updated(max, current)
    ↓
UI energy_bar updated
```

---

## 🎮 CURRENT GAMEPLAY IMPLICATIONS

1. **No Passive Healing**: Players must rely entirely on consumables
2. **Stamina Never Harms Health**: The energy-to-health damage bug means running out of stamina doesn't punish players
3. **Movement Always Drains**: Even tiny movements drain stamina
4. **Sprinting is Efficient**: No extra cost, just faster distance coverage

---

## 📋 CHECKLIST FOR USER

- [ ] Energy-to-health damage is broken (not a problem, but inconsistent)
- [ ] No passive regeneration (may be intentional, but skills exist for it)
- [ ] Movement threshold needed (minor optimization)
- [ ] All other systems working correctly ✅