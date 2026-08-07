extends Node
class_name ItemActionsManager

onready var editor = owner
onready var editor_camera = $"%EditorCamera"
onready var shared = $"%LevelShared"
onready var selection_actions = $"%SelectionActions"
onready var tile_selection_actions = $"%TileSelectionActions"
onready var paste_action = $"%PasteAction"

signal objects_copied(text)
signal tiles_copied(text)

signal objects_pasted(data)
signal tiles_pasted(data)

signal objects_deleted(objects)
signal tiles_deleted(tiles)

func _ready():
	yield(editor, "ready")
	handle_selection()

func handle_selection():
	var clipboard = JSON.parse(OS.get_clipboard()).result
	paste_action.visible = clipboard is Array || clipboard is Dictionary

	var is_any_selected: bool = false
	if editor.selected_objects:
		show_selection_actions()
		tile_selection_actions.visible = false
		is_any_selected = true
		
	if editor.selected_tiles:
		show_selection_actions()
		tile_selection_actions.visible = true
		is_any_selected = true
		
	if !is_any_selected: hide_selection_actions()

func handle_cut():
    if editor.selected_objects:
	    copy_objects()
		delete_objects()
		return 

	if editor.selected_tiles:
	    copy_tiles()
		delete_tiles()
		return


func handle_copy():
	if editor.selected_objects:
		copy_objects()
		return
		
	if editor.selected_tiles:
		copy_tiles()
		return
	
func handle_paste():
	var clipboard = JSON.parse(OS.get_clipboard()).result
	
	if clipboard[0].substr(0, 1) == "T":
		paste_tiles(clipboard)
	else:
		paste_objects(clipboard)
	
	
func handle_delete():
	if editor.selected_objects:
		delete_objects()
		return
		
	if editor.selected_tiles:
		delete_tiles()
		return

func copy_objects():
	var objects: Array = []
	for object in editor.selected_objects:
		objects.append(object.object_data)

	var text: String = JSON.print([LevelCodeSerializer.serialize_objects(objects), [editor_camera.position.x, editor_camera.position.y]])
	OS.set_clipboard(text)
	handle_selection()
	emit_signal("objects_copied", text)

func copy_tiles():
	var tile_data: TileData = LayerData.tiles_to_tile_data(editor.selected_tiles, CurrentLevelData.current_area.layers[shared.layers.find(editor.layer)].tile_data.chunks)
	
	var text: String = JSON.print([LevelCodeSerializer.serialize_data(tile_data), [editor_camera.position.x, editor_camera.position.y]])
	OS.set_clipboard(text)
	handle_selection()
	emit_signal("tiles_copied", text)
	
func paste_objects(data: Array):
	editor.selected_objects = []
	var objects: Array = LevelCodeDeserializer.deserialize_objects_code(data[0])

	for object in objects:
		object = object as ObjectData
		object.metadata.position += editor_camera.position - Vector2(data[1][0], data[1][1])
		
		editor.selected_objects.append(shared.create_object(object, editor.layer, true))
	
	editor.tool_manager.change_tool("%ObjectSelection")
	get_node("%ObjectSelection").fit_to_bounding_rectangle()
	emit_signal("objects_pasted", data)
	
func paste_tiles(data: Array):
	# Behavior is within tile_selection.gd
	# as it is too centralized to include here.
	editor.tool_manager.change_tool("%TileSelection")
	emit_signal("tiles_pasted", data)
	
func delete_objects():
	var action := EraseObjectBulkAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.objects = editor.selected_objects
	editor.action_manager.commit_action(action)
	
	action.connect("delete_undo", get_node("%ObjectSelection"), "on_undid_delete")
	emit_signal("objects_deleted", editor.selected_objects)
	editor.selected_objects = []
	handle_selection()
	
func delete_tiles():
	var undo_tiles: Dictionary = {}
	for pos in editor.selected_tiles:
		var tile = editor.selected_tiles[pos]
		undo_tiles.get_or_add(pos, shared.get_tile(pos.x, pos.y, editor.layer))
	
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = 0
	action.tile_id = 0
	action.palette = 0
	action.do_tiles = editor.selected_tiles.keys()
	action.undo_tiles = undo_tiles.duplicate(true)
	editor.action_manager.commit_action(action)

	get_node("%TileSelection").reset_bounds()
	emit_signal("tiles_deleted", editor.selected_tiles)
	editor.selected_tiles = {}
	handle_selection()
	
func create_tile_stamp():
	pass
	
func show_selection_actions():
	selection_actions.show()
	
func hide_selection_actions():
	selection_actions.hide()
