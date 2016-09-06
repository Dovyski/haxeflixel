package flixel.system.debug.interaction.tools;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.debug.Window;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSpriteUtil;
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
	
	override public function init(brain:Interaction):Tool 
	{
		super.init(brain);

		_name = "Tile";
		setButton(GraphicTileTool);
		setCursor(new GraphicTileTool(0, 0));
		
		_tilemaps = new FlxGroup();
		_tileHightligh = new FlxSprite(); // TODO: replace this with a Sprite.
		_properties = new TilePropertiesWindow(this);

		_brain.container.addChild(_properties);
		
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
		super.update();
		
		// If the tool is not active, do nothing.
		if (!isActive())
			return;
		
		_tileHightligh.x = Math.floor(_brain.flixelPointer.x / _tileHightligh.width) * _tileHightligh.width;
		_tileHightligh.y = Math.floor(_brain.flixelPointer.y / _tileHightligh.height) * _tileHightligh.height;
		
		if (_brain.pointerPressed)
		{
			if (_activeTilemap != null)
				var b :Bool = _activeTilemap.setTile(Std.int(_brain.flixelPointer.x / _tileHightligh.width), Std.int(_brain.flixelPointer.y / _tileHightligh.height), _brain.keyPressed(Keyboard.DELETE) ? 0 : _properties.getSelectedTileType());
		}
	}
	
	override public function draw():Void 
	{
		// If the tool is not active, do nothing.
		if (!isActive())
			return;
		
		_tileHightligh.drawDebug();
		drawTileLinesAroundCursor();
	}
	
	private function drawTileLinesAroundCursor():Void
	{
		var tile:FlxSprite = _tileHightligh.clone(); // TODO: remove the clone call!
		var amount:Int = 7;
		var amountHalf:Int = Std.int(amount / 2);
		
		for (row in -amountHalf...amountHalf + 1)
		{
			for (col in -amountHalf...amountHalf + 1)
			{
				tile.x = _tileHightligh.x + _tileHightligh.width * col;
				tile.y = _tileHightligh.y + _tileHightligh.height * row;
				
				drawTileOutline(tile);
			}
		}
	}
	
	// TODO: replace FlxSprite with rect probably
	private function drawTileOutline(sprite:FlxSprite):Void
	{
		var gfx:Graphics = _brain.getDebugGraphics();
		
		if (gfx == null)
			return;
		
		// Render a red rectangle centered at the selected item
		gfx.lineStyle(0.7, 0x990000, 0.15);
		gfx.drawRect(sprite.x - FlxG.camera.scroll.x,
			sprite.y - FlxG.camera.scroll.y,
			sprite.width * 1.0, sprite.height * 1.0);
		
		// Draw the debug info to the main camera buffer.
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
	
	private function findExistingTilemaps(members:Array<FlxBasic>, tiles:FlxGroup):FlxTilemap
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
					tiles.add(target);
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
	
	public function new(tileTool:Tile) 
	{
		super("Tilemap editor", new GraphicTileTool(0, 0), 200, 100);
		_tileTool = tileTool;
		
		initLayout();
		
		_tileHightligh = new Sprite();
		_tileHightligh.graphics.lineStyle(1, 0xff0000);
		_tileHightligh.graphics.drawRect(0, 0, 16, 16);
		_tileHightligh.width = 16;
		_tileHightligh.height = 16;
		_tileHightligh.x = 0;
		_tileHightligh.y = 0;
		_tileHightligh.visible = false;
		
		_tileSelected = new Sprite();
		_tileSelected.graphics.lineStyle(1, 0xffff00);
		_tileSelected.graphics.drawRect(0, 0, 16, 16);
		_tileSelected.width = 16;
		_tileSelected.height = 16;
		_tileSelected.x = 0;
		_tileSelected.y = 20;
		
		_graphicTile = new FlxPoint();
		
		addChild(_tileSelected);
		addChild(_tileHightligh);
		
		reposition(2, 150);
		
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
			resize(_tilemapBitmap.bitmapData.width * 2 + 10, _tilemapBitmap.bitmapData.height * 2 + _tilemapGraphic.y + 10);
			visible = true;
		}
	}
	
	public function getSelectedTileType():Int
	{
		return _tileType;
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
		
		_tileType = index;
		_tileSelected.x = _tileHightligh.x;
		_tileSelected.y = _tileHightligh.y;
	}
}