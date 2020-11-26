extends KinematicBody

onready var ownId:int = int(self.name)


#################################################################
### MOVEMENT AND POSITION VARS


onready var collisionShape:CollisionShape = $collisionShape
var bodyRotation:int = 1
const AIR_MOVEMENT:float = 0.8

# Speed values
const MAX_SPEED:float = 8.0
var motion:float = 0

# Acceleration values
const ACCEL:float = 8.5
const MVMNT_MOMENTUM:float = 10.0
const THROW_MOMENTUM:float = 2.0

# Jump and fall values
const JUMP_SPEED:float = 16.0
var isJumping:bool = false

var maxJump:int = 2         # Maximum number of jump that a character can do
var currentJump:int = 0     # Actual number of jump
var lastJumpId:int = 0      # Detect a new jump

# TODO: unreal, we may want to stick that to the physical value
const GRAVITY:float = -28.0

# Velocity updated continuously by move_and_slide
var vel:Vector3 = Vector3(0,0,0)

# move_and_slide need that
const FLOOR_NORMAL:Vector3 = Vector3(0,1,0)


#################################################################

#################################################################
### ATTACK VARS


onready var lastStrikerId:int = ownId;


var isAttacking:bool = false
onready var attackTimer:Tween = $attackTween


# General attacks ID
enum {
	NONE = 0,
	PUNCH = 1,
	KICK = 2
}


# Specific attacks ID
enum {
	ID_PUNCH_1 = 0,
	ID_PUNCH_2 = 1,
	ID_KICK_1 = 2,
	ID_KICK_2 = 3,
	ID_KICK_UP = 4,
	ID_KICK_JUMP_SIDE = 5,
	ID_KICK_JUMP_UP = 6,
	ID_KICK_JUMP_DOWN = 7
}


var lastPunchId:int = 0     # Detect a new punch (of any type)
var idleTime:float = 0      # Stun when hit + prevent spam


# Mouse oriented attacks
var attackDirection:int

enum {
	MOUSE_LEFT = 0,
	MOUSE_UP = 1,
	MOUSE_RIGHT = 2,
	MOUSE_DOWN = 3
}


# Punch attack parameters
onready var punchHitArea:Area = $punchHitArea 			# Node in player.tscn
var punchAttackDmg:int = 5								# Damages
var punchAttackDist:float = 1.3							# Distance
var punchAttackWait:float = 0.6							# Cooldown
var punch1AttackDuration:float = 0.1					# Duration (1)
var punch2AttackDuration:float = 0.2					# Duration (2)
var punchAttackDirection:Vector3 = Vector3(1,0.5,0) 	# Direction of the propulsion (normalized)
var punchAttackStrength:float = 0.5 					# Strength of the propulsion (multiply the direction)


# Kick (x-axis) attack parameters
onready var kickHitArea:Area = $kickHitArea
var kickAttackDmg:int = 10
var kick1AttackDist:float = 1.7
var kick2AttackDist:float = 1.5
var kickJumpSideAttackDist:float = 1.2
var kickAttackWait:float = 0.75
var kick1AttackDuration:float = 0.2
var kick2AttackDuration:float = 0.3
var kickJumpSideAttackDuration:float = 0.3
var kickAttackDirection:Vector3 = Vector3(1.2,0.75,0)
var kickAttackStrength:float = 1


# Jump (y-axis) Kick attack parameters
onready var jumpHitArea:Area = $jumpHitArea
var jumpAttackDmg:int = 10
var kickUpAttackDist:float = 1.5
var jumpUpAttackDist:float = 2
var jumpDownAttackDist:float = -0.7
var jumpAttackWait:float = 0.75
var kickUpAttackDuration:float = 0.2
var jumpUpAttackDuration:float = 0.2
var jumpDownAttackDuration:float = 0.3
var jumpAttackDirection:Vector3 = Vector3(0,1,0)
var jumpAttackStrength:float = 1


# Health points
var hp:int = 0
const critHP:int = 200

const IMPACT_FACTOR:float = 0.3
var critState:int = 0

# item to regain health points
var regainHp:int = 20

# Kills
var kills:int = 0

#################################################################

#################################################################
### ANIMATIONS VARS


# Odd/even attack
var animSequence:int = 0


# Animation IDs
enum {
	ANIM_CONTROLLED_FALL = -1,
	ANIM_IDLE = 0,
	ANIM_RUN = 1,
	ANIM_JUMP = 2,
	ANIM_PUNCH_1 = 3,
	ANIM_PUNCH_2 = 4,
	ANIM_KICK_1 = 5,
	ANIM_KICK_2 = 6,
	ANIM_KICK_UP = 7,
	ANIM_JUMP_KICK_SIDE = 8,
	ANIM_JUMP_KICK_UP = 9,
	ANIM_JUMP_KICK_DOWN = 10,
	ANIM_TURN = 11,
	ANIM_IMPACT_1 = 12,
	ANIM_IMPACT_2 = 13,
	ANIM_IMPACT_JUMP = 14,
	ANIM_BIG_IMPACT = 15
}

