extends Node2D

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


# main()
func _ready():
    #randomize()
    var grid = Maze.binary_tree(3,3)
    print(grid)
    
    var tileset: TileSet = $TileMap.tile_set
    find_tiles(tileset, tiles)
    
    paint_tiles($TileMap, tiles, grid)

# Paints the grid onto the tilemap
func paint_tiles(tilemap:TileMap, tiles:Dictionary, grid:Grid) -> void:
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
    
# Looks up the names of the tiles in the TileSet
func find_tiles(tileset: TileSet, tiles:Dictionary) -> void:
    for tile_name in tiles:
        var tile_id = tileset.find_tile_by_name(tile_name)
        if tile_id < 0:
            print_debug("No tile found with name:", tile_name)
        tiles[tile_name] = tile_id
