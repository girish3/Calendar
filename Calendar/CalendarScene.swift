//
//  Copyright 2013-2018 Microsoft Inc.
//

import ARKit

class CalendarScene {

//    private static let colors: [UIColor] = [
//        UIColor(red: 1.00, green: 0.23, blue: 0.19, alpha: 1.0),
//        UIColor(red: 1.00, green: 0.18, blue: 0.33, alpha: 1.0),
//        UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1.0),
//        UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.0),
//        UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1.0),
//        UIColor(red: 0.20, green: 0.67, blue: 0.86, alpha: 1.0),
//        UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)
//    ]

    private static let colors: [UIColor] = [
        UIColor(argb: 0xFFCF2B36),
        UIColor(argb: 0xFFE67E22),
        UIColor(argb: 0xFFF1C40F),
        UIColor(argb: 0xFF2ECC71),
        UIColor(argb: 0xFF058039),
        UIColor(argb: 0xFF1ABC9C),
        UIColor(argb: 0xFF3498DB),
        UIColor(argb: 0xFF1E6DA0),
        UIColor(argb: 0xFF8E44AD),
        UIColor(argb: 0xFF9B59B6),
        UIColor(argb: 0xFFED3D95),
        UIColor(argb: 0xFF7F8C8D)
    ]

    private static let floorColor = UIColor.green.withAlphaComponent(0.7)
    private static let floorStripeColor = UIColor.red.withAlphaComponent(0.7)
    private static let gridColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
    private static let floorTitleColor = UIColor.red
    private static let titleColor = UIColor.white
    private static let padding: Float = 0.05

    private let scene: SCNScene
    private let x: Float
    private let y: Float
    private let z: Float
    private let config: CalendarConfig
    private let agendas: [Agenda]

    init(_ scene: SCNScene, _ x: Float, _ y: Float, _ z: Float, _ config: CalendarConfig, _ agendas: [Agenda]) {
        self.scene = scene
        self.x = x
        self.y = y
        self.z = z
        self.config = config
        self.agendas = agendas
        createFloor()
        createGrid()
        createBoxes()
        createDates()
    }

    private func createFloor() {
        let node = SCNNode()
        let stripeWidth = 10 * config.lineWidth
        let length = 20 * Float(config.length)
        node.addChildNode(createBox(Float(config.width) * config.cellWidth, config.lineWidth, length, 0, 0, length / 2, 0, CalendarScene.floorColor))
        // addBox(to: node, stripeWidth, config.lineWidth, length, -stripeWidth, 0, length / 2, 0, CalendarScene.floorStripeColor)
        // weird bug: -stripeWidth doesn't work
        node.addChildNode(createBox(stripeWidth, config.lineWidth, length, -3.5 * stripeWidth, 0, length / 2, 0, CalendarScene.floorStripeColor))
        node.addChildNode(createBox(stripeWidth, config.lineWidth, length, Float(config.width), 0, length / 2, 0, CalendarScene.floorStripeColor))
        scene.rootNode.addChildNode(node)
    }

    private func createGrid() {
        let node = SCNNode()
        for i in 0...config.length {
            for j in 0...config.width {
                node.addChildNode(createBox(config.lineWidth, config.cellHeight * Float(config.height), config.lineWidth, Float(j), 0, -Float(i), 0, CalendarScene.gridColor))
            }
        }
        for i in 0...config.length {
            for j in 0...config.height {
                node.addChildNode(createBox(config.cellWidth * Float(config.width), config.lineWidth, config.lineWidth, 0, Float(j), -Float(i), 0, CalendarScene.gridColor))
            }
        }
        for i in 0...config.width {
            for j in 0...config.height {
                node.addChildNode(createBox(config.lineWidth, config.lineWidth, config.cellLength * Float(config.length), Float(i), Float(j), 0, 0, CalendarScene.gridColor))
            }
        }
        scene.rootNode.addChildNode(node)
    }

    private func createBoxes() {
        let node = SCNNode()
        for (dayIndex, agenda) in agendas.enumerated() {
            for (eventIndex, event) in agenda.events.enumerated() {
                let randomIndex = Utility.getRandomInt(max: CalendarScene.colors.count)
                let color = CalendarScene.colors[randomIndex].withAlphaComponent(0.95)
                let boxNode = createBox(config.cellWidth, config.cellHeight, config.cellLength, 0, Float(eventIndex), -Float(dayIndex), config.chamferRadius, color)
                boxNode.addChildNode(createFrontText(event, config.cellWidth, config.cellHeight, config.cellLength, Float(config.width), 0, -Float(dayIndex)))
                boxNode.addChildNode(createRightText(event, config.cellWidth, config.cellHeight, config.cellLength, Float(config.width), 0, -Float(dayIndex)))
                boxNode.addChildNode(createLeftText(event, config.cellWidth, config.cellHeight, config.cellLength, Float(config.width), 0, -Float(dayIndex)))
                boxNode.addChildNode(createTopText(event, config.cellWidth, config.cellHeight, config.cellLength, Float(config.width), 0, -Float(dayIndex)))
                node.addChildNode(boxNode)
            }
        }
        scene.rootNode.addChildNode(node)
    }

    private func createDates() {
        let node = SCNNode()
        for (dayIndex, _) in agendas.enumerated() {
            addDate(to: node, dayIndex: dayIndex, config.cellWidth, config.cellHeight, config.cellLength, Float(config.width), 0, -Float(dayIndex))
        }
        scene.rootNode.addChildNode(node)
    }

