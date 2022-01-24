extends Node2D

class_name HexColorTiles

export var cell_size := Vector2(10.0, 10.0)
export var color := Color.black
export var border_width := 2
export var spacing := 0
export var yHack := 150

var grid:HexGrid = null
var maxDistance:int = 0

#vertical hex height is incorrect for some reason

func _ready() -> void:
    grid = HexGrid.new(128, 128)
    grid.init()
    Maze.recursiveBacktracker(grid, grid.cell(0,0))
    grid.setStartCell(grid.cell(0,0))
    var farthestCell = grid.distances.farthest()
    maxDistance = grid.distances.cells[farthestCell]
    cell_size = getCellSize()

func getCellSize() -> Vector2:
    var visibleArea = get_viewport_rect().size
    #return visibleArea.x / (grid.ncols * 2)
    #return visibleArea.x / (7 * (grid.ncols - 1))
    
    #visibleArea.x = grid.ncols * cell_size + (grid.ncols + 1) * (cell_size / 2.0_
    # n = grid.ncols, c = cell_size, w = visibleArea.x
    #n * c + (n + 1) * (c/2) = w
    #n * c + (n * c / 2) + c/2 = w
    #c(n + n/2 + 0.5) = w
    #c = w / (n + n/2 + 0.5)
    #c = w / (n * 1.5 + 0.5)
    var x = visibleArea.x / (grid.ncols * 1.5 + 0.5 + spacing / (grid.ncols - 3))
    var y = (visibleArea.y - yHack) / (grid.nrows * 1.5 + 0.5 + spacing / (grid.nrows - 3))
    return Vector2(x, y)
    
func setGrid(grid:HexGrid) -> void:
    self.grid = grid
    var farthestCell = grid.distances.farthest()
    maxDistance = grid.distances.cells[farthestCell]
    cell_size = getCellSize()
    update()

func _draw() -> void:
    var a_size:float = cell_size.x / 2.0
    var b_size:float = cell_size.y * (sqrt(3) / 2.0)
    var width:float = cell_size.x * 2.0
    var height:float = b_size * 2.0
    
    #var img_width = int(3 * a_size * grid.ncols + a_size * 0.5)
    var img_width = (width - a_size / 2.0) * (grid.ncols - 1)
    #(cell_size * 2.0 - cell_size / 4.0) * (grid.ncols - 1) = width
    #(cell_size * 8.0 - cell_size)*(grid.ncols -1 ) = width
    #cell_size * 7 = width / (grid.ncols - 1)
    #cell_size = width / 7 * (grid.ncols - 1)
    var img_height = int(height * grid.nrows + b_size * 0.5)
    
    draw_circle(Vector2(img_width, 30), 10.0, Color.green)
    
    for row in range(grid.nrows):
        for col in range(grid.ncols):
            var cell = grid.cell(row, col)
            var cell_padding = Vector2(col * spacing, row * spacing)
            
            var cx:float = cell_size.x + 3.0 * col * a_size + cell_padding.x
            var cy:float = b_size + row * height + cell_padding.y
            
            if col % 2 != 0:
                cy += b_size
                
            # f/n = far/near
            # n/s/e/w = north/south/west/east
            var x_fw = cx - cell_size.x
            var x_nw := cx - a_size
            var x_ne := cx + a_size
            var x_fe := cx + cell_size.x
            
            # m = middle
            var y_n = cy - b_size
            var y_m = cy
            var y_s = cy + b_size
            
            var bg_color = colorAt(row, col)
            
            var points = PoolVector2Array([
                Vector2(x_fw, y_m), Vector2(x_nw, y_n), Vector2(x_ne, y_n),
                Vector2(x_fe, y_m), Vector2(x_ne, y_s), Vector2(x_nw, y_s)
               ])
            
            draw_colored_polygon(points, bg_color)
            
            # border
            var top_left = Vector2(x_nw, y_n)
            var top_right = Vector2(x_ne, y_n)
            var mid_right = Vector2(x_fe, y_m)
            var bot_right = Vector2(x_ne, y_s)
            var bot_left = Vector2(x_nw, y_s)
            var mid_left = Vector2(x_fw, y_m)
            
            if !cell.isLinkedTo(cell.north):
                draw_line(top_left, top_right, Color.black, border_width, true)
                
            if !cell.isLinkedTo(cell.northeast):
                draw_line(top_right, mid_right, Color.black, border_width, true)
                
            if !cell.isLinkedTo(cell.southeast):
                draw_line(mid_right, bot_right, Color.black, border_width, true)
                
            if !cell.isLinkedTo(cell.south):
                draw_line(bot_left, bot_right, Color.black, border_width, true)
                
            if !cell.isLinkedTo(cell.southwest):
                draw_line(bot_left, mid_left, Color.black, border_width, true)
                
            if !cell.isLinkedTo(cell.northwest):
                draw_line(mid_left, top_left, Color.black, border_width, true)
            
            
    
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
    
    
