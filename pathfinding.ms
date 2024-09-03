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
		result.insert 0, n.position
		n = n.parent
	end while
	return result
end function

// Main entry point: Find a path between two positions,
// each specified as a map with "x" and "y" values.
find = function(startPos, endPos)
	toDoList = [Node.make(startPos, endPos)]
	doneSet = {}
	while toDoList
		n = toDoList.pull
		if n.position.x == endPos.x and n.position.y == endPos.y then return n.path
        print [n.position.x, n.position.y]
		for pos in n.neighbors
			if doneSet.hasIndex(pos) then continue
			doneSet.push pos
			if not level.blocksWalking(pos.x, pos.y) then continue
			noob = Node.make(pos, endPos, n)
			if noob.costFromStart < 50 then toDoList.push noob
		end for
		toDoList.sort "estTotalCost"
	end while
    print "Cant Find Path!"
end function