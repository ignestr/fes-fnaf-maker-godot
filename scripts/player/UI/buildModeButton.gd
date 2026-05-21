extends Button


@onready var buildSys: DayshiftBuildSystem = $"../../../../../../dayshiftBuildSystem"
enum states {ADD, REMOVE, SELECT, ROOM}
@export var transferState : states

func _ready():
	button_up.connect(bullshit)


func bullshit():
	buildSys.curState = transferState
	
