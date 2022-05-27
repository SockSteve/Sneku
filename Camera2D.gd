extends Camera2D


var cur_screen := Vector2( 0, 0 )

func pan_left():
	self.position.x -= 600
	
func pan_right():
	position.x += 600
	
func pan_up():
	position.y -= 600
	
func pan_down():
	position.y += 600

func reset():
	position.x = 0
	position.y = 0