enum {
	TURN_LEFT = -1,
	TURN_RIGHT = 1
}


#################################################################

#################################################################
### PHYSICS LOOP


# called by the engine
func _physics_process(delta:float):
	processMovement(delta)
	self.translation.z = 0
	gamestate.broadcastMovement(self.ownId, self.get_translation())


#################################################################

#################################################################
### ANIMATIONS VARS


# Update the player's vars depending on the client's input
func getPlayerInputs(movementInput:int, jumpId:int, attackTypeInput:int, mouseX:int, mouseY:int, itemInput:bool):
	# If character is uncontrollable
	if (critState != 0):
		return

	# Prevent the player from moving when attacking
	if (isAttacking):
		if (self.is_on_floor()):
			motion = 0
		else:
			motion = movementInput*AIR_MOVEMENT
		return

	motion = movementInput

	# Differentiate a new jump from a reemitted one
	if (lastJumpId != jumpId):
		lastJumpId = jumpId
		isJumping = true

	# Executes attack and orients the player towards the mouse
	if (attackTypeInput != NONE):
		# Right
		if (mouseX < 0):
			bodyRotation = -1
			self.set_rotation_degrees(Vector3(0, 180, 0))
			broadcastTurn(bodyRotation)

		# Left
		else:
			bodyRotation = 1
			self.set_rotation_degrees(Vector3())
			broadcastTurn(bodyRotation)

		# Upward attack (default)
		attackDirection = MOUSE_UP

		# Left attack
		if (mouseX < 0 && 1.5*mouseX <= mouseY):
			attackDirection = MOUSE_LEFT

		# Right attack
		elif (mouseX >= 0 && 1.5*mouseX >= -mouseY):
			attackDirection = MOUSE_RIGHT
		if (!self.is_on_floor() && mouseY > 0 && 1.5*mouseX < mouseY
			&& 1.5*mouseX > -mouseY):
			attackDirection = MOUSE_DOWN

		# Process the attack according to the direction
		processAttack(attackTypeInput)

	# Pick Item
	if itemInput :
		var list = get_node(gamestate.GAMEPATH+"itemCollection/").get_children()
		for i in list:
			if i.nearItem(ownId):
				match i.typeItem:
					0,1: # item beer, hotdog
						if hp>regainHp:
							hp-=regainHp
						else :
							hp=0
						broadcastHp()
				i.on_timeout_complete()


# Process the movements depending on the inputs
func processMovement(delta:float):
	# Direction/rotation update
	if (motion > 0):
		if (!isAttacking):
			bodyRotation = 1
			self.set_rotation_degrees(Vector3())
			broadcastTurn(bodyRotation)
		if (self.is_on_floor()):
			broadcastAnimation(ANIM_RUN)
		else:
			broadcastAnimation(ANIM_CONTROLLED_FALL)
	elif (motion < 0):
		if (!isAttacking):
			bodyRotation = -1
			self.set_rotation_degrees(Vector3(0, 180, 0))
			broadcastTurn(bodyRotation)
		if (self.is_on_floor()):
			broadcastAnimation(ANIM_RUN)
		else:
			broadcastAnimation(ANIM_CONTROLLED_FALL)
	else:
		if (self.is_on_floor()):
			broadcastAnimation(ANIM_IDLE)
		else:
			broadcastAnimation(ANIM_CONTROLLED_FALL)


	if (self.is_on_floor()):
		# Reset the number of jumps left
		currentJump = 0
		# Reset the last striker
		# lastStrikerId = ownId
	elif (currentJump == 0 && !isJumping):
		# Initial jump prevented
		currentJump = 1

	# Jump attempts computation
	if (isJumping):
		isJumping = false
		if (currentJump < maxJump && !isAttacking):
			broadcastAnimation(ANIM_JUMP)
			currentJump += 1
			# Consider the gravity when jumping
			vel.y = JUMP_SPEED - delta*GRAVITY

	# Consider the gravity
	vel.y += delta*GRAVITY

	# Speed of the player
	var target:Vector3 = Vector3(motion, 0, 0)
	target *= MAX_SPEED

	# Acceleration of the player if he is moving horizontally
	var accel:float
	var hvel:Vector3 = Vector3(vel.x, 0, 0)
	if (target.dot(hvel) > 0):
		accel = ACCEL
	elif (!self.is_on_floor() && !isJumping):
		accel = THROW_MOMENTUM
	else:
		accel = MVMNT_MOMENTUM

	# Interpolating speed and acceleration through time and getting it
	vel.x = hvel.linear_interpolate(target, accel * delta).x

	# Update the velocity after the collisions (physical engine ftw)
	vel.y = self.move_and_slide(vel, FLOOR_NORMAL, true).y


