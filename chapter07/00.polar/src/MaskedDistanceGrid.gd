extends DistanceGrid

class_name MaskedDistanceGrid

var mask:Mask

func _init(mask:Mask).(mask.nrows, mask.ncols) -> void:
    self.mask = mask
    
func setStartCell(cell:Cell) -> void:
    .setStartCell(cell)
    
    # keep running djikstra until we've covered all the islands
    if distances.cells.size() != mask.count():
        var done := false
        # find the next cell that doesn't have any distances
        for row in range(nrows):
            for col in range(ncols):
                var next_start = cell(row, col)
                if next_start == null:
                    continue
                if not distances.cells.has(next_start):
                    computeDistancesAt(next_start, distances)
                    
                

func createCell(row:int, col:int, value:int) -> Cell:
    if mask.is_on(row, col):
        return .createCell(row, col, value)
    
    return null
        
func random_cell() -> Cell:
    var location:Vector2 = mask.random_location()
    return cell(location.y, location.x)

func count() -> int:
    return mask.count()
