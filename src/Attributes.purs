module Nud3.Attributes where

type AttributeSetter t = forall d. d -> Int -> t

data Attribute = 
    Remove
  | Background_ String
  | Background (AttributeSetter String)
  | Color_ String
  | Color (AttributeSetter String)
  | Classed_ String
  | Classed (AttributeSetter String)
  | CX_ Number
  | CX (AttributeSetter Number)
  | CY_ Number
  | CY (AttributeSetter Number)
  | DX_ Number
  | DX (AttributeSetter Number)
  | DY_ Number
  | DY (AttributeSetter Number)
  | Fill_ String
  | Fill (AttributeSetter String)
  | FontFamily_ String
  | FontFamily (AttributeSetter String)
  | FontSize_ Number
  | FontSize (AttributeSetter Number)
  | Height_ Number
  | Height (AttributeSetter Number)
  | Radius_ Number
  | Radius (AttributeSetter Number)
  | StrokeColor_ String
  | StrokeColor (AttributeSetter String)
  | StrokeOpacity_ Number
  | StrokeOpacity (AttributeSetter Number)
  | StrokeWidth_ Number
  | StrokeWidth (AttributeSetter Number)
  | Style_ String
  | Style (AttributeSetter String)
  | Text_ String
  | Text (AttributeSetter String)
  | TextAnchor String
  | TextAncho (AttributeSetter String)
  | TransitionTo (Array TransitionAttribute)
  | Width_ Number
  | Width (AttributeSetter Number)
  | ViewBox_ Number Number Number Number
  | X_ Number
  | X (AttributeSetter Number)
  | Y_ Number
  | Y (AttributeSetter Number)
  | X1_ Number
  | X1 (AttributeSetter Number)
  | X2_ Number
  | X2 (AttributeSetter Number)
  | Y1_ Number
  | Y1 (AttributeSetter Number)
  | Y2_ Number
  | Y2 (AttributeSetter Number)

data TransitionAttribute = -- TODO - add more transition attributes
    TransitionDuration_ Number
  | TransitionDuration (AttributeSetter Number)
  | TransitionDelay_ Number
  | TransitionDelay (AttributeSetter Number)
  | Attr Attribute
  