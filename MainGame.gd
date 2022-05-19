extends Node

const APPLE = 1
const SNAKE = 0
var apple_pos : Vector2
var snake_body := [Vector2(4,8), Vector2(3,8), Vector2(2,8)]
var snake_dir := Vector2(1, 0)
var add_apple = false

func _ready()->void:
	apple_pos = place_apple()
	draw_apple()
	draw_snake()


func place_apple() -> Vector2:
	randomize()
	var x = randi() % 15
	var y = randi() % 15
	return Vector2(x,y)


func draw_apple():
	$SnakeApple.set_cell( apple_pos.x, apple_pos.y, APPLE, false, false, false)


func draw_snake():
	for snake_part_index in snake_body.size():
		var snake_part = snake_body[snake_part_index]
		
		if snake_part_index == 0:
			var head_dir = relation2(snake_body[0], snake_body[1])
			if head_dir == 'left':
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false,Vector2(2,0))
			if head_dir == 'right':
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false,Vector2(3,1))
			if head_dir == 'up':
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false,Vector2(3,0))
			if head_dir == 'down':
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false,Vector2(2,1))	
		
		elif snake_part_index == snake_body.size()-1:
			var tail_dir = relation2(snake_body[-1], snake_body[-2])
			if tail_dir == 'left':
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false,Vector2(1,0))
			if tail_dir == 'right':
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false,Vector2(0,0))
			if tail_dir == 'up':
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false,Vector2(1,1))
			if tail_dir == 'down':
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false,Vector2(0,1))
		
		else:
			var prevoius_part = snake_body[snake_part_index + 1] - snake_part
			var next_part = snake_body[snake_part_index - 1] - snake_part
			
			if prevoius_part.x == next_part.x:
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false, Vector2(4,1))
			elif prevoius_part.y == next_part.y:
				$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false, Vector2(4,0))
			else:
				if prevoius_part.x == -1 and next_part.y == -1 or next_part.x == -1 and prevoius_part.y == -1:
					$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, false, false, Vector2(6,1))
				if prevoius_part.x == -1 and next_part.y == 1 or next_part.x == -1 and prevoius_part.y == 1:
					$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, false, true, false, Vector2(6,1))
				if prevoius_part.x == 1 and next_part.y == -1 or next_part.x == 1 and prevoius_part.y == -1:
					$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, true, false, false, Vector2(6,1))	
				if prevoius_part.x == 1 and next_part.y == 1 or next_part.x == 1 and prevoius_part.y == 1:
					$SnakeApple.set_cell(snake_part.x, snake_part.y, SNAKE, true, true, false, Vector2(6,1))


func relation2(first_part:Vector2, second_part:Vector2):
	var part_relation = second_part - first_part
	if part_relation == Vector2.LEFT: return 'left'
	if part_relation == Vector2.RIGHT: return 'right'
	if part_relation == Vector2.UP: return 'up'
	if part_relation == Vector2.DOWN: return 'down'


func move_snake():
	if add_apple:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 1)
		var new_snake_head = body_copy[0] + snake_dir
		body_copy.insert(0, new_snake_head)
		snake_body = body_copy
		add_apple = false
	else:	
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 2)
		var new_snake_head = body_copy[0] + snake_dir
		body_copy.insert(0, new_snake_head)
		snake_body = body_copy


func delete_tiles(id:int):
	var cells = $SnakeApple.get_used_cells_by_id(id)
	for cell in cells:
		$SnakeApple.set_cell(cell.x, cell.y, -1)


func _input(event):
	if Input.is_action_just_pressed("ui_up") and snake_dir != Vector2.DOWN: snake_dir = Vector2.UP
	if Input.is_action_just_pressed("ui_down") and snake_dir != Vector2.UP: snake_dir = Vector2.DOWN
	if Input.is_action_just_pressed("ui_left") and snake_dir != Vector2.RIGHT: snake_dir = Vector2.LEFT
	if Input.is_action_just_pressed("ui_right") and snake_dir != Vector2.LEFT: snake_dir = Vector2.RIGHT


func check_apple_eaten():
	if apple_pos == snake_body[0]:
		apple_pos = place_apple()
		add_apple = true
		get_tree().call_group("ScoreGroup", "update_score", snake_body.size())
		

func check_game_over():
	var snake_head = snake_body[0]
	if snake_head.x > 15 or snake_head.x < 0 or snake_head.y > 15 or snake_head.y < 0:
		reset()
		
	for body_part in snake_body.slice(1, snake_body.size()-1):
		if body_part == snake_head:
			reset()


func reset():
	snake_body = [Vector2(4,8), Vector2(3,8), Vector2(2,8)]
	snake_dir = Vector2(1,0)
	get_tree().call_group("ScoreGroup", "update_score", snake_body.size())


func _on_SnakeTick_timeout():
	move_snake()
	draw_apple()
	draw_snake()
	check_apple_eaten()
	check_game_over()

