module Nud3.Attributes
  where

import Prelude

import Data.Array (foldl, intercalate)
import Data.Int (floor)
import Nud3.FFI as FFI
import Nud3.Types (Selection_, Transition_)
import Unsafe.Coerce (unsafeCoerce)

-- | Foreign types
-- | Opaque types that we use to hide some of the details of the FFI
-- | Setters in JS/D3 can be either functions or values - as long as we have
-- | type-safety in the construction of the Attributes we can just coerce here
-- | before sending to the FFI
foreign import data AttributeSetter_ :: Type
foreign import data TransitionAttributeSetter_ :: Type

-- | Attribute Setter is the type of functions that can be used to set attributes on elements
-- | using functions that take the data and index as arguments
-- | thru the magic of unsafeCoerce we just drop all the type-safety at the final moment before
-- | calling the FFI
type AttributeSetter d t = d -> Int -> t

exportAttributeSetter_ :: forall d. d -> AttributeSetter_
exportAttributeSetter_ = unsafeCoerce

exportAttributeSetterUncurried_ :: forall d t. AttributeSetter d t -> AttributeSetter_
exportAttributeSetterUncurried_ f = unsafeCoerce $ uncurry_ f


exportAttributeSettersForTransform :: forall d t. Array (AttributeSetter d t) -> AttributeSetter_
exportAttributeSettersForTransform fs = unsafeCoerce $ uncurryMultipleForTransform_ fs


foldAttributes :: forall d. Selection_ -> Array (Attribute d) -> Selection_
foldAttributes s as = foldl addAttribute s as
  where
  -- | we special case on some attributes - Text, InnerHTML, Transition
  addAttribute :: Selection_ -> Attribute d -> Selection_
  addAttribute s = case _ of
    (BeginTransition t attrs) -> do
      -- a bit of sleight of hand here, st is a transition but we treat it as a selection because 
      -- transitions are a subclass of selections and we are going to add attributes to the selection
      -- apply the attrs to the transition, then retrieve the selection
      let st = addTransitionToSelection_ s t
      retrieveSelection_ $ foldAttributes st attrs

    Delay_ f -> transitionDelay_ s (exportAttributeSetterUncurried_ f) -- requires that we're in a selection-transition, will move to Attribute_ later
    Duration_ f -> transitionDuration_ s (exportAttributeSetterUncurried_ f) -- requires that we're in a selection-transition, will move to Attribute_ later
    RemoveElements -> removeElements_ s -- requires that we're in a selection-transition, will move to Attribute_ later
    FollowOnTransition attrs -> do
      let st = followOnTransition_ s -- requires that we're in a selection-transition, will move to Attribute_ later
          tt = foldAttributes st attrs
      retrieveSelection_ tt

    -- | Text and InnerHTML are special cases because they are not attributes in the DOM sense
    -- | We are deliberately eliding this distinction in the DSL
    attr@(Text _) -> addText_ s (getValueFromAttribute attr)
    attr@(Text_ _) -> addText_ s (getValueFromAttribute attr)
    -- | HER-18 innerHTML still TODO need to add addInnerHTML_ etc
    attr@(InnerHTML _) -> addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
    attr@(InnerHTML_ _) -> addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
    -- | style and opacity are special cases because they are not attributes in the DOM sense
    attr@(Opacity _) -> addStyle_ s "opacity" (getValueFromAttribute attr)
    attr@(Opacity_ _) -> addStyle_ s "opacity" (getValueFromAttribute attr)
    attr@(Style _) -> addStyle_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
    attr@(Style_ _) -> addStyle_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)
    -- | Transforms are also special in the individual transforms have to be concatenated together
    attr@(Transform _) -> addTransform_ s (getValueFromAttribute attr)
    attr@(Transform_ _) -> addTransform_ s (getValueFromAttribute attr)
    -- | regular attributes all handled the same way
    attr -> addAttribute_ s (getKeyFromAttribute attr) (getValueFromAttribute attr)


