package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import haxe.Json;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxCamera;
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
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.addons.display.FlxBackdrop;
import Achievements;
import editors.MasterEditorMenu;
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

class MainMenuState extends MusicBeatState
{
	public static var AyedVersion:String = 'DEMO';
	public static var AyedEngineVersion:String = '2.0'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	public static var creditsBG:Array<Array<String>> = [['Jake_Official', 'https://x.com/Jake_Official00'], ['PryoMania', 'https://www.youtube.com/channel/UCFSSXfpYCSP-fIbtTCVhoOA']];

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	/*
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'options'
	];
	*/

	// shit item
	var menushittyList:Array<String> = ['freeplay', 'credits', 'options'];
	public static var loadImg:FlxGraphicAsset;
	public var scrImg:String;
	var sumShit:FlxText;
	// shit done item

	var velocityBG:FlxBackdrop;
	var magenta:FlxSprite;
	var shitJson:MainMenuEditor;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		FlxG.mouse.visible = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		shitJson = Json.parse(Paths.getTextFromFile('images/JsonFileGame/shitJson.json'));

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		scrImg = "WallpaperBgMainMenu/menuBG";

		loadImg = Paths.image(scrImg + FlxG.random.int(1, 5));

		var yScroll:Float = Math.max(0.25 - (0.05 * (4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80);
		bg.loadGraphic(loadImg);
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		velocityBG = new FlxBackdrop(Paths.image('velocityBG'));
		velocityBG.alpha = 0.2;
		velocityBG.velocity.set(50, 50);
		add(velocityBG);

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...menushittyList.length)
		{
			// var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, 130);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.loadGraphic(Paths.image("MainMenuItem/" + menushittyList[i]));
			/*No Animation Until Next Version
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + menushittyList[i]);
			menuItem.animation.addByPrefix('idle', menushittyList[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', menushittyList[i] + " white", 24);
			menuItem.animation.play('idle');
			*/
			menuItem.ID = i;
			// menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (menushittyList.length - 4) * 0.135;
			if(menushittyList.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			if(FlxG.mouse.overlaps(menuItem)){
				FlxG.mouse.load(("assets/images/input/overlapsCursor.png"), 1);
			}else{
				FlxG.mouse.load(("assets/images/input/cursor.png"), 1);
			}

			switch(menushittyList[i]){
				case "freeplay":
					menuItem.setPosition(shitJson.secondItemX, shitJson.secondItemY);
				case "credits":
					menuItem.setPosition(shitJson.threeItemX, shitJson.threeItemY);
				case "options":
					menuItem.setPosition(shitJson.fourItemX, shitJson.fourItemY);
			}
		}

		// FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "VS AYED V " + AyedVersion, 12);
		versionShit.color = 0x1900FF;
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.CYAN, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' V" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.PINK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		sumShit = new FlxText(0, 0, 0, "", 32);
		sumShit.updateHitbox();
		sumShit.text = "Click On Shift To See The Credits Of Menu BackGround";
		sumShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT);
		add(sumShit);


		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
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

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			for(what in menuItems.members){
				if(FlxG.mouse.overlaps(what)){

					curSelected = menuItems.members.indexOf(what);

					if(FlxG.mouse.pressed){
						selectedSomethin = true;

						FlxG.sound.play(Paths.sound('confirmMenu'), 1);
	
						var chooseItem:String = menushittyList[curSelected];

						switch(chooseItem){
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new options.OptionsState());
								// cookkiieesssss so fuck me so bad aahhhh
						}
					}
				}
			}

			if(FlxG.keys.justPressed.SHIFT){
				trace("fucking hates tween's groups shit");
				FlxG.sound.play(Paths.sound("confirmMenu"));
				
				FlxTween.tween(FlxG.camera, {'zoom': 1.5, 'alpha': 0.4}, 2, {ease:FlxEase.circOut, onComplete:function(twnShit:FlxTween){
					openSubState(new BackGroundCredits());
					twnShit.destroy();
				}});

				// openSubState(new BackGroundMenu()); but wait a second :skull:
			}

			

			/*
			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			*/
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}

typedef BackGroundCreditsTypeDef = {
	textCredX:Float,
	textCredY:Float,
	textAlpha:String
}

class BackGroundCredits extends MusicBeatSubstate{
	var bgCredits:FlxSprite;
	var alphabetC:Alphabet;
	var bg:FlxSprite;
	var bgShit:FlxSprite;
	var shitJson:BackGroundCreditsTypeDef;
	var alphabetN:Alphabet;

	override function create(){
		FlxG.mouse.visible = true;

		shitJson = Json.parse(Paths.getTextFromFile("images/JsonFileGame/BackgroundCreditsSetting.json", true));
		
		#if desktop
		trace("sometime i hates coding like FUCK");
		DiscordClient.changePresence("In the Credits BackGround Main Menu", null);
		#end

		bgShit = new FlxSprite(0, 0);
		bgShit.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgShit.alpha = 0.5;
		add(bgShit);
		trace("Background Added");

		bgCredits = new FlxSprite(0, 50);
		bgCredits.loadGraphic(MainMenuState.loadImg);
		bgCredits.updateHitbox();
		bgCredits.screenCenter();
		add(bgCredits);

		alphabetC = new Alphabet(shitJson.textCredX, shitJson.textCredY, "", true);
		if(shitJson.textAlpha == null){
			alphabetC.text = "";
		}else{
			alphabetC.text = shitJson.textAlpha;
		}
		alphabetC.alpha=1;
		alphabetC.updateHitbox();
		add(alphabetC);

		super.create();
	}

	override function update(elapsed:Float){
		if(FlxG.keys.justPressed.ESCAPE){
			close();
		}	
		super.update(elapsed);
	}
}