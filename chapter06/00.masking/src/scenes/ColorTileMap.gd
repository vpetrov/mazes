extends Node2D

class_name ColorTileMap

export var tile_size := Vector2(4,4)
export var show_dead_ends := false

var distanceGrid:DistanceGrid = null
var maxDistance:int = 0

func setGrid(distanceGrid:DistanceGrid) -> void:
    self.distanceGrid = distanceGrid
    var visibleArea = get_viewport_rect().size
    tile_size = Vector2(visibleArea.x / distanceGrid.ncols, visibleArea.y / distanceGrid.nrows)

    var farthestCell = distanceGrid.distances.farthest()
    maxDistance = distanceGrid.distances.cells[farthestCell]
    update()
    
func colorAt(row:int, col:int) -> Color:
    var cell = distanceGrid.cell(row, col)
    if !distanceGrid.distances.cells.has(cell) || maxDistance <= 0:
        return Color.black
    if show_dead_ends && distanceGrid.deadEnds().has(cell):
        return Color(0.9, 0.9, 0.9)
    var distance:float= distanceGrid.distances.cells[cell]
    var intensity:float= (maxDistance - distance)/float(maxDistance)
    var green = 1.0
    if intensity < 0.5:
        green = intensity * 2
        
    var ambient = 0.05
        
    intensity = range_lerp(intensity, 0.0, 1.0, ambient, 1.0)
    green = range_lerp(green, 0.0, 1.0, ambient, 1.0)
    return Color(intensity, green, intensity)

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

func setShowDeadEnds(value:bool) -> void:
    show_dead_ends = value
    update()
