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
