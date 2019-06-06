tool
extends Control

var _all_scene_nodes = []

func _on_Button_pressed():
	print("Batching scene")
	
	_all_scene_nodes.clear()
	var scene_root = get_tree().get_edited_scene_root()
	_all_scene_nodes.append(scene_root)
	get_nodes(scene_root)
	
	var mesh_batches = {}
	
	for node in _all_scene_nodes:
		if node is MeshInstance:
			if node.mesh == null:
				continue
			
			if mesh_batches.has(node.mesh):
				mesh_batches[node.mesh].append(node)
			else:
				mesh_batches[node.mesh] = Array()
				mesh_batches[node.mesh].append(node)
	
	print("Mesh batches:%s" % mesh_batches.size())
	
	var root = Spatial.new()
	for i in range(mesh_batches.size()):
		var mesh = mesh_batches.keys()[i]
		var nodes = mesh_batches.values()[i]
		
		var multi_instance = MultiMeshInstance.new()
		root.add_child(multi_instance)
		multi_instance.owner = root
		var multi_mesh = MultiMesh.new()
		multi_instance.multimesh = multi_mesh
		multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
		multi_mesh.mesh = mesh
		multi_mesh.instance_count = nodes.size()
		for j in range(nodes.size()):
			var node = nodes[j]
			multi_mesh.set_instance_transform(j, node.global_transform)
	
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(root)
	print("Packed scene result:%s" % result)
	ResourceSaver.save("res://misc/batched_scene.tscn", packed_scene)


func get_nodes(node):
	for child in node.get_children():
		_all_scene_nodes.append(child)
		if child.get_child_count() > 0:
			get_nodes(child)
