extends Node2D

var debug = false

func _ready():
	for p in get_tree().get_nodes_in_group("players"):
		$MultiTargetCamera.add_target(p)
		
	var r = $TileMap.get_used_rect()
	$MultiTargetCamera.limit_left = r.position.x * $TileMap.tile_set.tile_size.x
	$MultiTargetCamera.limit_right = r.end.x * $TileMap.tile_set.tile_size.x
	$MultiTargetCamera.limit_bottom = r.end.y * $TileMap.tile_set.tile_size.y

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		debug = !debug

var cam_rect = Rect2()
func draw_cam_rect(r):
	cam_rect = r
	queue_redraw()
	
func _draw():
	if !debug:
		return
	draw_circle($MultiTargetCamera.position, 10, Color.CORAL)
	draw_rect(cam_rect, Color.CORAL, false, 4.0)
