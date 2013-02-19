-- Generated by wz2lua (implementation file)
version(0) --- version of the script API this script is written for
tutState = 0
dpMovedCount = 0
-- initial power level

-- Seemingly unused translateable strings
-- m_msg14	_("Now left click the Viper Body")
-- m_msg15	_("Select the Vehicle Propulsion icon")
-- m_msge3	_("Presently unused")

-- components



-- selected droid
selDroid = nil
factoryStruc = nil
researchStruc = nil

hiddenArtefact = nil



SND_ARTIFACT_DIS = nil

-- public	SOUND		SND_TUT26;
-- public	SOUND		SND_TUT27;
-- public	SOUND	SND_TUT76;
-- public	SOUND	SND_TUT77;
-- public	SOUND	SND_TUT79;
-- public	SOUND	SND_TUT80;

-- proximity messages
SND_GEN_ART_HERE = nil
SND_RESO_HERE = nil
SND_DROIDS_REQ = nil
SND_FRIEND_LZ = nil
SND_ENEMY_LZ = nil

-- Design screen buttons

-- holder for the researchCompleted callback - can use it if we want, but not really necessary
researchDone = nil

structure = nil

-- event videoDone; // not used.. see end of file

-- -------------------------------------------------------------
-- Main entry event - performs setup and the like
function setupEvent()
	deactivateEvent(setupEvent)
	
	-- ajl: setup templates...
	tutorialTemplates()
	
	-- Set the flag to say we're in the tutorial - C Variable
	C.inTutorial = true
	
	-- Specify the initial viewing position
	centreViewPos(3840, 3840)
	
	-- Set the initial level of radar zoom
	setRadarZoom(1)
	
	-- Set up the game level variable
	C.gameLevel = 0
	
	-- Num times delivery point moved
	dpMovedCount = 0
	
	-- Remove all the reticule buttons - we don't need them
	removeReticuleButton(MANUFACTURE, true)
	removeReticuleButton(RESEARCH, true)
	removeReticuleButton(INTELMAP, true)
	removeReticuleButton(DESIGN, true)
	removeReticuleButton(BUILD, true)
	removeReticuleButton(OPTIONS, true)
	
	-- Set up our initial power level - declared in .slo file
	setPowerLevel(initialPowerValue, 0)
	
	-- Make some components available for later
	makeComponentAvailable(viperBody, 0)
	makeComponentAvailable(spade, 0)
	makeComponentAvailable(wheeledProp, 0)
	makeComponentAvailable(mg, 0)
	
	-- Flag the default sensor
	setDefaultSensor(defaultSensor, 0)
	
	-- Setup the structure limits for all structures
	setStructureLimits(factory, 1, 0)
	setStructureLimits(oilDerrick, 1, 0)
	setStructureLimits(powerGen, 1, 0)
	setStructureLimits(research, 1, 0)
	
	-- Fire off track one on the CD if it's there...
	-- playIngameCDAudio();
	-- Actually, let's keep it quiet so that we can hear the tutorial instead - Per
	stopCDAudio()
	
	-- Cam3daynight has set to cam 3 so reset to cam 1 - GJ
	setCampaignNumber(1)
	
	-- wait
	pause(20/10.0)
	
	-- needed cos you can't have a pause in CALL_GAMEINIT
	playSound(SND_TUT1, 0)
	addConsoleText(_("In this training session you'll learn how to build an effective base"), 0)
	
	-- ... and setup the first real event for action
	repeatingEvent(buildDerrick, 1.0)
end
callbackEvent(setupEvent, CALL_GAMEINIT)
-- -------------------------------------------------------------
-- First event-Sets things up for the player to build a derrick
function buildDerrick()
	tutState = 1
	
	-- wait
	pause(20/10.0)
	
	tagConsoleText(_("Oil resources are key to your success"), 0)
	-- Playsound "Oil resources are key to your success"
	playSound(SND_TUT2, 0)
	
	pause(40/10.0)
	
	-- PlaySound "To build an oil derrick, select one of your trucks"
	playSound(SND_TUT3, 0)
	
	tagConsoleText(_("To build an oil derrick, select one of your trucks"), 0)
	
	callbackEvent(truckSelected, CALL_DROID_SELECTED)
	
	-- Close this event down
	deactivateEvent(buildDerrick)
