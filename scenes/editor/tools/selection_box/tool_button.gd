class_name SelectionToolButton
extends Node

export var associated_tool_path: NodePath
onready var associated_tool: SelectionTool = get_node(associated_tool_path)