# Check and trigger the attacks ID requested
func processAttack(attackType:int):
	# Turn off the other attacks input for the time being
	isAttacking = true

	# Use the right function
	match attackType:
		PUNCH:
			if (self.is_on_floor()):
				if (attackDirection == MOUSE_UP):
					broadcastAnimation(ANIM_KICK_UP)
					attack(ID_KICK_UP)

				# Sideward attack
				else:
					if (!animSequence):		# Attack sequence even
						animSequence = 1
						broadcastAnimation(ANIM_PUNCH_1)
						attack(ID_PUNCH_1)
					else:					# Attack sequence odd
						animSequence = 0
						broadcastAnimation(ANIM_PUNCH_2)
						attack(ID_PUNCH_2)

			# Midair attack
			else:
				# Upward attack
				if (attackDirection == MOUSE_UP):
					broadcastAnimation(ANIM_JUMP_KICK_UP)
					attack(ID_KICK_JUMP_UP)

				# Downward attack
				elif (attackDirection == MOUSE_DOWN):
					broadcastAnimation(ANIM_JUMP_KICK_DOWN)
					attack(ID_KICK_JUMP_DOWN)

				# Sideward attack
				else:
					broadcastAnimation(ANIM_JUMP_KICK_SIDE)
					attack(ID_KICK_JUMP_SIDE)

		KICK:
			if (self.is_on_floor()):
				if (attackDirection == MOUSE_UP):
					broadcastAnimation(ANIM_KICK_UP)
					attack(ID_KICK_UP)

				# Sideward attack
				else:
					if (!animSequence):		# Attack sequence even
						animSequence = 1
						broadcastAnimation(ANIM_KICK_1)
						attack(ID_KICK_1)
					else:
						animSequence = 0	# Attack sequence odd
						broadcastAnimation(ANIM_KICK_2)
						attack(ID_KICK_2)

			# Midair attack
			else:
				# Upward attack
				if (attackDirection == MOUSE_UP):
					broadcastAnimation(ANIM_JUMP_KICK_UP)
					attack(ID_KICK_JUMP_UP)

				# Downward attack
				elif (attackDirection == MOUSE_DOWN):
					broadcastAnimation(ANIM_JUMP_KICK_DOWN)
					attack(ID_KICK_JUMP_DOWN)

				# Sideward attack
				else:
					broadcastAnimation(ANIM_JUMP_KICK_SIDE)
					attack(ID_KICK_JUMP_SIDE)


# Process the attack according to the ID requested
func attack(idAttack:int):
	# Instanciate the attacks vars
	var hitArea:Area
	var axis:NodePath
	var distance:float
	var wait:float
	var duration:float

	# Initialize the attacks vars
	match idAttack:
		ID_PUNCH_1:	# Even sequence
			hitArea = punchHitArea
			axis = "translation:x"
			distance = punchAttackDist
			wait = punchAttackWait
			duration = punch1AttackDuration

		ID_PUNCH_2:	# Odd sequence
			hitArea = punchHitArea
			axis = "translation:x"
			distance = punchAttackDist
			wait = punchAttackWait
			duration = punch2AttackDuration

		ID_KICK_1:	# Even sequence
			hitArea = kickHitArea
			axis = "translation:x"
			wait = kickAttackWait
			distance = kick1AttackDist
			duration = kick1AttackDuration

		ID_KICK_2:	# Odd sequence
			hitArea = kickHitArea
			axis = "translation:x"
			wait = kickAttackWait
			distance = kick2AttackDist
			duration = kick2AttackDuration

		ID_KICK_UP:
			hitArea = jumpHitArea
			axis = "translation:y"
			wait = jumpAttackWait
			distance = kickUpAttackDist
			duration = kickUpAttackDuration
			jumpAttackDirection = Vector3(0,1,0)

		ID_KICK_JUMP_SIDE:
			hitArea = kickHitArea
			axis = "translation:x"
			wait = kickAttackWait
			distance = kickJumpSideAttackDist
			duration = kickJumpSideAttackDuration

		ID_KICK_JUMP_UP:
			hitArea = jumpHitArea
			axis = "translation:y"
			wait = jumpAttackWait
			distance = jumpUpAttackDist
			duration = jumpUpAttackDuration
			jumpAttackDirection = Vector3(0,1,0)

		ID_KICK_JUMP_DOWN:
			hitArea = jumpHitArea
			axis = "translation:y"
			wait = jumpAttackWait
			distance = jumpDownAttackDist
			duration = jumpDownAttackDuration
			jumpAttackDirection = Vector3(0,-1,0)

	# Set active the hitbox of the attack, its visual feedback on server
	hitArea.set_monitoring(true)
	hitArea.set_visible(true)

	# Prepare the translation as an interpolation over time (end position, duration and function used)
	if !(attackTimer.interpolate_property(hitArea, axis, 0, distance, duration,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)):
		isAttacking = false
		hitArea.set_visible(false)
	if !(attackTimer.start()):
		isAttacking = false
		hitArea.set_visible(false)
	yield(attackTimer, "tween_completed")
	hitArea.set_monitoring(false)
	if !(attackTimer.interpolate_property(hitArea, axis, distance, 0,
	wait-duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)):
		isAttacking = false
		hitArea.set_visible(false)
	if !(attackTimer.start()):
		isAttacking = false
		hitArea.set_visible(false)

	# Once the movement is finished, turn off the hitbox and visual feedback
	yield(attackTimer, "tween_completed")
	isAttacking = false
	hitArea.set_visible(false)