end

-- -------------------------------------------------------------
-- What to do when we get the truck selected
function truckSelected(_selDroid)
	selDroid = _selDroid -- wz2lua: probably these can be used as function arguments directly
	tutState = 2
	
	-- Allow the player to build derricks
	enableStructure(oilDerrick, 0)
	
	-- Wait..
	pause(10/10.0)
	
	addConsoleText(_("Left click the oil pool indicated by the radar pulse to order your truck to build"), 0)
	
	-- Playsound "then left click the oil pool indicated by the radar pulse"
	playSound(SND_TUT4, 0)
	
	-- Switch off this event - we don't need it anymore
	deactivateEvent(truckSelected)
end
-- -------------------------------------------------------------
-- What to do when the resource extractor has been built
function derrickBuilt()
	deactivateEvent(derrickBuilt)
	
	tutState = 3
	
	-- Wait for a wee bit...
	pause(20/10.0)
	
	addConsoleText(_("The oil derrick is currently dormant. Build a power generator to convert the oil into power"), 0)
	
	-- PlaySound "The oil derrick is currently dormant"
	playSound(SND_TUT5, 0)
	
	-- PlaySound "To extract the oil and convert it into power
	-- a power generator is needed"
	playSound(SND_TUT6, 0)
	
	-- wait...
	pause(20/10.0)
	
	-- PlaySound "Left click the flashing build icon"
	playSound(SND_TUT7, 0)
	
	pause(40/10.0)
	
	tagConsoleText(_("Left click the flashing BUILD icon"), 0)
	
	-- We want them to build a power generator now, so add the
	-- build button
	addReticuleButton(BUILD)
	
	-- Allow power generators to be built
	enableStructure(powerGen, 0)
	
	-- Set it off flashing
	flashOn(IDRET_BUILD)
end
callbackEvent(derrickBuilt, CALL_RESEX_BUILT)
-- -------------------------------------------------------------
-- Fires off when player has clicked on the build icon
function buildIconChosen()
	deactivateEvent(buildIconChosen)
	
	tutState = 4
	
	-- Stop the build icon flashing...
	flashOff(IDRET_BUILD)
	
	-- PlaySound "Now left click the power generator in the build menu"
	playSound(SND_TUT8, 0)
	
	tagConsoleText(_("Now left click the power generator in the build menu on the left"), 0)
	
	callbackEvent(buildItemChosen, CALL_BUILDGRID)
end
callbackEvent(buildIconChosen, CALL_BUILDLIST)
-- -------------------------------------------------------------
-- Fires off when we've clicked on the item in the build menu
function buildItemChosen()
	tutState = 5
	
	addConsoleText(_("Position the square at your base and left click to start the build process"), 0)
	
	-- PlaySound "Position the square at your base then left click
	-- to start the build process
	playSound(SND_TUT9, 0)
	
	-- Close event
	deactivateEvent(buildItemChosen)
end
-- -------------------------------------------------------------
-- Fires off when power station is being built
function tellToHelpBuild()
	tutState = 6
	
	addConsoleText(_("To increase your build rate, select your second truck"), 0)
	
	-- PlaySound "To increase your build rate, select your second truck"
	playSound(SND_TUT10, 0)
	
	-- Set up other trigger - conflict on droid selection?
	callbackEvent(otherUnitSelected, CALL_DROID_SELECTED)
	
	-- get rid of the build button to stop people being silly buggers
	removeReticuleButton(BUILD, true)
	
	-- Close this event
	deactivateEvent(tellToHelpBuild)
end
conditionalEvent(tellToHelpBuild, "structureBeingBuilt(powerGen, 0)", 1.0)

-- -------------------------------------------------------------
function otherUnitSelected(_selDroid)
	selDroid = _selDroid -- wz2lua: probably these can be used as function arguments directly
	tutState = 7
	
	-- Got to be the right unit - not the one already building
	conditionalEvent(correctUnit, "(selDroid.order == DORDER_NONE)", 0.5)
	
	-- Close this one
	deactivateEvent(otherUnitSelected)
