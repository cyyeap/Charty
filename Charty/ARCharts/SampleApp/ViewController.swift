//
//  ViewController.swift
//  ARCharts
//
//  Created by Bobo on 7/5/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import ARCharts
import ARKit
import SceneKit
import UIKit


class ViewController: UIViewController, ARSCNViewDelegate, SettingsDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pieChartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var accountPicker: UIPickerView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var roundedButtonCollection: [UIButton]!
    
    let accounts = ["Rate of Return - Last 5 Years ", "Asset Allocation", "Cumulative vs Monthly Return", "Portfolio Value vs Net Investment", "ASX: NWL"]

    @IBAction func NavigateToImage(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToImage", sender: nil)
    }
    
    var barChart: ARBarChart?{
        didSet {
            pieChartButton.setTitle(barChart == nil ? "Show Chart" : "Hide Chart", for: .normal)
        }
    }
    
    private let arKitColors = [
        UIColor(red: 0.0 / 255.0, green: 53.0 / 255.0, blue: 142.0 / 255.0, alpha: 1.0),
        UIColor(red: 0.0  / 255.0, green: 120.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0),
        UIColor(red: 0.0 / 255.0, green: 199.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0),
        
        UIColor(red: 109.0 / 255.0, green: 0.0 / 255.0, blue: 99.0 / 255.0, alpha: 1.0),
        UIColor(red: 240.0   / 255.0, green: 0.0 / 255.0, blue: 140.0 / 255.0, alpha: 1.0),
        UIColor(red: 249.0 / 255.0, green: 125.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0),
        
        UIColor(red: 0.0  / 255.0, green: 94.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0),
        UIColor(red: 0.0  / 255.0, green: 175.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0),
        UIColor(red: 160.0  / 255.0, green: 220.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0),
        
        UIColor(red: 185.0  / 255.0, green: 10.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0),
        UIColor(red: 255.0  / 255.0, green: 105.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0),
        UIColor(red: 255.0  / 255.0, green: 190.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
    ]
    
    private let arKitColorsBlue = [
        UIColor(red: 0.0 / 255.0, green: 53.0 / 255.0, blue: 142.0 / 255.0, alpha: 1.0),
        UIColor(red: 0.0  / 255.0, green: 120.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0),
        UIColor(red: 0.0 / 255.0, green: 199.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0),
        UIColor(red: 0.0 / 255.0, green: 40.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
    ]
    
    private let arKitColorsPurple = [
        UIColor(red: 109.0 / 255.0, green: 0.0 / 255.0, blue: 99.0 / 255.0, alpha: 1.0),
        UIColor(red: 240.0   / 255.0, green: 0.0 / 255.0, blue: 140.0 / 255.0, alpha: 1.0),
        UIColor(red: 249.0 / 255.0, green: 125.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0),
        UIColor(red: 51.0 / 255.0, green: 0.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
    ]
    
    private let arKitColorsGreen = [
        UIColor(red: 0.0  / 255.0, green: 94.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0),
        UIColor(red: 0.0  / 255.0, green: 175.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0),
        UIColor(red: 160.0  / 255.0, green: 220.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0),
        UIColor(red: 0.0 / 255.0, green: 61.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0)
    ]
    
    private let arKitColorsOrange = [
        UIColor(red: 185.0  / 255.0, green: 10.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0),
        UIColor(red: 255.0  / 255.0, green: 105.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0),
        UIColor(red: 255.0  / 255.0, green: 190.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0),
        UIColor(red: 63.0 / 255.0, green: 32.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)
    ]
    
    var session: ARSession {
        return sceneView.session
    }
    
    var screenCenter: CGPoint?
    var settings = Settings()
    var dataSeries: ARDataSeries?
    var configuration = ARWorldTrackingConfiguration()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        print("Main - ViewDidLoad")
        super.viewDidLoad()
        
        accountPicker.delegate = self
        accountPicker.dataSource = self
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.showsStatistics = false
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = false
        sceneView.contentScaleFactor = 1.0
        sceneView.preferredFramesPerSecond = 60
        DispatchQueue.main.async {
            self.screenCenter = self.sceneView.bounds.mid
        }
        
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
        
        for button in roundedButtonCollection {
            button.layer.cornerRadius = 5.0
            button.clipsToBounds = true
        }
        settingsButton.layer.cornerRadius = 5.0
        settingsButton.clipsToBounds = true
        
        setupFocusSquare()
        setupRotationGesture()
        setupHighlightGesture()
        
        addLightSource(ofType: .omni)
        
        print("Main - viewDidLoad - Finish")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Main - ViewWillAppear")
        
        super.viewWillAppear(animated)
        
        configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.configuration?.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        sceneView.delegate = self
        
        screenCenter = self.sceneView.bounds.mid
        
        print("Main - Finish ViewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Main - ViewDidAppear")
        super.viewDidAppear(animated)
        
        print("Main - ViewDidAppear - Finish")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Main - ViewWillDisAppear")
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK - Setups
    
    var focusSquare = FocusSquare()
    
    func setupFocusSquare() {
        focusSquare.isHidden = true
        focusSquare.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(focusSquare)
    }
    
    private func addBarChart(at position: SCNVector3) {
        if barChart != nil {
            barChart?.removeFromParentNode()
            barChart = nil
        }
        
        var values = generateRandomNumbers(withRange: 0..<50, numberOfRows: settings.numberOfSeries, numberOfColumns: settings.numberOfIndices)
        var seriesLabels = Array(0..<values.count).map({ "Series \($0)" })
        var indexLabels = Array(0..<values.first!.count).map({ "Index \($0)" })
        
        
        if settings.dataSet > -1 {
            values = generateNumbers(fromDataSampleWithIndex: settings.dataSet) ?? values
            seriesLabels = parseSeriesLabels(fromDataSampleWithIndex: settings.dataSet) ?? seriesLabels
            indexLabels = parseIndexLabels(fromDataSampleWithIndex: settings.dataSet) ?? indexLabels
        }
        
        dataSeries = ARDataSeries(withValues: values)
        if settings.showLabels {
            dataSeries?.seriesLabels = seriesLabels
            dataSeries?.indexLabels = indexLabels
            dataSeries?.spaceForIndexLabels = 0.2
            dataSeries?.spaceForIndexLabels = 0.2
        } else {
            dataSeries?.spaceForIndexLabels = 0.0
            dataSeries?.spaceForIndexLabels = 0.0
        }
        dataSeries?.barColors = setupColor()
        dataSeries?.barOpacity = settings.barOpacity
        
        barChart = ARBarChart()
        if let barChart = barChart {
            barChart.dataSource = dataSeries
            barChart.delegate = dataSeries
            setupGraph()
            barChart.position = position
            barChart.draw()
            sceneView.scene.rootNode.addChildNode(barChart)
        }
    }
    
    private func addLightSource(ofType type: SCNLight.LightType, at position: SCNVector3? = nil) {
        let light = SCNLight()
        light.color = UIColor.white
        light.type = type
        light.intensity = 1500 // Default SCNLight intensity is 1000
        
        let lightNode = SCNNode()
        lightNode.light = light
        if let lightPosition = position {
            // Fix the light source in one location
            lightNode.position = lightPosition
            self.sceneView.scene.rootNode.addChildNode(lightNode)
        } else {
            // Make the light source follow the camera position
            self.sceneView.pointOfView?.addChildNode(lightNode)
        }
    }
    
    private func setupRotationGesture() {
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        self.view.addGestureRecognizer(rotationGestureRecognizer)
    }
    
    private func setupHighlightGesture() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    private func setupColor() -> [UIColor] {
        switch settings.colourSet
        {
        case 0:
            return arKitColors
        case 1:
            return arKitColorsBlue
        case 2:
            return arKitColorsPurple
        case 3:
            return arKitColorsGreen
        case 4:
            return arKitColorsOrange
        default:
            return arKitColors
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("failed with error")
        
        restartSessionWithoutDelete()
    }
    @objc func restartSessionWithoutDelete() {
        self.sceneView.session.pause()
        self.sceneView.session.run(configuration, options: [
            .resetTracking,
            .removeExistingAnchors])
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("failed with error - Session Interrupted (Start)")
        // TODO: Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("failed with error - Session Interrupted (End)")
        // TODO: Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    // MARK: - Actions
    
    @IBAction func handleTapChartButton(_ sender: UIButton) {
        renderBarChart(button: "chart")
    }
    
    @IBAction func handleTapBarChartButton(_ sender: UIButton) {
        renderBarChart(button: "bar")
    }
    
    @IBAction func handleTapPieChartButton(_ sender: UIButton) {
        renderBarChart(button: "pie")
    }
    
    @IBAction func handleTapLineChartButton(_ sender: UIButton) {
        renderBarChart(button: "line")
    }
    
    func renderBarChart(button: String) {
        guard let lastPosition = focusSquare.lastPosition else {
            return
        }
        
        if self.barChart != nil {
            self.barChart?.removeFromParentNode()
            self.barChart = nil
        } else {
            self.addBarChart(at: lastPosition)
        }
    }
    
    private var startingRotation: Float = 0.0
    
    @objc func handleRotation(rotationGestureRecognizer: UIRotationGestureRecognizer) {
        guard let barChart = barChart,
            let pointOfView = sceneView.pointOfView,
            sceneView.isNode(barChart, insideFrustumOf: pointOfView) == true else {
            return
        }
        
        if rotationGestureRecognizer.state == .began {
            startingRotation = barChart.eulerAngles.y
        } else if rotationGestureRecognizer.state == .changed {
            self.barChart?.eulerAngles.y = startingRotation - Float(rotationGestureRecognizer.rotation)
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        var labelToHighlight: ARChartLabel?
        
        let animationStyle = settings.longPressAnimationType
        let animationDuration = 0.3
        let longPressLocation = gestureRecognizer.location(in: self.view)
        let selectedNode = self.sceneView.hitTest(longPressLocation, options: nil).first?.node
        if let barNode = selectedNode as? ARBarChartBar {
            barChart?.highlightBar(atIndex: barNode.index, forSeries: barNode.series, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
        } else if let labelNode = selectedNode as? ARChartLabel {
            // Detect long press on label text
            labelToHighlight = labelNode
        } else if let labelNode = selectedNode?.parent as? ARChartLabel {
            // Detect long press on label background
            labelToHighlight = labelNode
        }
        
        if let labelNode = labelToHighlight {
            switch labelNode.type {
            case .index:
                barChart?.highlightIndex(labelNode.id, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
            case .series:
                barChart?.highlightSeries(labelNode.id, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
            case .title:
                barChart?.highlightIndex(labelNode.id, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
            }
        }
        
        let tapToUnhighlight = UITapGestureRecognizer(target: self, action: #selector(handleTapToUnhighlight(_:)))
        self.view.addGestureRecognizer(tapToUnhighlight)
    }
    
    @objc func handleTapToUnhighlight(_ gestureRecognizer: UITapGestureRecognizer) {
        barChart?.unhighlight()
        self.view.removeGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: - Helper Functions
    
    func updateFocusSquare() {
        guard let screenCenter = screenCenter else {
            return
        }
        
        if barChart != nil {
            focusSquare.isHidden = true
            focusSquare.hide()
        } else {
            focusSquare.isHidden = false
            focusSquare.unhide()
        }
        
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare.position)
        if let worldPos = worldPos {
            focusSquare.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
        }
    }
    
    var dragOnInfinitePlanesEnabled = false
    
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor
            
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
            
            let pointOnPlane = objectPos ?? SCNVector3Zero
            
            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
    private func setupGraph() {
        barChart?.animationType = settings.animationType
        barChart?.size = SCNVector3(settings.graphWidth, settings.graphHeight, settings.graphLength)
    }
    
    // MARK: Navigation
    
    @IBAction func handleTapOnSettingsButton(_ sender: UIButton) {
        guard let settingsNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsPopoverNavigationControllerId") as? UINavigationController,
            let settingsViewController = settingsNavigationController.viewControllers.first as? SettingsTableViewController else {
                return
        }
        
        settingsNavigationController.modalPresentationStyle = .popover
        settingsNavigationController.popoverPresentationController?.permittedArrowDirections = .any
        settingsNavigationController.popoverPresentationController?.sourceView = sender
        settingsNavigationController.popoverPresentationController?.sourceRect = sender.bounds
        
        settingsViewController.delegate = self
        settingsViewController.settings = self.settings
        
        DispatchQueue.main.async {
            self.present(settingsNavigationController, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: SettingsDelegate
    
    func didUpdateSettings(_ settings: Settings) {
        self.settings = settings
        barChart?.removeFromParentNode()
        barChart = nil
    }
    
    // MARK: Picker Delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accounts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return accounts[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        settings.dataSet = row
        guard barChart != nil else {
            return
        }
        
        guard let lastPosition = focusSquare.lastPosition else {
            return
        }
        
        self.addBarChart(at: lastPosition)
    }
}
