extends Control

func update_lives(lives):
	$HBoxContainer/life_counter/ColorRect2/ColorRect/LifeCounter.text = str(lives)
	
func update_score(score):
	$HBoxContainer/Food_Score/ColorRect/Score.text = str(score)

func got_power_up(power):
	if power == "laser":
		$HBoxContainer/Laser.visible = true
	if power == "ff":
		$HBoxContainer/FF.visible = true
	if power == "slowdown":
		$HBoxContainer/Slowdown.visible = true
	if power == "block_shift":
		$HBoxContainer/Shifter.visible = true
	if power == "head_change":
		$HBoxContainer/HeadChanger.visible = true
