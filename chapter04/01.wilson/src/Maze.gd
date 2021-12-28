extends Node

# Populates grid neighbors using the Binary Tree algorithm from Chapter 2
func binary_tree(grid:Grid) -> void:
    for row in range(grid.nrows):
        for cell in grid.row(row):
            # select which neighbours we're interested in
            var neighbours := []
            if cell.north:
                neighbours.append(cell.north)
            if cell.east:
                neighbours.append(cell.east)
            if neighbours.size() == 0:
                continue
            # pick a random selected neighbor
            var random_index:int = randi() % neighbours.size()
            var neighbour:Cell = neighbours[random_index]
            
            # link the cells
            if neighbour != null:
                cell.link(neighbour)

# Populates grid neighbors using the Sidewinder algorithm from Chapter 3
func sidewinder(grid:Grid) -> void:
    for row in range(grid.nrows):
        var run = []
        
        for cell in grid.row(row):
            run.append(cell)
            
            var r = randi() % 2
            var should_close = cell.east == null || (cell.north != null && r == 0)
            
            if should_close:
                var random_index = rand_range(0, run.size())
                var random_cell = run[random_index]
                if random_cell.north != null:
                    random_cell.link(random_cell.north)
                run.clear()
            else:
                cell.link(cell.east)

# Populates grid neighbors using the Aldous-Broder algorithm
func aldousBroder(grid:Grid) -> void:
    var cell = grid.random_cell()
    var unvisited = grid.nrows * grid.ncols - 1
    
    while unvisited > 0:
        var neighbors = cell.neighbours()
        var random_index := rand_range(0, neighbors.size())
        var neighbor:Cell= neighbors[random_index]
        
        if neighbor.links().empty():
            cell.link(neighbor)
            unvisited -= 1
        
        cell = neighbor
        
func wilson(grid:Grid) -> void:
    var unvisited = []
    
    # add all cells into the unvisited array
    for row in range(grid.nrows):
        for col in range(grid.ncols):
            unvisited.append(grid.cell(row, col))
    
    var random_index := floor(rand_range(0, unvisited.size()))
    var first:Cell = unvisited[random_index]
    unvisited.erase(first)
    
    while !unvisited.empty():
        random_index = floor(rand_range(0, unvisited.size()))
        var cell:Cell = unvisited[random_index]
        var path = [cell]
        
        while unvisited.has(cell):
            cell = grid.random_neighbor(cell)
            
            # see if this random neighbor is already in the path
            var position = path.find(cell)
            
            # if we found it, leave only the elements from the beginning to this element
            if position >= 0:
                path.resize(position + 1)
            else:
                path.append(cell)
                
        # commit the path into the maze
        while !path.empty():
            var first_cell:Cell = path.pop_front()
            if path.empty():
                break
            first_cell.link(path[0])
            unvisited.erase(first_cell)
            
        
    
    
