import XCTest
@testable import AetherCore

final class SpatialIndexTests: XCTestCase {
    
    // MARK: - QuadTree Tests
    
    func testQuadTreeBasicInsertion() {
        let bbox = BoundingBox(minX: 0, minY: 0, maxX: 1000, maxY: 1000)
        var quadTree = QuadTree<PhysicalComponent>(boundingBox: bbox)
        
        let component = PhysicalComponent(
            name: "R1",
            boundingBox: BoundingBox(minX: 100, minY: 100, maxX: 150, maxY: 150)
        )
        
        quadTree.insert(component)
        
        let results = quadTree.query(in: BoundingBox(minX: 90, minY: 90, maxX: 160, maxY: 160))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].name, "R1")
    }
    
    func testQuadTreeSpaceQuery() {
        let bbox = BoundingBox(minX: 0, minY: 0, maxX: 10000, maxY: 10000)
        var quadTree = QuadTree<PhysicalComponent>(boundingBox: bbox)
        
        // 插入 1000 个组件
        for i in 0..<1000 {
            let x = Float(i % 32) * 300
            let y = Float(i / 32) * 300
            let component = PhysicalComponent(
                name: "C\(i)",
                boundingBox: BoundingBox(minX: x, minY: y, maxX: x + 100, maxY: y + 100)
            )
            quadTree.insert(component)
        }
        
        // 查询一个区域
        let results = quadTree.query(in: BoundingBox(minX: 0, minY: 0, maxX: 1500, maxY: 1500))
        XCTAssertGreaterThan(results.count, 0)
        XCTAssertLessThanOrEqual(results.count, 1000)
    }
    
    func testQuadTreeNearestNeighbors() {
        let bbox = BoundingBox(minX: 0, minY: 0, maxX: 1000, maxY: 1000)
        var quadTree = QuadTree<PhysicalComponent>(boundingBox: bbox)
        
        let components = [
            PhysicalComponent(name: "A", boundingBox: BoundingBox(minX: 100, minY: 100, maxX: 150, maxY: 150)),
            PhysicalComponent(name: "B", boundingBox: BoundingBox(minX: 200, minY: 200, maxX: 250, maxY: 250)),
            PhysicalComponent(name: "C", boundingBox: BoundingBox(minX: 500, minY: 500, maxX: 550, maxY: 550)),
        ]
        
        for component in components {
            quadTree.insert(component)
        }
        
        let neighbors = quadTree.nearestNeighbors(to: CGPoint(x: 120, y: 120), k: 2)
        XCTAssertEqual(neighbors.count, 2)
    }
    
    func testQuadTreeCollisionDetection() {
        let bbox = BoundingBox(minX: 0, minY: 0, maxX: 1000, maxY: 1000)
        var quadTree = QuadTree<PhysicalComponent>(boundingBox: bbox)
        
        let comp1 = PhysicalComponent(
            name: "R1",
            boundingBox: BoundingBox(minX: 100, minY: 100, maxX: 150, maxY: 150)
        )
        let comp2 = PhysicalComponent(
            name: "R2",
            boundingBox: BoundingBox(minX: 140, minY: 140, maxX: 190, maxY: 190)
        )
        
        quadTree.insert(comp1)
        quadTree.insert(comp2)
        
        let collisions = quadTree.collisions(for: comp1)
        XCTAssertEqual(collisions.count, 1)
    }
    
    // MARK: - R-Tree Tests
    
    func testRTreeBasicInsertion() {
        var rTree = RTree<PhysicalComponent>(maxEntries: 8)
        
        let component = PhysicalComponent(
            name: "R1",
            boundingBox: BoundingBox(minX: 100, minY: 100, maxX: 150, maxY: 150)
        )
        
        rTree.insert(component)
        
        let results = rTree.query(in: BoundingBox(minX: 90, minY: 90, maxX: 160, maxY: 160))
        XCTAssertEqual(results.count, 1)
    }
    
    func testRTreeVsQuadTreePerformance() {
        let bbox = BoundingBox(minX: 0, minY: 0, maxX: 10000, maxY: 10000)
        var quadTree = QuadTree<PhysicalComponent>(boundingBox: bbox)
        var rTree = RTree<PhysicalComponent>(maxEntries: 8)
        
        let components = (0..<5000).map { i in
            let x = Float.random(in: 0..<10000)
            let y = Float.random(in: 0..<10000)
            return PhysicalComponent(
                name: "C\(i)",
                boundingBox: BoundingBox(minX: x, minY: y, maxX: x + 50, maxY: y + 50)
            )
        }
        
        // QuadTree 插入
        let quadInsertStart = Date()
        for component in components {
            quadTree.insert(component)
        }
        let quadInsertTime = Date().timeIntervalSince(quadInsertStart)
        
        // R-Tree 插入
        let rInsertStart = Date()
        for component in components {
            rTree.insert(component)
        }
        let rInsertTime = Date().timeIntervalSince(rInsertStart)
        
        print("QuadTree insert time: \(quadInsertTime * 1000)ms")
        print("R-Tree insert time: \(rInsertTime * 1000)ms")
        
        // 查询性能
        let queryBbox = BoundingBox(minX: 2000, minY: 2000, maxX: 5000, maxY: 5000)
        
        let quadQueryStart = Date()
        _ = quadTree.query(in: queryBbox)
        let quadQueryTime = Date().timeIntervalSince(quadQueryStart)
        
        let rQueryStart = Date()
        _ = rTree.query(in: queryBbox)
        let rQueryTime = Date().timeIntervalSince(rQueryStart)
        
        print("QuadTree query time: \(quadQueryTime * 1000)ms")
        print("R-Tree query time: \(rQueryTime * 1000)ms")
    }
    
    // MARK: - ComponentManager Tests
    
    func testComponentManagerBasic() {
        let bbox = BoundingBox(minX: 0, minY: 0, maxX: 10000, maxY: 10000)
        let manager = ComponentManager(boundingBox: bbox, indexType: .quadTree)
        
        let component = PhysicalComponent(
            name: "R1",
            boundingBox: BoundingBox(minX: 100, minY: 100, maxX: 150, maxY: 150)
        )
        
        manager.insert(component)
        XCTAssertEqual(manager.components.count, 1)
    }
    
    func testComponentManagerBatchInsert() {
        let bbox = BoundingBox(minX: 0, minY: 0, maxX: 50000, maxY: 50000)
        let manager = ComponentManager(boundingBox: bbox, indexType: .quadTree)
        
        let components = (0..<10000).map { i in
            let x = Float(i % 100) * 450
            let y = Float(i / 100) * 450
            return PhysicalComponent(
                name: "C\(i)",
                boundingBox: BoundingBox(minX: x, minY: y, maxX: x + 100, maxY: y + 100)
            )
        }
        
        let startTime = Date()
        manager.insert(components)
        let elapsed = Date().timeIntervalSince(startTime)
        
        XCTAssertEqual(manager.components.count, 10000)
        print("Batch insert 10000 components: \(elapsed * 1000)ms")
    }
    
    func testComponentManagerDRC() {
        let bbox = BoundingBox(minX: 0, minY: 0, maxX: 1000, maxY: 1000)
        let manager = ComponentManager(boundingBox: bbox, indexType: .quadTree)
        
        // 创建两个接近的组件
        let comp1 = PhysicalComponent(
            name: "R1",
            boundingBox: BoundingBox(minX: 100, minY: 100, maxX: 150, maxY: 150)
        )
        let comp2 = PhysicalComponent(
            name: "R2",
            boundingBox: BoundingBox(minX: 160, minY: 160, maxX: 210, maxY: 210)
        )
        
        manager.insert([comp1, comp2])
        
        let violations = manager.performDRC(spacingRule: 50)
        XCTAssertGreaterThan(violations.count, 0)
    }
    
    func testComponentManagerMillionScale() {
        let bbox = BoundingBox(minX: 0, minY: 0, maxX: 100000, maxY: 100000)
        let manager = ComponentManager(boundingBox: bbox, indexType: .quadTree)
        
        print("Testing with 100,000 components...")
        
        let startInsert = Date()
        let components = (0..<100000).map { i in
            let x = Float.random(in: 0..<100000)
            let y = Float.random(in: 0..<100000)
            return PhysicalComponent(
                name: "C\(i)",
                boundingBox: BoundingBox(minX: x, minY: y, maxX: x + 50, maxY: y + 50),
                componentType: Int.random(in: 0..<5) == 0 ? "ic" : "resistor"
            )
        }
        manager.insert(components)
        let insertTime = Date().timeIntervalSince(startInsert)
        
        print("Insert 100k components: \(insertTime * 1000)ms")
        
        // 查询性能
        let startQuery = Date()
        let queryResults = manager.query(in: BoundingBox(minX: 20000, minY: 20000, maxX: 30000, maxY: 30000))
        let queryTime = Date().timeIntervalSince(startQuery)
        
        print("Query on 100k components: \(queryTime * 1000)ms, returned \(queryResults.count)")
        
        // K-NN 查询
        let startKNN = Date()
        let knnResults = manager.nearestNeighbors(to: CGPoint(x: 50000, y: 50000), k: 10)
        let knnTime = Date().timeIntervalSince(startKNN)
        
        print("K-NN query (k=10) on 100k components: \(knnTime * 1000)ms, returned \(knnResults.count)")
        
        // 验证性能指标
        XCTAssertLessThan(insertTime, 2.0, "Insert 100k components should be < 2 seconds")
        XCTAssertLessThan(queryTime, 0.05, "Query should be < 50ms")
        XCTAssertLessThan(knnTime, 0.02, "K-NN should be < 20ms")
    }
}