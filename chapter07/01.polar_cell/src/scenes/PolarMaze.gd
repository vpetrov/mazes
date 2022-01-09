extends Node2D

onready var polarWalls := $PolarWalls

var grid:PolarGrid = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if grid != null:
        changeGrid(grid)
        

func changeGrid(grid:PolarGrid) -> void:
    self.grid = grid
    polarWalls.setGrid(grid)

func onGridChanged(grid:PolarGrid) -> void:
    changeGrid(grid)

func updateCurrentGrid() -> void:
    polarWalls.setGrid(grid)
