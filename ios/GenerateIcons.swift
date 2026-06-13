import CoreGraphics
import CoreText
import Foundation
import ImageIO

// MARK: - Color Helpers

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}

func deg(_ d: CGFloat) -> CGFloat { d * .pi / 180 }

// MARK: - Brand Colors (from UI Design Spec §3.1)

let brandBlue1 = rgb(37, 112, 255)     // Primary Brand: #2570FF
let brandBlue2 = rgb(64, 150, 255)     // #4096FF
let brandBlueDeep = rgb(15, 58, 160)   // Dark shadow
let voiceGreen1 = rgb(0, 196, 140)     // Active Green: #00C48C
let voiceGreen2 = rgb(54, 211, 170)    // #36D3AA
let dangerRed = rgb(245, 63, 63)       // #F53F3F

// MARK: - Drawing Helpers

func drawBrandGradient(ctx: CGContext, size: CGSize) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [brandBlue1, brandBlue2] as CFArray
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) else { return }
    ctx.drawLinearGradient(gradient,
                           start: CGPoint(x: 0, y: 0),
                           end: CGPoint(x: size.width, y: size.height),
                           options: [])
}

func drawCircularBrandGradient(ctx: CGContext, center: CGPoint, radius: CGFloat) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [brandBlue1, brandBlue2] as CFArray
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) else { return }
    ctx.drawRadialGradient(gradient,
                           startCenter: center, startRadius: 0,
                           endCenter: center, endRadius: radius,
                           options: [])
}

// MARK: - Voice Waveform Rings (pulsing voice indicator)

func drawVoiceRings(ctx: CGContext, center: CGPoint, baseRadius: CGFloat, scale: CGFloat) {
    for (i, alpha) in [0.35, 0.22, 0.12].enumerated() {
        let r = baseRadius + (20 + CGFloat(i) * 30) * scale
        ctx.setStrokeColor(rgb(255, 255, 255, alpha))
        ctx.setLineWidth(6 * scale)
        ctx.setLineCap(.round)
        ctx.addArc(center: center, radius: r,
                   startAngle: deg(180), endAngle: deg(360), clockwise: false)
        ctx.strokePath()
    }
}

// MARK: - Central Microphone Icon (game voice chat core)

