extends Control

@export var units: Array[UnitData] = []
var avialable_units: Array[UnitData] = []
var party_units: Array[UnitData] = []
const PARTY_SIZE: int = 3
var selected_unit: UnitData:
	set(value):
		selected_unit = value
		GameManager.UpdateUnitCard.emit(selected_unit)
var selected_button: PartyButton = null
@export var party_buttons: Array[PartyButton] = []
@export var unit_card: Control

func _ready() -> void:
	GameManager.party_members.clear()
	for button in party_buttons:
		button.PartyButtonPressed.connect(_update_selected_button)
	for i in PARTY_SIZE:
		party_units.append(units[i])
	selected_button = party_buttons[0]
	_update_party_buttons()
	_update_available_units(party_units[0])

func _on_level_select_button_pressed() -> void:
	GameManager.party_members.append_array(party_units)
	SceneTransition.transition(GameManager.Scenes.LEVEL_SELECT, GameManager.Scenes.TEAM_SELECT)

func _update_party_buttons():
	if party_buttons.is_empty():
		return
	if party_buttons.size() > party_units.size():
		return
	for idx in party_buttons.size():
		party_buttons[idx].unit = party_units[idx]

func _update_selected_button(target_button: PartyButton):
	selected_button = null
	for button in party_buttons:
		if button == target_button:
			_update_available_units(target_button.unit)
			selected_button = target_button
	
	for button in party_buttons:
		if button == target_button:
			button.show_selection_indicator()
		else:
			button.hide_selection_indicator()

func _update_available_units(unit_to_select: UnitData):
	avialable_units.clear()
	avialable_units.append_array(units.duplicate())
	var filter_array: Array[UnitData] = []
	for button in party_buttons:
		if button != selected_button:
			filter_array.append(button.unit)
	avialable_units = avialable_units.filter(func(item): return item not in filter_array)
	selected_unit = unit_to_select
	if selected_button:
		selected_button.unit = unit_to_select
	_update_party()

func _update_party():
	if party_buttons.is_empty():
		return
	party_units.clear()
	for button in party_buttons:
		party_units.append(button.unit)

func _on_arrow_button_left_pressed() -> void:
	var idx: int = avialable_units.find(selected_unit)
	_update_available_units(avialable_units[posmod(idx - 1, avialable_units.size())])


func _on_arrow_button_right_pressed() -> void:
	var idx: int = avialable_units.find(selected_unit)
	_update_available_units(avialable_units[posmod(idx + 1, avialable_units.size())])


func _on_main_menu_button_pressed() -> void:
	GameManager.party_members.append_array(party_units)
	SceneTransition.transition(GameManager.Scenes.TITLE_SCREEN, GameManager.Scenes.TEAM_SELECT)
