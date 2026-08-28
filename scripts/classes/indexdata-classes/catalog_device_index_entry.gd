extends Resource
class_name CatalogDevicedexEntry

enum device_types {WALL_DEVICE, GROUND, WALL, ROOF}

@export var id : StringName
@export var device_type : device_types
