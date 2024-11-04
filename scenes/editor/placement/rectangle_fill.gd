extends Control


const TILE_SIZE: int = 32
const TILE: Vector2 = Vector2(TILE_SIZE, TILE_SIZE)

onready var editor: Node = get_owner()
onready var drag: ColorRect = $Node2D/Drag


var selected_box: Node

var editing_layer: int
var placing_button: int

var fill_rect: Rect2
var mouse_pos: Vector2
var mouse_tile_pos: Vector2

var left_down: bool
var right_down: bool

var left_last_down: bool
var right_last_down: bool

func _ready():
	drag.visible = false

func place_tiles():
	fill_rect.size = drag.rect_size.snapped(TILE)/TILE_SIZE

	if mouse_pos.x < fill_rect.position.x*32:
		fill_rect.position.x = round(mouse_pos.x/TILE_SIZE)
	if mouse_pos.y < fill_rect.position.y*32:
		fill_rect.position.y = round(mouse_pos.y/TILE_SIZE)
	
	for y in range(fill_rect.position.y, fill_rect.position.y+fill_rect.size.y):
		for x in range(fill_rect.position.x, fill_rect.position.x+fill_rect.size.x):
			var pos := Vector2(x, y)
			set_tile(pos)

#THANK YOU LB FOR LETTING ME SEE YOUR SCRIPTS <3
#THIS TOOL WOULDN'T WORK AS WELL AS IT DOES WITHOUT YOU GOAT

func set_tile(pos: Vector2):
	var item = selected_box.item
	var shared = editor.shared
	
	if not item.on_place(pos, editor.level_data, editor.level_area): return
	if not editor.level_area.settings.bounds.has_point(pos+Vector2(0.5,0.5)): return
	
	
	var tileset_id: int = item.tileset_id if placing_button == 0 else 0
	var tile_id: int = item.tile_id if placing_button == 0 else 0
	var palette_index: int = item.palette_index if placing_button == 0 else 0
	
	var last_tile = shared.get_tile(pos.x, pos.y, editing_layer)
	
	editor.tiles_stack.append([pos.x, pos.y, editing_layer, last_tile, [tileset_id, tile_id]])
	shared.set_tile(pos.x, pos.y, editing_layer, tileset_id, tile_id, palette_index)



func selected_update():
	if selected_box.item.is_object: return
	
	if drag.visible:
		var calculated_size : Vector2
		# If I had a nickel for every time I had to write a long set of if-else statements for
		# calculating the components of a Vector2, I'd have two nickels. Which isn't a lot,
		# but it's weird it's happened twice now.
		
		#calculating X component for the rectangle
		if mouse_pos.x > fill_rect.position.x*TILE_SIZE:
			drag.rect_position.x = ((fill_rect.position.x)) * TILE_SIZE
			
			calculated_size.x = (fill_rect.position.x - round(mouse_pos.x/TILE_SIZE)) * -TILE_SIZE
			drag.rect_size.x = abs(calculated_size.x)
			drag.rect_scale.x = sign(calculated_size.x)
			
		else:
			drag.rect_position.x = ((fill_rect.position.x)+1) * TILE_SIZE
			
			calculated_size.x = (round(mouse_pos.x/TILE_SIZE - 1) - fill_rect.position.x) * TILE_SIZE
			drag.rect_size.x = abs(calculated_size.x)
			drag.rect_scale.x = sign(calculated_size.x)
		
		
		#calculating the Y component for the rectangle (thrilling stuff I know)
		if mouse_pos.y > fill_rect.position.y*TILE_SIZE:
			drag.rect_position.y = (fill_rect.position.y) * TILE_SIZE
			
			calculated_size.y = (fill_rect.position.y - round(mouse_pos.y/TILE_SIZE)) * -TILE_SIZE
			drag.rect_size.y = abs(calculated_size.y)
			drag.rect_scale.y = sign(calculated_size.y)
			
		else:
			drag.rect_position.y = ((fill_rect.position.y)+1) * TILE_SIZE
			
			calculated_size.y = (round(mouse_pos.y/TILE_SIZE - 1) - fill_rect.position.y) * TILE_SIZE
			drag.rect_size.y = abs(calculated_size.y)
			drag.rect_scale.y = sign(calculated_size.y)
			
			
	## input
	
	if left_down and not left_last_down:
		placing_button = 0
		mouse_down()
	elif right_down and not right_last_down:
		placing_button = 1
		mouse_down()
	
	if not left_down and left_last_down: mouse_up()
	if not right_down and right_last_down: mouse_up()
	
	left_last_down = left_down
	right_last_down = right_down


func mouse_down() -> void:
	fill_rect.position = Vector2(round(mouse_pos.x/TILE_SIZE), round(mouse_pos.y/TILE_SIZE))
	
	drag.rect_position = fill_rect.position*TILE_SIZE + Vector2(8, 8)
	drag.rect_size = TILE
	drag.visible = true
	
	if right_down:
		drag.color = Color(1, 0.1, 0.1, .5)
	else:
		drag.color = Color(1, 1, 1, .5)


func mouse_up() -> void:
	drag.visible = false
	place_tiles()
