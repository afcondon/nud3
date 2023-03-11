module Nud3.Attributes where

import Prelude

type AttributeSetter d t = d -> Int -> t

data Attribute d = 
    Remove
  | Background_ String
  | Background (AttributeSetter d String)
  | Color_ String
  | Color (AttributeSetter d String)
  | Classed_ String
  | Classed (AttributeSetter d String)
  | CX_ Number
  | CX (AttributeSetter d Number)
  | CY_ Number
  | CY (AttributeSetter d Number)
  | DX_ Number
  | DX (AttributeSetter d Number)
  | DY_ Number
  | DY (AttributeSetter d Number)
  | Fill_ String
  | Fill (AttributeSetter d String)
  | FontFamily_ String
  | FontFamily (AttributeSetter d String)
  | FontSize_ Number
  | FontSize (AttributeSetter d Number)
  | Height_ Number
  | Height (AttributeSetter d Number)
  | Radius_ Number
  | Radius (AttributeSetter d Number)
  | StrokeColor_ String
  | StrokeColor (AttributeSetter d String)
  | StrokeOpacity_ Number
  | StrokeOpacity (AttributeSetter d Number)
  | StrokeWidth_ Number
  | StrokeWidth (AttributeSetter d Number)
  | Style_ String
  | Style (AttributeSetter d String)
  | Text_ String
  | Text (AttributeSetter d String)
  | TextAnchor_ String
  | TextAnchor (AttributeSetter d String)
  | TransitionTo (Array (TransitionAttribute d))
  | Width_ Number
  | Width (AttributeSetter d Number)
  | ViewBox_ Number Number Number Number
  | X_ Number
  | X (AttributeSetter d Number)
  | Y_ Number
  | Y (AttributeSetter d Number)
  | X1_ Number
  | X1 (AttributeSetter d Number)
  | X2_ Number
  | X2 (AttributeSetter d Number)
  | Y1_ Number
  | Y1 (AttributeSetter d Number)
  | Y2_ Number
  | Y2 (AttributeSetter d Number)

instance showAttribute :: Show (Attribute d) where
  show (Remove) = "\n\t\tRemove"
  show (Background_ v) = "\n\t\tBackground_" <> " set directly to " <> v
  show (Color_ v) = "\n\t\tColor_" <> " set directly to " <> v
  show (Classed_ v) = "\n\t\tClassed_" <> " set directly to " <> v
  show (CX_ v) = "\n\t\tCX_" <> " set directly to " <> show v
  show (CY_ v) = "\n\t\tCY_" <> " set directly to " <> show v
  show (DX_ v) = "\n\t\tDX_" <> " set directly to " <> show v
  show (DY_ v) = "\n\t\tDY_" <> " set directly to " <> show v
  show (Fill_ v) = "\n\t\tFill_" <> " set directly to " <> v
  show (FontFamily_ v) = "\n\t\tFontFamily_" <> " set directly to " <> v
  show (FontSize_ v) = "\n\t\tFontSize_" <> " set directly to " <> show v
  show (Height_ v) = "\n\t\tHeight_" <> " set directly to " <> show v
  show (Radius_ v) = "\n\t\tRadius_" <> " set directly to " <> show v
  show (StrokeColor_ v) = "\n\t\tStrokeColor_" <> " set directly to " <> v
  show (StrokeOpacity_ v) = "\n\t\tStrokeOpacity_" <> " set directly to " <> show v
  show (StrokeWidth_ v) = "\n\t\tStrokeWidth_" <> " set directly to " <> show v
  show (Style_ v) = "\n\t\tStyle_" <> " set directly to " <> v
  show (Text_ v) = "\n\t\tText_" <> " set directly to " <> v
  show (TextAnchor_ v) = "\n\t\tTextAnchor_" <> " set directly to " <> v
  show (TransitionTo vs) = "\n\t\tTransitionTo" <> " set directly to " <> show vs
  show (Width_ v) = "\n\t\tWidth_" <> " set directly to " <> show v
  show (ViewBox_ x y w h) = "\n\t\tViewBox_" <> " set directly to " <> show x <> " " <> show y <> " " <> show w <> " " <> show h
  show (X_ v) = "\n\t\tX_" <> " set directly to " <> show v
  show (Y_ v) = "\n\t\tY_" <> " set directly to " <> show v
  show (X1_ v) = "\n\t\tX1_" <> " set directly to " <> show v
  show (X2_ v) = "\n\t\tX2_" <> " set directly to " <> show v
  show (Y1_ v) = "\n\t\tY1_" <> " set directly to " <> show v
  show (Y2_ v) = "\n\t\tY2_" <> " set directly to " <> show v
  show (Background f) = "\n\t\tBackground set by function"
  show (Color f) = "\n\t\tColor set by function"
  show (Classed f) = "\n\t\tClassed set by function"
  show (CX f) = "\n\t\tCX set by function"
  show (CY f) = "\n\t\tCY set by function"
  show (DX f) = "\n\t\tDX set by function"
  show (DY f) = "\n\t\tDY set by function"
  show (Fill f) = "\n\t\tFill set by function"
  show (FontFamily f) = "\n\t\tFontFamily set by function"
  show (FontSize f) = "\n\t\tFontSize set by function"
  show (Height f) = "\n\t\tHeight set by function"
  show (Radius f) = "\n\t\tRadius set by function"
  show (StrokeColor f) = "\n\t\tStrokeColor set by function"
  show (StrokeOpacity f) = "\n\t\tStrokeOpacity set by function"
  show (StrokeWidth f) = "\n\t\tStrokeWidth set by function"
  show (Style f) = "\n\t\tStyle set by function"
  show (Text f) = "\n\t\tText set by function"
  show (TextAnchor f) = "\n\t\tTextAnchor set by function"
  show (Width f) = "\n\t\tWidth set by function"
  show (X f) = "\n\t\tX set by function"
  show (Y f) = "\n\t\tY set by function"
  show (X1 f) = "\n\t\tX1 set by function"
  show (X2 f) = "\n\t\tX2 set by function"
  show (Y1 f) = "\n\t\tY1 set by function"
  show (Y2 f) = "\n\t\tY2 set by function"


data TransitionAttribute d = -- TODO - add more transition attributes
    TransitionDuration_ Number
  | TransitionDuration (AttributeSetter d Number)
  | TransitionDelay_ Number
  | TransitionDelay (AttributeSetter d Number)
  | Attr (Attribute d)
  
instance showTransitionAttribute :: Show (TransitionAttribute d) where
  show (TransitionDuration_ v) = "TransitionDuration_" <> " set directly to " <> show v
  show (TransitionDelay_ v) = "TransitionDelay_" <> " set directly to " <> show v
  show (Attr a) = "Attr" <> " set directly to " <> show a
  show (TransitionDuration f) = "TransitionDuration set by function"
  show (TransitionDelay f) = "TransitionDelay set by function"
