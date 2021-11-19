extends Node2D

var lastComboMove
var comboWindow = ''
#= get_node("root/")
#get_node("root/Player/Player").lastCombatMove
onready var displayMessage = $Display/ComboMoveDisplay
onready var comboWindowMessage = $Display/ComboWindow

func _process(delta):
	displayMessage.set_text(lastComboMove)
	comboWindowMessage.set_text(comboWindow)
	pass
