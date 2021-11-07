extends Spatial

enum ViewType {
	TOP,
	FIRST_PERSON
}

var currentView = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var grid = Maze.binary_tree(16,16)
	
	
	var surfaceTool = SurfaceTool.new()
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surfaceTool.add_color(Color(1.0, 0.0, 0.0))
	
	var size = 1.0
	var thickness = 0.1
	
	for row in range(grid.nrows):
		for col in range(grid.ncols):
			var startX = size * col
			if col > 0:
				startX -= col * thickness
			var topLeft = Vector3(startX, 0, row * size)
			var topRight = Vector3(startX + size - thickness, 0, row * size)
			var bottomLeft = Vector3(startX, 0, row * size + size - thickness)
			var cell = grid.cell(row, col)
			
			if !cell.isLinkedTo(cell.north):
				addHorizontalWall(surfaceTool, topLeft, size, thickness)
			if !cell.isLinkedTo(cell.west):
				addVerticalWall(surfaceTool, topLeft, size, thickness)
			
			if col == grid.ncols - 1:
				addVerticalWall(surfaceTool, topRight, size, thickness)
			if row == grid.nrows - 1:
				addHorizontalWall(surfaceTool, bottomLeft, size, thickness)
	
	surfaceTool.generate_normals()
	surfaceTool.generate_tangents()
	
	var mesh:ArrayMesh = surfaceTool.commit()
	$MeshInstance.mesh = mesh
	
	switchToFirstPersonView()

func switchToFirstPersonView():
	$Camera.look_at_from_position(Vector3(0.1, 0.3, 0.0), Vector3(1.0, 0.3, 0.1), Vector3(0.0, 1.0, 0.0))
	currentView = ViewType.FIRST_PERSON

func switchToTopView():
	$Camera.look_at_from_position(Vector3(6, 10.0, 6), Vector3(7, 0.1, 6), Vector3(0.0, 1.0, 0.0))
	currentView = ViewType.TOP
	
func toggleCameraView():
	match currentView:
		ViewType.TOP: switchToFirstPersonView()
		ViewType.FIRST_PERSON: switchToTopView()

func _input(event:InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		toggleCameraView()
	
func _process(delta):
	var move = delta * 1.75
	if Input.is_action_pressed("ui_left"):
		$Camera.translate_object_local(Vector3(-move, 0.0, 0.0))
		print("-x")
	if Input.is_action_pressed("ui_right"):
		$Camera.translate_object_local(Vector3(move, 0.0, 0.0))
		print("+x")
	
	if Input.is_action_pressed("ui_up"):
		$Camera.translate_object_local(Vector3(0.0, move, 0.0))
	if Input.is_action_pressed("ui_down"):
		$Camera.translate_object_local(Vector3(0.0, -move, 0.0))		
	if Input.is_action_pressed("forward"):
		$Camera.translate_object_local(Vector3(0.0, 0.0, -move))
	if Input.is_action_pressed("backward"):
		$Camera.translate_object_local(Vector3(0.0, 0.0, move))

	if Input.is_action_pressed("rotate_left"):
		match currentView:
			ViewType.FIRST_PERSON : $Camera.rotate_object_local(Vector3(0.0, 1.0, 0.0), PI * delta)
			ViewType.TOP: $Camera.translate_object_local(Vector3(-5 * move, 0.0, 0.0))
	if Input.is_action_pressed("rotate_right"):
		match currentView:
			ViewType.FIRST_PERSON : $Camera.rotate_object_local(Vector3(0.0, 1.0, 0.0), -PI * delta)
			ViewType.TOP: $Camera.translate_object_local(Vector3(5 * move, 0.0, 0.0))

func addHorizontalWall(surface:SurfaceTool, origin:Vector3, size: float, thickness: float) -> void:
	# north
	addHorizontalFace(surface, origin, size, size)
	# south
	addHorizontalFace(surface, origin + Vector3(0.0, 0.0, thickness), size, size)
	# east
	addVerticalFace(surface, origin, thickness, size)
	# west
	addVerticalFace(surface, origin + Vector3(size, 0.0, 0.0), thickness, size)
	# ceiling
	addCeilingFace(surface, origin + Vector3(0.0, size, 0.0), size, thickness)
	
	
func addVerticalWall(surface:SurfaceTool, origin:Vector3, size: float, thickness: float) -> void:
	# west
	addVerticalFace(surface, origin, size, size)
	# east
	addVerticalFace(surface, origin + Vector3(thickness, 0, 0), size, size)	
	# north
	addHorizontalFace(surface, origin, thickness, size)
	# south
	addHorizontalFace(surface, origin + Vector3(0.0, 0.0, size), thickness, size)
	# ceiling
	addCeilingFace(surface, origin + Vector3(0.0, size, 0.0), thickness, size)

func addVerticalFace(surface:SurfaceTool, origin:Vector3, width: float, height: float) -> void:
	surface.add_vertex(origin + Vector3(0.0, 0.0, 0.0))
	surface.add_vertex(origin + Vector3(0.0, height, width))
	surface.add_vertex(origin + Vector3(0.0, height, 0.0))

	surface.add_vertex(origin + Vector3(0.0, 0.0, 0.0))
	surface.add_vertex(origin + Vector3(0.0, 0.0, width))
	surface.add_vertex(origin + Vector3(0.0, height, width))

func addHorizontalFace(surface:SurfaceTool, origin:Vector3, width: float, height: float) -> void:
	surface.add_vertex(origin + Vector3(0.0, 0.0, 0.0))
	surface.add_vertex(origin + Vector3(0.0, height, 0.0))
	surface.add_vertex(origin + Vector3(width, height, 0.0))
	
	surface.add_vertex(origin + Vector3(0.0, 0.0, 0.0))
	surface.add_vertex(origin + Vector3(width, height, 0.0))
	surface.add_vertex(origin + Vector3(width, 0.0, 0.0))
	
func addCeilingFace(surface:SurfaceTool, origin:Vector3, width: float, height: float) -> void:
	surface.add_vertex(origin + Vector3(0.0, 0.0, 0.0))
	surface.add_vertex(origin + Vector3(width, 0.0, height))
	surface.add_vertex(origin + Vector3(0.0, 0.0, height))

	surface.add_vertex(origin + Vector3(0.0, 0.0, 0.0))
	surface.add_vertex(origin + Vector3(width, 0.0, 0.0))
	surface.add_vertex(origin + Vector3(width, 0.0, height))
