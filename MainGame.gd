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
const MORBID_BLOCK = 25
const BLOCK_WHITE = 26

var save_path = "user://save.dat"
var dict : Dictionary = {"ending_1" : false, "ending_2" : false, "ending_3" : false, "ending_4" : false, "ending_5" : false,
"ending_6" : false, "ending_7" : false, "ending_8" : false, "ending_9" : false, "ending_10" : false, "ending_11" : false, "ending_12" : false}

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
var ending_1_completed = false
var ending_2_completed = false
var ending_3_completed = false
var ending_4_completed = false
var ending_5_completed = false
var ending_6_completed = false
var ending_7_completed = false
var ending_8_completed = false
var ending_9_completed = false
var ending_10_completed = false
var ending_11_completed = false
var ending_12_completed = false
onready var bed : Array = $SnakeApple.get_used_cells_by_id(BED)
onready var morbid_zone = $SnakeApple.get_used_cells_by_id(MORBID_BLOCK)
var morbid_zone_entered = false
var glowing_spot := Vector2(-38, 7)
var portaled = 0
var portaled_finished = true
var hidden_spot = Vector2(-23, 75)
var food_max
var apple_destroyed = false
var walked_over_glowing_spot = false
var cookie_square_1 = []
var cookie_square_1_collected = false
var cookie_square_2 = []
var cookie_square_2_collected = false
var cookie_square_3 = []
var cookie_square_3_collected = false
var cookie_square_4 = []
var cookie_square_4_collected = false

func _ready()->void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$WorldCam.set_as_toplevel(true)
	draw_snake()
	get_tree().call_group("ScoreGroup", "update_score", score)
	get_tree().call_group("ScoreGroup", "update_lives", lives)
	place_apple()
	draw_apple()
	place_powers()
	food_max = food.size()
	$"Cookie Counter".text = str(food.size()) + "/" + str(food_max)

	scan_cookie_squares(Vector2(5, 66), cookie_square_1)
	scan_cookie_squares(Vector2(71, 2), cookie_square_2)
	scan_cookie_squares(Vector2(2, -43), cookie_square_3)
	scan_cookie_squares(Vector2(-35, 10), cookie_square_4)
	
	#load ending flags
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open(save_path, File.READ)
		if error == OK:
			var ending_flags = file.get_var()
			dict = ending_flags
			print(ending_flags)
			if ending_flags != null:
				ending_1_completed = ending_flags.get("ending_1")
				ending_2_completed = ending_flags.get("ending_2")
				ending_3_completed = ending_flags.get("ending_3")
				ending_4_completed = ending_flags.get("ending_4")
				ending_5_completed = ending_flags.get("ending_5")
				ending_6_completed = ending_flags.get("ending_6")
				ending_7_completed = ending_flags.get("ending_7")
				ending_8_completed = ending_flags.get("ending_8")
				ending_9_completed = ending_flags.get("ending_9")
				ending_10_completed = ending_flags.get("ending_10")
				ending_11_completed = ending_flags.get("ending_11")
				ending_12_completed = ending_flags.get("ending_12")
	show_ending_star()

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
	#teleport home
	if Input.is_action_just_pressed("teleport_home"):
		portal_to_home()
	#Menu
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		$CanvasLayer/Menu.visible = true
		$CanvasLayer/Menu.pause_game()

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if !get_tree().paused:
			get_tree().paused = true
			$CanvasLayer/Menu.visible = true
			print("ddd")
		else:
			get_tree().paused = false
			$CanvasLayer/Menu.visible = false
			print("ddd")

