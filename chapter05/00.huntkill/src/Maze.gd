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
            
        
func huntKill(grid:Grid) -> void:
    var cell = grid.random_cell()
    
    while cell != null:
        var all_neighbors = grid.neighbors(cell)
        var unvisited_neighbors = []
        
        # select unvisited neighbors
        for neighbor in all_neighbors:
            if neighbor.links().empty():
                unvisited_neighbors.append(neighbor)
            
        if unvisited_neighbors.empty():
            cell = null
            var done := false
            
            # iterate over the entire grid - wtf.
            for row in range(grid.nrows):
                if done:
                    break
                for col in range(grid.ncols):
                    if done:
                        break
                    var grid_cell = grid.cell(row, col)
                    var all_neighbors2 = grid.neighbors(grid_cell)
                    var visited_neighbors = []
                    
                    # remove neighbors without links
                    for neighbor in all_neighbors2:
                        if not neighbor.links().empty():
                            visited_neighbors.append(neighbor)
                            
                    if grid_cell.links().empty() and !visited_neighbors.empty():
                        cell = grid_cell
                        var random_neighbor = Random.element(visited_neighbors)
                        cell.link(random_neighbor)
                        done = true
        else:
            var neighbor = Random.element(unvisited_neighbors)
            cell.link(neighbor)
            cell = neighbor
            
