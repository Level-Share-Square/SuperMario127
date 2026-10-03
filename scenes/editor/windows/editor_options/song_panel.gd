extends PanelContainer
class_name SongPanel

onready var song_name = $"%SongName"
onready var song_artist = $"%SongArtist"
onready var use_song = $"%UseSong"

onready var icon_select = $"%IconSelect"
onready var icon_current = $"%IconCurrent"
onready var selected_gradient = $"%SelectedGradient"

var id: int

func populate_song(song: LevelSong, song_id: int):
	song_name.text = song.title
	song_artist.text = song.note
	id = song_id
	
func connect_use_button(node: Node):
	use_song.connect("pressed", node, "on_used", [self])

func disable_button(value: bool):
	use_song.disabled = value
	icon_select.visible = not value
	icon_current.visible = value
	selected_gradient.visible = value
