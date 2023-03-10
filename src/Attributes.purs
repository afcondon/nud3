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
  show (Remove) = "Remove"
  show (Background_ v) = "Background_" <> " set directly to " <> v
  show (Color_ v) = "Color_" <> " set directly to " <> v
  show (Classed_ v) = "Classed_" <> " set directly to " <> v
  show (CX_ v) = "CX_" <> " set directly to " <> show v
  show (CY_ v) = "CY_" <> " set directly to " <> show v
  show (DX_ v) = "DX_" <> " set directly to " <> show v
  show (DY_ v) = "DY_" <> " set directly to " <> show v
  show (Fill_ v) = "Fill_" <> " set directly to " <> v
  show (FontFamily_ v) = "FontFamily_" <> " set directly to " <> v
  show (FontSize_ v) = "FontSize_" <> " set directly to " <> show v
  show (Height_ v) = "Height_" <> " set directly to " <> show v
  show (Radius_ v) = "Radius_" <> " set directly to " <> show v
  show (StrokeColor_ v) = "StrokeColor_" <> " set directly to " <> v
  show (StrokeOpacity_ v) = "StrokeOpacity_" <> " set directly to " <> show v
  show (StrokeWidth_ v) = "StrokeWidth_" <> " set directly to " <> show v
  show (Style_ v) = "Style_" <> " set directly to " <> v
  show (Text_ v) = "Text_" <> " set directly to " <> v
  show (TextAnchor_ v) = "TextAnchor_" <> " set directly to " <> v
  show (TransitionTo vs) = "TransitionTo" <> " set directly to " <> show vs
  show (Width_ v) = "Width_" <> " set directly to " <> show v
  show (ViewBox_ x y w h) = "ViewBox_" <> " set directly to " <> show x <> " " <> show y <> " " <> show w <> " " <> show h
  show (X_ v) = "X_" <> " set directly to " <> show v
  show (Y_ v) = "Y_" <> " set directly to " <> show v
  show (X1_ v) = "X1_" <> " set directly to " <> show v
  show (X2_ v) = "X2_" <> " set directly to " <> show v
  show (Y1_ v) = "Y1_" <> " set directly to " <> show v
  show (Y2_ v) = "Y2_" <> " set directly to " <> show v
  show (Background f) = "Background set by function"
  show (Color f) = "Color set by function"
  show (Classed f) = "Classed set by function"
  show (CX f) = "CX set by function"
  show (CY f) = "CY set by function"
  show (DX f) = "DX set by function"
  show (DY f) = "DY set by function"
  show (Fill f) = "Fill set by function"
  show (FontFamily f) = "FontFamily set by function"
  show (FontSize f) = "FontSize set by function"
  show (Height f) = "Height set by function"
  show (Radius f) = "Radius set by function"
  show (StrokeColor f) = "StrokeColor set by function"
  show (StrokeOpacity f) = "StrokeOpacity set by function"
  show (StrokeWidth f) = "StrokeWidth set by function"
  show (Style f) = "Style set by function"
  show (Text f) = "Text set by function"
  show (TextAnchor f) = "TextAnchor set by function"
  show (Width f) = "Width set by function"
  show (X f) = "X set by function"
  show (Y f) = "Y set by function"
  show (X1 f) = "X1 set by function"
  show (X2 f) = "X2 set by function"
  show (Y1 f) = "Y1 set by function"
  show (Y2 f) = "Y2 set by function"


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
  