end

-- -------------------------------------------------------------
function correctUnit()
	tutState = 8
	
	-- PlaySound "Now left click the power generator site
	playSound(SND_TUT11, 0)
	
	addConsoleText(_("Now left click the power generator site"), 0)
	
	-- Setup the helped-to-build event
	conditionalEvent(helpedToBuild, "(selDroid.order == DORDER_HELPBUILD)", 0.5)
	
	-- And close this one
	deactivateEvent(correctUnit)
end
-- -------------------------------------------------------------
function helpedToBuild()
	if tutState == 8 then
		tutState = 9
		
		addConsoleText(_("The other truck will now help to build the power generator"), 0)
		
		-- PlaySound "the truck will now help to build the power
		-- generator"
		playSound(SND_TUT12, 0)
		
		-- Close this event
		deactivateEvent(helpedToBuild)
	else
		clearConsole()
		deactivateEvent(helpedToBuild)
	end
end

-- -------------------------------------------------------------
-- PART TWO - Power Station has been built, by whatever means
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- Whatever - eventually they'll manage to build a power gen..?!
function powerGenBuilt()
	tutState = 10
	
	clearConsole()
	
	-- if they didn't select the other unit, oh well.
	deactivateEvent(otherUnitSelected)
	deactivateEvent(correctUnit)
	
	-- Wait for a bit
	pause(30/10.0)
	
	-- PlaySound "during missions, you need to ..."
	playSound(SND_TUT13, 0)
	addConsoleText(_("During missions you need to locate and recover technologies from before the Collapse"), 0)
	
	-- Wait a bit
	pause(40/10.0)
	
	-- PlaySound "Use a truck to search..."
	playSound(SND_TUT15, 0)
	
	-- Wait for a bit
	tagConsoleText(_("Use a truck to search for the artifact indicated by the radar pulse"), 0)
	
	pause(20/10.0)
	pause(20/10.0)
	tagConsoleText(_("Move the pointer over the artifact and left click to recover it"), 0)
	
	-- PlaySound "Move the pointer over the artifact"
	playSound(SND_TUT16, 0)
	
	-- Wait..
	pause(30/10.0)
	
	-- PlaySound "when it turns into a grabber..."
	playSound(SND_TUT17, 0)
	
	-- Add the feature to the map
	hiddenArtefact = addFeature(crate, art1X, art1Y)
	
	-- Fire off the in range event
	conditionalEvent(atArtefactSite, "droidInRange(0, hiddenArtefact.x, hiddenArtefact.y, 256)", 0.5)
	
	-- And kill this event
	deactivateEvent(powerGenBuilt)
end
callbackEvent(powerGenBuilt, CALL_POWERGEN_BUILT)
-- -------------------------------------------------------------
function atArtefactSite()
	tutState = 11
	
	-- Enable the research - premature?
	enableResearch(artefact, 0)
	
	-- Wait for a bit
	-- pause(10);
	
	-- fire off the build research centre malarky
	conditionalEvent(buildResearchCentre, "droidInRange(0, hiddenArtefact.x, hiddenArtefact.y, 128)", 0.5)
	
	-- Shut this event
	deactivateEvent(atArtefactSite)
end
-- -------------------------------------------------------------
function buildResearchCentre()
	tutState = 12
	
	addConsoleText(_("A research facility is required to research artifacts"), 0)
	
	-- Remove the artefact
	destroyFeature(hiddenArtefact)
	
	-- PlaySound "A research facility is required..."
	playSound(SND_TUT18, 0)
	
	-- Wait..
	pause(30/10.0)
	
	-- PlaySound "Left click the build icon"
	playSound(SND_TUT19, 0)
	
	tagConsoleText(_("Left click the flashing BUILD icon"), 0)
	
	-- Allow them to build research centres
	enableStructure(research, 0)
	
	-- Get the build icon back
	addReticuleButton(BUILD)
	
	-- flash the icon
	flashOn(IDRET_BUILD)
	
	-- Activate event
	callbackEvent(buildIconChosenResearch, CALL_BUILDLIST)
	
	-- close this event
	deactivateEvent(buildResearchCentre)
