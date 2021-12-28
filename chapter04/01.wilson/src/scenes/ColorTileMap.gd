extends Node2D

class_name ColorTileMap

export var tile_size := Vector2(64,64)

var distanceGrid:DistanceGrid = null
var maxDistance:int = 0

func setGrid(distanceGrid:DistanceGrid) -> void:
    self.distanceGrid = distanceGrid

    var farthestCell = distanceGrid.distances.farthest()
    maxDistance = distanceGrid.distances.cells[farthestCell]
    update()
    
func colorAt(row:int, col:int) -> Color:
    var cell = distanceGrid.cell(row, col)
    if !distanceGrid.distances.cells.has(cell):
        return Color.black
    var distance:float= distanceGrid.distances.cells[cell]
    var intensity:float= (maxDistance - distance)/float(maxDistance)
    var dark := round(intensity * 255.0)
    var bright := 128.0 + round(intensity * 127.0)
    return Color8(dark, bright, dark)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func _draw() -> void:
    if (distanceGrid == null):
        return
    var top_left := Vector2(0,0)
    for row in range(distanceGrid.nrows):
        for col in range(distanceGrid.ncols):
            var rect = Rect2(top_left, tile_size)
            draw_rect(rect, colorAt(row, col))
            top_left.x += tile_size.x
        top_left.x = 0
        top_left.y += tile_size.y
