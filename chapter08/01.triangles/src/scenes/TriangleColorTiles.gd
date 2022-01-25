extends Node2D

class_name TriangleColorTiles

export var cell_size := Vector2(10.0, 10.0)
export var color := Color.black
export var border_width := 2
export var spacing := 0

var grid:TriangleGrid = null
var maxDistance:int = 0

#vertical hex height is incorrect for some reason

func _ready() -> void:
    grid = TriangleGrid.new(128, 128)
    grid.init()
    Maze.recursiveBacktracker(grid, grid.cell(0,0))
    grid.setStartCell(grid.cell(0,0))
    var farthestCell = grid.distances.farthest()
    maxDistance = grid.distances.cells[farthestCell]
    cell_size = getCellSize()
    

func getCellSize() -> Vector2:
    var visibleArea = get_viewport_rect().size
    
    return Vector2((visibleArea.x / (grid.ncols + 1)) * 2.0, (visibleArea.y / grid.nrows) * 1.1 ) 

func setGrid(grid:TriangleGrid) -> void:
    self.grid = grid
    var farthestCell = grid.distances.farthest()
    maxDistance = grid.distances.cells[farthestCell]
    cell_size = getCellSize()
    update()

func _draw() -> void:
    var triangleWidth := cell_size.x
    var halfTriangleWidth := triangleWidth / 2.0
    
    var triangleHeight := cell_size.y * (sqrt(3) / 2.0)
    var halfTriangleHeight := triangleHeight / 2.0
    
    var imageWidth := triangleWidth * (grid.ncols + 1) / 2.0
    var imageHeight := triangleHeight * grid.nrows
    
    for row in range(grid.nrows):
        for col in range(grid.ncols):
            var cell:TriangleCell = grid.cell(row, col)
            
            var cx := halfTriangleWidth * (cell.col + 1)
            var cy := triangleHeight * (cell.row + 1)
            
            var westX := (cx - halfTriangleWidth)
            var midX := cx
            var eastX := (cx + halfTriangleWidth)
            
            var apexY := 0.0
            var baseY := 0.0
            
            if cell.isUpright:
                apexY = cy - halfTriangleHeight
                baseY = cy + halfTriangleHeight
            else:
                apexY = cy + halfTriangleHeight
                baseY = cy - halfTriangleHeight
                
            var bg_color := colorAt(row, col)
            
            var points := PoolVector2Array([
                Vector2(westX, baseY), Vector2(midX, apexY), Vector2(eastX, baseY)
               ])
            
            draw_colored_polygon(points, bg_color)
            
            var left := Vector2(westX, baseY)
            var right := Vector2(eastX, baseY)
            var mid := Vector2(midX, apexY)
            
            if !cell.isLinkedTo(cell.west):
                draw_line(left, mid, Color.black, border_width, true)
                
            if !cell.isLinkedTo(cell.east):
                draw_line(right, mid, Color.black, border_width, true)
                
            var no_south := cell.isUpright && cell.south == null
            var no_north := !cell.isUpright && !cell.isLinkedTo(cell.north)
            
            if no_south || no_north:
                draw_line(left, right,Color.black, border_width, true)
    
func colorAt(row:int, col:int) -> Color:
    var cell = grid.cell(row, col)
    if !grid.distances.cells.has(cell) || maxDistance <= 0:
        return Color.black
    var distance:float= grid.distances.cells[cell]
    var intensity:float= (maxDistance - distance)/float(maxDistance)
    var green = 1.0
    if intensity < 0.5:
        green = intensity * 2
        
    var ambient = 0.05
        
    intensity = range_lerp(intensity, 0.0, 1.0, ambient, 1.0)
    green = range_lerp(green, 0.0, 1.0, ambient, 1.0)
    return Color(intensity, green, intensity)
