extends Reference

class_name Cell

const NO_POSITION := -1

var col := NO_POSITION
var row := NO_POSITION
var value := 0
var links := {}

var north : Cell
var south: Cell
var east: Cell
var west: Cell

const NO_LINK = -1
const LINK_NORTH = 0
const LINK_SOUTH = 1
const LINK_EAST = 2
const LINK_WEST = 3

# Constructor
func _init(row:int, col: int, value:int) -> void:
    assert(row > NO_POSITION)
    assert(col > NO_POSITION)
    
    self.row = row
    self.col = col
    self.value = value
    
func linkDirection(cell) -> int:
    if cell == north:
        return LINK_NORTH
    if cell == south:
        return LINK_SOUTH
    if cell == east:
        return LINK_EAST
    if cell == west:
        return LINK_WEST
    return NO_LINK
    
# Links 2 cells
func link(cell:Cell, bidirectional := true) -> void:
    assert(cell != null)
    
    links[cell] = true
    if bidirectional:
        cell.link(self, false)

# returns all cells linked with this cell
func links() -> Array:
    return links.keys()

# checks if this cell is linked to another cell
func isLinkedTo(cell:Cell) -> bool:
    if cell == null:
        return false
    return links.has(cell)

# (hack) returns a string that represents the links. Useful for finding tiles
# by name
func linkString() -> String:
    var result = ""
    if isLinkedTo(north):
        result += "N"
    if isLinkedTo(east):
        result += "E"
    if isLinkedTo(south):
        result += "S"
    if isLinkedTo(west):
        result += "W"
    if result.empty():
        result = "0"
    return result

# Returns a list of neighbours of this cell.
func neighbours() -> Array:
    var result = []
    if north:
        result.append(north)
    if south:
        result.append(south)
    if east:
        result.append(east)
    if west:
        result.append(west)
    return result
    
func random_neighbor() -> Cell:
    var neighbors := self.neighbours()
    if neighbors.empty():
        return null
        
    var random_index := rand_range(0, neighbors.size())
    return neighbors[random_index]
    
# Returns a list of neighbours as a string, mostly useful for debugging
# Uppercase letter means the neighbour is linked to this cell, lowercase letter
# means the neighbour is not linked
func neighbours_string() -> String:
    var result = "    "
    var neighbours = {"N": north, "E": east, "S": south, "W": west}
    
    var index = 0
    for direction in neighbours:
        var neighbour = neighbours[direction]
        if neighbour == null:
            continue
        
        # capital letter if linked to neighbour, otherwise lowercase
        if neighbour in links:
            result[index] = direction.to_upper()
        else:
            result[index] = direction.to_lower()
        
        index += 1

    return result
    
# returns a string representation of this cell (for debugging)
func _to_string() -> String:
    return asString(str(value))

func asString(kernel:String) -> String:
    return "[(%d,%d)=%s %4s]" % [row, col, kernel, neighbours_string()]
