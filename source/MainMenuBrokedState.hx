package;

/**
 * Yo Buddy This File Is Not In Game So Um You Know That BackGround Shit Broked the State File So Yeah Move To The MainMenuState
 */

import haxe.Constraints.FlatEnum;
import openfl.sensors.Accelerometer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.group.FlxGroup;
import haxe.Json;
import flixel.FlxObject;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.util.FlxTimer;
import Achievements;
import editors.MasterEditorMenu;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.input.keyboard.FlxKey;

using StringTools;

typedef MainMenuEditor = {
	secondItemX:Float,
	secondItemY:Float,
	threeItemX:Float,
	threeItemY:Float,
	fourItemX:Float,
	fourItemY:Float,
	creditsBgIconX:Float,
	creditsBgIconY:Float,
	middleCenterPressedX:Float,
	middleCenterPressedY:Float,
	visibleMouse:Bool
}

class MainMenuState extends MusicBeatState {
	public static var AyedVersion:String = '1.5.0';
	public static var AyedEngineVersion:String = '1.5.0'; // This is also used for Discord RPC
	// public static var psychEngineVersion:String = '0.6.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static inline var BG_COLOR:FlxColor = 0xDDF700FF;
	public static var creditsBg:Array<Array<String>> = [["PryoMania", "https://www.youtube.com/channel/UCFSSXfpYCSP-fIbtTCVhoOA"], ["Jake_Official", ""], [], [], []];
	public static var doesit:Bool = false;
	var grpBg:FlxGroup;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	var shitJson:MainMenuEditor;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'Discord',
		// 'Gallery',
		'credits',
		'options',
		'Quit'
	];

	// var logo:FlxSprite;
	var magenta:FlxSprite;
	var velocityBG:FlxBackdrop;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var timer:FlxTimer;
	public var secondItem:FlxSprite;
	public var threeItem:FlxSprite;
	public var fourItem:FlxSprite;
	var creditsBgIcon:FlxSprite;
	public var bgShit:FlxSprite;
	public static var emotionalDamage:FlxGraphicAsset;
	public static var loadBgImg:String;

	override function create() {
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Main Menu", null);
		#end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		shitJson = Json.parse(Paths.getTextFromFile('images/JsonFileGame/shitJson.json'));

		FlxG.mouse.visible = true;

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		// logo = new FlxSprite(500, 0);
		// logo.frames = Paths.getSparrowAtlas('logoBumpin');

		// logo.antialiasing = ClientPrefs.globalAntialiasing;
		// logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		// logo.animation.play('bump');
		// logo.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;
		// add(logo);

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		
		emotionalDamage = Paths.image(loadBgImg);
		loadBgImg = "MainMenuBackGround/menuBG" + FlxG.random.int(1, 5);

		bgShit = new FlxSprite(-80).loadGraphic(emotionalDamage);
		bgShit.scrollFactor.set(0, yScroll);
		bgShit.setGraphicSize(Std.int(bgShit.width * 1.175));
		bgShit.updateHitbox();
		bgShit.screenCenter();
		bgShit.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgShit);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuBG' + FlxG.random.int(1, 5)));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		velocityBG = new FlxBackdrop(Paths.image('velocityBG'));
		velocityBG.velocity.set(50, 50);
		add(velocityBG);

		if(ClientPrefs.highGPU)
		{
			remove(velocityBG);
			// cancelTween();
			FlxG.camera.follow(camFollowPos, null, 0);
		}

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		// add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		/* old shit version v1.5

		for (i in 0...optionShit.length) {
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.x = 100;
			// menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			// menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			switch (i) {
				case 0:
					menuItem.setPosition(130, 50);
				case 1:
					menuItem.setPosition(270, 185);
				case 2:
					menuItem.setPosition(350, 315);
				case 3:
					menuItem.setPosition(490, 460);
				case 4:
					menuItem.setPosition(600, 600);
				case 5:
					menuItem.setPosition(-100, 700);
			}
		}

		*/

		// here the new version the item

		creditsBgIcon = new FlxSprite(shitJson.creditsBgIconX, shitJson.creditsBgIconY).loadGraphic(Paths.image("MainMenuItem/credits"));
		creditsBgIcon.updateHitbox();
		creditsBgIcon.antialiasing = ClientPrefs.globalAntialiasing;
		add(creditsBgIcon);

		FlxTween.tween(creditsBgIcon, {y: -300, x: 150}, 2, {ease:FlxEase.circOut, type: PINGPONG});

		secondItem = new FlxSprite(shitJson.secondItemX, shitJson.secondItemY).loadGraphic(Paths.image("MainMenuItem/freeplay"));
		secondItem.updateHitbox();
		secondItem.antialiasing = ClientPrefs.globalAntialiasing;
		add(secondItem);

		threeItem = new FlxSprite(shitJson.threeItemX, shitJson.threeItemY).loadGraphic(Paths.image("MainMenuItem/credits"));
		threeItem.updateHitbox();
		threeItem.antialiasing = ClientPrefs.globalAntialiasing;
		add(threeItem);

		fourItem = new FlxSprite(shitJson.fourItemX, shitJson.fourItemY).loadGraphic(Paths.image("MainMenuItem/options"));
		fourItem.updateHitbox();
		fourItem.antialiasing = ClientPrefs.globalAntialiasing;
		add(fourItem);


		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShitA:FlxText = new FlxText(12, FlxG.height - 64, 0, "Vs Ayed EDITION V" + AyedVersion, 15);
		versionShitA.color = 0x4677FF;
		versionShitA.scrollFactor.set();
		versionShitA.setFormat("VCR OSD Mono", 16, FlxColor.CYAN, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShitA);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Ayed Engine V" + AyedEngineVersion, 12);
		versionShit.color = 0x1900FF;
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.CYAN, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.PINK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		// changeItem();		if(doesit){

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { // It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievementA() {
		add(new AchievementObject('Secret_Song', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "Secret_Song"');
	}
	#end

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievementUi() {
		add(new AchievementObject('MainMenuUi', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "MainMenuUi"');
	}
	#end

	var selectedSomethin:Bool = false;
	var middleCenterX:Float; // first one is x
	var middleCenterY:Float; //this one goes y
	var buttonShit:FlxButton;
	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		doesit = false;

		middleCenterX = shitJson.middleCenterPressedX;
		middleCenterY = shitJson.middleCenterPressedY;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		
		/*
		if(FlxG.mouse.overlaps(bgShit)){
			if(FlxG.mouse.justPressed){
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound("confirmMenu"));
				FlxTween.tween(bgShit, {'alpha': 0.2}, 1.5, {ease:FlxEase.circOut});
				FlxTween.tween(velocityBG, {'alpha': 0.1}, 1.5, {ease:FlxEase.circOut});
				FlxTween.tween(secondItem, {'alpha': 0}, 1.5, {ease:FlxEase.circOut, onComplete:function(twn){secondItem.visible = false;}});
				FlxTween.tween(threeItem, {'alpha': 0}, 1.5, {ease:FlxEase.circOut, onComplete:function(twnS){threeItem.visible = false;}});
				FlxTween.tween(fourItem, {'alpha': 0}, 1.5, {ease:FlxEase.circOut, onComplete:function(twnS){fourItem.visible = false;}});
				FlxTween.tween(FlxG.camera, {'zoom': 1.3}, 1, {ease:FlxEase.circInOut});
				openSubState(new BackGroundSubState());
				FlxTween.tween(secondItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){secondItem.visible = true;}});
				FlxTween.tween(threeItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){threeItem.visible = true;}});
				FlxTween.tween(fourItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){fourItem.visible = true;}});
				FlxTween.tween(FlxG.camera, {'zoom': 1}, 1.3, {ease:FlxEase.circOut});
				FlxTween.tween(bgShit, {'alpha': 1}, 1.5, {ease:FlxEase.circOut});
				FlxTween.tween(velocityBG, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onComplete:function(wtf){velocityBG.velocity.set(50, 50);
				wtf.destroy();
				}});
			}
		}*/

		if(doesit){
			trace("tweens starting");
			FlxTween.tween(secondItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){secondItem.visible = true;}});
			FlxTween.tween(threeItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){threeItem.visible = true;}});
			FlxTween.tween(fourItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){fourItem.visible = true;}});
			FlxTween.tween(FlxG.camera, {'zoom': 1}, 1.3, {ease:FlxEase.circOut});
			FlxTween.tween(bgShit, {'alpha': 1}, 1.5, {ease:FlxEase.circOut});
			FlxTween.tween(velocityBG, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onComplete:function(wtf){velocityBG.velocity.set(50, 50);
			wtf.destroy();
			}});
			trace("tweens end");
			doesit = false;
			trace("and doesit bool unfalsed");
		}else{
			// Null Object Refence
			// return;
		}

		if (!selectedSomethin) {
				FlxG.mouse.wheel;
			if (FlxG.mouse.overlaps(secondItem)){
				if(FlxG.mouse.pressed){
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound("confirmMenu"));
					FlxTween.tween(FlxG.camera, {zoom: 1.4}, 2, {ease:FlxEase.circInOut});
					FlxTween.tween(secondItem, {x: middleCenterX, 'y': middleCenterY}, 1, {ease:FlxEase.circInOut});
					FlxTween.tween(threeItem, {alpha: 0}, 1, {ease:FlxEase.circInOut, onComplete:function(bro)(threeItem.visible = false)});
					FlxTween.tween(fourItem, {alpha: 0}, 1, {ease:FlxEase.circInOut, onComplete:function(what){
						fourItem.visible = false;
						MusicBeatState.switchState(new FreeplayState());
					}});
				}
			}
			if (FlxG.mouse.overlaps(threeItem)){
				// camFollowPos.setPosition(threeItem.x, threeItem.y);
				if(FlxG.mouse.pressed){
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound("confirmMenu"));
					FlxTween.tween(threeItem, {x: middleCenterX, 'y': middleCenterY}, 1, {ease:FlxEase.circInOut});
					FlxTween.tween(secondItem, {alpha: 0}, 1, {ease:FlxEase.circInOut, onComplete:function(bro)(secondItem.visible = false)});
					FlxTween.tween(fourItem, {alpha: 0}, 1, {ease:FlxEase.circInOut, onComplete:function(what){
						fourItem.visible = false;
						MusicBeatState.switchState(new CreditsState());
					}});
				}
			}
			if (FlxG.mouse.overlaps(fourItem)){
				// selectedSomethin = false;
				if (FlxG.mouse.pressed) {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound("confirmMenu"));
					FlxTween.tween(fourItem, {x: middleCenterX, 'y': middleCenterY}, 1, {ease:FlxEase.circInOut});
					FlxTween.tween(threeItem, {alpha: 0}, 1, {ease:FlxEase.circInOut, onComplete:function(bro)(threeItem.visible = false)});
					FlxTween.tween(secondItem, {alpha: 0}, 1, {ease:FlxEase.circInOut, onComplete:function(what){
						secondItem.visible = false;
						MusicBeatState.switchState(new options.OptionsState());
					}});
				}
			}

			// var scanImg = Paths.image(imgLoAD);
			// var imgLoAD:String = "";

			
			/*
			if(grpBg == null){
				if(FlxG.keys.justPressed.SPACE){
					remove(grpBg);
					FlxTween.tween(secondItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){secondItem.visible = true;}});
					FlxTween.tween(threeItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){threeItem.visible = true;}});
					FlxTween.tween(fourItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){fourItem.visible = true;}});
					FlxTween.tween(FlxG.camera, {'zoom': 1}, 1.3, {ease:FlxEase.circOut});
					FlxTween.tween(bg, {'alpha': 1}, 1.5, {ease:FlxEase.circOut});
					FlxTween.tween(velocityBG, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onComplete:function(wtf){velocityBG.velocity.set(50, 50);
					wtf.destroy();
					}});
				}
			} 
			*/

			if(FlxG.mouse.overlaps(creditsBgIcon)){
				if(FlxG.mouse.justPressed){
					FlxG.mouse.visible = false; // the mouse freak me out
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound("confirmMenu"));
					FlxTween.tween(bgShit, {'alpha': 0.2}, 1.5, {ease:FlxEase.circOut});
					FlxTween.tween(velocityBG, {'alpha': 0.1}, 1.5, {ease:FlxEase.circOut});
					FlxTween.tween(secondItem, {'alpha': 0}, 1.5, {ease:FlxEase.circOut, onComplete:function(twn){secondItem.visible = false;}});
					FlxTween.tween(threeItem, {'alpha': 0}, 1.5, {ease:FlxEase.circOut, onComplete:function(twnS){threeItem.visible = false;}});
					FlxTween.tween(fourItem, {'alpha': 0}, 1.5, {ease:FlxEase.circOut, onComplete:function(twnS){fourItem.visible = false;}});
					FlxTween.tween(FlxG.camera, {'zoom': 1.3}, 1, {ease:FlxEase.circInOut});
					trace("Tweens Is Done Now !!!! Next Is State");
					openSubState(new BackGroundSubState());
					if(closeSubState){
						trace("tweens starting");
						FlxTween.tween(secondItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){secondItem.visible = true;}});
						FlxTween.tween(threeItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){threeItem.visible = true;}});
						FlxTween.tween(fourItem, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onStart:function(twnStart){fourItem.visible = true;}});
						FlxTween.tween(FlxG.camera, {'zoom': 1}, 1.3, {ease:FlxEase.circOut});
						FlxTween.tween(bgShit, {'alpha': 1}, 1.5, {ease:FlxEase.circOut});
						FlxTween.tween(velocityBG, {'alpha': 1}, 1.5, {ease:FlxEase.circOut, onComplete:function(wtf){velocityBG.velocity.set(50, 50);
						wtf.destroy();
						}});
						trace("tweens end");
					}else{
						// nothing
					}
					// onCloseStateBg(true);
			}else{
				if (controls.BACK) {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new TitleState());
				}				
			}

			if (FlxG.keys.justPressed.F7) {		
				PlatformUtil.sendWindowsNotification("Secret Song Complete", "Your Open The Secret Song 0w0 \n
don't cheating -w-''", 0);
				FlxG.camera.shake(0.005, 0.1);
				#if ACHIEVEMENTS_ALLOWED
				// Achievements.loadAchievement();
				var achieveIDsong:Int = Achievements.getAchievementIndex('Secret_Song');
				if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveIDsong][2])) { 
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveIDsong][2], true);
				giveAchievementA();
				ClientPrefs.saveSettings();
				}
				#end
				FlxG.camera.flash(FlxColor.CYAN, 1);
				FlxG.mouse.visible = true;
				PlayState.SONG = Song.loadFromJson('HELL-ON', 'HELL-ON');
				PlayState.isStoryMode = false;
				LoadingState.loadAndSwitchState(new PlayState());
			}
			if (FlxG.keys.justPressed.F10) {
				#if ACHIEVEMENTS_ALLOWED
					var mainMenuUiID:Int = Achievements.getAchievementIndex('MainMenuUi');
					if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[mainMenuUiID][2])) { // It's a mainmenuui weeeeeeeeeeeeeeeeee again
					Achievements.achievementsMap.set(Achievements.achievementsStuff[mainMenuUiID][2], true);
					giveAchievementUi();
					ClientPrefs.saveSettings();
				}
				#end
				FlxG.sound.play(Paths.sound('confirmMenu'));
				MusicBeatState.switchState(new MainMenuUi());
				}
			}
			// #if desktop
			// else if (FlxG.keys.anyJustPressed(debugKeys))
			// {
			//	selectedSomethin = true;
			//	MusicBeatState.switchState(new MasterEditorMenu());
			// }
			// #end
			super.update(elapsed);
		}

	function changeItem(huh:Int = 0) {
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected) {
				spr.animation.play('selected');
				var add:Float = 0;
				if (menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				spr.centerOffsets();
			}
			});	
		}
	}
}