    private func createBox(_ w: Float, _ h: Float, _ l: Float, _ x: Float, _ y: Float, _ z: Float, _ chamferRadius: Float, _ color: UIColor) -> SCNNode {
        let box = SCNBox(width: cg(w), height: cg(h), length: cg(l), chamferRadius: cg(chamferRadius))
        let matrix = SCNMatrix4Translate(translate(x - 0.5, y, z - 0.5), w / 2, h / 2, -l / 2)
        return createNode(box, matrix, color)
    }

    private func createText(_ text: String) -> SCNText {
        let text = SCNText(string: text, extrusionDepth: 0.01)
        text.firstMaterial?.diffuse.contents = CalendarScene.titleColor
        text.font = UIFont.systemFont(ofSize: 1)
        text.isWrapped = true
        text.alignmentMode = kCAAlignmentLeft
        text.truncationMode = kCATruncationEnd
        text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
        return text
    }

    private func createFrontText(_ text: String, _ w: Float, _ h: Float, _ l: Float, _ x: Float, _ y: Float, _ z: Float) -> SCNNode {
        let textNode = SCNNode(geometry: createText(text))
        let (min, max) = textNode.boundingBox
        let pivot = SCNMatrix4MakeTranslation(0.5 * max.x, 0.5 * min.y, 0)
        textNode.pivot = pivot
        let matrix = SCNMatrix4MakeTranslation(-CalendarScene.padding, -CalendarScene.padding, l / 2).scale(0.05)
        textNode.transform = matrix
        return textNode
    }

    private func createRightText(_ text: String, _ w: Float, _ h: Float, _ l: Float, _ x: Float, _ y: Float, _ z: Float) -> SCNNode {
        let textNode = SCNNode(geometry: createText(text))
        let min = textNode.boundingBox.min
        let pivot = SCNMatrix4MakeTranslation(0.5 * min.x, 0.5 * min.y, 0.5 * min.z)
        textNode.pivot = pivot
        textNode.transform = SCNMatrix4Mult(SCNMatrix4MakeRotation(.pi / 2, 0, 1, 0), SCNMatrix4MakeTranslation(w / 2, -CalendarScene.padding, l / 2  - CalendarScene.padding)).scale(0.05)
        return textNode
    }

    private func createLeftText(_ text: String, _ w: Float, _ h: Float, _ l: Float, _ x: Float, _ y: Float, _ z: Float) -> SCNNode {
        let textNode = SCNNode(geometry: createText(text))
        let min = textNode.boundingBox.min
        let pivot = SCNMatrix4MakeTranslation(0.5 * min.x, 0.5 * min.y, 0.5 * min.z)
        textNode.pivot = pivot
        textNode.transform = SCNMatrix4Mult(SCNMatrix4MakeRotation(-.pi / 2, 0, 1, 0), SCNMatrix4MakeTranslation(-w / 2, -CalendarScene.padding, -l / 2 + CalendarScene.padding)).scale(0.05)
        return textNode
    }

    private func createTopText(_ text: String, _ w: Float, _ h: Float, _ l: Float, _ x: Float, _ y: Float, _ z: Float) -> SCNNode {
        let textNode = SCNNode(geometry: createText(text))
        let min = textNode.boundingBox.min
        let pivot = SCNMatrix4MakeTranslation(0.5 * min.x, 0.5 * min.y, 0.5 * min.z)
        textNode.pivot = pivot
        textNode.transform = SCNMatrix4Mult(SCNMatrix4MakeRotation(-.pi / 2, 1, 0, 0), SCNMatrix4MakeTranslation(-w / 2 + CalendarScene.padding, h / 2, CalendarScene.padding)).scale(0.05)
        return textNode
    }

    private func addDate(to node: SCNNode, dayIndex: Int, _ w: Float, _ h: Float, _ l: Float, _ x: Float, _ y: Float, _ z: Float) {
        guard let date = Calendar.current.date(byAdding: .day, value: dayIndex, to: Date()) else {
            return
        }
        let dateString = Utility.format(date: date)
        let text = SCNText(string: dateString, extrusionDepth: 0.01)
        text.isWrapped = true
        text.firstMaterial?.diffuse.contents = CalendarScene.floorTitleColor
        text.font = UIFont.systemFont(ofSize: 1)
        let textNode = SCNNode(geometry: text)
        let (min, max) = textNode.boundingBox
        let pivot = SCNMatrix4MakeTranslation(0.5 * min.x, min.y + 0.5 * (max.y - min.y), min.z + 0.5 * (max.z - min.z))
        textNode.pivot = pivot
        let matrix = SCNMatrix4Mult(SCNMatrix4MakeRotation(-.pi / 2, 1, 0, 0), SCNMatrix4Translate(translate(x - 0.5, y, z - 0.5), 0, 0, -l / 2)).scale(0.1)
        textNode.transform = matrix
        node.addChildNode(textNode)
    }

    private func createNode(_ geometry: SCNGeometry, _ matrix: SCNMatrix4, _ color: UIColor) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = color
        // use the same material for all geometry elements
        geometry.firstMaterial = material
        let node = SCNNode(geometry: geometry)
        node.transform = matrix
        return node
    }

    private func translate(_ x: Float, _ y: Float, _ z: Float = 0) -> SCNMatrix4 {
        return SCNMatrix4MakeTranslation(self.x + x * config.cellWidth, self.y + y * config.cellHeight, self.z + z * config.cellLength)
    }

    private func cg(_ f: Float) -> CGFloat { return CGFloat(f) }

}

extension SCNMatrix4 {
    func scale(_ s: Float) -> SCNMatrix4 { return SCNMatrix4Scale(self, s, s, s) }
}
