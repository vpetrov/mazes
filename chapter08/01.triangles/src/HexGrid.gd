extends DistanceGrid

class_name HexGrid

func _init(rows:int, cols:int).(rows, cols) -> void:
    pass
    
func createCell(row:int, col:int, value:int) -> Cell:
    return HexCell.new(row, col, value)

func _compute_neighbors() -> void:
    for row in range(nrows):
        for col in range(ncols):
            var cell = cell(row, col)
            
            var north_diagonal := -1
            var south_diagonal := -1
             
            if col % 2 == 0:
                north_diagonal = row - 1
                south_diagonal = row
            else:
                north_diagonal = row
                south_diagonal = row + 1
            
            cell.north = cell(row - 1, col)
            cell.northeast = cell(north_diagonal, col + 1)
            cell.southeast = cell(south_diagonal, col + 1)
            cell.south = cell(row + 1, col)
            cell.southwest = cell(south_diagonal, col - 1)
            cell.northwest = cell(north_diagonal, col - 1)

