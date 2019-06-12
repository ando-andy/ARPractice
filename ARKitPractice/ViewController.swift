//
//  ViewController.swift
//  ARKitPractice
//
//  Created by kazutaka.ando on 2019/06/12.
//  Copyright © 2019 Kazando. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        //tapGesture
        sceneView.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(self.tapView(sender:))))
        //TODO: Failed to drag the AR view
        //        sceneView.addGestureRecognizer(UIPanGestureRecognizer(
        //            target: self, action: #selector(self.dragView(sender:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        //Plane Detection
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("\(self.classForCoder)/" + #function)
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        //Configure scene and node
        guard let scene = SCNScene(named: "nrt.scn", inDirectory: "art.scnassets/nrt") else {fatalError()}
        guard let narutoNode = scene.rootNode.childNode(withName: "nrt", recursively: true) else {fatalError()}
        // Modify node
        let (min, max) = narutoNode.boundingBox
        let w = CGFloat(max.x - min.x)
        // magnification
        let magnification = 1.0 / w
        narutoNode.scale = SCNVector3(magnification, magnification, magnification)
        // Configure node position
        narutoNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        //add created node
        DispatchQueue.main.async(execute: {
            node.addChildNode(narutoNode)
        })
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("\(self.classForCoder)/" + #function)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @objc func tapView(sender: UIGestureRecognizer) {
        let tapPoint = sender.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        if !results.isEmpty {
            if let result = results.first ,
                let anchor = result.anchor ,
                let node = sceneView.node(for: anchor) {
                
                let action1 = SCNAction.rotateBy(x: CGFloat(-90 * (Float.pi / 180)), y: 0, z: 0, duration: 0.5)
                let action2 = SCNAction.wait(duration: 1)
                
                DispatchQueue.main.async(execute: {
                    node.runAction(
                        SCNAction.sequence([
                            action1,
                            action2,
                            action1.reversed()
                            ])
                    )
                })
                
            }
        }
    }
    
    @objc func dragView(sender: UIGestureRecognizer) {
        let tapPoint = sender.location(in: sceneView)
        
        let results = sceneView.hitTest(tapPoint, types: .existingPlane)
        if !results.isEmpty {
            if let result = results.first ,
                let anchor = result.anchor ,
                let node = sceneView.node(for: anchor) {
                
                DispatchQueue.main.async(execute: {
                    // apply the value of SCNVector3 to the axis of coordinates
                    node.position = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                })
            }
        }
    }
    
}
