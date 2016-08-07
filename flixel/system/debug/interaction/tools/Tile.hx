package flixel.system.debug.interaction.tools;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.debug.Window;
import flixel.tile.FlxTilemap;
import openfl.display.Sprite;

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
	private var _properties:TilePropertiesWindow;
	
	override public function init(Brain:Interaction):Tool 
	{
		super.init(Brain);

		setName("Tile");
		setButton(GraphicTileTool);
		setCursor(new GraphicTileTool(0, 0));
		
		_tilemaps = new FlxGroup();
		_tileHightligh = new FlxSprite(); // TODO: replace this with a Sprite.
		_properties = new TilePropertiesWindow(this);

		Brain.getContainer().addChild(_properties);
		
		return this;
	}
	
	override public function activate():Void 
	{
		super.activate();
		
		// Open room for all existing tilemaps
		_tilemaps.clear();
		findExistingTilemaps(FlxG.state.members, _tilemaps);
		
		_activeTilemap = cast _tilemaps.getFirstAlive();
		
		_tileHightligh.width = _activeTilemap.width / _activeTilemap.widthInTiles;
		_tileHightligh.height = _activeTilemap.height / _activeTilemap.heightInTiles;
		_tileHightligh.makeGraphic(cast _tileHightligh.width, cast _tileHightligh.height, 0xffff0000);
		
		_properties.refresh(_activeTilemap);
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
				var b :Bool = _activeTilemap.setTile(Std.int(brain.flixelPointer.x / _tileHightligh.width), Std.int(brain.flixelPointer.y / _tileHightligh.height), brain.keyPressed(Keyboard.DELETE) ? 0 : _properties.getSelectedTileType());
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

class TilePropertiesWindow extends Window
{
	private var _tileType:Int;
	private var _tileTool:Tile;
	private var _tileHightligh:Sprite;
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
	
	public function new(TileTool:Tile) 
	{
		super("Tilemap editor", new GraphicTileTool(0, 0), 200, 100);
		_tileTool = TileTool;
		
		initLayout();
		
		_tileHightligh = new Sprite();
		_tileHightligh.graphics.lineStyle(1, 0xff0000);
		_tileHightligh.graphics.drawRect(0, 0, 16, 16);
		_tileHightligh.width = 16;
		_tileHightligh.height = 16;
		_graphicTile = new FlxPoint();
		
		addChild(_tileHightligh);
		
		reposition(2, 150);
		
		_tilemapGraphic.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseOverGraphic);
		_tilemapGraphic.addEventListener(MouseEvent.MOUSE_UP, handleClickGraphic);
	}
	
	public function refresh(Tilemap:FlxTilemap):Void
	{
		_tilemap = Tilemap;
		
		if (_tilemap != null)
		{
			_tilemapBitmap.bitmapData = _tilemap.frames.parent.bitmap;
			resize(_tilemapBitmap.bitmapData.width * 2, _tilemapBitmap.bitmapData.height * 2 + _tilemapGraphic.y);
		}
	}
	
	public function getSelectedTileType():Int
	{
		return _tileType;
	}

	private function handleMouseOverGraphic(Event:MouseEvent):Void
	{		
		_graphicTile.x = Math.floor(Event.localX / 8) * 8;
		_graphicTile.y = Math.floor(Event.localY / 8) * 8;
		
		_tileHightligh.x = _graphicTile.x * 2;
		_tileHightligh.y = _graphicTile.y * 2;
		
		_tileHightligh.y += 20;
	}
	
	private function handleClickGraphic(Event:MouseEvent):Void
	{
		var tilesPerRow:Int = Std.int(_tilemapBitmap.bitmapData.width / 8);
		var row:Int = Std.int(_graphicTile.y / 8);
		var column:Int = Std.int(_graphicTile.x / 8);
		var index = row * tilesPerRow + column;
		
		FlxG.log.add("Click: " + _graphicTile.x + "," + _graphicTile.y + ", " + tilesPerRow);
		FlxG.log.add("row: " + row + ", col:" + column + ", idx: " + index);
		
		_tileType = index;
	}
}