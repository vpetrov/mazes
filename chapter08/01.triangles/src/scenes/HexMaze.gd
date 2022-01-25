extends Node2D

onready var hexColorTiles := $HexColorTiles

var grid:HexGrid = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if grid != null:
        changeGrid(grid)
        

func changeGrid(grid:HexGrid) -> void:
    self.grid = grid
    hexColorTiles.setGrid(grid)

func onGridChanged(grid:HexGrid) -> void:
    changeGrid(grid)

func updateCurrentGrid() -> void:
    hexColorTiles.setGrid(grid)
