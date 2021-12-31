extends VBoxContainer

onready var colorMaze = preload("res://src/scenes/ColorMaze.tscn")
onready var maze2d = preload("res://src/scenes/Maze2D.tscn")
#onready var maze2d_iso = preload("res://src/scenes/Maze2DIsometric.tscn")
onready var maze3d = preload("res://src/scenes/Maze3D.tscn")

onready var viewport2d = $ViewportContainer/Viewport
onready var mazeSelect = $PanelContainer/MarginContainer/HBoxContainer/ViewSelect
onready var algorithmSelect = $PanelContainer/MarginContainer/HBoxContainer/AlgorithmSelect
onready var rowsTextEdit = $PanelContainer/MarginContainer/HBoxContainer/RowsTextEdit
onready var columnsTextEdit = $PanelContainer/MarginContainer/HBoxContainer/ColumnsTextEdit

signal change_grid
signal show_distances

enum MazeAlgorithm {
    SIDEWINDER,
    BINARY_TREE,
    ALDOUS_BRODER,
    WILSON,
    HUNT_AND_KILL
}

export var rows:int = 64
export var columns:int = 64

var grid = null
var currentScene = null
var currentAlgorithm = MazeAlgorithm.SIDEWINDER
var showDistances := true

const mazeOptions = {
    "Color": 0,
    "2D": 1,
    "3D": 2
}

const algorithmOptions = {
    "Sidewinder": 0,
    "Binary Tree": 1,
    "Aldous-Broder": 2,
    "Wilson": 3,
    "Hunt and Kill": 4
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()
    grid = DistanceGrid.new(rows, columns)
    Maze.sidewinder(grid)
    grid.setStartCell(grid.cell(0,0))
    
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
        0: switchViewportScene(colorMaze)
        1: switchViewportScene(maze2d)
        2: switchViewportScene(maze3d)

    
func switchViewportScene(scene:PackedScene) -> void:
    viewport2d.remove_child(viewport2d.get_child(0))
    viewport2d.render_target_update_mode = Viewport.UPDATE_ALWAYS
    currentScene = scene.instance()
    currentScene.grid = grid
    connect("change_grid", currentScene, "onGridChanged")
    connect("show_distances", currentScene, "onShowDistancesChanged")
    viewport2d.add_child(currentScene)

# Called when the user picks another maze algorithm
func _on_AlgorithmSelect_item_selected(index) -> void:
    var selectedAlgorithm:int = algorithmSelect.get_item_id(index)
    match selectedAlgorithm:
        0: currentAlgorithm = MazeAlgorithm.SIDEWINDER
        1: currentAlgorithm = MazeAlgorithm.BINARY_TREE
        2: currentAlgorithm = MazeAlgorithm.ALDOUS_BRODER
        3: currentAlgorithm = MazeAlgorithm.WILSON
        4: currentAlgorithm = MazeAlgorithm.HUNT_AND_KILL
    switchAlgorithm(currentAlgorithm)
    
func switchAlgorithm(algorithm) -> void:
    match algorithm:
        MazeAlgorithm.SIDEWINDER: switchToSidewinderMaze()
        MazeAlgorithm.BINARY_TREE: switchToBinaryTreeMaze()
        MazeAlgorithm.ALDOUS_BRODER: switchToAldousBroderMaze()
        MazeAlgorithm.WILSON: switchToWilsonMaze()
        MazeAlgorithm.HUNT_AND_KILL: switchToHuntAndKillMaze()
        

func switchToBinaryTreeMaze() -> void:
    grid = DistanceGrid.new(rows, columns)
    Maze.binary_tree(grid)
    grid.setStartCell(grid.cell(0,0))
    
    emit_signal("change_grid", grid)
    
func switchToSidewinderMaze() -> void:
    grid = DistanceGrid.new(rows, columns)
    Maze.sidewinder(grid)
    grid.setStartCell(grid.cell(0,0))
    
    emit_signal("change_grid", grid)
    
func switchToAldousBroderMaze() -> void:
    grid = DistanceGrid.new(rows, columns)
    Maze.aldousBroder(grid)
    grid.setStartCell(grid.cell(0,0))
    
    emit_signal("change_grid", grid)
    
func switchToWilsonMaze() -> void:
    grid = DistanceGrid.new(rows, columns)
    Maze.wilson(grid)
    grid.setStartCell(grid.cell(0,0))
    
    emit_signal("change_grid", grid)
    
func switchToHuntAndKillMaze() -> void:
    grid = DistanceGrid.new(rows, columns)
    Maze.huntKill(grid)
    grid.setStartCell(grid.cell(0,0))
    
    emit_signal("change_grid", grid)

func _on_NewMazeButton_pressed() -> void:
    updateMazeSize()
    switchAlgorithm(currentAlgorithm)
    
func updateMazeSize() -> void:
    self.rows = rowsTextEdit.text.to_int()
    self.columns = columnsTextEdit.text.to_int()


func _on_DistancesCheckbox_toggled(button_pressed: bool) -> void:
    showDistances = button_pressed
    emit_signal("show_distances", showDistances)
    pass # Replace with function body.
