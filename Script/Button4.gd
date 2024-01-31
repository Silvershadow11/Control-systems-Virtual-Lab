extends Button


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Button4_pressed() -> void:
	OS.shell_open("https://www.mediafire.com/file/s4l4mpah2od8avh/PlotApp_setup.exe/file")
