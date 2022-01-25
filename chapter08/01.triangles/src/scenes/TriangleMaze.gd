extends Node2D

onready var triangleColorTiles := $TriangleColorTiles

var grid:TriangleGrid = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if grid != null:
        changeGrid(grid)
        

func changeGrid(grid:TriangleGrid) -> void:
    self.grid = grid
    triangleColorTiles.setGrid(grid)

func onGridChanged(grid:TriangleGrid) -> void:
    changeGrid(grid)

func updateCurrentGrid() -> void:
    triangleColorTiles.setGrid(grid)
