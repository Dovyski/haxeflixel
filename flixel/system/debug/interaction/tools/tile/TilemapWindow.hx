package flixel.system.debug.interaction.tools.tile;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.system.debug.Window;
import flixel.system.debug.interaction.tools.Tile.GraphicTileTool;

/**
 * Window displayed when the user clicks any tile tool. It contains
 * information regarding the tilemaps available on the screen, e.g.
 * width, height, etc.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class TilemapWindow extends Window
{
	private var _tileTool:Tile;
	private var _tilemap:FlxTilemap;
	private var _graphicTile:FlxPoint;
	private var _tilemapSelector:TilemapSelector;
	
	private function initLayout():Void
	{
		_tilemapSelector = new TilemapSelector(_tileTool);
		_tilemapSelector.y = 20;

		addChild(_tilemapSelector);
	}
	
	public function new(tileTool:Tile) 
	{
		super("Tilemap", new GraphicTileTool(0, 0), 200, 100);
		_tileTool = tileTool;
		
		initLayout();
		reposition(2, 100);
		
		visible = false;
	}
	
	public function refresh():Void {}
}