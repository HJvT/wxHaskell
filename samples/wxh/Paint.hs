{--------------------------------------------------------------------------------
  Copyright 2003, Daan Leijen
  Paint demo.
--------------------------------------------------------------------------------}
module Main where

import Graphics.UI.WXH

main :: IO ()
main
  = run gui

gui :: IO ()
gui
  = do -- create top frame
       f <- frameCreateTopFrame "Paint demo"

       -- for good measure: put a scrolled window inside the frame
       -- note that 'wxNO_FULL_REPAINT_ON_RESIZE'  is needed to prevent flicker on resize.
       s <- scrolledWindowCreate f idAny rectNull (wxHSCROLL + wxVSCROLL + wxNO_FULL_REPAINT_ON_RESIZE + wxCLIP_CHILDREN)

       -- virtual size is 20*40 = 800 pixels
       scrolledWindowSetScrollbars s 20 20 40 40 0 0 0

       -- to show the effect of double-buffering, we track the mouse with a small disc.
       mouseXY <- varCreate (pt 0 0)
       windowOnMouse s True {- get motion events -} (onMouse s mouseXY)

       -- set paint event handler:
       windowOnPaint s True {- double buffer? -} (onPaint mouseXY)

       -- show the frame
       windowShow f
       windowRaise f
       return ()
  where
    -- update the mouse position and force a repaint
    onMouse w mouseXY mouse
      = do varSet mouseXY (mousePos mouse)
           windowRefresh w False {- erase background -}

    -- do some painting.
    onPaint mouseXY dc viewRect updateAreas
      = -- first create some brushes and pens.
        withBrushStyle (BrushStyle (BrushHatch HatchCross) red) $ \brushRedHatch ->
        withBrushStyle (BrushStyle BrushSolid red)  $ \brushRed ->
        withBrushStyle (BrushStyle BrushSolid white)  $ \brushWhite ->
        withPenStyle (penColored blue 5) $ \penMedBlue ->
        do -- clear the canvas
           dcClear dc

           dcSetBrush dc brushWhite
           dcDrawRectangle dc (rect (pt 20 20) (sz 500 500))

           dcSetBrush dc brushRedHatch
           dcDrawCircle dc (pt 100 100) 50

           dcSetPen dc penMedBlue
           dcDrawRectangle dc (rect (pt 200 200) (sz 50 50))

           dcSetBrush dc brushRed
           dcDrawEllipticArc dc (rect (pt 100 200) (sz 50 100)) 45 135

           -- draw the mouse bullet
           xy <- varGet mouseXY
           dcDrawCircle dc xy 10

           drawPolygon dc [(pt 200 400),(pt 300 300),(pt 400 400)]
           dcDrawRotatedText dc "Polygon" (pt 200 370) 45

           -- fonts
           dcWithFontInfo dc fontSwiss{ fontSize = 12, fontWeight = WeightBold } $
            do dcDrawText dc "Swiss 12pt bold" (pt 50 270)
               dcWithFontInfo dc fontNormal{ fontFamily = FontScript, fontSize = 16} $
                dcDrawText dc "Hand writing 16pt" (pt 50 290)
               dcDrawText dc "Swiss 12pt bold" (pt 50 310)

           (Size w h) <- getTextExtent dc "label"
           dcDrawRectangle dc (rect (pt 450 350) (sz (w+10) (h+10)))
           dcDrawText dc "label" (pt 455 355)

           -- cap styles
           dcWithPenStyle dc (penDefault{ penWidth = 20, penCap = CapRound }) $
            dcDrawLine dc (pt 400 100) (pt 500 100)

           dcWithPenStyle dc (penDefault{ penWidth = 20, penCap = CapProjecting }) $
            dcDrawLine dc (pt 400 150) (pt 500 150)

           dcWithPenStyle dc (penDefault{ penWidth = 20, penCap = CapButt }) $
            dcDrawLine dc (pt 400 200) (pt 500 200)

           dcSetBrush dc nullBrush
           dcDrawEllipse dc (rect (pt 200 100) (sz 100 50))