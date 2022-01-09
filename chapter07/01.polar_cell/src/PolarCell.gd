extends Cell

class_name PolarCell

var cw:Cell
var ccw:Cell
var inward:Cell
var outward:Array = []

func _init(row:int, col:int,value:int).(row,col,value) ->void:
    pass

func neighbors() -> Array:
    var result = []
    
    if cw != null:
        result.append(cw)
        
    if ccw != null:
        result.append(ccw)
        
    if inward != null:
        result.append(inward)
        
    result.append_array(outward)
    return result
