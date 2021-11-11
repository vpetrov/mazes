extends VBoxContainer

onready var maze2d = preload("res://src/scenes/Maze2D.tscn")
onready var maze2d_iso = preload("res://src/scenes/Maze2DIsometric.tscn")
onready var maze3d = preload("res://src/scenes/Maze3D.tscn")

onready var viewport2d = $ViewportContainer/Viewport
onready var mazeSelect = $PanelContainer/MarginContainer/HBoxContainer/ViewSelect
onready var algorithmSelect = $PanelContainer/MarginContainer/HBoxContainer/AlgorithmSelect
onready var rowsTextEdit = $PanelContainer/MarginContainer/HBoxContainer/RowsTextEdit
onready var columnsTextEdit = $PanelContainer/MarginContainer/HBoxContainer/ColumnsTextEdit

signal change_grid

enum MazeAlgorithm {
	BINARY_TREE,
	SIDEWINDER
}

export var rows:int = 16
export var columns:int = 16

var grid = null
var currentScene = null
var currentAlgorithm = MazeAlgorithm.BINARY_TREE

const mazeOptions = {
	"2D": 0,
	"2D Isometric": 1,
	"3D": 2
}

const algorithmOptions = {
	"Binary Tree": 0,
	"Sidewinder": 1
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	grid = Maze.binary_tree(rows,columns)
	initDisplayOptions()
	initAlgorithmOptions()
	initGridSize(rows, columns)
	_on_MazeSelect_item_selected(0)

func initDisplayOptions() -> void:
	for label in mazeOptions.keys():
		mazeSelect.add_item(label, mazeOptions[label])

func initAlgorithmOptions() -> void:
	for label in algorithmOptions.keys():
		algorithmSelect.add_item(label, algorithmOptions[label])
		
func initGridSize(rows:int, cols:int) -> void:
	rowsTextEdit.text = str(rows)
	columnsTextEdit.text = str(cols)

# Called when the user chooses another Maze View type
func _on_MazeSelect_item_selected(index) -> void:
	var selectedMazeType:int = mazeSelect.get_item_id(index)
	match selectedMazeType:
		0: switchViewportScene(maze2d)
		1: switchViewportScene(maze2d_iso)
		2: switchViewportScene(maze3d)

	
func switchViewportScene(scene:PackedScene) -> void:
	viewport2d.remove_child(viewport2d.get_child(0))
	viewport2d.render_target_update_mode = Viewport.UPDATE_ALWAYS
	currentScene = scene.instance()
	currentScene.grid = grid
	connect("change_grid", currentScene, "onGridChanged")
	viewport2d.add_child(currentScene)

# Called when the user picks another maze algorithm
func _on_AlgorithmSelect_item_selected(index) -> void:
	var selectedAlgorithm:int = algorithmSelect.get_item_id(index)
	match selectedAlgorithm:
		0: currentAlgorithm = MazeAlgorithm.BINARY_TREE
		1: currentAlgorithm = MazeAlgorithm.SIDEWINDER
	switchAlgorithm(currentAlgorithm)
	
func switchAlgorithm(algorithm) -> void:
	match algorithm:
		MazeAlgorithm.BINARY_TREE: switchToBinaryTreeMaze(self.rows, self.columns)
		MazeAlgorithm.SIDEWINDER: switchToSidewinderMaze(self.rows, self.columns)

func switchToBinaryTreeMaze(rows:int, cols:int) -> void:
	grid = Maze.binary_tree(rows, cols)
	emit_signal("change_grid", grid)
	
func switchToSidewinderMaze(rows:int, cols:int):
	grid = Maze.sidewinder(rows, cols)
	emit_signal("change_grid", grid)

func _on_NewMazeButton_pressed() -> void:
	updateMazeSize()
	switchAlgorithm(currentAlgorithm)
	
func updateMazeSize() -> void:
	self.rows = rowsTextEdit.text.to_int()
	self.columns = columnsTextEdit.text.to_int()
