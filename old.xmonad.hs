import XMonad

import XMonad.Util.EZConfig
-- NOTE: Only needed for versions < 0.18.0! For 0.18.0 and up, this is 
-- already included in the XMonad import and will give you a warning!
import XMonad.Util.Ungrab

import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Magnifier (magnifiercz')
--import XMonad.Layout.Gaps
import XMonad.Layout.Spacing

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

import XMonad.Util.Loggers

main :: IO ()
main = xmonad 
  . withEasySB (statusBarProp "xmobar ~/.config/xmonad/xmobar.hs" (pure myXmobarPP)) defToggleStrutsKey
  $ myConf

myConf = def
  {
    modMask = mod4Mask, -- Rebind Mod to the Super key
    layoutHook = myLayout,
    terminal = "st",
    startupHook = myStartupHook
  }
  `additionalKeysP`
  [
    ("<PrtScr>", unGrab *> spawn "scrot -s")
  ]

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "set_background"
  spawnOnce "trayer --edge top --align right --SetDockType true --SetPartialStrut true\
             \--expand true --width 10 --transparent true --tint 0x5f5f5f --height 18"
  spawnOnce "picom"

myXmobarPP :: PP
myXmobarPP = def
  {
    -- TODO: In future use unicode for a bullet point not .
    ppSep             = magenta "  -  ",
    ppTitleSanitize   = xmobarStrip,
    ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2,
    ppHidden          = white . wrap " " "",
    ppHiddenNoWindows = lowWhite . wrap " " "",
    ppUrgent          = red . wrap (yellow "!") (yellow "!"),
    ppOrder           = \[ws, l, _, wins] -> [ws, l, wins],
    ppExtras          = [logTitles formatFocused formatUnfocused]
  }
  where
    formatFocused   = wrap (white "[") (white "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue . ppWindow

    -- Windows sould have some title, which should not exceed a sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    blue     = xmobarColor "#bd93f9" ""
    lowWhite = xmobarColor "#bbbbbb" ""
    magenta  = xmobarColor "#ff79c6" ""
    red      = xmobarColor "#ff5555" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""

myLayout = spacing $ tiled ||| Mirror tiled ||| Full ||| threeCol
  where
    --customGaps = gaps [(U,18), (D,18), (L,23), (R,23)]
    spacing    = spacingWithEdge 10
    tiled      = Tall nmaster delta ratio
    threeCol   = magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    nmaster    = 1     -- Default number of windows in the master pane
    ratio      = 1/2   -- Default proportion of screen occupied by master pane
    delta      = 3/100 -- Percent of screen to increment by when resizing panes