-- | TransitionAttributeSetter is the type of functions that can be used to set attributes on transitions
-- | using functions that take the data and index as arguments
-- | thru the magic of unsafeCoerce we just drop all the type-safety at the final moment before
-- | calling the FFI
type TransitionAttributeSetter d = d -> Int -> Int -- maybe this will have to revert to two type arguments later

exportTransitionAttributeSetter_ :: forall d. d -> TransitionAttributeSetter_
exportTransitionAttributeSetter_ = unsafeCoerce

exportTransitionAttributeSetterUncurried_ :: forall d. TransitionAttributeSetter d -> TransitionAttributeSetter_
exportTransitionAttributeSetterUncurried_ f = unsafeCoerce $ uncurry_ f


viewBoxFromNumbers :: forall d. Number -> Number -> Number -> Number -> Attribute d
viewBoxFromNumbers x y w h = ViewBox xi yi wi hi
  where
    xi = floor x
    yi = floor y
    wi = floor w
    hi = floor h

centerOriginViewBox :: forall d. Number -> Number -> Attribute d
centerOriginViewBox w h = viewBoxFromNumbers (-w / 2.0) (-h / 2.0) w h

-- | TODO there are actually two types of transition attributes when it comes down to it
-- | static transition attributes do not require there to be an underlying selection yet
-- | dynamic transition attributes will blow up if there is no underlying selection
-- | we should probably have two types of transition attributes TODO 

data TransitionAttribute :: forall k. k -> Type
data TransitionAttribute d
  = TransitionName String -- optional name for the transition
  | Delay Int
  | Duration Int
  | Easing (Number -> Number)
  | On
  | End
  | Each

addTransitionAttribute :: forall d. Transition_ -> TransitionAttribute d -> Transition_
addTransitionAttribute t =
  case _ of
    Delay d -> transitionInitDelay_ t d
    Duration d -> transitionInitDuration_ t d
    Easing e -> transitionInitEaseFunction t e
    On -> transitionOn_ t unit -- TODO
    End -> transitionEnd_ t unit -- TODO
    Each -> transitionEach_ t unit -- TODO
    TransitionName _ -> t -- NB we're not setting the name here, we've already set it in createTransition

foldTransitionAttributes :: forall d. Transition_ -> Array (TransitionAttribute d) -> Transition_
foldTransitionAttributes t as = foldl addTransitionAttribute t as

-- | haven't fully understood how this needs to work when multiple selections that use the "same" transition yet
-- | in the Anscombe example we give a 'unit' parameter to ensure a fresh transition for each "re-use"
-- | but this doesn't seem like it should be necessary. 
-- | TODO definitely needs to be fixed, unit param is a hack
createTransition :: forall d. Array (TransitionAttribute d) -> Transition_
createTransition params = do
  let
    getTransitionName :: Array (TransitionAttribute d) -> String
    getTransitionName attrs = foldl go "" attrs
      where
      go name attr = case attr of
        TransitionName name -> name
        _ -> name
    t = FFI.createNewTransition_ $ getTransitionName params
  foldTransitionAttributes t params

data AlignAspectRatio_X = XMin | XMid | XMax
instance Show AlignAspectRatio_X where
  show XMin = "xMin"
  show XMid = "xMid"
  show XMax = "xMax"
data AlignAspectRatio_Y = YMin | YMid | YMax
instance Show AlignAspectRatio_Y where -- YES!!! the Y is capitalized, where the x is not!!!!
  show YMin = "YMin"
  show YMid = "YMid"
  show YMax = "YMax"
data AspectRatioPreserve = Meet | Slice | None
instance Show AspectRatioPreserve where
  show Meet  = "meet"
  show Slice = "slice"
  show None  = "none"
data AspectRatioSpec = AspectRatio AlignAspectRatio_X AlignAspectRatio_Y AspectRatioPreserve

instance Show AspectRatioSpec where
  show (AspectRatio x y None) =  "none"
  show (AspectRatio x y p)    =  show x <> show y <> " " <> show p

