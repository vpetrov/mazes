extends Cell

class_name TriangleCell

var isUpright := false

func _init(row:int, col:int,value:int).(row,col,value) ->void:
    isUpright = (row + col) % 2 == 0

func neighbors() -> Array:
    var result = []
    
    if !isUpright && north != null:
        result.append(north)
        
    if east != null:
        result.append(east)
        
    if isUpright && south != null:
        result.append(south)
            
    if west != null:
        result.append(west)
        
    return result
