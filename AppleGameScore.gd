extends Label

onready var base_color = modulate

func update_score(apple_score):
	if apple_score == 10:
		text = str(apple_score)
		modulate = Color(100, 100, 100)
	else:
		text = str(apple_score)
		modulate = base_color
	
