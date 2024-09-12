import "mathUtil"

// Node class: used internally to represent one step
// in the search process.
Node = {}

Node.neighbors = function
	return [
		{"x": self.position.x + 1, "y": self.position.y,},
		{"x": self.position.x - 1, "y": self.position.y,},
		{"x": self.position.x, "y": self.position.y + 1,},
		{"x": self.position.x,"y": self.position.y - 1,},
	]
end function

Node.make = function(position, endPos, parentNode = null)
	n = new Node
	n.position = {"x": position.x, "y": position.y}
	n.parent = parentNode
	n.estCostToEnd = mathUtil.distance(n.position, endPos)
	n.estTotalCost = n.estCostToEnd
	n.costFromStart = 0
	if parentNode != null then
		n.costFromStart = parentNode.costFromStart + 1
	end if
	n.estTotalCost = n.costFromStart + n.estCostToEnd
	return n
end function

Node.path = function
	result = []
	n = self
	while n
		result.insert 0, [n.position.x, n.position.y]
		n = n.parent
	end while
	return result
end function

hazards = []
// Main entry point: Find a path between two positions,
// each specified as a map with "x" and "y" values.
find = function(startPos, endPos)
	toDoList = [Node.make(startPos, endPos)]
	doneSet = {}
	
	if hazards == [] then
		for tileData in level.mud
			hazards.push tileData[0]
		end for
		for tileData in level.water
			hazards.push tileData[0]
		end for
	end if

	while toDoList
		n = toDoList.pull
		//walls.setCellTint(n.position.x, n.position.y, color.red)
		if n.position.x == endPos.x and n.position.y == endPos.y then return n.path
		for pos in n.neighbors
			if doneSet.hasIndex(pos) then continue
			doneSet.push pos
			groundCell = ground.cell(pos.x, pos.y)

			if level.blocksWalking(pos.x*camera.tileCellSize, pos.y*camera.tileCellSize) then continue
			noob = Node.make(pos, endPos, n)
			if noob.costFromStart < 64 then toDoList.push noob
		end for
		toDoList.sort "estTotalCost"
	end while
    print "Cant Find Path!"
end function