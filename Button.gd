extends Button

export var scene: String = "res://MainGame.tscn"

func _on_Button_pressed():
	get_tree().change_scene(scene)
