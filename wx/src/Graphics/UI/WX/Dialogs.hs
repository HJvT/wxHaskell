{-# OPTIONS -fglasgow-exts #-}
--------------------------------------------------------------------------------
{-| Module      :  Dialogs
    Copyright   :  (c) Daan Leijen 2003
    License     :  wxWindows

    Maintainer  :  daan@cs.uu.nl
    Stability   :  provisional
    Portability :  portable

    Defines common dialogs.
-}
--------------------------------------------------------------------------------
module Graphics.UI.WX.Dialogs
    ( -- * Generic dialogs
      Dialog, dialog, showModal
     -- * Messages
    , errorDialog, warningDialog, infoDialog
    , confirmDialog, proceedDialog
      -- * Files
    , fileOpenDialog, filesOpenDialog
    , fileSaveDialog
    , dirOpenDialog
      -- * Misc.
    , fontDialog
    , colorDialog
    , passwordDialog
    , textDialog
    , numberDialog
      -- * Primitive
    , dialogEx
    ) where

import Graphics.UI.WXH.WxcClasses
import Graphics.UI.WXH.WxcDefs
import Graphics.UI.WXH.Dialogs

import Graphics.UI.WX.Types
import Graphics.UI.WX.Attributes
import Graphics.UI.WX.Layout
import Graphics.UI.WX.Classes

instance Form (Dialog a) where
  layout
    = writeAttr "layout" windowSetLayout

-- | Create a dialog window. Use 'showModal' for a modal dialog. Use
-- the 'visible' property to show\/hide a modeless dialog.
dialog :: Window a -> [Prop (Dialog ())] -> IO (Dialog ())
dialog parent props
  = dialogEx parent (wxCAPTION .+. wxSYSTEM_MENU .+. wxRESIZE_BORDER) props

-- | Create a dialog window with a certain style.
dialogEx :: Window a -> Style -> [Prop (Dialog ())] -> IO (Dialog ())
dialogEx parent style props
  = do d <- dialogCreate parent idAny "" rectNull style 
       set d props
       return d

-- | Show a modal dialog. Take a function as argument that takes a function itself
-- as argument that can be used to end the modal dialog. The argument of this function
-- is returned as the result of the dialog. The result is 'Nothing' when the dialog
-- is dismissed via the system menu.
--
-- > d   <- dialog [text := "Demo"]
-- > ok  <- button d [text := "Ok"]
-- > ...
-- > result <- showModal d (\stop -> set ok [on command := stop (Just 42)])
--
showModal :: Dialog b -> ((Maybe a -> IO ()) -> IO ()) -> IO (Maybe a)
showModal dialog f
  = do ret <- varCreate Nothing
       f (\x -> do{ varSet ret x; dialogEndModal dialog 0} )
       dialogShowModal dialog
       varGet ret
