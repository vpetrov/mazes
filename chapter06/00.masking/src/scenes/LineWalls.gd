extends Node2D

class_name LineWalls

export var tile_size := Vector2(64,64)
export var color := Color(0,0,0)
export var width := 3.0
var grid:Grid = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func setGrid(grid:Grid) -> void:
    self.grid = grid
    update()

func _draw() -> void:
    if (grid == null):
        return
    var top_left := Vector2(0,0)
    for row in range(grid.nrows):
        for col in range(grid.ncols):
            draw_cell(row, col)
            top_left.x += tile_size.x
        top_left.x = 0
        top_left.y += tile_size.y

func draw_cell(row:int, col:int) -> void:
    var cell = grid.cell(row, col)
    if cell == null:
        return
    
    if row == 0:
        draw_north_wall(row, col, cell)
    if row == grid.nrows - 1:
        draw_south_wall(row, col, cell)
    if col == 0:
        draw_west_wall(row, col, cell)
    if col == grid.ncols - 1:
        draw_east_wall(row, col, cell)
        
    # north
    if !cell.isLinkedTo(grid.cell(row - 1, col)):
        draw_north_wall(row, col, cell)
        
    # east
    if !cell.isLinkedTo(grid.cell(row, col + 1)):
        draw_east_wall(row, col, cell)
        
    # south
    if !cell.isLinkedTo(grid.cell(row + 1, col)):
        draw_south_wall(row, col, cell)
        
    # west
    if !cell.isLinkedTo(grid.cell(row, col - 1)):
        draw_west_wall(row, col, cell)
    
func draw_north_wall(row:int, col:int, cell:Cell) -> void:
    var start = Vector2(tile_size.x * col, tile_size.y * row)
    var end = start + Vector2(tile_size.x, 0)
    draw_line(start, end, color, width, true)

func draw_east_wall(row:int, col:int, cell:Cell) -> void:
    var start = Vector2(tile_size.x * (col + 1), tile_size.y * row)
    var end = start + Vector2(0, tile_size.y)
    draw_line(start, end, color, width, true)

func draw_south_wall(row:int, col:int, cell:Cell) -> void:
    var start = Vector2(tile_size.x * col, tile_size.y * (row + 1))
    var end = start + Vector2(tile_size.x, 0)
    draw_line(start, end, color, width, true)
    
func draw_west_wall(row:int, col:int, cell:Cell) -> void:
    var start = Vector2(tile_size.x * col, tile_size.y * row)
    var end = start + Vector2(0, tile_size.y)
    draw_line(start, end, color, width, true)
