set_controller_instance(id, true, true)

#region === STATS ===

statStarCounter = 99

statCriticalZone = 50

statDodgePerfect = 2 //Zone around crit zone
statDodgeSpeed = 20
statDodgeCooldown = 120
statDodgeInvincibleDuration = 10

statRecoveryInvincibility = 120
statRecoveryControls = 5

#endregion

enum STATE {
	IDLE, RUNNING, WALK
}

spd = 8
spdCurrent = 0
spdAcc = 0.5
moveDirection = 0

invincible = false

controlsDisabled = false
controlsDisabledHandle = noone

dodgeCooldownCurrent = 0

move = use_tdmc()

zoneCurrent = undefined

#region ==== ANIMATION ====

shakeStrengthLower = 8
shakeStrengthHigher = 12

#endregion