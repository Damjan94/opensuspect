extends WindowDialog
class_name BaseMaintenanceTaskGui

var backend: BaseMaintenanceTask = null
var menuData: Dictionary

func _ready():
	connect("popup_hide", self, "_on_gasvalve_popup_hide")
	
# Implement this to receive updates from the backend
func update_gui(params: Dictionary):
	assert(false)
	pass
	
func open():
	popup()
	UIManager.menu_opened(getGuiName())
	if self.menuData.has("linkedNode"):
		if self.menuData["linkedNode"] is BaseMaintenanceTask:
			backend = self.menuData["linkedNode"]
			var registration_successful: bool = backend.register_gui(self)
			if not registration_successful:
				backend = null
				# TODO show an error saying that we failed to link the backend?
func close():
	hide()
	UIManager.menu_closed(getGuiName())
	if backend != null:
		backend.unregister_gui(self)
		backend = null

func _on_gasvalve_about_to_show():
	pass

func _on_gasvalve_popup_hide():
	UIManager.menu_closed(getGuiName())
	if backend != null:
		backend.unregister_gui(self)
		backend = null

# override this in your implementation. the name should be what you
# wrote in UIManager.menus
func getGuiName() -> String:
	assert(false)
	return "null"
