package flixel.system.debug.interaction.tools;

import flash.Vector;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.ui.Keyboard;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.debug.Window;
import flixel.system.debug.interaction.tools.tile.TileSelectionWindow;
import flixel.system.debug.interaction.tools.tile.TilemapWindow;
import flixel.system.debug.interaction.tools.tile.Pointer;
import flixel.system.debug.interaction.tools.tile.Editor;
import flixel.system.ui.FlxSystemButton;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSpriteUtil;
import openfl.display.Sprite;

@:bitmap("assets/images/debugger/buttons/tile.png") 
class GraphicTileTool extends BitmapData {}

/**
 * A tool to perform some operations in tilemaps, such as adding/removing
 * tiles, moving things around, etc. This class acts as a meta tool, because
 * it can be added to the list of available tools in the interaction system,
 * however it is not a tool itself. It houses smaller tilemap-related tools,
 * centralizing its operations and data.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 * @copyright I got several ideas from here: https://github.com/LordTim/FlxTilemap-Demo
 */
class Tile extends Tool
{		
	public var tilemaps(default, null):Vector<FlxTilemap> = new Vector<FlxTilemap>();
	public var activeTilemap(default, set):Int = -1;
	public var tileHightligh(default, null):FlxSprite;
	public var properties(default, null):TilemapWindow;
	public var palette(default, null):TileSelectionWindow;
	
	override public function init(brain:Interaction):Tool 
	{
		super.init(brain);
		
		_name = "Tile";
		properties = new TilemapWindow(this, 2, 150);
		palette = new TileSelectionWindow(this, properties.x, 250);
		
		brain.container.addChild(properties);
		brain.container.addChild(palette);
		
		brain.addTool(new Editor(this));
		
		tileHightligh = new FlxSprite(); // TODO: replace this with a Sprite.
		
		return this;
	}
	
	public function refresh():Void
	{
		var tilemap:FlxTilemap = null;
		
		if(activeTilemap == -1) {
			activeTilemap = 0;
		}
		
		tilemaps.length = 0;
		findExistingTilemaps(FlxG.state.members, tilemaps);
		
		if (tilemaps.length > 0)
		{
			tilemap = tilemaps[activeTilemap];
		
			tileHightligh.width = tilemap.width / tilemap.widthInTiles;
			tileHightligh.height = tilemap.height / tilemap.heightInTiles;
			tileHightligh.makeGraphic(cast tileHightligh.width, cast tileHightligh.height, 0xffff0000);
		}
		
		properties.refresh(tilemap);
		palette.refresh(tilemap);
	}
	
	override public function update():Void 
	{
		super.update();
		
		tileHightligh.x = Math.floor(_brain.flixelPointer.x / tileHightligh.width) * tileHightligh.width;
		tileHightligh.y = Math.floor(_brain.flixelPointer.y / tileHightligh.height) * tileHightligh.height;
	}
			
	override public function draw():Void 
	{
		// If the tool is not active, do nothing.
		if (!isActive())
			return;
	}
	
	private function findExistingTilemaps(members:Array<FlxBasic>, tiles:Vector<FlxTilemap>):FlxTilemap
	{
		var i:Int = 0;
		var size:Int = members.length;
		var b:FlxBasic;
		var target:FlxTilemap = null;
		
		while (i < size)
		{
			b = members[i++];

			if (b != null && b.exists && b.alive && b.visible)
			{
				if (Std.is(b, FlxGroup))
				{
					target = findExistingTilemaps((cast b).members, tiles);
				}
				else if(Std.is(b, FlxTilemap))
				{
					target = cast(b, FlxTilemap);
				}
				if (target != null)
				{
					tiles.push(target);
				}
			}
		}
		
		return target;
	}
	
	function set_activeTilemap(value:Int)
	{
		// TODO: check for out of bound values
		activeTilemap = value;
		refresh();
		
		return activeTilemap;
	}
}