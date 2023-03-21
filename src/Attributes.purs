module Nud3.Attributes where

import Prelude

import Data.Nullable (Nullable)
import Effect (Effect)
import Nud3.FFI as FFI
import Nud3.Types (Selection_, Transition_)
import Unsafe.Coerce (unsafeCoerce)

-- | the foreign AttributeSetter_ is not really typeable in PureScript while still being efficient
-- | certainly could be an option to remove all this and do something complicated with Variants or 
-- | Options or heterogeneous lists or whatever
foreign import data AttributeSetter_ :: Type 
foreign import addAttribute_ :: forall d. Selection_ -> String -> d -> Unit
foreign import addText_ :: forall d. Selection_ -> d -> Selection_
foreign import addTransitionToSelection_ :: Selection_ -> Transition_ -> Selection_
-- | no attempt will be made to manage named transitions in contrast to D3
foreign import removeElement_ :: forall d. Selection_ -> Unit

exportAttributeSetter_ :: forall d. d -> AttributeSetter_
exportAttributeSetter_ = unsafeCoerce 

type AttributeSetter d t = d -> Int -> t

{-
      .join(
        enter => enter.append("text")
            .attr("fill", "green")
            .attr("x", (d, i) => i * 16)
            .attr("y", -30)
            .text(d => d)
          .call(enter => enter.transition(t)
            .attr("y", 0)),
        update => update
            .attr("fill", "black")
            .attr("y", 0)
          .call(update => update.transition(t)
            .attr("x", (d, i) => i * 16)),
        exit => exit
            .attr("fill", "brown")
          .call(exit => exit.transition(t)
            .attr("y", 30)
            .remove())

From the D3 docs:
The return value of the enter and update function is important—it specifies the
selections to merge and return by selection.join. To avoid breaking the method
chain, use selection.call to create transitions. Or, return an undefined enter
or update selection to prevent merging.

Now, it's not clear to me that _our_ enter, update and exit functions are being
given to D3 correctly and it's certainly the case given the way we map over
attributes that we are not returning the underlying selection after the
transition is added

I believe it's still possible under the hood to use the previous general update
patter and it may turn out to be necessary to do it this way if we can't find a
way to make the PureScript version work exactly as the above example shows

-}
-- | we special case on some attributes - Text, InnerHTML, Transition
addAttribute :: forall d. Selection_ -> Attribute d -> Selection_
-- | TODO we need to use the format .call() see blockcomment above
addAttribute s (Transition transition attrs ) = do
  let selectionTransition = addTransitionToSelection_ s transition 
      -- we coerce the transition back to a selection to add the attributes, not pretty but isolated here
      s' = (addAttribute selectionTransition) <$> attrs 
  s'
addAttribute s (TransitionThenRemove transition attrs ) = do
  let selectionTransition = addTransitionToSelection_ s transition
  let _ = removeElement_ selectionTransition -- we can just go ahead and add this at the start given the semantics
      s' = (addAttribute selectionTransition) <$> attrs
  s'

addAttribute s attr@(Text d) = addText_ s (getValueFromAttribute attr)
addAttribute s attr@(Text_ d) = addText_ s (getValueFromAttribute attr)
-- | innerHTML still TODO need to add addInnerHTML_ etc
addAttribute s attr@(InnerHTML d) = addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
addAttribute s attr@(InnerHTML_ d) = addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
-- | regular attributes all handled the same way
addAttribute s attr = addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)

addAttributes :: forall d. Selection_ -> Array (Attribute d) -> Effect Selection_
addAttributes s attrs = do
  let _ = (addAttribute s) <$> attrs -- relies on the fact that addAttribute returns the same selection each time
  pure s

-- | TODO TransitionConfig needs to be fully specified, all possible params set (tho in practice it may be
-- | built by modifying a default config)
type TransitionConfig = { 
    duration :: Int -- TODO this can also be a lambda, see AttributeSetter for how to do this
  , delay :: Int -- TODO this can also be a lambda, see AttributeSetter for how to do this
  , easing :: Number -> Number 
}

createTransition :: TransitionConfig -> Transition_
createTransition config = do
  let t = FFI.createNewTransition_ unit
      _ = FFI.transitionDurationFixed_ t config.duration
      _ = FFI.transitionDelayFixed_ t config.delay
      _ = FFI.transitionEaseFunction t config.easing
  t -- NB we return t because all the intermediate steps are just for FFI side-effects which we aren't exposing here

data Attribute d = 
    BackgroundColor_ String
  | BackgroundColor (AttributeSetter d String) -- ie CSS background-color NOT HTML background
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
  | Transition Transition_ (Array (Attribute d))
  | TransitionThenRemove Transition_ (Array (Attribute d))
  | Width_ Number
  | Width (AttributeSetter d Number)
  | ViewBox_ Number Number Number Number -- TODO can't these be Int instead of Number?
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
  BackgroundColor_ v -> exportAttributeSetter_ v
  BackgroundColor f -> exportAttributeSetter_ f
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
  -- | transition attributes are different and we never actually getValueFromAttribute 
  -- | from them like this but we have to typecheck here
  Transition t vs -> exportAttributeSetter_ vs
  TransitionThenRemove t vs -> exportAttributeSetter_ vs
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
  BackgroundColor_ _ -> "background-color"
  BackgroundColor _ -> "background-color"
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
  -- | transition attributes are different and we never actually getKeyFromAttribute 
  -- | from them like this but we have to typecheck here
  Transition _ _ -> "transition" -- special case
  TransitionThenRemove _ _ -> "transition with removal afterwards" -- special case
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
  show (BackgroundColor_ v) = "\n\t\tBackgroundColor_" <> " set directly to " <> v
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
  show (Transition _ vs) = "\n\t\tTransition to these following attrs " <> show vs -- could show transition config too
  show (TransitionThenRemove _ vs) = "\n\t\tTransition to these following attrs " <> show vs -- could show transition config too
  show (Width_ v) = "\n\t\tWidth_" <> " set directly to " <> show v
  show (ViewBox_ x y w h) = "\n\t\tViewBox_" <> " set directly to " <> show x <> " " <> show y <> " " <> show w <> " " <> show h
  show (X_ v) = "\n\t\tX_" <> " set directly to " <> show v
  show (Y_ v) = "\n\t\tY_" <> " set directly to " <> show v
  show (X1_ v) = "\n\t\tX1_" <> " set directly to " <> show v
  show (X2_ v) = "\n\t\tX2_" <> " set directly to " <> show v
  show (Y1_ v) = "\n\t\tY1_" <> " set directly to " <> show v
  show (Y2_ v) = "\n\t\tY2_" <> " set directly to " <> show v
  show (BackgroundColor f) = "\n\t\tBackgroundColor set by function"
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
