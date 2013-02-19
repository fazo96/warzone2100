-- Generated by wz2lua (data file)
version(0) -- version of the script API this script is written for
-- slo: "basic.slo"



-- a script to run
-- structures
babaBunker = "A0BaBaBunker"
babaCorner = "A0BabaCornerWall"
babFactory = "A0BaBaFactory"
babaTower = "A0BaBaGunTower"
babWall = "A0BaBaHorizontalWall"
babaPower = "A0BaBaPowerGenerator"
babaRocket = "A0BaBaRocketPit"
command = "A0CommandCentre"
factory = "A0LightFactory"
wall = "A0HardcreteMk1Wall"
cornerWall = "A0HardcreteMk1CWall"
oilderrick = "A0ResourceExtractor"
powerGen = "A0PowerGenerator"
research = "A0ResearchFacility"

-- components
viperBody = "Body1REC"
howitzerBody = "Body5REC"
missileBody = "Body2SUP"
trikeBody = "B4body-sml-trike01"
buggyBody = "B3body-sml-buggy01"
babaBody = "B1BaBaPerson01"

machineGun = getWeapon("MG1Mk1")

spade = "Spade1Mk1"

-- ecm				ECM				"ECM1PylonMk1"
defaultSensor = "DefaultSensor1Mk1"

wheeledProp = "wheeled01"
trackProp = "tracked01"
babaProp = "BaBaProp"

--run the code
dofile('basic_logic.lua')