extends Node2D

export var cell_size := 10.0
export var color := Color(0,0,0)
export var width := 3
var grid:DistanceGrid = null
var maxDistance:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    
    grid = DistanceGrid.new(10,10)
    grid.init()
    Maze.recursiveBacktracker(grid, grid.cell(0,0))
    grid.setStartCell(grid.cell(0,0))
    var farthestCell = grid.distances.farthest()
    maxDistance = grid.distances.cells[farthestCell]
    cell_size = getCellSize()
    pass # Replace with function body.

func setGrid(grid:Grid) -> void:
    self.grid = grid
    cell_size = getCellSize()
    update()

func getCellSize() -> float:
    var visibleArea = get_viewport_rect().size
    return visibleArea.x / (grid.ncols * 2.0)

func _draw() -> void:
    var size := 2.0 * grid.nrows * cell_size
    var center := size / 2.0
    
    draw_circle(Vector2(center, center), cell_size * grid.nrows, color)
    
    var i= 0
    for row in range(grid.nrows):
        for col in range(grid.ncols):
            var cell := grid.cell(row, col)
            draw_cell(cell, center)
            i += 1
            if i > 200:
                return

func draw_cell(cell:Cell, center:int) -> void:
    var theta := 2.0 * PI / grid.row(cell.row).size()
    var inner_radius := cell.row * cell_size
    var outer_radius := inner_radius + cell_size
    var bg_radius = inner_radius + cell_size / 2.0
    var theta_ccw := cell.col * theta
    var theta_cw := theta_ccw + theta
    
    var ax := center + inner_radius * cos(theta_ccw)
    var ay := center + inner_radius * sin(theta_ccw)
    
    var bx := center + outer_radius * cos(theta_ccw)
    var by := center + outer_radius * sin(theta_ccw)
    
    var cx := center + inner_radius * cos(theta_cw)
    var cy := center + inner_radius * sin(theta_cw)
    
    var dx := center + outer_radius * cos(theta_cw)
    var dy := center + outer_radius * sin(theta_cw)
    
    var bg_color := colorAt(cell.row, cell.col)
    var fg_color := Color.black
    
    # background
    draw_arc(Vector2(center, center), bg_radius, theta_cw, theta_ccw, 100, bg_color, cell_size, true)
    
    # line drawing
    #if !cell.isLinkedTo(cell.north):
        #draw_line(Vector2(ax, ay), Vector2(cx, cy), Color.white, width)
    
    if !cell.isLinkedTo(cell.east):
        draw_line(Vector2(cx, cy), Vector2(dx, dy), fg_color, width * 2, true)
    
    if !cell.isLinkedTo(cell.north): 
        draw_arc(Vector2(center, center), inner_radius, theta_cw, theta_ccw, 100, fg_color, width, true)
    
    #draw_circle(Vector2(ax, ay), 3.0, Color.red)
    #draw_circle(Vector2(bx + 5.0, by), 5.0, Color.green)
    #draw_circle(Vector2(cx + 2.0, cy), 3.0, Color.blue)
    #draw_circle(Vector2(dx + 4.0, dy), 2.0, Color.yellow)
    
func colorAt(row:int, col:int) -> Color:
    var cell = grid.cell(row, col)
    if !grid.distances.cells.has(cell) || maxDistance <= 0:
        return Color.black
    var distance:float= grid.distances.cells[cell]
    var intensity:float= (maxDistance - distance)/float(maxDistance)
    var green = 1.0
    if intensity < 0.5:
        green = intensity * 2
        
    var ambient = 0.2
        
    intensity = range_lerp(intensity, 0.0, 1.0, ambient, 1.0)
    green = range_lerp(green, 0.0, 1.0, ambient, 1.0)
    return Color(intensity, green, intensity)
