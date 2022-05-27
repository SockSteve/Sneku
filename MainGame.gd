extends Node
const APPLE = 21
const FOOD = 4
const SNAKE = 3
const LASERBEAM = 18
const SHIFTBLOCK = 10
const SHIFTBLOCK_SHIFTED = 17
const SHIFTBLOCK_2 = 19
const SHIFTBLOCK_2_SHIFTED = 20
const WATER = 9
const FF_POWER = 12
const LASER_POWER = 13
const BLOCK_SHIFTER_POWER = 14
const SLOWDOWN_POWER = 22
const HEAD_CHANGE_POWER = 23
const BED = 8

onready var dangers = $SnakeApple.get_used_cells_by_id(2)
onready var food = $SnakeApple.get_used_cells_by_id(4)

var snake_body := [Vector2(4,8), Vector2(3,8), Vector2(2,8)]
var snake_dir := Vector2(1, 0)
var snake_save := [[Vector2(4,8), Vector2(3,8), Vector2(2,8)], Vector2(1, 0)]
var screen_right_off = 14
var screen_left_off = 0
var screen_up_off = 0
var screen_down_off = 14

var screen_right__tail_off = 14
var screen_left__tail_off = 0
var screen_up_tail_off = 0
var screen_down_tail_off = 14

var add_food = false
var snake_moved = false
var start_label_change = true

var save_food_eaten_temp_for_retry =[]
var lives = 3
var score = 0
var apple_game_score = 0
var apple_pos = Vector2(0, 0)

var power_up_locations = [Vector2(71,36), Vector2(32,57), Vector2(35,13), Vector2(13,-44), Vector2(22,24)]
var has_laser = false
var shot_laser = false
var laser_collection: Array = []
var has_head_changer = false
var head_changed = false
var has_ff = false
var has_slowdown = false
var has_shifter = false
var shifted = false

#ending variables
onready var bed = $SnakeApple.get_used_cells_by_id(BED)

func _ready()->void:
	$WorldCam.set_as_toplevel(true)
	draw_snake()
	get_tree().call_group("ScoreGroup", "update_score", score)
	get_tree().call_group("ScoreGroup", "update_lives", lives)
	place_apple()
	draw_apple()
	place_powers()


func place_apple():
	randomize()
	var x = randi() % 15
	var y = randi() % 15 + 45
	apple_pos = Vector2(x, y)


func place_powers():
	randomize()
	var powers = [LASER_POWER, HEAD_CHANGE_POWER, FF_POWER, SLOWDOWN_POWER, BLOCK_SHIFTER_POWER]
	power_up_locations.shuffle()
	for powers_index in powers.size():
		$SnakeApple.set_cell(power_up_locations[powers_index].x, power_up_locations[powers_index].y, powers[powers_index])


func draw_apple():
	if $SnakeApple.get_cellv(apple_pos) == -1:
		$SnakeApple.set_cell( apple_pos.x, apple_pos.y, APPLE, false, false, false)
	else:
		place_apple()
		draw_apple()


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
	check_live_up()
	
	if check_get_damage():
		if lives >= 0:
			reset_room()
		else:
			reset_game()
	
	elif add_food:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 1)
		var new_snake_head = body_copy[0] + snake_dir
		body_copy.insert(0, new_snake_head)
		snake_body = body_copy
		add_food = false
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


