extends Resource
class_name ActionStackAction

var field : DayshiftManager.fields
var idx
var floor_idx : int = 0
var old_data
var new_data

func clone():
	var clone = ActionStackAction.new()
	clone.field = field
	clone.idx = idx
	clone.floor_idx = floor_idx
	clone.old_data = old_data
	clone.new_data = new_data
	return clone
