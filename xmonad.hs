import XMonad
import System.Exit

import XMonad.Util.EZConfig
import XMonad.Util.Ungrab

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Magnifier (magnifiercz')
--import XMonad.Layout.Gaps
import XMonad.Layout.Spacing

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
-- import XMonad.Hooks.StatusBar.PP

import XMonad.Util.Loggers
import XMonad.Hooks.ManageHelpers
-- import Control.Monad

import System.CPUTime


----------------------- Colors ----------------------------
purple, lowWhite, magenta, red, white, yellow, maroon :: String -> String
purple   = xmobarColor "#bd93f9" ""
lowWhite = xmobarColor "#bbbbbb" ""
magenta  = xmobarColor "#ff79c6" ""
red      = xmobarColor "#f30000" ""
maroon   = xmobarColor "#5b030f" ""
white    = xmobarColor "#f8f8f2" ""
yellow   = xmobarColor "#f1fa8c" ""
maroonStr= "#5b030f"
redStr   = "#f30000"
-----------------------------------------------------------



---------------- Definitions of values --------------------
mask :: KeyMask
mask = mod4Mask
term :: String
term = "st"
numer :: [String]
numer= ["1","2","3","4","5","6","7","8","9"]
rome :: [String]
rome = ["  I ","II ","III ","IV ","V ","VI ","VII ","VIII"," IX "]
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
unfocBorderColor :: String
unfocBorderColor = maroonStr
focusBorderColor :: String
focusBorderColor = redStr
myBorderWidth :: Dimension
myBorderWidth = 4
winSpacing :: Int
winSpacing = 6

-- Return true if at least 15 ms has passed since lastt - last time
-- Roughly the reaction speed of a person thank you Baltz-Knorr lol

-- Computation getCPUTime returns the number of picoseconds CPU time used by the current program. The precision of this result is implementation-dependent.

-- Last time that one of the volume buttons were pressed is stored here.
-- This is an attempt to prevent pressing F2 and F3 cause a repeated call to volume
--lastvolpress :: () -> IO Integer
--lastvolpress = System.CPUTime.getCPUTime

--delayPassed :: IO Integer -> Bool
--delayPassed = do
--  last <- lastvolpress
--  return (last - )


  ------------- Implement a delay using Monads ----------------
  -- 1.  When volume buttons are pressed, 

-----------------------------------------------------------




main :: IO ()
main = xmonad 
  . withEasySB (statusBarProp "xmobar ~/.config/xmonad/xmobar.hs" (pure myXmobarPP)) defToggleStrutsKey
  $ myConf

myConf = def
  {
    modMask = mask, 
    layoutHook = myLayout,
    manageHook = myManageHook,
    terminal = term,
    workspaces = rome,
    focusFollowsMouse = myFocusFollowsMouse,
    borderWidth = myBorderWidth,
    normalBorderColor = unfocBorderColor,
    focusedBorderColor = focusBorderColor,
    keys = defaultKeys,
    startupHook = myStartupHook
  }
  `additionalKeys`
  [
    ((mask, xK_Print), unGrab *> spawn "screenshot wind"),
    ((mask, xK_f), spawn "firefox-bin"),
--    ((mask, xK_w), spawn "wpa_gui"),
    ((mask .|. shiftMask, xK_Print), unGrab *> spawn "screenshot sel"),
    ((0, xK_Print), unGrab *> spawn "screenshot scrn"),
    ((0, xK_F1), spawn "pactl set-sink-mute alsa_output.pci-0000_00_1f.3.analog-stereo toggle"),
    ((0, xK_F2), spawn "volume down 5"), -- run /usr/bin/volume --> ~/.config/scripts/cpp/volume
    ((0, xK_F3), spawn "volume up 5")  -- ditto

  ]

defaultKeys conf@(XConfig {XMonad.modMask = mod}) = M.fromList $
  [
    ((mod, xK_Return), spawn $ XMonad.terminal conf),
    ((mod, xK_space), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\""),
    ((mod, xK_q), kill),
    ((mod .|. shiftMask, xK_space), sendMessage NextLayout),
    ((mod, xK_r), setLayout $ XMonad.layoutHook conf),
    ((mod, xK_n), refresh),
    ((mod, xK_s), spawn $ "xscreensaver-command --suspend"),
    ((mod, xK_j), windows W.focusDown),
    ((mod, xK_k), windows W.focusUp),
    ((mod, xK_m), windows W.focusMaster),
    ((mod .|. shiftMask, xK_Return), windows W.swapMaster),
    ((mod .|. shiftMask, xK_j), windows W.swapDown),
    ((mod .|. shiftMask, xK_k), windows W.swapUp),
    ((mod, xK_h), sendMessage Shrink),
    ((mod, xK_l), sendMessage Expand),
    ((mod, xK_t), withFocused $ windows . W.sink),
    ((mod, xK_comma), sendMessage (IncMasterN 1)),
    ((mod, xK_period), sendMessage (IncMasterN (-1))),
    ((mod, xK_c), io (exitWith ExitSuccess)),
    ((mod .|. shiftMask, xK_c), restart "xmonad" True),
    ((mod .|. shiftMask, xK_s), spawn $ "shutdown -hP now"),
    ((mod .|. shiftMask, xK_r), spawn $ "reboot")
  ]
  ++
  [
    ((m .|. mod, k), windows $ f i) 
    | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9],
    (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ]

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "xsetroot -cursor_name left_ptr"
  spawnOnce "set_background"
  spawnOnce "trayer --edge top --align right --SetDockType true --SetPartialStrut true\
             \--expand true --width 10 --transparent true --tint 0x5f5f5f --height 18"
  spawnOnce "pulseaudio -D"
  spawnOnce "picom"
--  spawnOnce "dbus-update-activation-environment --all"
--  spawnOnce "gnome-keyring-daemon --login"
--  spawnOnce "gnome-keyring-daemon --start --components=secrets"
  spawnOnce "xscreensaver --no-splash"

myXmobarPP :: PP
myXmobarPP = def
  {
    -- TODO: In future use unicode for a bullet point not .
    ppSep             = red "  -  ",
    ppTitleSanitize   = xmobarStrip,
    ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2,
    ppHidden          = white . wrap " " "",
    ppHiddenNoWindows = lowWhite . wrap " " "",
    ppUrgent          = red . wrap (yellow "!") (yellow "!"),
    ppOrder           = \[ws, l, _, wins] -> [ws, l, wins],
    ppExtras          = [logTitles formatFocused formatUnfocused]
  }
  where
    formatFocused   = wrap (white "[") (white "]") . red . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . maroon . ppWindow

    -- Windows sould have some title, which should not exceed a sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

myManageHook :: ManageHook
myManageHook = composeAll
  [
    className =? "zenity" --> doFloat, -- All zenity dialog boxes such as winetricks are floated
    isDialog --> doFloat
  ]
    
myLayout = spacing $ tiled ||| Mirror tiled ||| Full ||| threeCol
  where
    --customGaps = gaps [(U,18), (D,18), (L,23), (R,23)]
    spacing    = spacingWithEdge winSpacing
    tiled      = Tall nmaster delta ratio
    threeCol   = magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    nmaster    = 1     -- Default number of windows in the master pane
    ratio      = 1/2   -- Default proportion of screen occupied by master pane
    delta      = 3/100 -- Percent of screen to increment by when resizing panes
