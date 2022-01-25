extends DistanceGrid

class_name TriangleGrid

func _init(rows:int, cols:int).(rows, cols) -> void:
    pass
    
func createCell(row:int, col:int, value:int) -> Cell:
    return TriangleCell.new(row, col, value)

func _compute_neighbors() -> void:
    for row in range(nrows):
        for col in range(ncols):
            var cell = cell(row, col)
            
            cell.west = cell(row, col - 1)
            cell.east = cell(row, col + 1)
            
            if cell.isUpright:
                cell.south = cell(row + 1, col)
            else:
                cell.north = cell(row - 1, col)
