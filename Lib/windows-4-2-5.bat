@echo off
color 0a
cd ..
@echo on
echo Installing Package dependencies...
echo If You Wifi Work As Faster
haxelib install lime 8.0.0
haxelib install hxcpp 4.2.1
haxelib install flixel 4.11.0 
haxelib install flixel-addons 2.11.0
haxelib install flixel-ui 2.4.0
haxelib install hxCodec 2.5.1
haxelib install hscript 2.5.0
haxelib install openfl 9.2.1
haxelib install flixel-tools 1.5.1
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit
haxelib git hscript-ex https://github.com/ianharrigan/hscript-ex
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib install hxcpp-debug-server
haxelib list
echo Finished!
pause
