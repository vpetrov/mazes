extends Node

class_name Mask

var cells = []
var nrows:int
var ncols:int

func _init(rows:int, cols:int) -> void:
    assert(rows > 0)
    assert(cols > 0)
    _allocate(rows, cols)
    
func _allocate(rows:int, cols:int) -> void:
    assert(rows > 0)
    assert(cols > 0)
    nrows = rows
    ncols = cols

    cells.resize(nrows)
    
    for row in range(nrows):
        cells[row] = Array()
        cells[row].resize(ncols)
        
    clear()
    
# Clears the entire grid (does not populate neighbors or links)
func clear() -> void:
    for row in range(nrows):
        for col in range(ncols):
            cells[row][col] = true # all cells are enabled
            
func is_on(row:int, col:int) -> bool:
    if row < 0 || col < 0 || row >= nrows || col >= ncols:
        return false
        
    return cells[row][col]

func set_value(row:int, col:int, on:bool) -> void:
    assert(row < nrows)
    assert(row >= 0)
    assert(col < ncols)
    assert(col >= 0)
    
    cells[row][col] = on
    
func off(row, col) -> void:
    set_value(row, col, false)
    
func on(row, col) -> void:
    set_value(row, col, true)
    
func count() -> int:
    var result := 0
    
    for row in range(nrows):
        for col in range(ncols):
            if cells[row][col]:
                result += 1
    
    return result
    
func random_location() -> Vector2:
    assert(count() > 0)
    
    while true:
        var row = rand_range(0, nrows)
        var col = rand_range(0, ncols)
        if is_on(row, col):
            return Vector2(col, row)
            
    # unreachable
    return Vector2(0,0)

