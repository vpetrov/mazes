extends Reference

class_name Grid

var ncols := 0
var nrows := 0
var dead_ends = null

const cells := Array()
var initialized = false

func _init(rows:int, cols:int) -> void:
    self.nrows = rows
    self.ncols = cols
    
func init() -> void:
    _allocate(nrows, ncols)
    _compute_neighbors()
    pass

func _allocate(rows:int, cols:int) -> void:
    assert(rows > 0)
    assert(cols > 0)

    cells.resize(nrows)
    
    for row in range(nrows):
        cells[row] = Array()
        cells[row].resize(ncols)
        
    clear()

# Populates the north/east/south/west neighbor references to Cells
func _compute_neighbors() -> void:
    for row in range(nrows):
        for col in range(ncols):
            var cell = cell(row, col)
            if cell == null:
                continue
            cell.north = cell(row - 1, col)
            cell.south = cell(row + 1, col)
            cell.east = cell(row, col + 1)
            cell.west = cell(row, col - 1)

# A convenient function to get a row. Same as cells[row].
# @return Array<Cell>
func row(row:int) -> Array:
    assert(row >= 0 && row < nrows)
    return self.cells[row]

# Retreives a single Cell at the specified grid coordinate
func cell(row:int, col:int) -> Cell:
    if row < 0 || col < 0 || row >= nrows || col >= cells[row].size():
        return null
    var result = cells[row][col]
    return result
    
# Returns a random cell in the grid
func random_cell() -> Cell:
    var row = rand_range(0.0, nrows)
    var col = rand_range(0.0, ncols)
    return cell(row, col)

# Clears the entire grid (does not populate neighbors or links)
func clear() -> void:
    for row in range(nrows):
        clearRow(row)

# Clears a single row (does not populate neighbors or links)
func clearRow(row:int) -> void:
    assert(row < nrows)
    for col in range(ncols):
        cells[row][col] = createCell(row, col, 0)
        
func createCell(row:int, col:int, value:int) -> Cell:
    return Cell.new(row, col, value)

func _to_string():
    for row in range(nrows):
        print(row(row))

func deadEnds() -> Array:
    # cache
    if dead_ends != null:
        return dead_ends
        
    dead_ends = []
    
    for row in range(nrows):
        for col in range(cells[row].size()):
            var cell = cell(row, col)
            if cell == null:
                continue
            if cell.links().size() == 1:
                dead_ends.append(cell)
    
    return dead_ends

func count() -> int:
    var result := 0
    for row in range(nrows):
        result += cells[row].size()
        
    return result