end
-- -------------------------------------------------------------
function buildIconChosenResearch()
	tutState = 13
	
	-- Switch off flashing...
	flashOff(IDRET_BUILD)
	
	-- PlaySound "Now left click thr research facility.."
	playSound(SND_TUT20, 0)
	
	tagConsoleText(_("Now left click the research facility and position it at your base"), 0)
	
	deactivateEvent(buildIconChosenResearch)
end
-- -------------------------------------------------------------
function rfUnderConstruction()
	tutState = 14
	
	clearConsole()
	
	-- Wait...
	pause(10/10.0)
	
	-- And get rid of it
	removeReticuleButton(BUILD, true)
	
	-- PlaySound "Use your other truck to help build..."
	playSound(SND_TUT21, 0)
	
	-- fire off this event second time on different state number - woohoo!
	conditionalEvent(helpedToBuild, "(selDroid.order == DORDER_HELPBUILD)", 0.5)
	
	addConsoleText(_("Use your other truck to help build the research facility"), 0)
	
	-- close event
	deactivateEvent(rfUnderConstruction)
end
conditionalEvent(rfUnderConstruction, "structureBeingBuilt(research, 0)", 1.0)
-- -------------------------------------------------------------
-- PART THREE - they've built a research centre!!! Whahey!
-- -------------------------------------------------------------

-- -------------------------------------------------------------
function researchCentreBuilt()
	tutState = 15
	
	-- Get the structure
	researchStruc = getStructure(research, 0)
	
	-- Wait
	pause(30/10.0)
	
	-- PlaySound "to resarch the artefact.."
	playSound(SND_TUT22, 0)
	
	-- Set the event that catches this
	callbackEvent(researchIconSelected, CALL_RESEARCHLIST)
	
	addConsoleText(_("To research the artifact, left click on the flashing RESEARCH icon"), 0)
	
	-- Better add it then
	addReticuleButton(RESEARCH)
	
	-- Set it flashing
	flashOn(RESEARCH)
	
	-- Kill this event
	deactivateEvent(researchCentreBuilt)
end
callbackEvent(researchCentreBuilt, CALL_RESEARCH_BUILT)
-- -------------------------------------------------------------
function researchIconSelected()
	tutState = 16
	
	-- stop the icon flashing
	flashOff(IDRET_RESEARCH)
	
	-- PlaySound "Now left click the icon"
	playSound(SND_TUT23, 0)
	
	tagConsoleText(_("Now left click the machinegun artifact"), 0)
	
	-- Fire up event
	conditionalEvent(artefactChosen, "not (structureIdle(researchStruc))", 0.5)
	
	-- Close this one
	deactivateEvent(researchIconSelected)
end
-- -------------------------------------------------------------
function artefactChosen()
	tutState = 17
	
	addConsoleText(_("The artifact is now being researched by the facility"), 0)
	
	-- PlaySound "the artefact will now be researched"
	playSound(SND_TUT24, 0)
	
	-- Remove the button
	removeReticuleButton(RESEARCH, true)
	
	-- Close event...
	deactivateEvent(artefactChosen)
end
-- -------------------------------------------------------------
function researchCompleted(_researchDone, _structure, _player)
	researchDone, structure = _researchDone, _structure -- wz2lua: probably these can be used as function arguments directly
	tutState = 18
	
	pause(20/10.0)
	
	-- PlaySound "the researched mg can now be used to .."
	
	playSound(SND_TUT28, 0)
	addConsoleText(_("The researched machinegun can now be used to design a new vehicle"), 0)
	
	pause(20/10.0)
	
	-- Remove intel button
	removeReticuleButton(INTELMAP, true)
	
	-- Add the design button
	addReticuleButton(DESIGN)
	
	-- Flash Icon
	flashOn(IDRET_DESIGN)
	
	-- PlaySound "Left click the deisgn icon"
	playSound(SND_TUT29, 0)
	
	pause(30/10.0)
	tagConsoleText(_("Left click the flashing DESIGN icon"), 0)
	
	-- Setup up design event
	callbackEvent(designSelected, CALL_BUTTON_PRESSED)
	
	-- Kill this event..
	deactivateEvent(researchCompleted)