func drawGameMic(ctx: CGContext, center: CGPoint, scale: CGFloat) {
    let micW = 140 * scale
    let micH = 210 * scale
    let micX = center.x - micW / 2
    let micY = center.y - micH / 2 - 10 * scale
    let micR = 70 * scale

    // Outer soft glow
    ctx.setFillColor(rgb(0, 196, 140, 0.15))
    let glowRect = CGRect(x: micX - 20 * scale, y: micY - 20 * scale,
                          width: micW + 40 * scale, height: micH + 40 * scale)
    ctx.addPath(CGPath(roundedRect: glowRect, cornerWidth: micR + 10 * scale,
                       cornerHeight: micR + 10 * scale, transform: nil))
    ctx.fillPath()

    // Mic body shadow
    ctx.setFillColor(rgb(0, 40, 100, 0.2))
    let shRect = CGRect(x: micX + 5 * scale, y: micY + 8 * scale, width: micW, height: micH)
    ctx.addPath(CGPath(roundedRect: shRect, cornerWidth: micR, cornerHeight: micR, transform: nil))
    ctx.fillPath()

    // Mic body (white with subtle gradient feel - solid white clean look)
    ctx.setFillColor(rgb(255, 255, 255))
    let bodyRect = CGRect(x: micX, y: micY, width: micW, height: micH)
    ctx.addPath(CGPath(roundedRect: bodyRect, cornerWidth: micR, cornerHeight: micR, transform: nil))
    ctx.fillPath()

    // Mic top grille (dark blue tech accent - represents voice pickup area)
    ctx.setFillColor(rgb(37, 112, 255))
    let grilleH = 100 * scale
    let grilleRect = CGRect(x: micX + 20 * scale, y: micY + 20 * scale,
                            width: micW - 40 * scale, height: grilleH)
    ctx.addPath(CGPath(roundedRect: grilleRect, cornerWidth: 25 * scale,
                       cornerHeight: 25 * scale, transform: nil))
    ctx.fillPath()

    // Grille dot pattern (tech style sound pickup holes)
    ctx.setFillColor(rgb(255, 255, 255, 0.9))
    let dotR = 4 * scale
    let cols = 3
    let rows = 3
    for r in 0..<rows {
        for c in 0..<cols {
            let dotX = micX + 32 * scale + CGFloat(c) * 30 * scale
            let dotY = micY + 32 * scale + CGFloat(r) * 22 * scale
            ctx.addEllipse(in: CGRect(x: dotX - dotR, y: dotY - dotR,
                                      width: dotR * 2, height: dotR * 2))
            ctx.fillPath()
        }
    }

    // Mic bottom stem connector
    ctx.setFillColor(rgb(37, 112, 255))
    let stemW = 60 * scale
    let stemH = 18 * scale
    let stemX = center.x - stemW / 2
    let stemY = micY + micH - 8 * scale
    ctx.addPath(CGPath(roundedRect: CGRect(x: stemX, y: stemY, width: stemW, height: stemH),
                       cornerWidth: stemH/2, cornerHeight: stemH/2, transform: nil))
    ctx.fillPath()

    // Mic stand vertical bar
    ctx.setStrokeColor(rgb(255, 255, 255))
    ctx.setLineWidth(10 * scale)
    ctx.setLineCap(.round)
    let standTopY = stemY + stemH + 5 * scale
    let standBottomY = standTopY + 35 * scale
    ctx.move(to: CGPoint(x: center.x, y: standTopY))
    ctx.addLine(to: CGPoint(x: center.x, y: standBottomY))
    ctx.strokePath()

    // Mic stand base (horizontal bar)
    let baseW = 160 * scale
    let baseH = 14 * scale
    ctx.setFillColor(rgb(255, 255, 255))
    ctx.addPath(CGPath(roundedRect: CGRect(x: center.x - baseW/2, y: standBottomY - baseH/2,
                                           width: baseW, height: baseH),
                       cornerWidth: baseH/2, cornerHeight: baseH/2, transform: nil))
    ctx.fillPath()

    // Voice active green indicator dot on mic (center of grille)
    ctx.setFillColor(voiceGreen1)
    let greenDotR = 8 * scale
    ctx.addEllipse(in: CGRect(x: center.x - greenDotR, y: micY + grilleH/2 + 10 * scale - greenDotR,
                              width: greenDotR * 2, height: greenDotR * 2))
    ctx.fillPath()

    // Green dot outer ring (pulse)
    ctx.setStrokeColor(rgb(0, 196, 140, 0.4))
    ctx.setLineWidth(3 * scale)
    ctx.addEllipse(in: CGRect(x: center.x - greenDotR * 1.8, y: micY + grilleH/2 + 10 * scale - greenDotR * 1.8,
                              width: greenDotR * 3.6, height: greenDotR * 3.6))
    ctx.strokePath()
}

// MARK: - Teammate Avatar Circles (team / online players concept)

func drawTeammateAvatars(ctx: CGContext, center: CGPoint, scale: CGFloat) {
    let avatarR = 60 * scale
    let orbitR = 230 * scale

    // Positions: three teammates around the mic at 11 o'clock, 1 o'clock, 6 o'clock
    let positions: [(CGFloat, CGFloat)] = [
        (deg(155), 1.0),   // top-left teammate
        (deg(205), 0.85),  // left teammate (slightly behind)
        (deg(25), 1.0),    // top-right teammate
        (deg(-35), 0.85),  // right teammate (slightly behind)
        (deg(90), 0.9),    // bottom-center teammate
    ]

    for (i, (angle, sizeScale)) in positions.enumerated() {
        let ax = center.x + cos(angle) * orbitR
        let ay = center.y + sin(angle) * orbitR
        let r = avatarR * sizeScale

        // Shadow
        ctx.setFillColor(rgb(0, 40, 100, 0.2))
        ctx.addEllipse(in: CGRect(x: ax - r + 4 * scale, y: ay - r + 6 * scale,
                                  width: r * 2, height: r * 2))
        ctx.fillPath()

        // Avatar circle (white background like profile pic)
        ctx.setFillColor(rgb(255, 255, 255))
        ctx.addEllipse(in: CGRect(x: ax - r, y: ay - r, width: r * 2, height: r * 2))
        ctx.fillPath()

        // Inner blue border ring (tech style)
        ctx.setStrokeColor(rgb(37, 112, 255, 0.35))
        ctx.setLineWidth(4 * scale)
        ctx.addEllipse(in: CGRect(x: ax - r + 6 * scale, y: ay - r + 6 * scale,
                                  width: r * 2 - 12 * scale, height: r * 2 - 12 * scale))
        ctx.strokePath()

        // Simple stylized person silhouette inside (minimalist head + shoulders)
        ctx.setFillColor(rgb(37, 112, 255))
        // Head
        let headR = r * 0.32
        ctx.addEllipse(in: CGRect(x: ax - headR, y: ay - r * 0.55,
                                  width: headR * 2, height: headR * 2))
        ctx.fillPath()
        // Shoulders / body (semi-circle)
        let bodyW = r * 1.1
        let bodyH = r * 0.7
        let bodyY = ay - r * 0.15
        ctx.saveGState()
        ctx.beginPath()
        ctx.addArc(center: CGPoint(x: ax, y: bodyY + bodyH),
                   radius: bodyW / 2, startAngle: deg(180), endAngle: deg(0), clockwise: false)
        ctx.closePath()
        ctx.fillPath()
        ctx.restoreGState()

        // Online green dot indicator (bottom-right of each avatar)
        let dotR = 9 * scale
        let dotX = ax + r * 0.65
        let dotY = ay + r * 0.65

        // Dot shadow
        ctx.setFillColor(rgb(255, 255, 255))
        ctx.addEllipse(in: CGRect(x: dotX - dotR - 2 * scale, y: dotY - dotR - 2 * scale,
                                  width: dotR * 2 + 4 * scale, height: dotR * 2 + 4 * scale))
        ctx.fillPath()

        ctx.setFillColor(voiceGreen1)
        ctx.addEllipse(in: CGRect(x: dotX - dotR, y: dotY - dotR,
                                  width: dotR * 2, height: dotR * 2))
        ctx.fillPath()

        // Alternate: some teammates with brand blue dot (waiting/invited state) to add visual variety
        if i == 2 || i == 3 {
            // override with blue to show mixed state
            ctx.setFillColor(rgb(64, 150, 255))
            ctx.addEllipse(in: CGRect(x: dotX - dotR, y: dotY - dotR,
                                      width: dotR * 2, height: dotR * 2))
            ctx.fillPath()
        }
    }
}

