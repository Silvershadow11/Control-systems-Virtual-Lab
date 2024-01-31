extends Node2D

onready var startBut: Button = get_node("Start")
onready var stopBut: Button = get_node("Stop")
onready var resetBut: Button = get_node("Reset")
onready var desHeight: SpinBox = get_node("DesiredHeight")
onready var currHeight: SpinBox = get_node("CurrHeight")
onready var timeBox: SpinBox = get_node("TimeTaken")
onready var errorBox: SpinBox = get_node("Error")
# onready var timer = get_node("TimeTaken/Timer2")
onready var plot: Button = get_node("Plot")
onready var yPos: TextureRect = get_node("Cover")
onready var popUp: FileDialog = get_node("Plot_dialog")
onready var height_meter: VSlider = get_node("VSlider")
onready var disturbance_but: CheckButton = get_node("Disturbance_button")
onready var disturbance_slider: HSlider = get_node("Disturbance_button/HSlider")
onready var disturbance_label: Label = get_node("Disturbance_button/HSlider/dist_slider_val")

var temp: float
var originalHeight: float
var finalHeight: float
var detectPress


var ch: float
var dh: float

var flag: bool

var dict = {
	0:0
}

# default path
var filePath: String = "C:\\Users\\dstev\\OneDrive\\Desktop\\Open_loop.txt"

var H0: float # H(k-1)
var H: float # H(K)
var U0: float # U(k-1)
var U: float # U(k)
var E0: float # E(k-1)
var E: float # E(K)

var Uf : float # Feed forward control to linearize the system
var A: float # Surface Area of tank
var apipe: float # Area of the pipe

var Ts : float # Sampling time period
var Ud :float # Disturbance in water flow
var Ur: float # Randomness added to the water flow
var Hm: float # Measured height



# Called when the node enters the scene tree for the first time.
func _ready():
	originalHeight = yPos.rect_position.y # 135 units
	finalHeight = -182.0 # Y-axis value denoting 100% fill
	temp = (originalHeight - finalHeight)/100 # 1 unit = temp units in godot y axis
	print("All ready!")
	print("Original Height: ", originalHeight)
	print("Final height: ", finalHeight)
	
	H = 0
	U = 0
	H0 = 0
	U0 = 0
	E0 = 0
	Hm = 0
	
	flag = true
	

func _physics_process(delta):
	
	Ts = delta * 10 # Speed up process by 10
		
	# Desired Height
	dh = desHeight.value
	
	if disturbance_but.pressed:
		disturbance_slider.editable = true
		Ud = disturbance_slider.value
		disturbance_label.text = str(Ud) + " litres/hr"
	else:
		disturbance_slider.editable = false
		disturbance_label.text = ""
		
	if startBut.pressed:
		detectPress = true
	if stopBut.pressed:
		detectPress = false
		disturbance_slider.editable = true
		disturbance_but.disabled = false
		
	if detectPress == true:
		if E != 10000:
			
			E = dh - Hm
			
			# Time elapsed
			timeBox.value += delta
			errorBox.value = E
			currHeight.value = Hm
			
			# dont allow to change values during the simulation
			disturbance_slider.editable = false
			disturbance_but.disabled = true
			
			# Adding to dict
			dict[timeBox.value] = Hm
			
			
			# U = Litres/hr (From compensator)
			# H = cm
			# Area = cm^2 (pi*d^2/4, d = 15cm) 
			# Gravity(g) = cm/s^2 (981)
			
#			A = 3.14 * 225/4;
#			A = 176.71
			A = PI * pow(15,2)/4
			
			apipe = 0.1963
			
			Uf = 3.6 * apipe * sqrt(2*981*dh)
			Ur = (randf() - 0.5) * 2
			
			if H0 < 0:
				H0 = 0
			
			U = 0
			H = H0 + ( (apipe * -1 * sqrt(2*981*H0) + (U+Uf+Ud+Ur)/3.6)/A ) * Ts
			
			Hm = H + (randf() - 0.5) * 0.5
			if Hm < 0:
				Hm = 0
			
			H0 = H
			
			yPos.rect_position.y = originalHeight - temp*H
			
			height_meter.value = Hm
			
			if E < 0.001:
				E = 10000
			
	
	if resetBut.pressed:
		detectPress = false
		yPos.rect_position.y = originalHeight
		ch = 0
		H = 0
		E = 0
		H0 = 0
		E0 = 0
		currHeight.value = 0
		timeBox.value = 0
		errorBox.value = 0
		height_meter.value = 0
		disturbance_but.pressed = false
		dict.clear()
#		print(dict)
	
	if plot.pressed:
		# writeToFile()
		var x = timeBox.value
		while x <= 200:
			x = x+0.1
			dict[x] = Hm + (randf() - 0.5) * 0.5
		popUp.popup_centered_ratio(0.5)
		
#	print("Height : ", ch)
	


func _on_Plot_dialog_file_selected(path: String) -> void:
	# print(path)
	writeToFile(path)

func writeToFile(path: String):
	
	if path[len(path) - 1] == '/':
		path = path + "Open_loop.txt"
	
	var saveFile = File.new()
	saveFile.open(path, File.WRITE)
	
	saveFile.store_line(to_json(dict))
	saveFile.close()
	



