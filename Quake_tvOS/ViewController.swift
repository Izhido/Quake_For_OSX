//
//  ViewController.swift
//  Quake_tvOS
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

import MetalKit
import GameController

class ViewController: GCEventViewController, MTKViewDelegate
{
    @IBOutlet weak var metalView: MTKView!
    
    fileprivate var device: MTLDevice!
    
    fileprivate var commandQueue: MTLCommandQueue!
    
    fileprivate var pipelineState: MTLRenderPipelineState!
    
    fileprivate var modelViewProjectionMatrixBuffer: MTLBuffer! = nil
    
    fileprivate var buffer: MTLBuffer! = nil
    
    fileprivate var texture: MTLTexture! = nil
    
    fileprivate var colorTable: MTLTexture! = nil
    
    fileprivate var textureSamplerState: MTLSamplerState! = nil
    
    fileprivate var colorTableSamplerState: MTLSamplerState! = nil
    
    fileprivate var previousWidth: Float = -1
    
    fileprivate var previousHeight: Float = -1
    
    fileprivate var previousTime: TimeInterval = -1
    
    fileprivate var currentTime: TimeInterval = -1
    
    fileprivate var remote: GCController? = nil
    
    fileprivate var extendedRemote: GCController? = nil
    
    fileprivate var renderingStopped: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        
        commandQueue = device.makeCommandQueue()
        
        let library = device.makeDefaultLibrary()
        
        let vertexProgram = library!.makeFunction(name: "vertexMain")
        
        let fragmentProgram = library!.makeFunction(name: "fragmentMain")
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = 16
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = 24
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineStateDescriptor.sampleCount = metalView.sampleCount
        
        do
        {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        }
        catch let error as NSError
        {
            NSLog("Failed to create the textured pipeline state, error \(error)")
            abort()
        }
        
        modelViewProjectionMatrixBuffer = device.makeBuffer(length: 16 * MemoryLayout<Float>.size, options:[])
        
        let data : [Float] = [
            -1.6, 1.0, -1.0, 1.0,
            0.0, 0.0,
            1.6, 1.0, -1.0, 1.0,
            1.0, 0.0,
            -1.6, -1.0, -1.0, 1.0,
            0.0, 1.0,
            1.6, -1.0, -1.0, 1.0,
            1.0, 1.0
        ]
        
        let colorTableDescriptor = MTLTextureDescriptor()
        colorTableDescriptor.textureType = .type1D
        colorTableDescriptor.width = 256
        
        colorTable = device.makeTexture(descriptor: colorTableDescriptor)
        
        let textureSamplerDescriptor = MTLSamplerDescriptor()
        
        textureSamplerState = device.makeSamplerState(descriptor: textureSamplerDescriptor)
        
        let colorTableSamplerDescriptor = MTLSamplerDescriptor()
        
        colorTableSamplerState = device.makeSamplerState(descriptor: colorTableSamplerDescriptor)
        
        buffer = device.makeBuffer(bytes: data, length: data.count * MemoryLayout.size(ofValue: data[0]), options:[])
        
