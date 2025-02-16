import Xmobar

config :: Config
config = defaultConfig {
  font = "xft:Sans Mono-9:size=18",
  additionalFonts = [],
  borderColor = "black",
  border = TopB,
--  bgColor = "#5f3f3f",
  bgColor = "#000f0b",
  fgColor = "#f8f8f2",
  position = TopH 30,
  overrideRedirect = False,
  commands = [ Run $ Weather "KHUF" 
                     [ "--template", "<stationState>: <tempF>F",
		       "-L", "65", "-H", "80",
		       "--normal", "green",
		       "--high", "red",
		       "--low", "lightblue" ] 36000,
	       Run $ Cpu
	             [ "-L", "3",
		       "-H", "50",
		       "--high", "red",
		       "--normal", "green"
		     ] 10,
	       Run $ Com "volume" [] "vol" 1,
	       Run $ BatteryP ["BAT0"]
	             [ "-t", "<acstatus>",
		       "-L", "25", "-H", "75",
		       "-l", "red", "-h", "green",
		       "--", "-O", "Bat:+<left>%", "-o", "Bat: <left>%"
		     ] 10,
	       Run $ Memory [ "--template", "Mem: <usedratio>%" ] 10,
	       Run $ Swap [] 10,
	       Run $ Date "%a %m-%d-%Y <fc=#8be9fd>%l:%M%P</fc>" "date" 10,
	       Run $ XMonadLog
	     ],
  sepChar = "%",
  alignSep = "}{",
  template  = "%XMonadLog% } <fc=#f30000>|</fc> %date% <fc=#f30000>|</fc> \
  				\{ %KHUF% <fc=#f30000>|</fc> Vol: %vol% <fc=#f30000>|</fc> %cpu% <fc=#f30000>|</fc> %memory% <fc=#f30000>-</fc> %swap% \
				\ <fc=#f30000>|</fc> \
				\%battery% "
}

--				\%disku% <fc=#ff79c6>|</fc> \
main :: IO ()
main = configFromArgs config >>= xmobar
