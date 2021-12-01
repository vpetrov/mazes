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