// MARK: - Decorative Tech Grid Lines (sci-fi atmosphere)

func drawTechBackground(ctx: CGContext, center: CGPoint, scale: CGFloat, size: CGSize) {
    // Radial subtle rings
    for i in 1...4 {
        let r = (120 + CGFloat(i) * 80) * scale
        ctx.setStrokeColor(rgb(255, 255, 255, 0.04))
        ctx.setLineWidth(1.5 * scale)
        ctx.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        ctx.strokePath()
    }

    // Horizontal tech accent line near top
    ctx.setStrokeColor(rgb(255, 255, 255, 0.08))
    ctx.setLineWidth(2 * scale)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: center.x - 180 * scale, y: 80 * scale))
    ctx.addLine(to: CGPoint(x: center.x - 80 * scale, y: 80 * scale))
    ctx.strokePath()
    ctx.move(to: CGPoint(x: center.x + 80 * scale, y: 80 * scale))
    ctx.addLine(to: CGPoint(x: center.x + 180 * scale, y: 80 * scale))
    ctx.strokePath()

    // Small corner dots (4 corners, tech HUD style)
    let cornerDots: [(CGFloat, CGFloat)] = [
        (80, 80), (size.width - 80, 80),
        (80, size.height - 80), (size.width - 80, size.height - 80)
    ]
    for (cx, cy) in cornerDots {
        ctx.setFillColor(rgb(255, 255, 255, 0.18))
        ctx.addEllipse(in: CGRect(x: cx - 4 * scale, y: cy - 4 * scale,
                                  width: 8 * scale, height: 8 * scale))
        ctx.fillPath()
    }
}

// MARK: - App Title Text

func drawAppText(ctx: CGContext, center: CGPoint, scale: CGFloat, size: CGSize) {
    let fontSize = 44 * scale
    let font = CTFontCreateWithName("Helvetica Neue Bold" as CFString, fontSize, nil)
    let attrs: [CFString: Any] = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: rgb(255, 255, 255, 0.95)
    ]
    let text = "PlayVoice" as CFString
    let attrString = CFAttributedStringCreate(nil, text, attrs as CFDictionary)!
    let line = CTLineCreateWithAttributedString(attrString)
    let lineBounds = CTLineGetBoundsWithOptions(line, [])
    let textX = center.x - lineBounds.width / 2
    let textY = size.height - 120 * scale
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: textX, y: textY)
    CTLineDraw(line, ctx)
    ctx.restoreGState()

    // Subtitle: "TEAM VOICE"
    let subSize = 18 * scale
    let subFont = CTFontCreateWithName("Helvetica Neue Bold" as CFString, subSize, nil)
    let subAttrs: [CFString: Any] = [
        kCTFontAttributeName: subFont,
        kCTForegroundColorAttributeName: rgb(0, 196, 140, 0.9)
    ]
    let subText = "TEAM VOICE CHAT" as CFString
    let subAttrString = CFAttributedStringCreate(nil, subText, subAttrs as CFDictionary)!
    let subLine = CTLineCreateWithAttributedString(subAttrString)
    let subBounds = CTLineGetBoundsWithOptions(subLine, [])
    let subX = center.x - subBounds.width / 2
    let subY = size.height - 75 * scale
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: subX, y: subY)
    CTLineDraw(subLine, ctx)
    ctx.restoreGState()
}

