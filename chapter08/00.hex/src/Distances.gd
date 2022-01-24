extends Reference

class_name Distances

var root:Cell = null
var cells := {}

func _init(root:Cell) -> void:
    self.root = root
    cells[root] = 0

func toList() -> Array:
    var result = Array()
    result.resize(cells.size())
    for cell in cells:
        var distance = cells[cell]
        result[distance] = cell
    return result

func to(cell:Cell) -> int:
    return cells[cell]

func farthest() -> Cell:
    var max_distance := 0
    var result := root
    
    for cell in cells:
        var distance = cells[cell]
        if distance > max_distance:
            max_distance = distance
            result = cell

    return result