end
callbackEvent(researchCompleted, CALL_RESEARCHCOMPLETED)
-- -------------------------------------------------------------
function designSelected(_button)
	if _button ~= IDRET_DESIGN then return end
	tutState = 20
	
	-- Switch off flashing
	flashOff(IDRET_DESIGN)
	
	addConsoleText(_("To start your design, left click the NEW DESIGN icon"), 0)
	
	-- PlaySound "To start your design"
	playSound(SND_TUT30, 0)
	
	-- Close this one
	deactivateEvent(designSelected)
end
-- -------------------------------------------------------------
-- they're going to clikc on the vehicle body icon
function design1(_button)
	if _button ~= NEWDESIGN_BUT then return end
	tutState = 21
	
	clearConsole()
	addConsoleText(_("Now left click the Vehicle Body icon"), 0)
	
	-- PlaySound "Now left click the vehicle body icon"
	playSound(SND_TUT31, 0)
	
	-- Kill this event.
	deactivateEvent(design1)
end
callbackEvent(design1, CALL_BUTTON_PRESSED)

-- tell them to click on the body - it's flashing
function design4(_button)
	if _button ~= BODY_BUT then return end
	tutState = 22
	
	addConsoleText(_("Then left click the Viper body"), 0)
	playSound(SND_TUT32, 0)
	
	-- Kill event
	deactivateEvent(design4)
end
callbackEvent(design4, CALL_BUTTON_PRESSED)

-- tell them to select the viper body
function design5()
	tutState = 23
	
	addConsoleText(_("Left click the Wheels icon"), 0)
	-- PlaySound "then left click the machine gun  to complete design"
	playSound(SND_TUT33, 0)
	deactivateEvent(design5)
end
callbackEvent(design5, CALL_DESIGN_BODY)

function design7()
	tutState = 27
	
	-- click the machinegun to finalise oyur design
	addConsoleText(_("Then left click the machinegun to complete your design"), 0)
	playSound(SND_TUT34, 0)
	
	deactivateEvent(design7)
end
callbackEvent(design7, CALL_DESIGN_PROPULSION)

function design3()
	playSound(SND_TUT35, 0)
	playSound(SND_TUT36, 0)
	-- Kill event
	deactivateEvent(design3)
end
callbackEvent(design3, CALL_DESIGN_WEAPON)

-- -------------------------------------------------------------
-- PART FOUR - they've designed their first droid!!!
-- -------------------------------------------------------------

-- -------------------------------------------------------------
function droidDesigned()
	tutState = 28
	
	removeReticuleButton(DESIGN, false)
	
	callbackEvent(droidCreated, CALL_DESIGN_QUIT)
	
	-- wait..
	pause(60/10.0)
	
	addConsoleText(_("To finalize your design, left click the CLOSE icon"), 0)
	
	-- 'to finalise your design'
	playSound(SND_TUT37, 0)
	
	-- flash the close button
	flashOn(IDRET_CANCEL)
	
	deactivateEvent(droidDesigned)
end
callbackEvent(droidDesigned, CALL_DROIDDESIGNED)

-- -------------------------------------------------------------
function droidCreated()
	tutState = 29
	
	clearConsole()
	
	-- Allow 'em to build factories.
	enableStructure(factory, 0)
	
	-- turn off the flashing
	flashOff(IDRET_CANCEL)
	
	-- Wait for a bit
	pause(30/10.0)
	
	addConsoleText(_("A factory is now required to manufacture your new vehicle"), 0)
	
	-- PlaySound "A factory is now required to build..."
	playSound(SND_TUT38, 0)
	
	-- Wait for a bit...
	pause(20/10.0)
	
	-- PlaySound "Left click the build icon"
	playSound(SND_TUT39, 0)
	pause(20/10.0)
	
	tagConsoleText(_("Left click the flashing BUILD icon"), 0)
	
	-- Add the reticule button
	addReticuleButton(BUILD)
	
	-- Start it flashing
	flashOn(IDRET_BUILD)
	
	-- Start next event
	callbackEvent(buildSelectedFactory, CALL_BUILDLIST)
	
	-- Kill this event
	deactivateEvent(droidCreated)