func _input(_event):
	var snake_head_temp = snake_body[0]
	#Movement
	if Input.is_action_just_pressed("ui_up") and snake_dir != Vector2.DOWN and !snake_moved: 
		snake_dir = Vector2.UP
		snake_moved = true
	if Input.is_action_just_pressed("ui_down") and snake_dir != Vector2.UP and !snake_moved: 
		snake_dir = Vector2.DOWN
		snake_moved = true
	if Input.is_action_just_pressed("ui_left") and snake_dir != Vector2.RIGHT and !snake_moved: 
		snake_dir = Vector2.LEFT
		snake_moved = true
	if Input.is_action_just_pressed("ui_right") and snake_dir != Vector2.LEFT and !snake_moved: 
		snake_dir = Vector2.RIGHT
		snake_moved = true
	
	#Actions
	#fast forward
	if Input.is_action_just_pressed("fast_forward") and has_ff:
		$SnakeTick.wait_time = .1
	elif Input.is_action_just_released("fast_forward") and has_ff:
		$SnakeTick.wait_time = .2
	#fast forward
	if Input.is_action_just_pressed("slowdown") and has_slowdown:
		$SnakeTick.wait_time = .4
	elif Input.is_action_just_released("slowdown") and has_slowdown:
		$SnakeTick.wait_time = .2
	#change tail to head and head to tail
	if Input.is_action_just_pressed("head_change") and has_head_changer:
		change_snake_head_to_tail()
	#shift_block
	if Input.is_action_just_pressed("shift_block") and has_shifter:
		shift_blocks()
	#shoot laser
	if Input.is_action_just_pressed("shoot_laser") and has_laser:
		fire_laser()


func check_food_eaten():
	if apple_pos == snake_body[0]:
		add_food = true
		apple_game_score +=1
		$AppleGameScore.update_score(apple_game_score)
		score += 1
		get_tree().call_group("ScoreGroup", "update_score", score)
		$CrunchSound.play()
		place_apple()
		draw_apple()
		
	else:
		for cookie_pos in food:
			if cookie_pos == snake_body[0]:
				add_food = true
				save_food_eaten_temp_for_retry.append(cookie_pos)
				food.erase(cookie_pos)
				score += 1
				get_tree().call_group("ScoreGroup", "update_score", score)
				$CrunchSound.play()


func check_got_power_up():
	for power_up_location in power_up_locations:
		if power_up_location == snake_body[0] + snake_dir:
			if $SnakeApple.get_cellv(power_up_location) == HEAD_CHANGE_POWER:
				get_tree().call_group("ScoreGroup", "got_power_up", "head_change")
				has_head_changer = true
			if $SnakeApple.get_cellv(power_up_location) == FF_POWER:
				get_tree().call_group("ScoreGroup", "got_power_up", "ff")
				has_ff = true
			if $SnakeApple.get_cellv(power_up_location) == LASER_POWER:
				get_tree().call_group("ScoreGroup", "got_power_up", "laser")
				has_laser = true
			if $SnakeApple.get_cellv(power_up_location) == BLOCK_SHIFTER_POWER:
				get_tree().call_group("ScoreGroup", "got_power_up", "block_shift")
				has_shifter = true
			if $SnakeApple.get_cellv(power_up_location) == SLOWDOWN_POWER:
				get_tree().call_group("ScoreGroup", "got_power_up", "slowdown")
				has_slowdown = true


func fire_laser():
	if !shot_laser:
		var laser_spawn_point = Vector2(snake_body[0] + snake_dir)
		var laser_dir = snake_dir
		var unique_laser: Array = [laser_spawn_point, laser_dir]
		laser_collection.append(unique_laser)
		draw_laser()
		shot_laser = true


func draw_laser():
	for laser_array_index in laser_collection.size():
		var laser_array : Array = laser_collection[laser_array_index]
		var laser_loc : Vector2 = laser_array[0]
		if laser_array[1].x == 0:
			$SnakeApple.set_cell(laser_loc.x, laser_loc.y, LASERBEAM, true, false, false, Vector2(1,0))
		else:
			$SnakeApple.set_cell(laser_loc.x, laser_loc.y, LASERBEAM, false, false, false, Vector2(0,0))


func move_laser():
	delete_tiles(LASERBEAM)
	laser_hit()
	if laser_collection.size() == 0:
		return
	for laser_array_index in laser_collection.size():
		var laser_array: Array = laser_collection[laser_array_index]
		var laser_new_loc: Vector2 = laser_array[0] + laser_array[1] 
		var laser_new_array = [laser_new_loc, laser_array[1]]
		laser_collection[laser_array_index] = laser_new_array


