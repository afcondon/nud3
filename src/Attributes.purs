module Nud3.Attributes where

import Prelude

import Unsafe.Coerce (unsafeCoerce)

foreign import data AttributeSetter_ :: Type 

exportAttributeSetter_ :: forall d. d -> AttributeSetter_
exportAttributeSetter_ = unsafeCoerce -- probably the only efficient way to do this, at least the unsafeCoerce is in one place and on one type

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

getValueFromAttribute :: forall d v. Attribute d -> AttributeSetter_
getValueFromAttribute = case _ of 
  Remove -> exportAttributeSetter_ unit -- TODO this one is a special case
  Background_ v -> exportAttributeSetter_ v
  Background f -> exportAttributeSetter_ f
  Color_ v -> exportAttributeSetter_ v
  Color f -> exportAttributeSetter_ f
  Classed_ v -> exportAttributeSetter_ v
  Classed f -> exportAttributeSetter_ f
  CX_ v -> exportAttributeSetter_ v
  CX f -> exportAttributeSetter_ f
  CY_ v -> exportAttributeSetter_ v
  CY f -> exportAttributeSetter_ f
  DX_ v -> exportAttributeSetter_ v
  DX f -> exportAttributeSetter_ f
  DY_ v -> exportAttributeSetter_ v
  DY f -> exportAttributeSetter_ f
  Fill_ v -> exportAttributeSetter_ v
  Fill f -> exportAttributeSetter_ f
  FontFamily_ v -> exportAttributeSetter_ v
  FontFamily f -> exportAttributeSetter_ f
  FontSize_ v -> exportAttributeSetter_ v
  FontSize f -> exportAttributeSetter_ f
  Height_ v -> exportAttributeSetter_ v
  Height f -> exportAttributeSetter_ f
  Radius_ v -> exportAttributeSetter_ v
  Radius f -> exportAttributeSetter_ f
  StrokeColor_ v -> exportAttributeSetter_ v
  StrokeColor f -> exportAttributeSetter_ f
  StrokeOpacity_ v -> exportAttributeSetter_ v
  StrokeOpacity f -> exportAttributeSetter_ f
  StrokeWidth_ v -> exportAttributeSetter_ v
  StrokeWidth f -> exportAttributeSetter_ f
  Style_ v -> exportAttributeSetter_ v
  Style f -> exportAttributeSetter_ f
  Text_ v -> exportAttributeSetter_ v
  Text f -> exportAttributeSetter_ f
  TextAnchor_ v -> exportAttributeSetter_ v
  TextAnchor f -> exportAttributeSetter_ f
  TransitionTo vs -> exportAttributeSetter_ vs
  Width_ v -> exportAttributeSetter_ v
  Width f -> exportAttributeSetter_ f
  ViewBox_ x y w h -> exportAttributeSetter_ [x, y, w, h] -- TODO this one is a special case, impressive that CoPilot guessed it
  X_ v -> exportAttributeSetter_ v
  X f -> exportAttributeSetter_ f
  Y_ v -> exportAttributeSetter_ v
  Y f -> exportAttributeSetter_ f
  X1_ v -> exportAttributeSetter_ v
  X1 f -> exportAttributeSetter_ f
  X2_ v -> exportAttributeSetter_ v
  X2 f -> exportAttributeSetter_ f
  Y1_ v -> exportAttributeSetter_ v
  Y1 f -> exportAttributeSetter_ f
  Y2_ v -> exportAttributeSetter_ v
  Y2 f -> exportAttributeSetter_ f

getKeyFromAttribute :: forall d. Attribute d -> String
getKeyFromAttribute = case _ of 
  Remove -> "remove" -- TODO this one is a special case
  Background_ _ -> "background"
  Background _ -> "background"
  Color_ _ -> "color"
  Color _ -> "color"
  Classed_ _ -> "classed"
  Classed _ -> "classed"
  CX_ _ -> "cx"
  CX _ -> "cx"
  CY_ _ -> "cy"
  CY _ -> "cy"
  DX_ _ -> "dx"
  DX _ -> "dx"
  DY_ _ -> "dy"
  DY _ -> "dy"
  Fill_ _ -> "fill"
  Fill _ -> "fill"
  FontFamily_ _ -> "font-family"
  FontFamily _ -> "font-family"
  FontSize_ _ -> "font-size"
  FontSize _ -> "font-size"
  Height_ _ -> "height"
  Height _ -> "height"
  Radius_ _ -> "radius"
  Radius _ -> "radius"
  StrokeColor_ _ -> "stroke"
  StrokeColor _ -> "stroke"
  StrokeOpacity_ _ -> "stroke-opacity"
  StrokeOpacity _ -> "stroke-opacity"
  StrokeWidth_ _ -> "stroke-width"
  StrokeWidth _ -> "stroke-width"
  Style_ _ -> "style"
  Style _ -> "style"
  Text_ _ -> "text"
  Text _ -> "text"
  TextAnchor_ _ -> "text-anchor"
  TextAnchor _ -> "text-anchor"
  TransitionTo _ -> "transition"
  Width_ _ -> "width"
  Width _ -> "width"
  ViewBox_ _ _ _ _ -> "viewBox"
  X_ _ -> "x"
  X _ -> "x"
  Y_ _ -> "y"
  Y _ -> "y"
  X1_ _ -> "x1"
  X1 _ -> "x1"
  X2_ _ -> "x2"
  X2 _ -> "x2"
  Y1_ _ -> "y1"
  Y1 _ -> "y1"
  Y2_ _ -> "y2"
  Y2 _ -> "y2"

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