typedef BackGroundSetting = {
	blackBgX:Float,
	blackBgY:Float,
	blackBgWidth:Int,
	blackBgHeight:Int,
	bgX:Float,
	bgY:Float,
	alphabetX:Float,
	alphabetY:Float,
}

class BackGroundSubState extends MusicBeatSubstate
{
	var grpShit:FlxGroup;
	var namePerson:Alphabet;
	var bg:FlxSprite;
	var bgScript:BackGroundSetting;

	override function create(){
		FlxG.mouse.visible = true;

		bgScript = Json.parse(Paths.getTextFromFile("images/JsonFileGame/backGroundScriptX.json"));

		var bgReturn:FlxSprite = new FlxSprite(-500, -500);
		bgReturn.makeGraphic(bgScript.blackBgHeight, bgScript.blackBgWidth, FlxColor.BLACK);
		bgReturn.alpha = 0.3;
		bgReturn.updateHitbox();
		add(bgReturn);

		bg = new FlxSprite(-500, -500);
		// bg.loadGraphic(MainMenuState.emotionalDamage);
		bg.updateHitbox();
		bg.screenCenter();
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;

		namePerson = new Alphabet(bgScript.alphabetX, bgScript.alphabetY);
		// namePerson.screenCenter(Y);
		namePerson.alpha = 1;
		namePerson.updateHitbox();
		
		grpShit = new FlxGroup();
		add(grpShit);
		
		add(bg);

		add(namePerson);
		// namePerson = new Alphabet(0, 0, "", true);

		switch(MainMenuState.loadBgImg){
			case "menuBG1":
				namePerson.text = MainMenuState.creditsBg[0][0];
				bg.loadGraphic(Paths.image("menuBG1"));
			case "menuBG2":
				namePerson.text = MainMenuState.creditsBg[1][0];
				bg.loadGraphic(Paths.image("menuBG2"));
			case "menuBG3":
				namePerson.text = MainMenuState.creditsBg[2][0];
				bg.loadGraphic(Paths.image("menuBG3"));
			case "menuBG4":
				namePerson.text = MainMenuState.creditsBg[3][0];
				bg.loadGraphic(Paths.image("menuBG4"));
			case "menuBG5":
				namePerson.text = MainMenuState.creditsBg[4][0];
				bg.loadGraphic(Paths.image("menuBG5"));
		}
		super.create();
	}
	override function update(elapsed:Float){
		if(FlxG.keys.justPressed.ENTER){
			switch(MainMenuState.loadBgImg){
				case "menuBG1":
					FlxG.openURL(MainMenuState.creditsBg[1][2]);
				case "menuBG2":
					FlxG.openURL(MainMenuState.creditsBg[2][2]);
				case "menuBG3":
					FlxG.openURL(MainMenuState.creditsBg[3][2]);
				case "menuBG4":
					FlxG.openURL(MainMenuState.creditsBg[4][2]);			
				case "menuBG5":
					FlxG.openURL(MainMenuState.creditsBg[5][2]);	
			}
		}
		if(FlxG.keys.justPressed.ESCAPE){
			remove(bg);
			remove(namePerson);
			remove(grpShit);
			close();
			MainMenuState.doesit = true;
			if(MainMenuState.doesit){trace("so It's True Like It's Working On It");}else{trace("Welp Fuck It's False");}
			trace("Complete To Close State !!!!");
		}
		super.update(elapsed);
	}
}