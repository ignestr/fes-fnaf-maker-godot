extends ObjectScene
class_name light_object

@export var property_light_color : Color = Color(1.0, 0.895, 0.7, 1.0):
	set(new):
		property_light_color = new
		hide_light_point.light_color = new

@export var property_light_brightness : float = 4.0:
	set(new):
		property_light_brightness = new
		hide_light_point.light_energy = new

@export var property_light_range : float = 16:
	set(new):
		property_light_range = new
		hide_light_point.omni_range = new

@export var property_adv_light_distance_fade_dist : float = 40.0:
	set(new):
		property_adv_light_distance_fade_dist = new
		hide_light_point.distance_fade_length = new

@export var property_light_shadow : bool = false:
	set(new):
		property_light_shadow = new
		hide_light_point.shadow_enabled = new

@export var property_adv_light_distance_fade : bool = false:
	set(new):
		property_adv_light_distance_fade = new
		hide_light_point.distance_fade_enabled = new

@export var property_light_flicker : bool = false:
	set(new):
		property_light_flicker = new
		flicker()

@export var hide_light_point : Light3D


func flicker():
	if property_light_flicker:
		hide_light_point.light_energy -= property_light_brightness /randi_range(2, 5)
		await get_tree().create_timer(randf_range(0.1, 1)).timeout
		hide_light_point.light_energy = property_light_brightness
		await get_tree().create_timer(randf_range(0.1, 10)).timeout
		flicker()