data Attribute d
  = BackgroundColor String
  | Color String
  | Classed String
  | CX Number
  | CY Number
  | DX Number
  | DY Number
  | Fill String
  | FontFamily String
  | FontSize Number
  | Height Number
  | InnerHTML String
  | Opacity Number
  | Path String
  | PreserveAspectRatio String
  | Radius Number
  | StrokeColor String
  | StrokeOpacity Number
  | StrokeWidth Number
  | Style String
  | Text String
  | TextAnchor String
  | Transform String

  -- | attributes specific to transitions
  | BeginTransition Transition_ (Array (Attribute d))
  | Delay_ (TransitionAttributeSetter d) -- a function to set the delay per datum
  | Duration_ (TransitionAttributeSetter d)
  | FollowOnTransition (Array (Attribute d)) -- make a new transition that follows on from this one
  | RemoveElements -- TODO could finalize transition here and/or add Don'tRemove for those rare cases where we want to keep the element

  | Width Number
  | ViewBox Int Int Int Int
  | X Number
  | Y Number
  | X1 Number
  | X2 Number
  | Y1 Number
  | Y2 Number
  | BackgroundColor_ (AttributeSetter d String) -- ie CSS background-color NOT HTML background
  | Color_ (AttributeSetter d String)
  | Classed_ (AttributeSetter d String)
  | CX_ (AttributeSetter d Number)
  | CY_ (AttributeSetter d Number)
  | DX_ (AttributeSetter d Number)
  | DY_ (AttributeSetter d Number)
  | Fill_ (AttributeSetter d String)
  | FontFamily_ (AttributeSetter d String)
  | FontSize_ (AttributeSetter d Number)
  | Height_ (AttributeSetter d Number)
  | InnerHTML_ (AttributeSetter d String)
  | Opacity_ (AttributeSetter d Number)
  | Path_ (AttributeSetter d String)
  | PreserveAspectRatio_ (AttributeSetter d String)
  | Radius_ (AttributeSetter d Number)
  | StrokeColor_ (AttributeSetter d String)
  | StrokeOpacity_ (AttributeSetter d Number)
  | StrokeWidth_ (AttributeSetter d Number)
  | Style_ (AttributeSetter d String)
  | Text_ (AttributeSetter d String)
  | TextAnchor_ (AttributeSetter d String)
  | Transform_ (Array (AttributeSetter d String)) -- there can be multiple transforms
  | Width_ (AttributeSetter d Number)
  | X_ (AttributeSetter d Number)
  | Y_ (AttributeSetter d Number)
  | X1_ (AttributeSetter d Number)
  | X2_ (AttributeSetter d Number)
  | Y1_ (AttributeSetter d Number)
  | Y2_ (AttributeSetter d Number)

-- | Boilerplate function of Show for a TransitionAttribute
instance showTransitionAttribute :: Show (TransitionAttribute d) where
  show (TransitionName name) = "TransitionName " <> name
  show (Delay d) = "Delay " <> show d
  show (Duration d) = "Duration " <> show d
  show (Easing _) = "Easing"
  show On = "On"
  show End = "End"
  show Each = "Each"

