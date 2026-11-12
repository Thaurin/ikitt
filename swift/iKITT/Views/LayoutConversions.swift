import CoreGraphics

extension LayoutRect {
    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }

    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
}

extension LayoutPoint {
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

extension LayoutSize {
    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
}
