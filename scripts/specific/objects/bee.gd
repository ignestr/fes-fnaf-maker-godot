extends ObjectScene

enum animations {IDLE, JUMP, HOVER}

func _ready():
	#properties = {&"current_animation" : play}
	#print_rich(play)
	pass


func play(play_anim : animations):
	play_anim * 2
	pass
