extends Node

const APPLE = 1
const SNAKE = 0
var apple_pos : Vector2
var snake_body := [Vector2(4,8), Vector2(3,8), Vector2(2,8)]

func _ready()->void:
	apple_pos = place_apple()
	draw_apple()
	
	
func place_apple() -> Vector2:
	randomize()
	var x = randi() % 15
	var y = randi() % 15
	return Vector2(x,y)


func draw_apple():
	$SnakeApple.set_cell( apple_pos.x, apple_pos.y, APPLE, false, false, false)
	

func draw_snake():
	pass
