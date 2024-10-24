import Foundation

protocol UISizes {
    static var nano   : Double { get set }
    static var micro  : Double { get set }
    static var mini   : Double { get set }
    static var normal : Double { get set }
    static var large  : Double { get set }
    static var huge   : Double { get set }
}

protocol UIMiniSizes {
    static var little : Double { get set }
}

protocol UIGiantSizes {
    static var giant        : Double { get set }
    static var colossal     : Double { get set }
    static var titanic      : Double { get set }
    static var monumental   : Double { get set }
    static var astronomical : Double { get set }
}

public struct UIViewConstants {
    
    public struct FontSizes : UISizes, UIGiantSizes {
        /** Represents 16px on screen */
        public static var nano         : Double = 16
        /** Represents 24px on screen */
        public static var micro        : Double = 24
        /** Represents 36px on screen */
        public static var mini         : Double = 36
        /** Represents 48px on screen */
        public static var normal       : Double = 48
        /** Represents 56px on screen */
        public static var large        : Double = 56
        /** Represents 64px on screen */
        public static var huge         : Double = 64
        /** Represents 72px on screen */
        public static var giant        : Double = 72
        /** Represents 81px on screen */
        public static var colossal     : Double = 81
        /** Represents 90px on screen */
        public static var titanic      : Double = 90
        /** Represents 106px on screen */
        public static var monumental   : Double = 106
        /** Represents 128px on screen */
        public static var astronomical : Double = 128
    }
    
    public struct SidebarSizes : UISizes {
        /** Represents 160px on screen */
        public static var nano   : Double = 160
        /** Represents 192px on screen */
        public static var micro  : Double = 192
        /** Represents 224px on screen */
        public static var mini   : Double = 224
        /** Represents 256px on screen */
        public static var normal : Double = 256
        /** Represents 320px on screen */
        public static var large  : Double = 320
        /** Represents 384px on screen */
        public static var huge   : Double = 384
    }
    
    public struct SquareSizes : UISizes {
        /** Represents 16px on screen */
        public static var nano   : Double = 16
        /** Represents 32px on screen */
        public static var micro  : Double = 32
        /** Represents 64px on screen */
        public static var mini   : Double = 64
        /** Represents 96px on screen */
        public static var normal : Double = 96
        /** Represents 128px on screen */
        public static var large  : Double = 128
        /** Represents 156px on screen */
        public static var huge   : Double = 156
        /** Represents 256px on screen */
        public static var giant  : Double = 256
    }
    
    public struct CornerRadiuses : UISizes {
        /** Represents 2px on screen */
        public static var nano   : Double = 2
        /** Represents 4px on screen */
        public static var micro  : Double = 4
        /** Represents 6px on screen */
        public static var mini   : Double = 6
        /** Represents 8px on screen */
        public static var normal : Double = 8
        /** Represents 12px on screen */
        public static var large  : Double = 12
        /** Represents 24px on screen */
        public static var huge   : Double = 24
    }
    
    public struct Spacings : UISizes {
        /** Represents 1px on screen */
        public static var nano   : Double = 1
        /** Represents 2px on screen */
        public static var micro  : Double = 2
        /** Represents 4px on screen */
        public static var mini   : Double = 4
        /** Represents 8px on screen */
        public static var normal : Double = 8
        /** Represents 16px on screen */
        public static var large  : Double = 16
        /** Represents 32px on screen */
        public static var huge   : Double = 32
    }
    
    public struct Paddings : UISizes {
        /** Represents 2px on screen */
        public static var nano   : Double = 2
        /** Represents 4px on screen */
        public static var micro  : Double = 4
        /** Represents 6px on screen */
        public static var mini   : Double = 6
        /** Represents 8px on screen */
        public static var normal : Double = 8
        /** Represents 12px on screen */
        public static var large  : Double = 12
        /** Represents 24px on screen */
        public static var huge   : Double = 24
    }
    
}