end
-- -------------------------------------------------------------
function buildSelectedFactory()
	tutState = 30
	
	-- playSound "Now left click the factory"
	playSound(SND_TUT40, 0)
	
	tagConsoleText(_("Now left click the factory icon and position it at your base"), 0)
	
	-- Setup next event
	callbackEvent(buildIconChosenFactory, CALL_BUILDGRID)
	
	-- Kill this event
	deactivateEvent(buildSelectedFactory)
end

-- -------------------------------------------------------------
function buildIconChosenFactory()
	tutState = 31
	
	-- Stop icon flashing
	flashOff(IDRET_BUILD)
	
	-- Playsound - now position it at your base
	playSound(SND_TUT41, 0)
	
	addConsoleText(_("Select a location for your factory"), 0)
	
	-- kill event
	deactivateEvent(buildIconChosenFactory)
end
-- -------------------------------------------------------------
function factoryChosen()
	tutState = 32
	
	clearConsole()
	
	pause(10/10.0)
	
	-- Remove build button
	removeReticuleButton(BUILD, true)
	
	playSound(SND_TUT42, 0)
	pause(10/10.0)
	addConsoleText(_("The delivery point is indicated by the number 1"), 0)
	pause(20/10.0)
	playSound(SND_TUT43, 0)
	tagConsoleText(_("All new units will drive to this location once built"), 0)
	pause(40/10.0)
	tagConsoleText(_("You can move the delivery point at any time by left clicking it"), 0)
	playSound(SND_TUT44, 0)
	
	-- Kill event
	deactivateEvent(factoryChosen)
end
conditionalEvent(factoryChosen, "structureBeingBuilt(factory, 0)", 1.0)
-- -------------------------------------------------------------
function delivPointMoved()
	if dpMovedCount == 0 then
		tutState = 33
		dpMovedCount = 1
		playSound(SND_TUT45, 0)
		tagConsoleText(_("Now click where you want to position the delivery point"), 0)
	else
		if tutState == 33 then
			clearConsole()
		end
	end
end
callbackEvent(delivPointMoved, CALL_DELIVPOINTMOVED)
-- -------------------------------------------------------------
function factoryBuilt()
	tutState = 34
	
	addConsoleText(_("The factory can now be ordered to build a new unit"), 0)
	
	-- get a handle to the built structure
	factoryStruc = getStructure(factory, 0)
	
	-- Wait...
	pause(30/10.0)
	
	-- PlaySound "Manufactre a viper"
	playSound(SND_TUT47, 0)
	
	-- wait..
	pause(10/10.0)
	
	-- Add the manufacture icon
	addReticuleButton(MANUFACTURE)
	
	-- Setup event trigger
	callbackEvent(manufactureChosen, CALL_MANULIST)
	
	-- Flash the manufacture button
	flashOn(IDRET_MANUFACTURE)
	
	-- PlaySound "Left click the flashing manufacture icon"
	playSound(SND_TUT48, 0)
	
	tagConsoleText(_("Left click the flashing MANUFACTURE icon"), 0)
	
	-- Kill this event
	deactivateEvent(factoryBuilt)
end
callbackEvent(factoryBuilt, CALL_FACTORY_BUILT)
-- -------------------------------------------------------------
function manufactureChosen()
	tutState = 35
	
	-- Stop flashing
	flashOff(IDRET_MANUFACTURE)
	
	-- Play sound "now in te build list..."
	playSound(SND_TUT49, 0)
	
	playSound(SND_TUT50, 0)
	
	tagConsoleText(_("Now left click the units you want to build from the menu at the left"), 0)
	
	-- Set off next event
	conditionalEvent(manufactureIconChosen, "not (structureIdle(factoryStruc))", 0.5)
	
	-- Kill this one...
	deactivateEvent(manufactureChosen)
