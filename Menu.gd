extends Control

var save_path = "user://save.dat"
var save_path_settings = "user://save_settings.dat"
var dict : Dictionary = {"sfx_volume": 0, "music_volume": 0, "default_paused": true}
var game_paused = false

func _ready():
	var file = File.new()
	if file.file_exists(save_path_settings):
		var error = file.open(save_path_settings, File.READ)
		if error == OK:
			var volume_data = file.get_var()
			dict = volume_data
			if dict != null:
				for music_piece in get_tree().get_nodes_in_group("music_group"):
					music_piece.volume_db = dict.get("music_volume")
					$ColorRect2/MusicSlider.value = dict.get("music_volume")
					print(dict)
				
				for sfx_piece in get_tree().get_nodes_in_group("sfx_group"):
					sfx_piece.volume_db = dict.get("sfx_volume")
					$ColorRect2/SFXSlider.value = dict.get("sfx_volume")
					print(dict)
				
				$ColorRect2/CheckBox.pressed = dict.get("default_paused")
	

func _on_Btn_Continue_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	self.visible = false
	game_paused = false


func pause_game():
	yield(get_tree(), "idle_frame")
	game_paused = true


func _unhandled_key_input(event):
	if game_paused:
		if Input.is_action_just_pressed("ui_cancel"):
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				get_tree().paused = false
				self.visible = false
				game_paused = false



func _on_deleteSavedata_pressed():
	var file = File.new()
	var error = file.open(save_path, File.WRITE)
	if error == OK:
		var dicc = {}
		file.store_var(dicc)
		file.close()
		print("saved")
		get_tree().paused = false
		self.visible = false
		get_tree().reload_current_scene()


func _on_Btn_Restart_pressed():
	get_tree().paused = false
	self.visible = false
	get_tree().reload_current_scene()


func _on_MusicSlider_value_changed(value):
	for music_piece in get_tree().get_nodes_in_group("music_group"):
		music_piece.volume_db = value
	dict["music_volume"] = value 
	var file = File.new()
	var error = file.open(save_path_settings, File.WRITE)
	if error == OK:
		file.store_var(dict)
		file.close()


func _on_SFXSlider_value_changed(value):
	for sfx_piece in get_tree().get_nodes_in_group("sfx_group"):
		sfx_piece.volume_db = value
	dict["sfx_volume"] = value 
	var file = File.new()
	var error = file.open(save_path_settings, File.WRITE)
	if error == OK:
		file.store_var(dict)
		file.close()


func _on_Btn_Hints_pressed():
	$Hints.visible = true


func _on_CheckBox_pressed():
	dict["default_paused"] = $ColorRect2/CheckBox.pressed
	var file = File.new()
	var error = file.open(save_path_settings, File.WRITE)
	if error == OK:
		file.store_var(dict)
		file.close()