func check_food_eaten():
	if apple_pos == snake_body[0] and !apple_destroyed:
		add_food = true
		apple_game_score +=1
		$AppleGameScore.update_score(apple_game_score)
		score += 1
		get_tree().call_group("ScoreGroup", "update_score", score)
		$SFX/CrunchSound.play()
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
				$"Cookie Counter".text = str(food.size()) + "/" + str(food_max)
				$SFX/CrunchSound.play()
				
				if check_cookie_square_eaten(cookie_square_1) == 0 and not cookie_square_1_collected:
					$SnakeApple.set_cell(6, 67, BLOCK_WHITE)
					cookie_square_1_collected = true
				if check_cookie_square_eaten(cookie_square_2) == 0and not cookie_square_2_collected:
					$SnakeApple.set_cell(72, 3, BLOCK_WHITE)
					cookie_square_2_collected = true
				if check_cookie_square_eaten(cookie_square_3) == 0 and not cookie_square_3_collected:
					$SnakeApple.set_cell(3, -42, BLOCK_WHITE)
					cookie_square_3_collected = true
				if check_cookie_square_eaten(cookie_square_4) == 0 and not cookie_square_4_collected:
					$SnakeApple.set_cell(-34, 11, BLOCK_WHITE)
					cookie_square_4_collected = true


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
		$SFX/LaserShoot.play()
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
		if $SnakeApple.get_cellv(next_cell) != -1 and $SnakeApple.get_cellv(next_cell) != MORBID_BLOCK:
			laser_collection.remove(laser_array_index)
			$SFX/LaserHit.play()
			if $SnakeApple.get_cellv(next_cell) == 21:
				apple_destroyed = true
			if $SnakeApple.get_cellv(next_cell) == SNAKE:
				return true
			elif $SnakeApple.get_cellv(next_cell) == 4:
				return true
			elif $SnakeApple.get_cellv(next_cell) == 24:
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
		
	if $SnakeApple.get_cellv(snake_body[0] + snake_dir) == 24:
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
		if apple_game_score != 10:
			$AppleGameScore.update_score(apple_game_score)
			apple_game_score = 0
		portaled = 0
		halt_time(.2)
		
		
	elif snake_head.x < screen_left_off:
		screen_right_off -= 15
		screen_left_off -= 15
		$WorldCam.pan_left()
		save_snake_for_retry()
		if apple_game_score != 10:
			$AppleGameScore.update_score(apple_game_score)
			apple_game_score = 0
		portaled = 0
		halt_time(.2)
		
	elif snake_head.y > screen_down_off:
		screen_down_off += 15
		screen_up_off += 15
		$WorldCam.pan_down()
		save_snake_for_retry()
		if apple_game_score != 10:
			$AppleGameScore.update_score(apple_game_score)
			apple_game_score = 0
		portaled = 0
		halt_time(.2)
		
	elif snake_head.y < screen_up_off:
		screen_down_off -= 15
		screen_up_off -= 15
		$WorldCam.pan_up()
		save_snake_for_retry()
		if apple_game_score != 10:
			$AppleGameScore.update_score(apple_game_score)
			apple_game_score = 0
		portaled = 0
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
	if apple_game_score != 10:
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


func portal_to_home():
	$PortalHome.visible = true
	portaled += 1
	var snake_head_coord = snake_body[0]
	$PortalSnake.position = $SnakeApple.map_to_world(snake_body[0])
	$PortalSnake2.position = $SnakeApple.map_to_world(snake_body[1])
	$PortalSnake.visible = true
	$PortalSnake2.visible = true
	snake_body[0] = Vector2(7,7)
	portaled_finished = false


func check_portal_finished():
	if snake_body[snake_body.size()-1] == Vector2(7,7):
		$PortalHome.visible = false
		$PortalSnake.visible = false
		$PortalSnake2.visible = false
		portaled_finished = true


func halt_time(time):
	$SnakeTick.stop()
	yield(get_tree().create_timer(time),"timeout")
	$SnakeTick.start()


func _on_SnakeTick_timeout():
	#check_game_over()
	#draw_apple()
	if !portaled_finished:
		check_portal_finished()
	check_got_power_up()
	move_snake()
	draw_snake()
	#check_pan_cam()
	snake_moved = false
	shot_laser = false
	check_food_eaten()
	check_end()
	if not morbid_zone_entered:
		check_enter_morbid_zone()


func _on_Laser_Tick_timeout():
	move_laser()
	draw_laser()


func _process(delta):
	check_pan_cam()


func respawn_bed():
	for bed_part in bed:
			if bed_part == bed[0]:
				$SnakeApple.set_cell(bed_part.x, bed_part.y, BED, false, false, false, Vector2(0,0))
			elif bed_part == bed[bed.size()-1]:
				$SnakeApple.set_cell(bed_part.x, bed_part.y, BED, false, false, false, Vector2(2,0))
			else:
				$SnakeApple.set_cell(bed_part.x, bed_part.y, BED, false, false, false, Vector2(1,0))


func check_enter_morbid_zone():
	for coords in morbid_zone:
		if snake_body[0] == coords and not morbid_zone_entered:
			morbid_zone_entered = true
			
	
	if morbid_zone_entered:
		$BGM.stop()


func scan_cookie_squares(cell, square):
	var i = 0
	var j = 0
	while i < 3:
		while j < 3:
			if i != 1 or j != 1:
				square.append(Vector2(cell.x + i, cell.y + j))
			j += 1
		j = 0
		i += 1


func check_cookie_square_eaten(cookie_square)-> int:
	var amnt = 0
	for cookie in cookie_square:
		if $SnakeApple.get_cellv(cookie) == 4:
			amnt += 1
	return amnt


func check_end():
	if score >= 100 and !food.empty() and not morbid_zone_entered:
		ending_1()
	
	elif score == 1:
		ending_2()
		
	elif score == 0 and has_laser:
		ending_3()
		
	elif food.empty():
		ending_4()
	
	elif morbid_zone_entered:
		ending_5()
	
	elif apple_game_score >= 50:
		ending_6()
		
	if snake_body[0] == glowing_spot and score == 0 and not morbid_zone_entered:
		ending_7()
		
	if snake_body[0] == glowing_spot and morbid_zone_entered:
		ending_8()
	
	elif portaled >= 10:
		ending_9()
		
	elif snake_body[0] == hidden_spot and apple_destroyed and cookie_square_1_collected and cookie_square_2_collected and cookie_square_3_collected and cookie_square_4_collected and apple_game_score == 10:
		ending_11()
	
	elif snake_body[0] == hidden_spot:
		ending_10()
	
	if ending_12():
		get_tree().change_scene("res://Endings/Ending_12.tscn")