// MARK: - 1024x1024 App Store Icon

func generateAppIcon() {
    let size = 1024
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                              bytesPerRow: 0, space: colorSpace,
                              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
        print("Failed to create context")
        return
    }

    let cgSize = CGSize(width: size, height: size)
    let center = CGPoint(x: size/2, y: size/2 - 50)
    let scale = CGFloat(size) / 1024.0

    drawBrandGradient(ctx: ctx, size: cgSize)
    drawTechBackground(ctx: ctx, center: center, scale: scale, size: cgSize)
    drawVoiceRings(ctx: ctx, center: center, baseRadius: 130 * scale, scale: scale)
    drawTeammateAvatars(ctx: ctx, center: center, scale: scale)
    drawGameMic(ctx: ctx, center: center, scale: scale)

    guard let image = ctx.makeImage() else { return }
    let url = URL(fileURLWithPath: "/Users/yangpengliang/project/PlayVoice/ios/GoogleSignInDemo/Assets.xcassets/AppIcon.appiconset/1024.png")
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else { return }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
    print("App icon saved: \(url.path)")
}

// MARK: - 512x512 Circular Launch Icon

func generateLaunchIcon() {
    let size = 512
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                              bytesPerRow: 0, space: colorSpace,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        print("Failed to create context")
        return
    }

    let cgSize = CGSize(width: size, height: size)
    let center = CGPoint(x: size/2, y: size/2 - 25)
    let scale = CGFloat(size) / 1024.0

    // Clear to transparent
    ctx.clear(CGRect(origin: .zero, size: cgSize))

    // Clip to circle
    let circleRadius = CGFloat(size) / 2
    ctx.addEllipse(in: CGRect(x: CGFloat(size)/2 - circleRadius, y: CGFloat(size)/2 - circleRadius,
                               width: circleRadius * 2, height: circleRadius * 2))
    ctx.clip()

    // Background gradient
    drawBrandGradient(ctx: ctx, size: cgSize)

    // Tech rings
    for i in 1...3 {
        let r = (60 + CGFloat(i) * 50) * scale
        ctx.setStrokeColor(rgb(255, 255, 255, 0.05))
        ctx.setLineWidth(1.5 * scale)
        ctx.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        ctx.strokePath()
    }

    // Voice rings
    drawVoiceRings(ctx: ctx, center: center, baseRadius: 70 * scale, scale: scale)

    // Small teammate avatars (2, for compact look)
    let avatarR = 32 * scale
    let orbitR = 115 * scale
    for (_, angleDeg) in [150, 30].enumerated() {
        let angle = deg(CGFloat(angleDeg))
        let ax = center.x + cos(angle) * orbitR
        let ay = center.y + sin(angle) * orbitR
        let r = avatarR

        ctx.setFillColor(rgb(255, 255, 255))
        ctx.addEllipse(in: CGRect(x: ax - r, y: ay - r, width: r * 2, height: r * 2))
        ctx.fillPath()

        ctx.setFillColor(rgb(37, 112, 255))
        let headR = r * 0.32
        ctx.addEllipse(in: CGRect(x: ax - headR, y: ay - r * 0.55,
                                  width: headR * 2, height: headR * 2))
        ctx.fillPath()

        // green online dot
        let dotR = 5 * scale
        ctx.setFillColor(voiceGreen1)
        ctx.addEllipse(in: CGRect(x: ax + r * 0.55 - dotR, y: ay + r * 0.55 - dotR,
                                  width: dotR * 2, height: dotR * 2))
        ctx.fillPath()
    }

    // Central mic (smaller)
    drawGameMic(ctx: ctx, center: center, scale: scale * 0.52)

    guard let image = ctx.makeImage() else { return }
    let url = URL(fileURLWithPath: "/Users/yangpengliang/project/PlayVoice/ios/GoogleSignInDemo/Assets.xcassets/LaunchIcon.imageset/LaunchIcon.png")
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else { return }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
    print("Launch icon saved: \(url.path)")
}

// MARK: - Main

generateAppIcon()
generateLaunchIcon()
print("Done!")
