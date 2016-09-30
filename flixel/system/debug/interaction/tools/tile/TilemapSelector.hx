package flixel.system.debug.interaction.tools.tile;

import flash.display.Sprite;
import flash.text.TextField;
import flixel.system.ui.FlxSystemButton;
import flixel.system.debug.interaction.tools.Tile.GraphicTileTool;

/**
 * UI component to navigate among the available tilemaps.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class TilemapSelector extends Sprite
{
	private var _prev:FlxSystemButton;
	private var _next:FlxSystemButton;
	private var _text:TextField = new TextField();
	private var _tileTool:Tile;
		
	public function new(tileTool:Tile) 
	{
		super();
		_tileTool = tileTool;

		_prev = new FlxSystemButton(Type.createInstance(GraphicTileTool, [0, 0]), prev);
		_next = new FlxSystemButton(Type.createInstance(GraphicTileTool, [0, 0]), next);
		
		_prev.x = 0;
		_text.x = _prev.x + _prev.width + 2;
		_next.x = _text.x + _text.width + 2;
		
		addChild(_prev);
		addChild(_text);
		addChild(_next);
		
		refresh();
	}
	
	public function refresh():Void
	{
		_text.text = "Tilemap" + _tileTool.activeTilemap;
	}
	
	private function next():Void
	{
		FlxG.log.add("Next");
		_tileTool.activeTilemap++; 
		refresh();
	}
	
	private function prev():Void
	{
		FlxG.log.add("Prev");
		_tileTool.activeTilemap--; 
		refresh();
	}
}