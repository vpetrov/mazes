extends Node

const X = 88

# Creates a mask from a text file
func fromTextFile(filename:String) -> Mask:
    var file = File.new()
    var err = file.open(filename, File.READ)
    if err != OK:
        print("Failed to open file", filename, err)
        return Mask.new(1,1) # hack
        
    var lines = []
    
    while !file.eof_reached():
        var line = file.get_line().strip_edges()
        if line.empty():
            continue
        lines.append(line)
        
    var rows = lines.size()
    var cols = lines[0].length()
    var mask = Mask.new(rows, cols)
    
    for row in range(mask.nrows):
        for col in range(mask.ncols):
            var is_on = lines[row].ord_at(col) != X
            mask.set_value(row, col, is_on)

    return mask
        
func fromImage(filename:String, size:Vector2) -> Mask:
    var image:Image = load(filename).get_data()
    if size != null:
        image.resize(size.x, size.y)
        
    image.lock()
    var rows = image.get_height()
    var cols = image.get_width()
    var mask = Mask.new(rows, cols)
    
    for row in range(mask.nrows):
        for col in range(mask.ncols):
            var pixel := image.get_pixel(col, row)
            var is_on := !pixel.is_equal_approx(Color.black)
            mask.set_value(row, col, is_on)
            
    return mask
