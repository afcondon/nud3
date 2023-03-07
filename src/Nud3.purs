module Nud3.FFI  where

import Prelude

import Nud3.Types (Selection, Selector(..))
import Unsafe.Coerce (unsafeCoerce)

foreign import data D3Selection :: Type
foreign import data D3SelectorFunction :: Type

foreign import selectFirstWithStringSelector :: String -> D3Selection
foreign import selectManyWithStringSelector :: String -> D3Selection
foreign import selectGroupedWithStringSelector :: Selection -> String -> D3Selection
foreign import selectFirstFromWithStringSelector :: Selection -> String -> D3Selection


foreign import selectFirstWithFunctionSelector :: D3SelectorFunction -> D3Selection
foreign import selectManyWithFunctionSelector :: D3SelectorFunction -> D3Selection
foreign import selectGroupedWithFunctionSelector :: Selection -> D3SelectorFunction -> D3Selection
foreign import selectFirstFromWithFunctionSelector :: Selection -> D3SelectorFunction -> D3Selection


-- | hiding all the coercion stuff from the user here
-- | to be replaced with code that doesn't need coercion later when the D3 api is replaced one native to this library

selectFirst :: Selector -> Selection
selectFirst =
  case _ of
    SelectorString selectorString -> unsafeCoerce $ selectFirstWithStringSelector selectorString
    SelectorFunction selectorFunction -> unsafeCoerce $ selectFirstWithFunctionSelector (unsafeCoerce selectorFunction)

selectMany :: Selector -> Selection
selectMany =
  case _ of
    SelectorString selectorString -> unsafeCoerce $ selectManyWithStringSelector selectorString
    SelectorFunction selectorFunction -> unsafeCoerce $ selectManyWithFunctionSelector (unsafeCoerce selectorFunction)

selectFirstFrom :: Selection -> Selector -> Selection
selectFirstFrom selection =
  case _ of
    SelectorString selectorString -> unsafeCoerce $ selectFirstFromWithStringSelector selection selectorString
    SelectorFunction selectorFunction -> unsafeCoerce $ selectFirstFromWithFunctionSelector selection (unsafeCoerce selectorFunction)

selectGrouped :: Selection -> Selector -> Selection
selectGrouped selection =
  case _ of
    SelectorString selectorString -> unsafeCoerce $ selectGroupedWithStringSelector selection selectorString
    SelectorFunction selectorFunction -> unsafeCoerce $ selectGroupedWithFunctionSelector selection (unsafeCoerce selectorFunction)