func save_ending_flag(ending: String, ending_flag: bool):
	dict[ending] = ending_flag
	var file = File.new()
	var error = file.open(save_path, File.WRITE)
	if error == OK:
		file.store_var(dict)
		file.close()
		print("saved")


func show_ending_star():
	if ending_1_completed:
		$EndingVisuals/Ending_Star_1.visible = true
	if ending_2_completed:
		$EndingVisuals/Ending_Star_2.visible = true
	if ending_3_completed:
		$EndingVisuals/Ending_Star_3.visible = true
	if ending_4_completed:
		$EndingVisuals/Ending_Star_4.visible = true
	if ending_5_completed:
		$EndingVisuals/Ending_Star_5.visible = true
	if ending_6_completed:
		$EndingVisuals/Ending_Star_6.visible = true
	if ending_7_completed:
		$EndingVisuals/Ending_Star_7.visible = true
	if ending_8_completed:
		$EndingVisuals/Ending_Star_8.visible = true
	if ending_9_completed:
		$EndingVisuals/Ending_Star_9.visible = true
	if ending_10_completed:
		$EndingVisuals/Ending_Star_10.visible = true
	if ending_11_completed:
		$EndingVisuals/Ending_Star_11.visible = true
	if ending_1_completed and ending_2_completed and ending_3_completed and ending_4_completed and ending_5_completed and ending_6_completed and ending_7_completed and ending_8_completed and ending_9_completed and ending_10_completed and ending_11_completed:
		$EndingVisuals/glow_ending_12.visible = true
	if ending_12_completed:
		$EndingVisuals/Ending_Star_12.visible = true

# score 100 -> Bed
func ending_1():
	respawn_bed()
	for bed_part in bed:
		if snake_body[0] == bed_part:
			ending_1_completed = true
			save_ending_flag("ending_1", ending_1_completed)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene("res://Endings/Ending_1.tscn")


# score 1 -> Bed
func ending_2():
	
	respawn_bed()
	for bed_part in bed:
		if snake_body[0] == bed_part:
			ending_2_completed = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			save_ending_flag("ending_2", ending_2_completed)
			get_tree().change_scene("res://Endings/Ending_2.tscn")
	
# score 0 + has_laser -> Bed
func ending_3():
	respawn_bed()
	for bed_part in bed:
		if snake_body[0] == bed_part:
			ending_3_completed = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			save_ending_flag("ending_3", ending_3_completed)
			get_tree().change_scene("res://Endings/Ending_3.tscn")

# score == cookie amount glutton
func ending_4():
	respawn_bed()
	for bed_part in bed:
		if snake_body[0] == bed_part:
			ending_4_completed = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			save_ending_flag("ending_4", ending_4_completed)
			get_tree().change_scene("res://Endings/Ending_4.tscn")

# go morbid realms -> Bed
func ending_5():
	respawn_bed()
	for bed_part in bed:
		if snake_body[0] == bed_part:
			ending_5_completed = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			save_ending_flag("ending_5", ending_5_completed)
			get_tree().change_scene("res://Endings/Ending_5.tscn")

# 50 fruits
func ending_6():
	ending_6_completed = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	save_ending_flag("ending_6", ending_6_completed)
	get_tree().change_scene("res://Endings/Ending_6.tscn")

# score 0 -> glowing spot
func ending_7():
	ending_7_completed = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	save_ending_flag("ending_7", ending_7_completed)
	get_tree().change_scene("res://Endings/Ending_7.tscn")

# go morbid realms -> glowing spot
func ending_8():
	ending_8_completed = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	save_ending_flag("ending_8", ending_8_completed)
	get_tree().change_scene("res://Endings/Ending_8.tscn")
	
# portal 10 times in the same room
func ending_9():
	ending_9_completed = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	save_ending_flag("ending_9", ending_9_completed)
	get_tree().change_scene("res://Endings/Ending_9.tscn")

# hidden spot in morbid realms
func ending_10():
	ending_10_completed = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	save_ending_flag("ending_10", ending_10_completed)
	get_tree().change_scene("res://Endings/Ending_10.tscn")

# enigma
# score at least 10 apple
# eat all rings of cookies
# destroy fruit
# -> hidden spot
func ending_11():
	ending_11_completed = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	save_ending_flag("ending_11", ending_11_completed)
	get_tree().change_scene("res://Endings/Ending_11.tscn")

# get all other endings -> Bed
func ending_12():
	if ending_1_completed and ending_2_completed and ending_3_completed and ending_4_completed and ending_5_completed and ending_6_completed and ending_7_completed and ending_8_completed and ending_9_completed and ending_10_completed and ending_11_completed and snake_body[0] == Vector2(22, 7):
		ending_12_completed = true
		save_ending_flag("ending_12", ending_12_completed)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return true
	return false
