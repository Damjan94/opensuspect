extends Node
class_name BaseMaintenanceTask

# the name of the gui that should represent this task to the user
# as defined in UIManager.menus
export var guiName: String

export var idealOutput = 10.0
export var acceptedRange = 2.0
export var warningRange = 3.0

#The minimum and maximum input with min and max drift velocities
export var inputMinPressure = 0
export var inputMaxPressure = 10
export var inputMaxDrift = 1
export var inputMinDrift = 0.0
export var driftDrift = 0.01
#Possible settings of the dial

export var dialMinValue = 0
export var dialMaxValue = 10.0
export var dialUnit = 0.2
export var outputDrift = 0.2

var frontend

# peers that have opened a gui on their end
var peers = Array()

func register_gui(gui) -> bool:
	# only assign a gui if we don't already have a gui
	if frontend == null:
		frontend = gui
		rpc_id(1, "_register_peer") # tell the server we have opened a gui
			
	# if the gui was previously assigned, the below expression will be false
	return frontend == gui

func unregister_gui(gui):
	if frontend == gui:
		frontend = null
		rpc_id(1, "_unregister_peer") # tell the server we have closed a gui

master func _register_peer():
	var peer_id = get_tree().get_rpc_sender_id()
	if not peers.has(peer_id):
		peers.append(peer_id)
		$Timer.set_has_peers(true)
		
		
master func _unregister_peer():
	peers.erase(get_tree().get_rpc_sender_id())
	if peers.size() < 1:
		# no peers left, no need to waste processing power and network bandwidth
		$Timer.set_has_peers(false)
	
	
var last_timer_fire: float
func _ready():
	set_network_master(1)
	#warning-ignore:return_value_discarded
	MapManager.connect("interacted_with", self, "interacted_with")
	# only the server should start the timer
	if Network.is_network_master():
		# timer is used to save processing power,
		# no need to update tasks every frame
		#warning-ignore:return_value_discarded
		$Timer.connect("timeout", self, "_timer_update")
		

	
func interacted_with(interactNode, _from, _interact_data):
	if interactNode != self:
		return
	if PlayerManager.assignedtasks[0] == 0:
		UIManager.open_menu(get_gui_name(), {"linkedNode": self})
#test if client has correct assigned task
	
master func input_from_gui(new_input_data: Dictionary):
	if not Network.is_network_master():
		rpc_id(1, "input_from_gui", new_input_data)
		return
	_handle_input_from_gui(new_input_data)
	
"""
The child class calls this method.
This method should display a warning to the user
"""
puppet func output_low():
	if Network.is_network_master():
		rpc("output_low")
	
puppet func output_high():
	if Network.is_network_master():
		rpc("output_high")
	
puppet func output_low_critical():
	if Network.is_network_master():
		rpc("output_low_critical")
		
puppet func output_high_critical():
	if Network.is_network_master():
		rpc("output_high_critical")
	
func _timer_update():
	if not Network.is_network_master():
		return
	var current_time = OS.get_ticks_msec()
	var delta = (current_time - last_timer_fire) / 1000
	last_timer_fire = current_time
	update(delta)
	rpc("_update_gui", _get_update_gui_dict())
	
remotesync func _update_gui(gui_update_dict: Dictionary):
	if frontend != null:
		frontend.update_gui(gui_update_dict)
# All of the logic goes into this method
# the _process function calls this if we are the server
func update(_delta):
	pass
	#assert(false) # Never can be called on base class
	
func _get_update_gui_dict() -> Dictionary:
	assert(false) # Never can be called on base class
	return {}
# overwrite this method in your implementation
# and make it return the gui name that you specified in UIManager.menus
func get_gui_name() -> String:
	assert(false) # Never can be called on base class
	return guiName
	
func _handle_input_from_gui(_new_input_data: Dictionary):
	assert(false) # Never can be called on base class
	
