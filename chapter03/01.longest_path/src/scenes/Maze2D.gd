extends Node2D

var grid: DistanceGrid = null

# A map of tile name to tile id
const tiles = {
    "0": null,
    "N": null,
    "E": null,
    "S": null,
    "W": null,
    "NE" :null,
    "NS" :null,
    "NW" :null,
    "ES" :null,
    "EW" :null,
    "SW" :null,
    "NES": null,
    "NEW": null,
    "NSW": null,
    "ESW": null,
    "NESW": null
}

onready var tileset: TileSet = $TileMap.tile_set

var showDistances := true
var labels := []

var tankPath := []
var currentPathIndex := -1

func _input(event) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        var gridCoordinates = positionToCellCoord(event.position)
        var col = gridCoordinates.x
        var row = gridCoordinates.y
        if col >= 0 && row >= 0:
            onGridClick(grid, row, col)
            
# finds the cell from pixel coordinates
func positionToCellCoord(vector:Vector2) -> Vector2:
    var localPosition:Vector2 = $TileMap.to_local(vector)
    return $TileMap.world_to_map(localPosition)
    
# main()
func _ready() -> void:
    labels.resize(grid.nrows * grid.ncols)
    find_tiles(tileset, tiles)
    paint_tiles($TileMap, tiles, grid)
    
    # setup the tank
    $Tank.position = getCellCenter(0, 0)
    $Tank.connect("target_reached", self, "onTankArrived")
    
func onGridClick(grid:DistanceGrid, row:int, col:int) -> void:
    assert(row < grid.nrows)
    assert(col < grid.ncols)
    
    # find current tank cell
    var tankBodyPosition = $Tank.getWorldPosition()
    var tankRootPosition = $Tank.position
    var tankCellCoord := positionToCellCoord($Tank.getWorldPosition())
    var tankCell := grid.cell(tankCellCoord.y, tankCellCoord.x)
    grid.setStartCell(tankCell)
    
    var cell = grid.cell(row, col)
    var shortestDistances = grid.pathTo(cell)
    var maxD = shortestDistances.farthest()
    
    tankPath = shortestDistances.toList()
    currentPathIndex = -1
    $Tank.stop()
    moveTankToNextCell()
    
func moveTankToNextCell():    
    var nextPathIndex = getNextPathIndex()
    if nextPathIndex == currentPathIndex || nextPathIndex >= tankPath.size():
        print("Done navigating")
        return false
        
    currentPathIndex = nextPathIndex
    var cell = tankPath[currentPathIndex]
    moveTankToCell(cell.row, cell.col)
    return true

func getNextPathIndex() -> int:
    var previousCell = tankPath[currentPathIndex]
    var newIndex := currentPathIndex
    var linkDirection := Cell.NO_LINK
    
    while newIndex < tankPath.size() - 1:
        var nextCell = tankPath[newIndex + 1]
        var transition = previousCell.linkDirection(nextCell)
        
        # first transition
        if linkDirection == Cell.NO_LINK:
            linkDirection = transition
            previousCell = nextCell
            newIndex += 1
            continue
            
        # erroneous case
        if transition == Cell.NO_LINK:
            print("ERROR: Cell " + str(nextCell) + " is on the path, but not linked to " + str(previousCell))
            break
        
        # compare the previous transition with the current one. If it's not the same, then we're done
        if transition != linkDirection:
            break
        
        # if we got here, then we found another identical transition in the path
        linkDirection = transition
        previousCell = nextCell
        newIndex += 1
        
    return newIndex   
        
func teleportTankToCell(row:int, col:int) -> void:
    var location = getCellCenter(row, col)
    $Tank.teleport(location)


func moveTankToCell(row:int, col:int) -> void:
    var location = getCellCenter(row, col)
    $Tank.goto(location, true, true)
    
func getTankCell() -> Cell:
    return $TileMap.map
    
func getCellCenter(row:int, col:int) -> Vector2:
    var cellTopLeft = $TileMap.map_to_world(Vector2(col, row))
    return cellTopLeft + $TileMap.cell_size / 2.0
    
func onTankArrived(location:Vector2) -> void:
    print("Tank has arrived at ", location)
    if !moveTankToNextCell():
        $Tank.stop()
    
    
func onGridChanged(grid:DistanceGrid) -> void:
    self.grid = grid
    labels.resize(grid.nrows * grid.ncols)
    paint_tiles($TileMap, tiles, grid)
    
func onShowDistancesChanged(showDistances:bool) -> void:
    self.showDistances = showDistances
    $Labels.visible = showDistances

# Paints the grid onto the tilemap
func paint_tiles(tilemap:TileMap, tiles:Dictionary, grid:DistanceGrid) -> void:
    tilemap.clear()
    var i = 0
    for row in range(grid.nrows):
        for col in range(grid.ncols):
            var cell = grid.cell(row, col)
            # a cell linked to the North and East neighbors will return a 
            # link string like "NE" (clockwise). The tileset has tiles named
            # using the same convention, based on where the road openings are
            # (so a tile with openings to the North and East sides is named
            # "NE". This code then uses the link name ("NE") to look up a tile
            # named "NE". The result is a tile integer id, which can then be
            # sent to the TileMap at the specified x, y position.
            var tile_name = cell.linkString().to_upper()
            var tile_id = tiles[tile_name]
            tilemap.set_cell(col, row, tile_id)
            
            var labelText = str(grid.distances.cells[cell])
            setLabel($TileMap, row, col, labelText)

func setLabel(tilemap:TileMap, row:int, col:int, text:String) -> void:
    var label := getLabelAt(row, col)
    if label != null:
        label.text = text
    else:
        addLabelAt(tilemap, row, col, text)

func getLabelAt(row:int, col:int) -> Label:
    return labels[row * grid.ncols + col]
    
func setLabelAt(row:int, col:int, label:Label) -> void:
    var index = row * grid.ncols + col
    labels[index] = label
    
func addLabelAt(tilemap:TileMap, row:int, col:int, text:String) -> void:
    var cell_width = tilemap.cell_size.x
    var cell_height = tilemap.cell_size.y
    var label = Label.new()
    label.set_global_position(tilemap.position + Vector2(cell_width * col, cell_height * row))
    label.text = text
    label.set_size(tilemap.cell_size)
    label.align = Label.ALIGN_CENTER
    label.valign = Label.VALIGN_CENTER
    $Labels.add_child(label)
    setLabelAt(row, col, label)
    
    
# Looks up the names of the tiles in the TileSet
func find_tiles(tileset: TileSet, tiles:Dictionary) -> void:
    for tile_name in tiles:
        var tile_id = tileset.find_tile_by_name(tile_name)
        if tile_id < 0:
            print_debug("No tile found with name:", tile_name)
        tiles[tile_name] = tile_id
