extends DistanceGrid

class_name MaskedDistanceGrid

var mask:Mask

func _init(mask:Mask).(mask.nrows, mask.ncols) -> void:
    self.mask = mask

func createCell(row:int, col:int, value:int) -> Cell:
    if mask.is_on(row, col):
        return .createCell(row, col, value)
    
    return null
        
func random_cell() -> Cell:
    var location:Vector2 = mask.random_location()
    return cell(location.y, location.x)

func count() -> int:
    return mask.count()
