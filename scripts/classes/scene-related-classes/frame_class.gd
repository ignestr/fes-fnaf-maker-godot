extends wall_device
class_name entry_frame_device

# Class may be deprecated, I'm only making it in case it becomes relevant later on
# (e.g. needing a separate class to simplify certain behaviors
# like how animatronics don't walk in directly through 
# office entry points but rather wait outside for a given time

@export var borders : Mesh

var type := TYPES.CLEAR
