package flixel.system.debug.interaction.tools.tile;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.system.debug.Window;
import flixel.system.debug.interaction.tools.Tile.GraphicTileTool;

/**
 * Window displayed when the user clicks the tile editing tool.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class TileSelectionWindow extends Window
{
	public var selectedTile(default, null):Int;
	
	private var _tileTool:Tile;
	private var _tileHightligh:Sprite;
	private var _tileSelected:Sprite;
	private var _tilemap:FlxTilemap;
	private var _tilemapGraphic:Sprite;
	private var _tilemapBitmap:Bitmap;
	private var _graphicTile:FlxPoint;
	
	private function initLayout():Void
	{
		_tilemapGraphic = new Sprite();
		_tilemapBitmap = new Bitmap();
		
		_tilemapGraphic.addChild(_tilemapBitmap);
		
		_tilemapGraphic.y = 20;
		_tilemapGraphic.scaleX = 2; // TODO: get values from Flixel
		_tilemapGraphic.scaleY = 2; // TODO: get values from Flixel
		
		addChild(_tilemapGraphic);
	}
	
	public function new(tileTool:Tile, x:Float, y:Float) 
	{
		super("Tile palette", new GraphicTileTool(0, 0), 200, 100);
		_tileTool = tileTool;
		
		initLayout();
		
		_tileHightligh = new Sprite();
		_tileHightligh.graphics.lineStyle(1, 0xff0000);
		_tileHightligh.graphics.drawRect(0, 0, 16, 16);
		_tileHightligh.width = 16; // TODO: get this value dynamically
		_tileHightligh.height = 16; // TODO: get this value dynamically
		_tileHightligh.x = 0;
		_tileHightligh.y = 0;
		_tileHightligh.visible = false;
		
		_tileSelected = new Sprite();
		_tileSelected.graphics.lineStyle(1, 0xffff00);
		_tileSelected.graphics.drawRect(0, 0, 16, 16);
		_tileSelected.width = 16; // TODO: get this value dynamically
		_tileSelected.height = 16; // TODO: get this value dynamically
		_tileSelected.x = _tilemapGraphic.x; // TODO: get this value dynamically
		_tileSelected.y = _tilemapGraphic.y; // TODO: get this value dynamically
		
		_graphicTile = new FlxPoint();
		
		addChild(_tileSelected);
		addChild(_tileHightligh);
		
		reposition(x, y);
		
		_tilemapGraphic.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseOverGraphic);
		_tilemapGraphic.addEventListener(MouseEvent.MOUSE_UP, handleClickGraphic);
		_tilemapGraphic.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOverGraphic);
		
		visible = false;
	}
	
	public function refresh(tilemap:FlxTilemap):Void
	{
		_tilemap = tilemap;
		
		if (_tilemap != null)
		{
			_tilemapBitmap.bitmapData = _tilemap.frames.parent.bitmap;
			resize(_tilemapBitmap.bitmapData.width * 2 + 5, _tilemapBitmap.bitmapData.height * 2 + _tilemapGraphic.y + 5);
		}
	}
	
	private function handleMouseOverGraphic(event:MouseEvent):Void
	{		
		if (event.type == MouseEvent.MOUSE_MOVE)
		{
			_graphicTile.x = Math.floor(event.localX / 8) * 8;
			_graphicTile.y = Math.floor(event.localY / 8) * 8;
			
			_tileHightligh.x = _graphicTile.x * 2;
			_tileHightligh.y = _graphicTile.y * 2;
			
			_tileHightligh.y += 20;
			_tileHightligh.visible = true;
		}
		else if (event.type == MouseEvent.MOUSE_OUT)
		{
			_tileHightligh.visible = false;
		}
	}
	
	private function handleClickGraphic(event:MouseEvent):Void
	{
		var tilesPerRow:Int = Std.int(_tilemapBitmap.bitmapData.width / 8);
		var row:Int = Std.int(_graphicTile.y / 8);
		var column:Int = Std.int(_graphicTile.x / 8);
		var index = row * tilesPerRow + column;
		
		selectedTile = index;
		_tileSelected.x = _tileHightligh.x;
		_tileSelected.y = _tileHightligh.y;
	}
}