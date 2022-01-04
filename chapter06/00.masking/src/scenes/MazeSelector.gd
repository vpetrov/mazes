extends VBoxContainer

onready var colorMaze = preload("res://src/scenes/ColorMaze.tscn")
onready var maze2d = preload("res://src/scenes/Maze2D.tscn")
#onready var maze2d_iso = preload("res://src/scenes/Maze2DIsometric.tscn")
onready var maze3d = preload("res://src/scenes/Maze3D.tscn")

onready var viewport2d = $ViewportContainer/Viewport
onready var menuContainer = $PanelContainer/MarginContainer
onready var mazeSelect = $PanelContainer/MarginContainer/HBoxContainer/ViewSelect
onready var algorithmSelect = $PanelContainer/MarginContainer/HBoxContainer/AlgorithmSelect
onready var rowsTextEdit = $PanelContainer/MarginContainer/HBoxContainer/RowsTextEdit
onready var columnsTextEdit = $PanelContainer/MarginContainer/HBoxContainer/ColumnsTextEdit
onready var deadEndsLabel = $PanelContainer/MarginContainer/HBoxContainer/DeadEndsLabel
onready var maskedMazeButton = $PanelContainer/MarginContainer/HBoxContainer/NewMaskedMazeButton
onready var maskPanel = $PanelContainer/MarginContainer/HBoxContainer/MaskPopupPanel
onready var maskGrid = $PanelContainer/MarginContainer/HBoxContainer/MaskPopupPanel/MaskGrid

signal change_grid
signal show_distances
signal show_dead_ends

enum MazeAlgorithm {
    SIDEWINDER,
    BINARY_TREE,
    ALDOUS_BRODER,
    WILSON,
    HUNT_AND_KILL,
    RECURSIVE_BACKTRACKER
}

export var rows:int = 128
export var columns:int = 128

var grid = null
var currentScene = null
var currentAlgorithm = MazeAlgorithm.RECURSIVE_BACKTRACKER
var showDistances := true
var last_start_cell = Vector2(0,0)

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
    "Hunt and Kill": 4,
    "Recursive Backtracker": 5
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()
    grid = DistanceGrid.new(rows, columns)
    grid.init()
    var start_cell = grid.cell(0,0)
    Maze.recursiveBacktracker(grid, start_cell)
    grid.setStartCell(start_cell)
    updateDeadEnds()
    
    initDisplayOptions()
    initAlgorithmOptions()
    initGridSize(rows, columns)
    _on_MazeSelect_item_selected(0)
    algorithmSelect.select(5)

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
    connect("show_dead_ends", currentScene, "onShowDeadEnds")
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
        5: currentAlgorithm = MazeAlgorithm.RECURSIVE_BACKTRACKER
    switchAlgorithm(currentAlgorithm)
    
func switchAlgorithm(algorithm) -> void:
    match algorithm:
        MazeAlgorithm.SIDEWINDER: switchToSidewinderMaze(last_start_cell.y, last_start_cell.x)
        MazeAlgorithm.BINARY_TREE: switchToBinaryTreeMaze(last_start_cell.y, last_start_cell.x)
        MazeAlgorithm.ALDOUS_BRODER: switchToAldousBroderMaze(last_start_cell.y, last_start_cell.x)
        MazeAlgorithm.WILSON: switchToWilsonMaze(last_start_cell.y, last_start_cell.x)
        MazeAlgorithm.HUNT_AND_KILL: switchToHuntAndKillMaze(last_start_cell.y, last_start_cell.x)
        MazeAlgorithm.RECURSIVE_BACKTRACKER: switchToRecursiveBacktracker(last_start_cell.y, last_start_cell.x)
    updateDeadEnds()
        

func switchToBinaryTreeMaze(start_row:int, start_col:int) -> void:
    grid = DistanceGrid.new(rows, columns)
    grid.init()
    var start_cell = grid.cell(start_row, start_col)
    Maze.binary_tree(grid, start_cell)
    grid.setStartCell(start_cell)
    
    emit_signal("change_grid", grid)
    
func switchToSidewinderMaze(start_row:int, start_col:int) -> void:
    grid = DistanceGrid.new(rows, columns)
    grid.init()
    var start_cell = grid.cell(start_row, start_col)
    Maze.sidewinder(grid, start_cell)
    grid.setStartCell(start_cell)
    
    emit_signal("change_grid", grid)
    
