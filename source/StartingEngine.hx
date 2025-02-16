package;

import haxe.display.Protocol.FileParams;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;

class StartingEngine extends MusicBeatState
{
    var velocityBG:FlxBackdrop;
    var startingText:FlxText;
    var understand:FlxText;

    override function create() 
    {
        #if mobile
        FlxG.mouse.visible = true;
        #end

        PlatformUtil.sendWindowsNotification("Thanks For Download", "Loading Assets Game ...", 3);

        FlxG.sound.playMusic(Paths.music('MusicCredits'), 1);

		velocityBG = new FlxBackdrop(Paths.image('velocityBG'));
		velocityBG.velocity.set(50, 50);
		add(velocityBG);

        startingText = new FlxText(0, 0, 0, '       Yo Player ! This Mods Is May Be Some Assets Not Completed Yet \n
        cuz your running as DEMO version Mods And Version Engine Is 2.0\n
        Flash Warning | Bit Loader Song | Some Bug May Be Fixed In Next Version \n
        Hope Ya Enjoy The Mods And Engine And Thank You For Downloading It !!!!\n
        Press Space To Join Discord Server Developer Engine !!!! -Jake_Official', 20);
        startingText.color = FlxColor.WHITE;
        startingText.screenCenter();
        // startingText.alpha = 0.4;
        add(startingText);

        understand = new FlxText(0, 0, 0, 'i hope you understand ^w^ okay wait for loading . . .', 15);
        understand.color = FlxColor.CYAN;
        understand.screenCenter(X);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.mouse.justPressed || FlxG.keys.justPressed.ENTER)
        {
            startingText.alpha = 0.5;
            add(understand);
            new FlxTimer().start(5, startingEngine, 1);
        }
        if (FlxG.keys.justPressed.SPACE)
        {
            CoolUtil.browserLoad('https://discord.gg/SGjExuzB8G');
        }

        super.update(elapsed);
    }

    function startingEngine(timer:FlxTimer)
        {
            FlxG.sound.music.stop();
            FlxG.sound.play(Paths.sound('hey'));
            MusicBeatState.switchState(new TitleState());
            TitleState.initialized = false;
            TitleState.closedState = false;
            FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
        }
}