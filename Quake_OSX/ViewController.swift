//
//  ViewController.swift
//  Quake_OSX
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

import MetalKit
import GameController

class ViewController: NSViewController, MTKViewDelegate
{
    @IBOutlet weak var metalView: MetalView!
    
    private var device: MTLDevice!
    
    private var commandQueue: MTLCommandQueue!
    
    private var pipelineState: MTLRenderPipelineState!

    private var modelViewProjectionMatrixBuffer: MTLBuffer! = nil
    
    private var buffer: MTLBuffer! = nil
    
    private var texture: MTLTexture! = nil
    
    private var colorTable: MTLTexture! = nil
    
    private var textureSamplerState: MTLSamplerState! = nil

    private var colorTableSamplerState: MTLSamplerState! = nil
    
    private var previousWidth: Float = -1
    
    private var previousHeight: Float = -1
    
    private var previousTime: NSTimeInterval = -1
    
    private var currentTime: NSTimeInterval = -1
    
    private var remote: GCController? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        device = MTLCreateSystemDefaultDevice()

        commandQueue = device.newCommandQueue()
        
        let library = device.newDefaultLibrary()
        
        let vertexProgram = library!.newFunctionWithName("vertexMain")
        
        let fragmentProgram = library!.newFunctionWithName("fragmentMain")
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].format = .Float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .Float2
        vertexDescriptor.attributes[1].offset = 16
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = 24
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineStateDescriptor.colorAttachments[0].blendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
        pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
        pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha
        pipelineStateDescriptor.sampleCount = metalView.sampleCount
        
        do
        {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        }
        catch let error as NSError
        {
            NSLog("Failed to create the textured pipeline state, error \(error)")
            abort()
        }

        modelViewProjectionMatrixBuffer = device.newBufferWithLength(16 * sizeof(Float), options:[])
        
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
        colorTableDescriptor.textureType = .Type1D
        colorTableDescriptor.width = 256
        
        colorTable = device.newTextureWithDescriptor(colorTableDescriptor)
        
        let textureSamplerDescriptor = MTLSamplerDescriptor()
        
        textureSamplerState = device.newSamplerStateWithDescriptor(textureSamplerDescriptor)
        
        let colorTableSamplerDescriptor = MTLSamplerDescriptor()
        
        colorTableSamplerState = device.newSamplerStateWithDescriptor(colorTableSamplerDescriptor)
        
        buffer = device.newBufferWithBytes(data, length: data.count * sizeofValue(data[0]), options:[])

        metalView.device = device
        metalView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidConnect), name: "GCControllerDidConnectNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidDisconnect), name: "GCControllerDidDisconnectNotification", object: nil)
        
        Sys_Init(Process.argc, Process.unsafeArgv)
    }

    func orthographic(top: Float, bottom: Float, left: Float, right: Float, near: Float, far: Float) -> [Float]
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
    
    func mtkView(view: MTKView, drawableSizeWillChange size: CGSize)
    {
    }

    func drawInMTKView(view: MTKView)
    {
        if previousTime < 0
        {
            previousTime = NSProcessInfo().systemUptime
        }
        else if currentTime < 0
        {
            currentTime = NSProcessInfo().systemUptime
        }
        else
        {
            previousTime = currentTime
            
            currentTime = NSProcessInfo().systemUptime
            
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
            let matrixPointer = UnsafeMutablePointer<Float>(matrixData)
            
            for i in 0..<16
            {
                matrixPointer[i] = matrix[i]
            }

            let textureDescriptor = MTLTextureDescriptor()
            textureDescriptor.pixelFormat = .R8Unorm
            textureDescriptor.width = Int(vid_screenWidth)
            textureDescriptor.height = Int(vid_screenHeight)
            
            texture = device.newTextureWithDescriptor(textureDescriptor)
        }

        let screenRegion = MTLRegionMake2D(0, 0, Int(vid_screenWidth), Int(vid_screenHeight))
        
        texture.replaceRegion(screenRegion, mipmapLevel: 0, slice: 0, withBytes: vid_buffer, bytesPerRow: Int(vid_screenWidth), bytesPerImage: 0)

        let colorTableRegion = MTLRegionMake1D(0, 256);
        
        colorTable.replaceRegion(colorTableRegion, mipmapLevel: 0, slice: 0, withBytes: d_8to24table, bytesPerRow: 0, bytesPerImage: 0)
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        
        let currentDrawable = view.currentDrawable
        
        if renderPassDescriptor != nil && currentDrawable != nil
        {
            renderPassDescriptor!.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            renderPassDescriptor!.depthAttachment.loadAction = .Clear
            
            let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor!)
            
            commandEncoder.setRenderPipelineState(pipelineState)
            
            commandEncoder.setVertexBuffer(buffer, offset: 0, atIndex: 0)
            commandEncoder.setVertexBuffer(modelViewProjectionMatrixBuffer, offset: 0, atIndex: 1)
            commandEncoder.setFragmentTexture(texture, atIndex: 0)
            commandEncoder.setFragmentTexture(colorTable, atIndex: 1)
            commandEncoder.setFragmentSamplerState(textureSamplerState, atIndex: 0)
            commandEncoder.setFragmentSamplerState(colorTableSamplerState, atIndex: 1)
            
            commandEncoder.drawPrimitives(.TriangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)

            commandEncoder.endEncoding()
            
            commandBuffer.presentDrawable(currentDrawable!)
        }
        
        commandBuffer.commit()
    }
    
    func controllerDidConnect(notification: NSNotification)
    {
        for controller in GCController.controllers()
        {
            if controller.extendedGamepad != nil && remote == nil
            {
                remote = controller
                
                remote!.playerIndex = .Index1
                
                remote!.controllerPausedHandler = { (controller: GCController) -> () in
                    
                    Key_Event(255, qboolean(1)) // K_PAUSE, true
                    Key_Event(255, qboolean(0)) // K_PAUSE, false
                    
                    Key_Event(27, qboolean(1)) // K_ESCAPE, true
                    Key_Event(27, qboolean(0)) // K_ESCAPE, false
                    
                }
                
                remote!.extendedGamepad!.dpad.up.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(128, qboolean(pressed ? 1 : 0)) // K_UPARROW, true / false
                }
                
                
                remote!.extendedGamepad!.dpad.left.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(130, qboolean(pressed ? 1 : 0)) // K_LEFTARROW, true / false
                    
                }
                
                remote!.extendedGamepad!.dpad.right.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(131, qboolean(pressed ? 1 : 0)) // K_RIGHTARROW, true / false
                    
                }
                
                remote!.extendedGamepad!.dpad.down.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(129, qboolean(pressed ? 1 : 0)) // K_DOWNARROW, true / false
                    
                }
                
                remote!.extendedGamepad!.buttonA.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(13, qboolean(pressed ? 1 : 0)) // K_ENTER, true / false
                    
                }
                
                remote!.extendedGamepad!.buttonB.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(27, qboolean(pressed ? 1 : 0)) // K_ESCAPE, true / false
                    
                }
                
                remote!.extendedGamepad!.leftThumbstick.xAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_forwardmove = value
                    
                }
                
                remote!.extendedGamepad!.leftThumbstick.yAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_sidestepmove = value
                    
                }
                
                remote!.extendedGamepad!.rightThumbstick.xAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_rollangle = value
                    
                }
                
                remote!.extendedGamepad!.rightThumbstick.yAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_pitchangle = value
                    
                }
                
                remote!.extendedGamepad!.rightTrigger.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(133, qboolean(pressed ? 1 : 0)) // K_CTRL, true / false
                    
                }
                
                remote!.extendedGamepad!.rightShoulder.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    if pressed
                    {
                        Sys_Cbuf_AddText("impulse 10\n")
                    }
                    
                }
                
                break
            }
        }
    }
    
    func controllerDidDisconnect(notification: NSNotification)
    {
        if remote == notification.object as! GCController!
        {
            remote!.playerIndex = .IndexUnset
            
            in_forwardmove = 0.0
            in_sidestepmove = 0.0
            in_rollangle = 0.0
            in_pitchangle = 0.0

            remote = nil
        }
    }
}

