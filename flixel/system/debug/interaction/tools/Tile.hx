package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.ui.Keyboard;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;

@:bitmap("assets/images/debugger/buttons/tile.png") 
class GraphicTileTool extends BitmapData {}

/**
 * A tool to edit tilemaps. 
 * TODO: make a nice dialog to select which tilemap to edit
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 * @copyright I got several ideas from here: https://github.com/LordTim/FlxTilemap-Demo
 */
class Tile extends Tool
{		
	private var _tileHightligh:FlxSprite;
	private var _tilemaps:FlxGroup;
	private var _activeTilemap:FlxTilemap;
	private var _activeTileType:Int;
	
	override public function init(Brain:Interaction):Tool 
	{
		super.init(Brain);

		setName("Tile");
		setButton(GraphicTileTool);
		setCursor(new GraphicTileTool(0, 0));
		
		_tilemaps = new FlxGroup();
		
		return this;
	}
	
	override public function activate():Void 
	{
		super.activate();
		
		// Open room for all existing tilemaps
		_tilemaps.clear();
		findExistingTilemaps(FlxG.state.members, _tilemaps);
		
		_activeTilemap = cast _tilemaps.getFirstAlive();
		
		// TODO: get tile width/height from selected tilemap
		_tileHightligh = new FlxSprite();
		_tileHightligh.makeGraphic(8, 8, 0xffff0000);
		_tileHightligh.width = 8;
		_tileHightligh.height = 8;
		
		// TODO: get this based on user input
		_activeTileType = 3;
	}
	
	override public function update():Void 
	{
		var brain :Interaction = getBrain();
		
		super.update();
		
		if (!isActive())
		{
			// Tool is not active. Nothing to do here.
			return;
		}
		
		_tileHightligh.x = Math.floor(brain.flixelPointer.x / _tileHightligh.width) * _tileHightligh.width;
		_tileHightligh.y = Math.floor(brain.flixelPointer.y / _tileHightligh.height) * _tileHightligh.height;
		
		if (brain.pointerPressed)
		{
			if (_activeTilemap != null)
			{
				var b :Bool = _activeTilemap.setTile(Std.int(brain.flixelPointer.x / _tileHightligh.width), Std.int(brain.flixelPointer.y / _tileHightligh.height), brain.keyPressed(Keyboard.DELETE) ? 0 : _activeTileType);
			}
		}
	}
	
	override public function draw():Void 
	{
		if (!isActive())
		{
			// Tool is not active. Nothing to do here.
			return;
		}
		
		_tileHightligh.drawDebug();
	}
	
	private function findExistingTilemaps(Members:Array<FlxBasic>, Tiles:FlxGroup):FlxTilemap
	{
		var i:Int = 0;
		var size:Int = Members.length;
		var b:FlxBasic;
		var target:FlxTilemap = null;
		
		while (i < size)
		{
			b = Members[i++];

			if (b != null && b.exists && b.alive && b.visible)
			{
				if (Std.is(b, FlxGroup))
				{
					target = findExistingTilemaps((cast b).members, Tiles);
				}
				else if(Std.is(b, FlxTilemap))
				{
					target = cast(b, FlxTilemap);
				}
				if (target != null)
				{
					Tiles.add(target);
				}
			}
		}
		
		return target;
	}
}
