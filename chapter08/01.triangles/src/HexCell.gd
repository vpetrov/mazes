extends Cell

class_name HexCell

var northeast:Cell
var northwest:Cell
var southeast:Cell
var southwest:Cell

func _init(row:int, col:int,value:int).(row,col,value) ->void:
    pass

func neighbors() -> Array:
    var result = []
    
    if north != null:
        result.append(north)
        
    if northeast != null:
        result.append(northeast)
        
    if southeast != null:
        result.append(southeast)

    if south != null:
        result.append(south)
        
    if southwest != null:
        result.append(southwest)
        
    if northwest != null:
        result.append(northwest)
        
    return result
