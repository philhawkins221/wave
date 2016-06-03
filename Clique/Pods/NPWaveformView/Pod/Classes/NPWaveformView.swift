//
//  NPWaveformView.swift
//  Pods
//
//  Created by Nicola Perantoni on 16/11/15.
//
//

import UIKit

let pi = M_PI

@IBDesignable
public class NPWaveformView: UIView {

    /// waveColor: Color to use when drawing the waves
    /// - Note: Default value is red
    @IBInspectable public var waveColor = UIColor.redColor()
    
    /// numberOfWaves: The total number of waves
    /// - Note: Default value is 6
    @IBInspectable public var numberOfWaves = 6
    
    /// primaryWaveLineWidth: Line width used for the prominent wave
    /// - Note: Default value is 1.5
    @IBInspectable public var primaryWaveLineWidth: CGFloat = 1.5
    
    /// secondaryWaveLineWidth: Line width used for all secondary waves
    /// - Note: Default value is 0.5
    @IBInspectable public var secondaryWaveLineWidth: CGFloat = 0.5
    
    /// idleAmplitude: The amplitude that is used when the incoming amplitude is near zero.
    /// Setting a value greater 0 provides a more vivid visualization.
    /// - Note: Default value is 0.01
    @IBInspectable public var idleAmplitude: CGFloat = 0.01
    
    /// frequency: The frequency of the sinus wave. The higher the value, the more sinus wave peaks you will have.
    /// - Note: Default value is 1.5
    @IBInspectable public var frequency: CGFloat = 1.5
    
    /// density: The lines are joined stepwise, the more dense you draw, the more CPU power is used.
    /// - Note: Default value is 1
    @IBInspectable public var density: CGFloat = 1.0
    
    /// phaseShift: The phase shift that will be applied with each level setting
    /// Change this to modify the animation speed or direction
    /// - Note: Default value is -0.15
    @IBInspectable public var phaseShift: CGFloat = -0.15
    
    /// amplitude: The current amplitude.
    /// - Note: Default value is 1.0
    @IBInspectable public var amplitude: CGFloat = 1.0 {
        didSet {
            amplitude = max(amplitude, self.idleAmplitude)
            self.setNeedsDisplay()
        }
    }
    
    private var _phase: CGFloat = 0.0
    private var _amplitude: CGFloat = 0.0
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func updateWithLevel(level: CGFloat) -> Void {
        _phase += phaseShift
        _amplitude = fmax(level, idleAmplitude)
        setNeedsDisplay()
    }
    
    /// drawRect: We draw multiple sinus waves, with equal phases but altered amplitudes, multiplied by a parable function.
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, bounds)
        
        backgroundColor?.set()
        CGContextFillRect(context, rect)
        
        for var i = 0; i < numberOfWaves; i++ {
            let context = UIGraphicsGetCurrentContext()
            CGContextSetAllowsAntialiasing(context, true)
            
            CGContextSetLineWidth(context, (i == 0 ? primaryWaveLineWidth : secondaryWaveLineWidth))
            
            let halfHeight = CGRectGetHeight(bounds) / 2.0
            let width = CGRectGetWidth(bounds)
            let mid = width / 2.0
            
            let maxAmplitude = halfHeight - 4.0 // 4 corresponds to twice the stroke width
            
            // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
            let progress = CGFloat(1.0 - Float(i) / Float(numberOfWaves))
            let normedAmplitude = (1.5 * progress - 0.5) * amplitude
            
            let multiplierProgress = ((progress / 3.0 * 2.0) + (1.0 / 3.0))
            let multiplier = CGFloat(min(1.0, multiplierProgress))
            
            waveColor.colorWithAlphaComponent(multiplier * CGColorGetAlpha(waveColor.CGColor)).set()
            
            for var x: CGFloat = 0.0; x < width + density; x += density {
                // We use a parable to scale the sinus wave, that has its peak in the middle of the view.
                let scaling = -pow(1 / mid * (x - mid), 2) + 1
                
                let tempCasting = CGFloat(2.0 * Float(pi) * Float(x / width)) * frequency + _phase
                let y = scaling * maxAmplitude * normedAmplitude * CGFloat(sinf(Float(tempCasting))) + halfHeight
                
                if x == 0 {
                    CGContextMoveToPoint(context, x, y)
                } else {
                    CGContextAddLineToPoint(context, x, y)
                }
            }
            
            CGContextStrokePath(context)
        }
    }
    
}
