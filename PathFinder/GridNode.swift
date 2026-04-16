import Foundation

class GridNode {
    var x: Int
    var y: Int
    var gCost: Int = 0
    var hCost: Int = 0
    var parent: GridNode?
    
    var fCost: Int {
        return gCost + hCost
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}