# Called when detected by an attack's hitbox
func hurt(damages:int, sourceId:int, direction:Vector3, strength:float):
	var timerFlag:bool = false

	# Play hurt animation
	if (direction.x < 0):
		broadcastTurn(TURN_RIGHT)
	elif (direction.x > 0):
		broadcastTurn(TURN_LEFT)

	if (hp >= critHP && !(self.is_on_floor() && direction.y < 0)):
		broadcastAnimation(ANIM_BIG_IMPACT)
		broadcastRotateOnHit(Vector2(direction.x,direction.y).angle())
		critState += 1
		timerFlag = true
	elif (self.is_on_floor()):
		if (!animSequence):
			broadcastAnimation(ANIM_IMPACT_1)
			animSequence = 1
		else:
			broadcastAnimation(ANIM_IMPACT_2)
			animSequence = 0
	else:
		broadcastAnimation(ANIM_IMPACT_JUMP)

	# Add damages to your bar
	hp += damages

	# Projection: normalized vector * direction * strength added to the velocity of the player
	vel += strength*hp*IMPACT_FACTOR*direction

	# Update the last played who hit you
	lastStrikerId = sourceId

	# Feedback on the player's client
	broadcastHp()

	if (timerFlag):
		var waitTimer = Timer.new()
		waitTimer.set_wait_time(1)
		waitTimer.set_one_shot(true)
		self.add_child(waitTimer)
		waitTimer.start()
		yield(waitTimer, "timeout")
		waitTimer.queue_free()
		critState -= 1



# Broadcast hps to every player
func broadcastHp():
	gamestate.broadcastHp(self.ownId, hp)


# Give kill to player
func giveKill():
	kills += 1
	gamestate.broadcastKill(self.ownId, kills)

# Broadcast the death and destroy the remote player
func die():
	gamestate.killPlayer(self.ownId, lastStrikerId)
	if (lastStrikerId != self.ownId):
		get_node("../"+str(lastStrikerId)).giveKill()
	self.queue_free()


# Broadcast the directions update
func broadcastTurn(direction:int):
	gamestate.broadcastTurn(self.ownId, direction)


# Make rotation on critical hit
func broadcastRotateOnHit(angle:float):
	gamestate.broadcastRotateOnHit(self.ownId, angle)


# Broadcast the animation
func broadcastAnimation(animationType:int):
	gamestate.broadcastAnimation(self.ownId, animationType)


#################################################################

#################################################################
### SIGNALS


# General function on attack's hitboxes
func _on_generalHitArea_entered(damageVar:int, directionVar:Vector3, strengthVar:float, body:Node):
	# Don't hurt yourself
	if (int(body.name) == ownId):
		return

	# Normalized projection vector
	var direction:Vector3 = directionVar.normalized()

	# Rotate the vector depending on the player orientation
	direction.x *= bodyRotation

	# Call the function on the affected player
	body.hurt(damageVar, ownId, direction, strengthVar)


# Punch has landed on something
func _on_punchHitArea_body_entered(body:Node):
	_on_generalHitArea_entered(punchAttackDmg, punchAttackDirection, punchAttackStrength, body)


# Kick has landed on something
func _on_kickHitArea_body_entered(body:Node):
	_on_generalHitArea_entered(kickAttackDmg, kickAttackDirection, kickAttackStrength, body)


# Midair-hit has landed on semothing
func _on_jumpHitArea_body_entered(body:Node):
	_on_generalHitArea_entered(jumpAttackDmg, jumpAttackDirection, jumpAttackStrength, body)


#################################################################
