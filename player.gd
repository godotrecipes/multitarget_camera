extends CharacterBody2D

@export var player_num = 0
@export var speed = 750
@export var jump_speed = -1400
@export var friction = 12
@export var acceleration = 36

var is_jumping = false
var hit = false
var align_speed = 24
var gravity = ProjectSettings.get("physics/2d/default_gravity")

var controls = [
	{
		"walk_right": KEY_D,
		"walk_left": KEY_A,
		"jump": KEY_W,
		"attack": KEY_V},
	{
		"walk_right": KEY_RIGHT,
		"walk_left": KEY_LEFT,
		"jump": KEY_UP,
		"attack": KEY_SLASH}
]

var image_rect = [
	Rect2(1152, 0, 128, 128),
	Rect2(1152, 128, 128, 128)
]

func _ready():
	add_inputs()
	$Sprite2D.region_rect = image_rect[player_num]

func add_inputs():
	var ev
	for action in controls[player_num]:
		var action_name = action + str(player_num)
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		ev = InputEventKey.new()
		ev.keycode = controls[player_num][action]
		InputMap.action_add_event(action_name, ev)

func get_input(delta):
	var dir = 0
	if not hit:
		dir = Input.get_axis("walk_left"+str(player_num),
				"walk_right"+str(player_num))
	if dir != 0:
		$Sprite2D.scale.x = sign(dir)
		velocity.x = lerp(velocity.x, dir * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
	return dir != 0
	
func _physics_process(delta):
	var is_input = get_input(delta)
	velocity.y += gravity * delta
	floor_snap_length = 64 if !is_jumping else 0
	move_and_slide()
	if is_on_floor():
		rotation = lerp(rotation, get_floor_normal().angle() + PI/2, align_speed * delta)
		is_jumping = false
		if Input.is_action_just_pressed("jump"+str(player_num)):
			is_jumping = true
			velocity.y = jump_speed
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider().is_in_group("players"):
			hit_react(col.get_normal())
			col.get_collider().hit_react(-col.get_normal())
			
func hit_react(n):
	if not hit:
		hit = true
		velocity.y = jump_speed / 4.0
		if is_equal_approx(n.y, -1):
			velocity.y += jump_speed / 2.0
		else:
			velocity.x = n.x * 400
		is_jumping = true
		await get_tree().create_timer(0.2).timeout
		hit = false