-- | Boilerplate function to get the key from an Attribute
getValueFromAttribute :: forall d. Attribute d -> AttributeSetter_
getValueFromAttribute = case _ of
  --| first the direct value setters
  BackgroundColor v -> exportAttributeSetter_ v
  Color v -> exportAttributeSetter_ v
  Classed v -> exportAttributeSetter_ v
  CX v -> exportAttributeSetter_ v
  CY v -> exportAttributeSetter_ v
  DX v -> exportAttributeSetter_ v
  DY v -> exportAttributeSetter_ v
  Fill v -> exportAttributeSetter_ v
  FontFamily v -> exportAttributeSetter_ v
  FontSize v -> exportAttributeSetter_ v
  Height v -> exportAttributeSetter_ v
  InnerHTML v -> exportAttributeSetter_ v
  Opacity v -> exportAttributeSetter_ v
  Path v -> exportAttributeSetter_ v
  PreserveAspectRatio v -> exportAttributeSetter_ v
  Radius v -> exportAttributeSetter_ v
  StrokeColor v -> exportAttributeSetter_ v
  StrokeOpacity v -> exportAttributeSetter_ v
  StrokeWidth v -> exportAttributeSetter_ v
  Style v -> exportAttributeSetter_ v
  Text v -> exportAttributeSetter_ v
  TextAnchor v -> exportAttributeSetter_ v
  Transform v -> exportAttributeSetter_ v
  Width v -> exportAttributeSetter_ v
  ViewBox x y w h -> exportAttributeSetter_ [ x, y, w, h ]
  X v -> exportAttributeSetter_ v
  Y v -> exportAttributeSetter_ v
  X1 v -> exportAttributeSetter_ v
  X2 v -> exportAttributeSetter_ v
  Y1 v -> exportAttributeSetter_ v
  Y2 v -> exportAttributeSetter_ v
  -- | transition and their attributes are different and we never actually getValueFromAttribute 
  -- | from them like this but we have to typecheck here
  BeginTransition t _ -> exportAttributeSetter_ unit
  Delay_ f -> exportAttributeSetter_ unit
  Duration_ f -> exportAttributeSetter_ unit
  FollowOnTransition _ -> exportAttributeSetter_ unit
  RemoveElements -> exportAttributeSetter_ unit

  -- | finally the lambda setters
  -- | setter functions are different because they should be uncurried
  BackgroundColor_ f -> exportAttributeSetterUncurried_ f
  Color_ f -> exportAttributeSetterUncurried_ f
  Classed_ f -> exportAttributeSetterUncurried_ f
  CX_ f -> exportAttributeSetterUncurried_ f
  CY_ f -> exportAttributeSetterUncurried_ f
  DX_ f -> exportAttributeSetterUncurried_ f
  DY_ f -> exportAttributeSetterUncurried_ f
  Fill_ f -> exportAttributeSetterUncurried_ f
  FontFamily_ f -> exportAttributeSetterUncurried_ f
  FontSize_ f -> exportAttributeSetterUncurried_ f
  Height_ f -> exportAttributeSetterUncurried_ f
  InnerHTML_ f -> exportAttributeSetterUncurried_ f
  Radius_ f -> exportAttributeSetterUncurried_ f
  Opacity_ f -> exportAttributeSetterUncurried_ f
  Path_ f -> exportAttributeSetterUncurried_ f
  PreserveAspectRatio_ f -> exportAttributeSetterUncurried_ f
  StrokeColor_ f -> exportAttributeSetterUncurried_ f
  StrokeOpacity_ f -> exportAttributeSetterUncurried_ f
  StrokeWidth_ f -> exportAttributeSetterUncurried_ f
  Style_ f -> exportAttributeSetterUncurried_ f
  Text_ f -> exportAttributeSetterUncurried_ f
  TextAnchor_ f -> exportAttributeSetterUncurried_ f
  Transform_ fs -> exportAttributeSettersForTransform fs
  Width_ f -> exportAttributeSetterUncurried_ f
  X_ f -> exportAttributeSetterUncurried_ f
  Y_ f -> exportAttributeSetterUncurried_ f
  X1_ f -> exportAttributeSetterUncurried_ f
  X2_ f -> exportAttributeSetterUncurried_ f
  Y1_ f -> exportAttributeSetterUncurried_ f
  Y2_ f -> exportAttributeSetterUncurried_ f

