extends DistanceGrid

class_name PolarGrid

func _init(rows).(rows, 1) -> void:
    pass

func _allocate(nrows:int, ncols:int) -> void:
    assert(nrows > 0)
    cells.resize(nrows)
    clear()
        
func clearRow(row:int) -> void:
    if row == 0:
        cells[row] = [PolarCell.new(0,0,0)]
        return
        
    var row_height := 1.0 / nrows
    var radius := float(row) / nrows
    var circumference := 2.0 * PI * radius
    
    var previous_count:int = cells[row - 1].size()
    var estimated_cell_width := circumference / float(previous_count)
    var ratio := round(estimated_cell_width / row_height)
    
    var ncells := int(previous_count * ratio)
    var cols = []
    cols.resize(ncells)
    for col in range(ncells):
        cols[col] = createCell(row, col, 0)
    
    cells[row] = cols
    
func createCell(row:int, col:int, value:int) -> Cell:
    return PolarCell.new(row, col, value)

func _compute_neighbors() -> void:
    for row in range(nrows):
        for col in range(cells[row].size()):
            var cell = cell(row, col)
            
            if row > 0:
                cell.cw = cell(row, col + 1)
                cell.ccw = cell(row, col - 1)
                
                var ratio:float = cells[row].size() / cells[row - 1].size()
                var parent:Cell = cell(row - 1, int(col / ratio))
                parent.outward.append(cell)
                cell.inward = parent
                
    
func cell(row:int, col:int) -> Cell:
    if row < 0 || row >= nrows:
        return null

    var wrapped_col = col % cells[row].size()

    return cells[row][wrapped_col]
                
func random_cell() -> Cell:
    var row = rand_range(0, nrows)
    var col = rand_range(0, cells[row].size())
    return cell(row, col)
