package flixel.system.debug.interaction.tools.tile;

/**
 * Base class extended by all tile tools.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class TileSubTool extends Tool
{		
	private var _tileBrain(default, null):Tile;

	public function new(tileTool:Tile) 
	{
		super();
		_tileBrain = tileTool;
	}
}