-- | Boilerplate function to get the key from an Attribute
getKeyFromAttribute :: forall d. Attribute d -> String
getKeyFromAttribute = case _ of
  BackgroundColor_ _ -> "background-color"
  BackgroundColor _ -> "background-color"
  Color_ _ -> "color"
  Color _ -> "color"
  Classed _ -> "class"
  Classed_ _ -> "class"
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
  Opacity_ _ -> "opacity"
  Opacity _ -> "opacity"
  Path_ _ -> "d" -- we use "Path" for readability but the attribute is really "d"
  Path _ -> "d" -- we use "Path" for readability but the attribute is really "d"
  PreserveAspectRatio_ _ -> "preserveAspectRatio"
  PreserveAspectRatio _ -> "preserveAspectRatio"
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
  Transform _ -> "transform"
  Transform_ _ -> "transform"
  -- | transition attributes are different and we never actually getKeyFromAttribute 
  -- | from them like this but we have to typecheck here
  BeginTransition _ _ -> "transition begins here" -- special case
  Delay_ _ -> "custom transition delay"
  Duration_ _ -> "custom transition duration"
  FollowOnTransition _ -> "follow-on transition begins here"
  RemoveElements -> "remove elements"

  Width_ _ -> "width"
  Width _ -> "width"
  ViewBox _ _ _ _ -> "viewBox"
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

-- | Boilerplate instance of Show for an Attribute
instance showAttribute :: Show (Attribute d) where
  show (BackgroundColor v) = "\n\t\tBackgroundColor_" <> " set directly to " <> v
  show (Color v) = "\n\t\tColor_" <> " set directly to " <> v
  show (Classed v) = "\n\t\tClassed" <> " set directly to " <> v
  show (CX v) = "\n\t\tCX_" <> " set directly to " <> show v
  show (CY v) = "\n\t\tCY_" <> " set directly to " <> show v
  show (DX v) = "\n\t\tDX_" <> " set directly to " <> show v
  show (DY v) = "\n\t\tDY_" <> " set directly to " <> show v
  show (Fill v) = "\n\t\tFill_" <> " set directly to " <> v
  show (FontFamily v) = "\n\t\tFontFamily_" <> " set directly to " <> v
  show (FontSize v) = "\n\t\tFontSize_" <> " set directly to " <> show v
  show (Height v) = "\n\t\tHeight_" <> " set directly to " <> show v
  show (InnerHTML v) = "\n\t\tInnerHTML_" <> " set directly to " <> v
  show (Opacity v) = "\n\tOpacity_" <> " set directly to " <> show v
  show (Path v) = "\n\t\tPath_" <> " set directly to " <> v
  show (PreserveAspectRatio v) = "\n\t\tPreserveAspectRatio_" <> " set directly to " <> v
  show (Radius v) = "\n\t\tRadius_" <> " set directly to " <> show v
  show (StrokeColor v) = "\n\t\tStrokeColor_" <> " set directly to " <> v
  show (StrokeOpacity v) = "\n\t\tStrokeOpacity_" <> " set directly to " <> show v
  show (StrokeWidth v) = "\n\t\tStrokeWidth_" <> " set directly to " <> show v
  show (Style v) = "\n\t\tStyle_" <> " set directly to " <> v
  show (Text v) = "\n\t\tText_" <> " set directly to " <> v
  show (TextAnchor v) = "\n\t\tTextAnchor_" <> " set directly to " <> v
  show (Transform v) = "\n\t\tTransform_" <> " set directly to " <> v

  show (BeginTransition t v) = "\n\t\tTransition started " <> show v 
  show (Delay_ _) = "Delay lambda"
  show (Duration_ _) = "Duration lambda"
  show (FollowOnTransition v) = "FollowOnTransition" <> show v
  show RemoveElements = "Remove elements"

  show (Width v) = "\n\t\tWidth_" <> " set directly to " <> show v
  show (ViewBox x y w h) = "\n\t\tViewBox" <> " set directly to " <> show x <> " " <> show y <> " " <> show w <> " " <> show h
  show (X v) = "\n\t\tX_" <> " set directly to " <> show v
  show (Y v) = "\n\t\tY_" <> " set directly to " <> show v
  show (X1 v) = "\n\t\tX1_" <> " set directly to " <> show v
  show (X2 v) = "\n\t\tX2_" <> " set directly to " <> show v
  show (Y1 v) = "\n\t\tY1_" <> " set directly to " <> show v
  show (Y2 v) = "\n\t\tY2_" <> " set directly to " <> show v
  show (BackgroundColor_ _) = "\n\t\tBackgroundColor set by function"
  show (Color_ _) = "\n\t\tColor set by function"
  show (Classed_ _) = "\n\t\tClassed set by function"
  show (CX_ _) = "\n\t\tCX set by function"
  show (CY_ _) = "\n\t\tCY set by function"
  show (DX_ _) = "\n\t\tDX set by function"
  show (DY_ _) = "\n\t\tDY set by function"
  show (Fill_ _) = "\n\t\tFill set by function"
  show (FontFamily_ _) = "\n\t\tFontFamily set by function"
  show (FontSize_ _) = "\n\t\tFontSize set by function"
  show (Height_ _) = "\n\t\tHeight set by function"
  show (InnerHTML_ _) = "\n\t\tInnerHTML set by function"
  show (Radius_ _) = "\n\t\tRadius set by function"
  show (Opacity_ _) = "\n\t\tOpacity set by function"
  show (Path_ _) = "\n\t\tPath set by function"
  show (PreserveAspectRatio_ _) = "\n\t\tPreserveAspectRatio set by function"
  show (StrokeColor_ _) = "\n\t\tStrokeColor set by function"
  show (StrokeOpacity_ _) = "\n\t\tStrokeOpacity set by function"
  show (StrokeWidth_ _) = "\n\t\tStrokeWidth set by function"
  show (Style_ _) = "\n\t\tStyle set by function"
  show (Text_ _) = "\n\t\tText set by function"
  show (TextAnchor_ _) = "\n\t\tTextAnchor set by function"
  show (Transform_ _) = "\n\t\tTransform set by function"
  show (Width_ _) = "\n\t\tWidth set by function"
  show (X_ _) = "\n\t\tX set by function"
  show (Y_ _) = "\n\t\tY set by function"
  show (X1_ _) = "\n\t\tX1 set by function"
  show (X2_ _) = "\n\t\tX2 set by function"
  show (Y1_ _) = "\n\t\tY1 set by function"
  show (Y2_ _) = "\n\t\tY2 set by function"

