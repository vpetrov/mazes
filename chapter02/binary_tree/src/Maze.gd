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
