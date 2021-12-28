extends Grid

class_name DistanceGrid

var start:Cell = null
var distances:Distances = null

func _init(rows:int, cols:int).(rows, cols) -> void:
    pass

func setStartCell(cell:Cell) -> void:
    start = cell
    distances = computeDistancesAt(cell)

# Runs Djikstra to compute the distance from 'start' to each cell in the grid
func computeDistancesAt(start:Cell) -> Distances:
    var result = Distances.new(start)
    var queue = [start]
    
    while !queue.empty():
        var cell = queue.pop_front()
        var current_distance = result.cells[cell]
        
        for linked_cell in cell.links():
            # skip linked cells we already looked at
            if linked_cell in result.cells:
                continue
            
            result.cells[linked_cell] = current_distance + 1
            queue.push_back(linked_cell)
    
    return result
    

func pathTo(goal:Cell) -> Distances:
    assert(goal != null)
    var current = goal
    var breadcrumbs = Distances.new(goal)
    breadcrumbs.cells[current] = self.distances.cells[current]
    
    while current != self.distances.root:
        for linked_neighbour in current.links:
            if self.distances.cells[linked_neighbour] < self.distances.cells[current]:
                breadcrumbs.cells[linked_neighbour] = self.distances.cells[linked_neighbour]
                current = linked_neighbour
    
    return breadcrumbs


func _to_string():
    if (distances == null):
        return ._to_string()
    
    for row in range(nrows):
        var row_string = "["
        for col in range(ncols):
            var cell = self.cell(row, col)
            row_string += cell.asString(str(distances.cells[cell]))
            row_string += " "
        row_string += "]"
        print(row_string)