func laser_hit():
	for laser_array_index in laser_collection.size():
		var next_cell = laser_collection[laser_array_index][0] + laser_collection[laser_array_index][1]
		if $SnakeApple.get_cellv(next_cell) != -1:
			laser_collection.remove(laser_array_index)
			if $SnakeApple.get_cellv(next_cell) == SNAKE:
				return true
			elif $SnakeApple.get_cellv(next_cell) == 4:
				return true
			else:
				$SnakeApple.set_cell(next_cell.x, next_cell.y, -1)
				return true
	return false


func change_snake_head_to_tail():
	var snake_tail = snake_body[snake_body.size()-1]
	if $SnakeApple.get_cell_autotile_coord(snake_tail.x, snake_tail.y) == Vector2(0,0):
		snake_dir = Vector2.LEFT
	elif $SnakeApple.get_cell_autotile_coord(snake_tail.x, snake_tail.y) == Vector2(1,0):
		snake_dir = Vector2.RIGHT
	elif $SnakeApple.get_cell_autotile_coord(snake_tail.x, snake_tail.y) == Vector2(0,1):
		snake_dir = Vector2.UP
	elif $SnakeApple.get_cell_autotile_coord(snake_tail.x, snake_tail.y) == Vector2(1,1):
		snake_dir = snake_dir * -1
		snake_dir = Vector2.DOWN
	snake_body.invert()
	head_changed = true
	draw_snake()
	halt_time(.2)


func shift_blocks():
	if !shifted:
		for block in $SnakeApple.get_used_cells_by_id(SHIFTBLOCK):
			$SnakeApple.set_cell(block.x, block.y, SHIFTBLOCK_SHIFTED)
		for block in $SnakeApple.get_used_cells_by_id(SHIFTBLOCK_2_SHIFTED):
			$SnakeApple.set_cell(block.x, block.y, SHIFTBLOCK_2)
		shifted = true
	
	else:
		for block in $SnakeApple.get_used_cells_by_id(SHIFTBLOCK_SHIFTED):
			$SnakeApple.set_cell(block.x, block.y, SHIFTBLOCK)
		for block in $SnakeApple.get_used_cells_by_id(SHIFTBLOCK_2):
			$SnakeApple.set_cell(block.x, block.y, SHIFTBLOCK_2_SHIFTED)
		shifted = false


func check_get_damage()->bool:
	var snake_head = snake_body[0]
	
	if $SnakeApple.get_cellv(snake_body[0] + snake_dir) == WATER:
		if !check_water(snake_body[0] + snake_dir):
			delete_tiles(SNAKE)
			lives -= 1
			get_tree().call_group("ScoreGroup", "update_lives", lives)
			return true
	
	if $SnakeApple.get_cellv(snake_body[0] + snake_dir) == 2:
		delete_tiles(SNAKE)
		lives -= 1
		get_tree().call_group("ScoreGroup", "update_lives", lives)
		return true
		
	
	if $SnakeApple.get_cellv(snake_body[0] + snake_dir) == SHIFTBLOCK or $SnakeApple.get_cellv(snake_body[0] + snake_dir) == SHIFTBLOCK_2:
		delete_tiles(SNAKE)
		lives -= 1
		get_tree().call_group("ScoreGroup", "update_lives", lives)
		return true
	
	for body_part in snake_body.slice(1, snake_body.size()-1):
		if body_part == snake_head:
			lives -= 1
			get_tree().call_group("ScoreGroup", "update_lives", lives)
			return true
	return false


func check_live_up():
	if $SnakeApple.get_cellv(snake_body[0] + snake_dir) == 11:
		lives +=1
		get_tree().call_group("ScoreGroup", "update_lives", lives)


