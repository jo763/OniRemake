extends KinematicBody

# physics
export var moveSpeed = 10
export var acceleration = 8
export var jumpForce = 40
export var gravity = 1.2
export var sprint_setting = 12
var sprint

# camera
var minLookAngle = -60
var maxLookAngle = 25
export var lookSensitivity = 0.3

# vectors
var velocity = Vector3()

# Node shortcuts
onready var camera = $CameraAnchor
onready var comboTimer = $ComboTimer
# Lists
var comboTimeWindow
var lastCombatMove = ''
# gameplay mechanic
var moveInProgress = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Quits when escape is pressed
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
	var direction_basis = get_global_transform().basis
	var direction = Vector3()
	# Cannot move when doing an attack move
	if moveInProgress == false:
		if Input.is_action_pressed("move_forward"):
			direction -= direction_basis.z
			$CollisionShape/character_rigged_animated3/AnimationPlayer.play("Run")
		else:
			$CollisionShape/character_rigged_animated3/AnimationPlayer.play("Idle")
		if Input.is_action_pressed("move_backward"):
			direction += direction_basis.z
		if Input.is_action_pressed("move_left"):
			direction -= direction_basis.x
		if Input.is_action_pressed("move_right"):
			direction += direction_basis.x
		direction = direction.normalized()
	
	if Input.is_action_pressed("sprint"):
		sprint = sprint_setting
		$CollisionShape/character_rigged_animated3/AnimationPlayer.playback_speed = 2
	else:
		sprint = 0
		$CollisionShape/character_rigged_animated3/AnimationPlayer.playback_speed = 1
	
	
	velocity = velocity.linear_interpolate(direction * (moveSpeed + sprint), acceleration * delta)
	velocity.y -= gravity
	#movementInputs(delta)
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
	velocity = move_and_slide(velocity, Vector3.UP)

	combat()


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera.rotate_x(deg2rad(event.relative.y * lookSensitivity * -1))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
		rotate_y(deg2rad(event.relative.x * lookSensitivity * -1))
	pass

func hurt():
	#set combotimer to zero 
	# take damage depending on type of attack
	# if damage brings health to zero, die
	pass

func combostart(time):
	comboTimer.start(time)
	comboTimeWindow = time * 0.3
	Hud.comboWindow = "Attack move in progress"
	print(comboTimer.time_left)
	moveInProgress = true
	

func combat():
	if comboTimer.is_stopped():
		if Input.is_action_just_pressed("punch"):
			print("punch")
			lastCombatMove = "punch"
			combostart(1.5)
			
		elif Input.is_action_just_pressed("kick"):
			print("kick")
			lastCombatMove = "kick"
			combostart(2)
	elif comboTimer.time_left < comboTimeWindow:
		#print("ATTACK WINDOW")
		Hud.comboWindow = "Can Combo"
		if Input.is_action_pressed("punch") and lastCombatMove == "punch":
			print("Double Punch")
			lastCombatMove = "double punch"
			combostart(2)
		elif Input.is_action_pressed("kick") and lastCombatMove == "double punch":
			print("Spinning Kick")
			lastCombatMove = "spinning kick"
			combostart(2)
		elif Input.is_action_pressed("punch") and lastCombatMove == "double punch":
			print("Triple Punch")
			lastCombatMove = "triple punch"
			combostart(2)
			
	else:
		pass
	Hud.lastComboMove = lastCombatMove
	


func _on_ComboTimer_timeout():
	print("time ran out")
	comboTimer.stop()
	#print(comboTimer.time_left)
	lastCombatMove = ''
	Hud.comboWindow = "Combo Gone"
	print(comboTimer.is_stopped())
	moveInProgress = false
	

