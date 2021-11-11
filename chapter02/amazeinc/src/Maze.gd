extends Node

# Generates a new grid and populates its neighbors using the Binary Tree 
# algorithm from Chapter 2
func binary_tree(x:int, y:int) -> Grid:
	var grid := Grid.new(x,y)
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
	return grid

func sidewinder(x:int, y:int) -> Grid:
	var grid := Grid.new(x, y)
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
	return grid
