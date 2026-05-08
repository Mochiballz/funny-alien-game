extends CharacterBody2D

const FLOOR_SNAP_LENGTH = 10.0
const SPEED = 500.0

const JUMP_VELOCITY = -800.0

const DIVE_VELOCITY = 600.0
const DIVE_ROTATE_MAX = 45.0

const BONK_DURATION = 0.5

var is_diving = false
var elapsed_rotate = 0.0
var dive_velocity = velocity

func rotate_on_fall(delta: float):
	var max_rotation = deg_to_rad(DIVE_ROTATE_MAX)
	if $AnimatedSprite2D.flip_h:
		max_rotation *= -1
	rotation = rotate_toward(0.0, max_rotation, ease(elapsed_rotate, 0.2))
	elapsed_rotate += delta / 8

func _ready() -> void:
	set_floor_snap_length(FLOOR_SNAP_LENGTH)

func _physics_process(delta: float) -> void:
	
	# Add animation
	if velocity.x > 1 or velocity.x < -1:
		$AnimatedSprite2D.animation = "running"
	else:
		$AnimatedSprite2D.animation = "idle"
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		$AnimatedSprite2D.animation = "jump"
		
	else:
		rotation = 0.0


	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle dive
	if Input.is_action_just_pressed("dive") and not is_on_floor():
		is_diving = true
		velocity.y = DIVE_VELOCITY
	
	if velocity.y > 1 and is_diving:
		$AnimatedSprite2D.animation = "dive"
		rotate_on_fall(delta)
	else:
		elapsed_rotate = 0.0
		is_diving = false
		
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
