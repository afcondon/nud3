module Nud3.Attributes where

import Prelude

import Nud3.Types (Selection_)
import Unsafe.Coerce (unsafeCoerce)

-- | the foreign AttributeSetter_ is not really typeable in PureScript while still being efficient
-- | certainly could be an option to remove all this and do something complicated with Variants or 
-- | Options or heterogeneous lists or whatever
foreign import data AttributeSetter_ :: Type 
foreign import addAttribute_ :: forall d. Selection_ -> String -> d -> Unit
foreign import addTransition_ :: forall d. Selection_ -> Number -> Number -> Selection_

exportAttributeSetter_ :: forall d. d -> AttributeSetter_
exportAttributeSetter_ = unsafeCoerce 

type AttributeSetter d t = d -> Int -> t

-- | we special case on some attributes - Text, InnerHTML, ViewBox, TransitionTo and Transition attributes
addAttribute :: forall d. Selection_ -> Attribute d -> Unit
-- | transition attributes are handled by creating a transition selection,
-- | then applying the transition attributes and regular attributes to this transition selection
addAttribute s (NamedTransition name config attrs)) = -- TODO
addAttribute s (NewTransition config attrs ) = -- TODO
-- | these special cases are still TODO, they need to call selectionText_, selectionInnerHTML_ etc
addAttribute s attr@(Text d) = addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
addAttribute s attr@(Text_ d) = addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
addAttribute s attr@(InnerHTML d) = addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
addAttribute s attr@(InnerHTML_ d) = addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
-- | regular attributes all handled the same way
addAttribute s attr = addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)

addTransition :: forall d. Selection_ -> Array (TransitionAttribute d) -> Unit
addTransition s attrs = do
  let t = addTransition_ s -- this makes a transition selection to which we can add attributes, including transition attributes
  let t' = addTransitionAttributes t attrs
  pure t'

addTransitionAttributes :: forall d. Selection_ -> TransitionAttribute d -> Unit
addTransitionAttributes t (TransitionDuration_ v) = addTransitionAttribute_ t "transitionDuration" v
addTransitionAttributes t (TransitionDelay_ v) = addTransitionAttribute_ t "transitionDelay" v
addTransitionAttributes t (TransitionDuration f) = addTransitionAttribute_ t "transitionDuration" f
addTransitionAttributes t (TransitionDelay f) = addTransitionAttribute_ t "transitionDelay" f
addTransitionAttributes t (Attr a) = addAttributes t a -- t needs to definitely be the transition selection here
addTransitionAttributes t Remove = remove_ t "remove" true

addAttributes :: forall d. Selection_ -> Array (Attribute d) -> Effect Selection_
addAttributes s attrs = do
  let _ = (addAttribute s) <$> attrs -- relies on the fact that addAttribute returns the same selection each time
  pure s



data TransitionAttribute d = -- TODO - add more transition attributes
    TransitionDuration_ Number
  | TransitionDuration (AttributeSetter d Number)
  | TransitionDelay_ Number
  | TransitionDelay (AttributeSetter d Number)
  -- | The easing function is invoked for each frame of the animation, 
  -- |being passed the normalized time t in the range [0, 1];
  -- | it must then return the eased time tʹ which is typically also in the range [0, 1]. 
  -- | A good easing function should return 0 if t = 0 and 1 if t = 1. 
  | TransitionEasing (AttributeSetter d Number) 
  | Remove
  | Attr (Attribute d)
  
instance showTransitionAttribute :: Show (TransitionAttribute d) where
  show (TransitionDuration_ v) = "TransitionDuration_" <> " set directly to " <> show v
  show (TransitionDelay_ v) = "TransitionDelay_" <> " set directly to " <> show v
  show (Attr a) = "Attr" <> " set directly to " <> show a
  show (TransitionDuration f) = "TransitionDuration set by function"
  show (TransitionDelay f) = "TransitionDelay set by function"
  show Remove = "Remove these nodes"

type TransitionConfig = { duration :: Number, delay :: Number, easing :: Number -> Number }