-- | Foreign functions
-- | NB attr can be a value or a function
foreign import addAttribute_ :: forall attr. Selection_ -> String -> attr -> Selection_
foreign import addText_ :: forall d. Selection_ -> d -> Selection_
foreign import addTransform_ :: forall d. Selection_ -> d -> Selection_
foreign import addStyle_ :: forall d. Selection_ -> String -> d -> Selection_
foreign import addTransitionToSelection_ :: Selection_ -> Transition_ -> Selection_ -- returns a selection with _mode = Transition
-- | we're actually retrieving a selection from a transition here but it's not worth exposing that in the types
foreign import uncurry_ :: forall d t. AttributeSetter d t -> AttributeSetter_
foreign import uncurryMultipleForTransform_ :: forall d t. Array (AttributeSetter d t) -> Array AttributeSetter_

foreign import transitionInitDelay_ :: forall attr. Transition_ -> attr -> Transition_
foreign import transitionOn_ :: forall attr. Transition_ -> attr -> Transition_
foreign import transitionEnd_ :: forall attr. Transition_ -> attr -> Transition_
foreign import transitionEach_ :: forall attr. Transition_ -> attr -> Transition_
foreign import transitionInitDuration_ :: forall attr. Transition_ -> attr -> Transition_
foreign import transitionInitEaseFunction :: Transition_ -> (Number -> Number) -> Transition_
foreign import transitionDelay_ :: forall attr. Selection_ -> attr -> Selection_ -- only works on transitions, ie _mode = Transition
foreign import transitionDuration_ :: forall attr. Selection_ -> attr -> Selection_ -- only works on transitions, ie _mode = Transition
foreign import followOnTransition_ :: Selection_ -> Selection_ -- only works on transitions, ie _mode = Transition
foreign import retrieveSelection_ :: Selection_ -> Selection_ -- only works on transitions, ie _mode = Transition
foreign import removeElements_ :: Selection_ -> Selection_ -- only works on transitions, ie _mode = Transition

foreign import easeCubic_ :: Number -> Number
