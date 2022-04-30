extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	add_items()
	
func add_items():
	self.add_item("Lag Compensator")
	self.add_separator()
	self.add_item("Lead Compensator")
	self.add_separator()
#	self.add_item("Lag-Lead Compensator")
#	self.add_separator()

