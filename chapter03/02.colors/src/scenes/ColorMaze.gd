extends Node2D

onready var colorTileMap := $ColorTileMap
onready var lineWalls := $LineWalls

var grid:DistanceGrid = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if grid != null:
        changeGrid(grid)
        
func _input(event) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        var gridCoordinates = positionToCellCoord(event.position)
        var col = gridCoordinates.x
        var row = gridCoordinates.y
        if col >= 0 && row >= 0 && col < grid.ncols && row < grid.nrows:
            onGridClick(grid, row, col)
    
func onGridChanged(grid:DistanceGrid) -> void:
    changeGrid(grid)

func changeGrid(grid:DistanceGrid) -> void:
    self.grid = grid
    grid.setStartCell(grid.cell(0,0))
    colorTileMap.setGrid(grid)
    lineWalls.setGrid(grid)
    
func updateCurrentGrid() -> void:
    colorTileMap.setGrid(grid)
    lineWalls.setGrid(grid)    
            
func positionToCellCoord(pos:Vector2) -> Vector2:
    var x = floor((pos - position).x / colorTileMap.tile_size.x)
    var y = floor((pos - position).y / colorTileMap.tile_size.y)
    return Vector2(int(x), int(y))
    
func onGridClick(grid:Grid, row:int, col:int) -> void:
    grid.setStartCell(grid.cell(row, col))
    updateCurrentGrid()