        metalView.device = device
        metalView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidConnect), name: NSNotification.Name(rawValue: "GCControllerDidConnectNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidDisconnect), name: NSNotification.Name(rawValue: "GCControllerDidDisconnectNotification"), object: nil)
        
        let ipAddress = UserDefaults.standard.string(forKey: "net_ipaddress")
        
        if ipAddress != nil && !ipAddress!.isEmpty
        {
            net_ipaddress = UnsafeMutablePointer<Int8>.allocate(capacity: ipAddress!.count + 1)
            
            strcpy(net_ipaddress, ipAddress!.cString(using: String.defaultCStringEncoding)!)
        }
        
        Sys_Init(Bundle.main.resourcePath!, try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).path)

        let server = UserDefaults.standard.string(forKey: "lanConfig_joinname")
        
        if server != nil && !server!.isEmpty
        {
            strcpy(lanConfig_joinname, server!.cString(using: String.defaultCStringEncoding)!)
        }
        
        let port = UserDefaults.standard.integer(forKey: "lanConfig_port")
        
        if port != 0
        {
            lanConfig_port = Int32(port)
        }
        
        let playerName = UserDefaults.standard.string(forKey: "cl_name")
        
        if playerName != nil && !playerName!.isEmpty
        {
            Sys_Cbuf_AddText("name \(playerName!)")
        }
    }
    
    func orthographic(_ top: Float, bottom: Float, left: Float, right: Float, near: Float, far: Float) -> [Float]
    {
        let ral = right + left
        let rsl = right - left
        let tab = top + bottom
        let tsb = top - bottom
        let fan = far + near
        let fsn = far - near
        
        return [
            2.0 / rsl, 0.0, 0.0, 0.0,
            0.0, 2.0 / tsb, 0.0, 0.0,
            0.0, 0.0, -2.0 / fsn, 0.0,
            -ral / rsl, -tab / tsb, -fan / fsn, 1.0
        ]
    }
    
    func setupEndingScreen()
    {
        if !renderingStopped
        {
            renderingStopped = true
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
    {
    }
    
    func draw(in view: MTKView)
    {
        if sys_ended.rawValue != 0
        {
            setupEndingScreen()
            
            return
        }

        if previousTime < 0
        {
            previousTime = ProcessInfo().systemUptime
        }
        else if currentTime < 0
        {
            currentTime = ProcessInfo().systemUptime
        }
        else
        {
            previousTime = currentTime
            
            currentTime = ProcessInfo().systemUptime
            
            frame_lapse = Float(currentTime - previousTime)
        }
        
        Sys_Frame()
        
        let width = Float(metalView.bounds.width)
        
        let height = Float(metalView.bounds.height)
        
        if previousWidth != width || previousHeight != height
        {
            previousWidth = width
            previousHeight = height
            
            VID_SetSize(Int32(width), Int32(height))
            
            let vid_aspect = Float(vid_screenWidth) / Float(vid_screenHeight)
            
            var matrix : [Float]
            
            if width > height * vid_aspect
            {
                let aspectRatio = width / height
                
                matrix = orthographic(1.0, bottom: -1.0, left: -aspectRatio, right: aspectRatio, near: -1.0, far: 1.0)
            }
            else
            {
                let aspectRatio = height * vid_aspect / width
                
                matrix = orthographic(aspectRatio, bottom: -aspectRatio, left: -vid_aspect, right: vid_aspect, near: -1.0, far: 1.0)
            }
            
            let matrixData = modelViewProjectionMatrixBuffer.contents()
            
            memcpy(matrixData, matrix, 16 * MemoryLayout<Float>.size)
            
            let textureDescriptor = MTLTextureDescriptor()
            textureDescriptor.pixelFormat = .r8Unorm
            textureDescriptor.width = Int(vid_screenWidth)
            textureDescriptor.height = Int(vid_screenHeight)
            
            texture = device.makeTexture(descriptor: textureDescriptor)
        }
        
        let screenRegion = MTLRegionMake2D(0, 0, Int(vid_screenWidth), Int(vid_screenHeight))
        
        texture.replace(region: screenRegion, mipmapLevel: 0, slice: 0, withBytes: vid_buffer, bytesPerRow: Int(vid_screenWidth), bytesPerImage: 0)
        
        let colorTableRegion = MTLRegionMake1D(0, 256);
        
        colorTable.replace(region: colorTableRegion, mipmapLevel: 0, slice: 0, withBytes: d_8to24table, bytesPerRow: 0, bytesPerImage: 0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        
        let currentDrawable = view.currentDrawable
        
        if renderPassDescriptor != nil && currentDrawable != nil
        {
            renderPassDescriptor!.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            renderPassDescriptor!.depthAttachment.loadAction = .clear
            
            let commandEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
            
            commandEncoder!.setRenderPipelineState(pipelineState)
            
            commandEncoder!.setVertexBuffer(buffer, offset: 0, index: 0)
            commandEncoder!.setVertexBuffer(modelViewProjectionMatrixBuffer, offset: 0, index: 1)
            commandEncoder!.setFragmentTexture(texture, index: 0)
            commandEncoder!.setFragmentTexture(colorTable, index: 1)
            commandEncoder!.setFragmentSamplerState(textureSamplerState, index: 0)
            commandEncoder!.setFragmentSamplerState(colorTableSamplerState, index: 1)
            
            commandEncoder!.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
            
            commandEncoder!.endEncoding()
            
            commandBuffer!.present(currentDrawable!)
        }
        
        commandBuffer!.commit()
    }

    @objc func controllerDidConnect(_ notification: Notification)
    {
        for controller in GCController.controllers()
        {
            if controller.gamepad == nil && controller.extendedGamepad == nil && controller.motion != nil && remote == nil
            {
                remote = controller
                
                if extendedRemote == nil
                {
                    remote!.playerIndex = .index1
                }
                
                remote!.motion!.valueChangedHandler = { (motion: GCMotion)->() in
                    
                    in_pitchangle = Float(asin(self.remote!.motion!.gravity.y) / (.pi / 2))
                    
                    in_rollangle = Float(atan2(-self.remote!.motion!.gravity.x, -self.remote!.motion!.gravity.z) / (.pi / 2))
                }
                
                break
            }
            else if controller.extendedGamepad != nil && extendedRemote == nil
            {
                extendedRemote = controller
                
                if remote != nil
                {
                    remote!.playerIndex = .indexUnset
                }

                extendedRemote!.playerIndex = .index1
                
                in_extendedinuse = qboolean(1)

                extendedRemote!.controllerPausedHandler = { (controller: GCController) -> () in
                    
                    Key_Event(27, qboolean(1)) // K_ESCAPE, true
                    Key_Event(27, qboolean(0)) // K_ESCAPE, false
                    
                }
                
                extendedRemote!.extendedGamepad!.dpad.up.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(128, qboolean(pressed ? 1 : 0)) // K_UPARROW, true / false
                }
                
                extendedRemote!.extendedGamepad!.dpad.left.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(130, qboolean(pressed ? 1 : 0)) // K_LEFTARROW, true / false
                    
                }
                
                extendedRemote!.extendedGamepad!.dpad.right.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(131, qboolean(pressed ? 1 : 0)) // K_RIGHTARROW, true / false
                    
                }
                
                extendedRemote!.extendedGamepad!.dpad.down.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(129, qboolean(pressed ? 1 : 0)) // K_DOWNARROW, true / false
                    
                }
                
                extendedRemote!.extendedGamepad!.buttonA.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(13, qboolean(pressed ? 1 : 0)) // K_ENTER, true / false
                    
                }
                
                extendedRemote!.extendedGamepad!.buttonB.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(27, qboolean(pressed ? 1 : 0)) // K_ESCAPE, true / false
                    
                }
                
                extendedRemote!.extendedGamepad!.leftThumbstick.xAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_extendedforwardmove = value
                    
                }
                
                extendedRemote!.extendedGamepad!.leftThumbstick.yAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_extendedsidestepmove = value
                    
                }
                
                extendedRemote!.extendedGamepad!.rightThumbstick.xAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_extendedrollangle = value
                    
                }
                
                extendedRemote!.extendedGamepad!.rightThumbstick.yAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_extendedpitchangle = value
                    
                }
                
                extendedRemote!.extendedGamepad!.rightTrigger.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(133, qboolean(pressed ? 1 : 0)) // K_CTRL, true / false
                    
                }
                
                extendedRemote!.extendedGamepad!.rightShoulder.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    if pressed
                    {
                        Sys_Cbuf_AddText("impulse 10\n")
                    }
                    
                }
                
                break
            }

        }
    }
    
    @objc func controllerDidDisconnect(_ notification: Notification)
    {
        if extendedRemote == notification.object as? GCController
        {
            in_extendedinuse = qboolean(0)
            
            extendedRemote!.playerIndex = .indexUnset
            
            if remote != nil
            {
                remote!.playerIndex = .index1
            }

            in_extendedpitchangle = 0.0
            in_extendedrollangle = 0.0
            in_extendedforwardmove = 0.0
            in_extendedsidestepmove = 0.0
            
            extendedRemote = nil
        }

        if remote == notification.object as? GCController
        {
            remote!.playerIndex = .indexUnset
            
            in_pitchangle = 0.0
            in_rollangle = 0.0
            in_touchx = 0.0
            in_touchy = 0.0
            
            remote = nil
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?)
    {
        for press in presses
        {
            if press.type == .menu
            {
                if extendedRemote == nil
                {
                    Key_Event(27, qboolean(1)) // K_ESCAPE, true
                }
            }
            else if press.type == .playPause
            {
                if extendedRemote == nil
                {
                    Key_Event(255, qboolean(1)) // K_PAUSE, true
                }
            }
            else if press.type == .upArrow
            {
                if key_dest != key_game
                {
                    Key_Event(128, qboolean(1)) // K_UPARROW, true
                }
            }
            else if press.type == .downArrow
            {
                if key_dest == key_game
                {
                    Key_Event(32, qboolean(1)) // K_SPACE, true
                }
                else
                {
                    Key_Event(129, qboolean(1)) // K_DOWNARROW, true
                }
            }
            else if press.type == .leftArrow
            {
                if key_dest == key_game
                {
                    Sys_Cbuf_AddText("impulse 10\n")
                }
                else
                {
                    Key_Event(130, qboolean(1)) // K_LEFTARROW, true
                }
            }
            else if press.type == .rightArrow
            {
                if key_dest == key_game
                {
                    Sys_Cbuf_AddText("impulse 10\n")
                }
                else
                {
                    Key_Event(131, qboolean(1)) // K_RIGHTARROW, true
                }
            }
            else if press.type == .select
            {
                if key_dest == key_game
                {
                    Key_Event(133, qboolean(1)) // K_CTRL, true
                }
                else
                {
                    Key_Event(13, qboolean(1)) // K_ENTER, true
                }
            }
        }
    }
    
    fileprivate func releaseAllPresses(_ presses: Set<UIPress>)
    {
        for press in presses
        {
            if press.type == .menu
            {
                Key_Event(27, qboolean(0)) // K_ESCAPE, false
            }
            else if press.type == .playPause
            {
                Key_Event(255, qboolean(0)) // K_PAUSE, false
            }
            else if press.type == .upArrow
            {
                if key_dest != key_game
                {
                    Key_Event(128, qboolean(0)) // K_UPARROW, false
                }
            }
            else if press.type == .downArrow
            {
                if key_dest == key_game
                {
                    Key_Event(32, qboolean(0)) // K_SPACE, false
                }
                else
                {
                    Key_Event(129, qboolean(0)) // K_DOWNARROW, false
                }
            }
            else if press.type == .leftArrow
            {
                if key_dest != key_game
                {
                    Key_Event(130, qboolean(0)) // K_LEFTARROW, false
                }
            }
            else if press.type == .rightArrow
            {
                if key_dest != key_game
                {
                    Key_Event(131, qboolean(0)) // K_RIGHTARROW, false
                }
            }
            else if press.type == .select
            {
                if key_dest == key_game
                {
                    Key_Event(133, qboolean(0)) // K_CTRL, false
                }
                else
                {
                    Key_Event(13, qboolean(0)) // K_ENTER, false
                }
            }
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?)
    {
        releaseAllPresses(presses)
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?)
    {
        releaseAllPresses(presses)
    }

    fileprivate func resetTouchValues(_ touches: Set<UITouch>?)
    {
        if touches!.count == 1
        {
            in_touchx = 0.0;
            in_touchy = 0.0;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        resetTouchValues(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if touches.count == 1
        {
            let touch = touches.first
            
            let point = touch!.location(in: view)
            
            in_touchx = 2.0 * Float(point.x / view.bounds.width) - 1.0
            in_touchy = 2.0 * Float(point.y / view.bounds.height) - 1.0
        }
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        resetTouchValues(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
        resetTouchValues(touches)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