func check_pan_cam():
	var snake_head = snake_body[0]
	
	if snake_head.x > screen_right_off: 
		screen_right_off += 15
		screen_left_off += 15
		$WorldCam.pan_right()
		save_snake_for_retry()
		$AppleGameScore.update_score(apple_game_score)
		apple_game_score = 0
		halt_time(.2)
		
		
	elif snake_head.x < screen_left_off:
		screen_right_off -= 15
		screen_left_off -= 15
		$WorldCam.pan_left()
		save_snake_for_retry()
		$AppleGameScore.update_score(apple_game_score)
		apple_game_score = 0
		halt_time(.2)
		
	elif snake_head.y > screen_down_off:
		screen_down_off += 15
		screen_up_off += 15
		$WorldCam.pan_down()
		save_snake_for_retry()
		$AppleGameScore.update_score(apple_game_score)
		apple_game_score = 0
		halt_time(.2)
		
	elif snake_head.y < screen_up_off:
		screen_down_off -= 15
		screen_up_off -= 15
		$WorldCam.pan_up()
		save_snake_for_retry()
		$AppleGameScore.update_score(apple_game_score)
		apple_game_score = 0
		halt_time(.2)


func save_snake_for_retry():
	var snake_pos_copy = snake_body
	var snake_dir_copy = snake_dir
	snake_save = [snake_pos_copy, snake_dir_copy]
	save_food_eaten_temp_for_retry.clear()


func reset_game():
	get_tree().reload_current_scene()


func reset_room():
	delete_tiles(SNAKE)
	snake_body = snake_save[0]
	snake_dir = snake_save[1]
	snake_moved = false
	score -= save_food_eaten_temp_for_retry.size()
	score -= apple_game_score
	apple_game_score = 0
	get_tree().call_group("ScoreGroup", "update_score", score)
	$AppleGameScore.update_score(apple_game_score)
	
	for eaten_food in save_food_eaten_temp_for_retry:
		food.append(eaten_food)
		$SnakeApple.set_cell(eaten_food.x, eaten_food.y, 4)
	
	save_food_eaten_temp_for_retry.clear()


func check_water(water_coords)->bool:
	var water_score = $SnakeApple.get_cell_autotile_coord(water_coords.x, water_coords.y)
	if water_score == Vector2(1,0) and score < 10:
		return false
	elif water_score == Vector2(3,0) and score < 20:
		return false
	elif water_score == Vector2(5,0) and score < 30:
		return false
	elif water_score == Vector2(9,0) and score < 50:
		return false
	elif water_score == Vector2(3,1) and score < 70:
		return false
	elif water_score == Vector2(5,1) and score < 80:
		return false
	elif water_score == Vector2(11,1) and score <= 100:
		return false
	$SnakeApple.set_cell(water_coords.x, water_coords.y, -1)
	return true


func halt_time(time):
	$SnakeTick.stop()
	yield(get_tree().create_timer(time),"timeout")
	$SnakeTick.start()


func _on_SnakeTick_timeout():
	#check_game_over()
	#draw_apple()
	check_got_power_up()
	move_snake()
	draw_snake()
	#check_pan_cam()
	snake_moved = false
	shot_laser = false
	check_food_eaten()
	#quick and dirty
	if score == 100:
		for bed_part in bed:
			if bed_part == bed[0]:
				$SnakeApple.set_cell(bed_part.x, bed_part.y, BED, false, false, false, Vector2(0,0))
			elif bed_part == bed[bed.size()-1]:
				$SnakeApple.set_cell(bed_part.x, bed_part.y, BED, false, false, false, Vector2(2,0))
			else:
				$SnakeApple.set_cell(bed_part.x, bed_part.y, BED, false, false, false, Vector2(1,0))
			
			if snake_body[0] == bed_part:
				get_tree().change_scene("res://Ending_1.tscn")


func _on_Laser_Tick_timeout():
	move_laser()
	draw_laser()


func _process(delta):
	check_pan_cam()
	