data Attribute d = 
    Background_ String
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
  | InnerHTML_ String
  | InnerHTML (AttributeSetter d String)
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
  | NamedTransition String TransitionConfig (Array (Attribute d))
  | NewTransition TransitionConfig (Array (Attribute d))
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
  Background_ v -> exportAttributeSetter_ v
  Background f -> exportAttributeSetter_ f
  Color_ v -> exportAttributeSetter_ v
  Classed_ v -> exportAttributeSetter_ v
  CX_ v -> exportAttributeSetter_ v
  CY_ v -> exportAttributeSetter_ v
  DX_ v -> exportAttributeSetter_ v
  DY_ v -> exportAttributeSetter_ v
  Fill_ v -> exportAttributeSetter_ v
  FontFamily_ v -> exportAttributeSetter_ v
  FontSize_ v -> exportAttributeSetter_ v
  Height_ v -> exportAttributeSetter_ v
  InnerHTML_ v -> exportAttributeSetter_ v
  Radius_ v -> exportAttributeSetter_ v
  StrokeColor_ v -> exportAttributeSetter_ v
  StrokeOpacity_ v -> exportAttributeSetter_ v
  StrokeWidth_ v -> exportAttributeSetter_ v
  Style_ v -> exportAttributeSetter_ v
  Text_ v -> exportAttributeSetter_ v
  TextAnchor_ v -> exportAttributeSetter_ v
  TransitionTo vs -> exportAttributeSetter_ vs
  Width_ v -> exportAttributeSetter_ v
  ViewBox_ x y w h -> exportAttributeSetter_ [x, y, w, h] -- TODO this one is a special case, impressive that CoPilot guessed it
  X_ v -> exportAttributeSetter_ v
  Y_ v -> exportAttributeSetter_ v
  X1_ v -> exportAttributeSetter_ v
  X2_ v -> exportAttributeSetter_ v
  Y1_ v -> exportAttributeSetter_ v
  Y2_ v -> exportAttributeSetter_ v
  -- setter functions are different because they should be uncurried
  Color f -> exportAttributeSetter_ (uncurry_ f)
  Classed f -> exportAttributeSetter_ (uncurry_ f)
  CX f -> exportAttributeSetter_ (uncurry_ f)
  CY f -> exportAttributeSetter_ (uncurry_ f)
  DX f -> exportAttributeSetter_ (uncurry_ f)
  DY f -> exportAttributeSetter_ (uncurry_ f)
  Fill f -> exportAttributeSetter_ (uncurry_ f)
  FontFamily f -> exportAttributeSetter_ (uncurry_ f)
  FontSize f -> exportAttributeSetter_ (uncurry_ f)
  Height f -> exportAttributeSetter_ (uncurry_ f)
  InnerHTML f -> exportAttributeSetter_ (uncurry_ f)
  Radius f -> exportAttributeSetter_ (uncurry_ f)
  StrokeColor f -> exportAttributeSetter_ (uncurry_ f)
  StrokeOpacity f -> exportAttributeSetter_ (uncurry_ f)
  StrokeWidth f -> exportAttributeSetter_ (uncurry_ f)
  Style f -> exportAttributeSetter_ (uncurry_ f)
  Text f -> exportAttributeSetter_ (uncurry_ f)
  TextAnchor f -> exportAttributeSetter_ (uncurry_ f)
  Width f -> exportAttributeSetter_ (uncurry_ f)
  X f -> exportAttributeSetter_ (uncurry_ f)
  Y f -> exportAttributeSetter_ (uncurry_ f)
  X1 f -> exportAttributeSetter_ (uncurry_ f)
  X2 f -> exportAttributeSetter_ (uncurry_ f)
  Y1 f -> exportAttributeSetter_ (uncurry_ f)
  Y2 f -> exportAttributeSetter_ (uncurry_ f)

foreign import uncurry_ :: forall d t. AttributeSetter d t -> AttributeSetter_

getKeyFromAttribute :: forall d. Attribute d -> String
getKeyFromAttribute = case _ of 
  Background_ _ -> "background"
  Background _ -> "background"
  Color_ _ -> "color"
  Color _ -> "color"
  Classed_ _ -> "class"
  Classed _ -> "class"
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
  InnerHTML_ _ -> "html"
  InnerHTML _ -> "html"
  Radius_ _ -> "r"
  Radius _ -> "r"
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
  show (InnerHTML_ v) = "\n\t\tInnerHTML_" <> " set directly to " <> v
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
  show (InnerHTML f) = "\n\t\tInnerHTML set by function"
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
