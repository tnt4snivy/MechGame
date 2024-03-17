extends CharacterBody3D


var SPEED = 3.0
const JUMP_VELOCITY = 7
var MAX_BOOST_POWER=9
var BOOST_ACCELERATION=0.5
var HORIZONTAL_BOOST_SPEED=2
var bullet_instance

@onready var pivot=$CameraOrigin
@onready var sens=0.1
@onready var gun = $CameraOrigin/SpringArm3D/Camera3D/Gun
@onready var gun_barrel = $CameraOrigin/SpringArm3D/Camera3D/Gun/gunBarrel


var bullet=load("res://scenes/bullet.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x*sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y*sens))
		pivot.rotation.x=clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y+=JUMP_VELOCITY
	
	if Input.is_action_pressed("boost"):
		if not is_on_floor():
			velocity.y+=BOOST_ACCELERATION
			velocity.y=clamp(velocity.y, 0, MAX_BOOST_POWER)
			SPEED+=HORIZONTAL_BOOST_SPEED/2
		else:
			SPEED+=HORIZONTAL_BOOST_SPEED
		
	if Input.is_action_just_released("boost"):
		SPEED=3.0
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		SPEED=clamp(SPEED,0,8)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if Input.is_action_just_pressed("shoot"):
		if Input.mouse_mode==Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
		else:
			bullet_instance=bullet.instantiate()
			bullet_instance.position=gun_barrel.global_position
			bullet_instance.transform.basis=gun_barrel.global_transform.basis
			get_parent().add_child(bullet_instance)
	
	move_and_slide()