func switchToAldousBroderMaze(start_row:int, start_col:int) -> void:
    grid = DistanceGrid.new(rows, columns)
    grid.init()
    var start_cell = grid.cell(start_row, start_col)
    Maze.aldousBroder(grid, start_cell)
    grid.setStartCell(start_cell)
    
    emit_signal("change_grid", grid)
    
func switchToWilsonMaze(start_row:int, start_col:int) -> void:
    grid = DistanceGrid.new(rows, columns)
    grid.init()
    var start_cell = grid.cell(start_row, start_col)
    Maze.wilson(grid, start_cell)
    grid.setStartCell(start_cell)
    
    emit_signal("change_grid", grid)
    
func switchToHuntAndKillMaze(start_row:int, start_col:int) -> void:
    grid = DistanceGrid.new(rows, columns)
    grid.init()
    var start_cell = grid.cell(start_row, start_col)
    Maze.huntKill(grid, start_cell)
    grid.setStartCell(start_cell)
    
    emit_signal("change_grid", grid)
    
func switchToRecursiveBacktracker(start_row:int, start_col:int) -> void:
    grid = DistanceGrid.new(rows, columns)
    grid.init()
    var start_cell = grid.random_cell()
    
    Maze.recursiveBacktracker(grid, start_cell)
    grid.setStartCell(start_cell)
    
    emit_signal("change_grid", grid)
    
func newMaskedGrid(resourcePath:String) -> void:
    var size = Vector2(columns,rows)
    var mask = MaskFactory.fromImage(resourcePath, size)
    grid = MaskedDistanceGrid.new(mask)
    grid.init()
    var start_cell = grid.random_cell()
    
    Maze.recursiveBacktracker(grid, start_cell)
    grid.setStartCell(start_cell)
    updateDeadEnds()
    
    emit_signal("change_grid", grid)

func _on_NewMazeButton_pressed() -> void:
    updateMazeSize()
    switchAlgorithm(currentAlgorithm)
    updateDeadEnds()
    
func updateMazeSize() -> void:
    self.rows = rowsTextEdit.text.to_int()
    self.columns = columnsTextEdit.text.to_int()


func _on_DistancesCheckbox_toggled(button_pressed: bool) -> void:
    showDistances = button_pressed
    emit_signal("show_distances", showDistances)
    pass # Replace with function body.
    
func updateDeadEnds() -> void:
    var ndeadEnds = grid.deadEnds().size()
    deadEndsLabel.text = "Dead Ends: " + str(ndeadEnds)

func _on_DeadEndsCheckbox_toggled(button_pressed: bool) -> void:
    emit_signal("show_dead_ends", button_pressed)

func _on_NewMaskedMaze_pressed() -> void:
    updateMazeSize()
    if maskGrid.get_children().empty():
        prepareMaskPanel()
    maskPanel.popup()

func prepareMaskPanel() -> void:
    var images = [
        "pattern_01.png",
        "pattern_02.png",
        "pattern_07.png",
        "pattern_10.png",
        "pattern_11.png",
        "pattern_12.png",
        "pattern_16.png",
        "pattern_19.png",
        "pattern_21.png",
        "pattern_24.png",
        "pattern_27.png",
        "pattern_32.png",
        "pattern_38.png",
        "pattern_45.png",
        "pattern_57.png",
        "pattern_58.png",
        "pattern_72.png",
        "pattern_77.png",
        "pattern_80.png",
        "pattern_83.png",
       ]
    maskGrid.columns = 4
    maskPanel.set_position(maskedMazeButton.rect_position +  Vector2(menuContainer.margin_left, menuContainer.rect_size.y))
    
    for filename in images:
        var resourcePath = "res://masks/" + filename
        var image := Image.new()
        image.load(resourcePath)
        image.resize(128,128)
        var imageTexture = ImageTexture.new()
        imageTexture.create_from_image(image)
        
        var icon := TextureRect.new()
        icon.texture = imageTexture
        icon.stretch_mode = TextureRect.STRETCH_KEEP
        icon.size_flags_horizontal = SIZE_SHRINK_CENTER
        icon.connect("gui_input", self, "onMaskIconClicked", [icon, resourcePath])
        
        maskGrid.add_child(icon)
    
func onMaskIconClicked(event:InputEvent, icon:TextureRect, resourcePath:String) -> void:
    if event is InputEventMouseButton:
        print("onMaskIconClicked", resourcePath)
        if event.button_index == BUTTON_LEFT and event.pressed:
            icon.accept_event()
            newMaskedGrid(resourcePath)
            maskPanel.hide()