end
-- -------------------------------------------------------------
function manufactureIconChosen()
	tutState = 36
	
	addConsoleText(_("Please wait whilst the factory manufactures the new unit(s)"), 0)
	
	-- playSoundHere
	playSound(SND_TUT52, 0)
	
	deactivateEvent(manufactureIconChosen)
end
-- -------------------------------------------------------------
-- PART FIVE - They've built their first droid.
-- -------------------------------------------------------------

function firstDroidBuilt()
	tutState = 37
	
	-- Remove Button
	removeReticuleButton(MANUFACTURE, true)
	
	-- playVideo((TEXTSTRING)"factory.ogg", NULLSTRING); // we don't have cut-scenes, to this would cause the bare sky-box to be shown
	
	-- #REGION copied from videoDone(...)
	pause(20/10.0)
	playSound(SND_TUT81, 0)
	addConsoleText(_("Congratulations commander - you are ready for your first mission"), 0)
	pause(80/10.0)
	gameOver(true)
	-- #END-REGION
	
	deactivateEvent(firstDroidBuilt)
end
callbackEvent(firstDroidBuilt, CALL_DROIDBUILT)


---------- stubs ----------

if makeComponentAvailable == nil then makeComponentAvailable = function() print("stub: makeComponentAvailable"); return 0 end end
if enableResearch == nil then enableResearch = function() print("stub: enableResearch"); return 0 end end
if flashOff == nil then flashOff = function() print("stub: flashOff"); return 0 end end
if tutorialTemplates == nil then tutorialTemplates = function() print("stub: tutorialTemplates"); return 0 end end
if addFeature == nil then addFeature = function() print("stub: addFeature"); return 0 end end
if droidInRange == nil then droidInRange = function() print("stub: droidInRange"); return 0 end end
if setEventTrigger == nil then setEventTrigger = function() print("stub: setEventTrigger"); return 0 end end
if destroyFeature == nil then destroyFeature = function() print("stub: destroyFeature"); return 0 end end
if getStructure == nil then getStructure = function() print("stub: getStructure"); return 0 end end
if setStructureLimits == nil then setStructureLimits = function() print("stub: setStructureLimits"); return 0 end end
if setPowerLevel == nil then setPowerLevel = function() print("stub: setPowerLevel"); return 0 end end
if removeReticuleButton == nil then removeReticuleButton = function() print("stub: removeReticuleButton"); return 0 end end
if addReticuleButton == nil then addReticuleButton = function() print("stub: addReticuleButton"); return 0 end end
if setDefaultSensor == nil then setDefaultSensor = function() print("stub: setDefaultSensor"); return 0 end end
if pause == nil then pause = function() print("stub: pause"); return 0 end end
if playSound == nil then playSound = function() print("stub: playSound"); return 0 end end
if addConsoleText == nil then addConsoleText = function() print("stub: addConsoleText"); return 0 end end
if _ == nil then _ = function() print("stub: _"); return 0 end end
if tagConsoleText == nil then tagConsoleText = function() print("stub: tagConsoleText"); return 0 end end
if flashOn == nil then flashOn = function() print("stub: flashOn"); return 0 end end
if setRadarZoom == nil then setRadarZoom = function() print("stub: setRadarZoom"); return 0 end end
if structureBeingBuilt == nil then structureBeingBuilt = function() print("stub: structureBeingBuilt"); return 0 end end
if structureIdle == nil then structureIdle = function() print("stub: structureIdle"); return 0 end end
if stopCDAudio == nil then stopCDAudio = function() print("stub: stopCDAudio"); return 0 end end
if enableStructure == nil then enableStructure = function() print("stub: enableStructure"); return 0 end end
if gameOver == nil then gameOver = function() print("stub: gameOver"); return 0 end end
if centreViewPos == nil then centreViewPos = function() print("stub: centreViewPos"); return 0 end end
if clearConsole == nil then clearConsole = function() print("stub: clearConsole"); return 0 end end
if setCampaignNumber == nil then setCampaignNumber = function() print("stub: setCampaignNumber"); return 0 end end