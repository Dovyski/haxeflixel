package flixel.system.debug.interaction;

import flash.display.Sprite;
import flixel.group.FlxGroup;
import flixel.system.debug.FlxDebugger;
import flixel.system.debug.interaction.tools.*;

/**
 * A plugin to visually and interactively debug a game while it is running.
 * 
 * TODO:
 * - Make Tool#init(brain) instead of passing that in the constructor
 * - Make tools setIcon() instead of using _icon or something
 * - Move _selectedItems from brain to Pointer tool (make tools able to communicate with brain.getTool(Class).
 * - Create update/draw methods for tools?
 * - Add signals to tools, so Pointer can dispatch when an item was selected?
 * - Make ToolsPanel only contain the tool icons, not the tools itself, it should be the brain's responsability
 * 
 * @author	Fernando Bevilacqua (dovyski@gmail.com)
 */
class Interaction
{
	private var _container:Sprite;
	private var _selectedItems:FlxGroup;
	private var _tools:Array<Tool>;
	
	public function new(Container:Sprite)
	{		
		_container = Container;
		_selectedItems = new FlxGroup();
		_tools = [];
		
		// Add all built-in tools
		addTool(new Pointer());
		addTool(new Mover());
		addTool(new Eraser());
		
		// Subscrite to some Flixel signals
		FlxG.signals.postDraw.add(postDraw);
		FlxG.signals.preUpdate.add(preUpdate);
	}
	
	/**
	 * 
	 * @param	Instance
	 */
	public function addTool(Instance :Tool):Void
	{	
		Instance.init(this);
		
		_tools.push(Instance);
		
		// If the tool has an icon, it should be displayed in
		// the tools panel
		if (Instance.icon != null)
		{
			// TODO: add icon to debugger
		}
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		// TODO: remove all entities and free memory.
	}
	
	/**
	 * Called before the game gets updated.
	 */
	private function preUpdate():Void
	{
		var tool:Tool;
		var i:Int;
		var l:Int = _tools.length;
		
		for (i in 0...l)
		{
			tool = _tools[i];
			tool.update();
		}
	}
	
	/**
	 * Called after the game state has been drawn.
	 */
	private function postDraw():Void
	{
		var tool:Tool;
		var i:Int;
		var l:Int = _tools.length;
		
		for (i in 0...l)
		{
			tool = _tools[i];
			tool.draw();
		}
	}
	
	public function getTool(ClassName:Class<Tool>):Tool
	{
		var tool:Tool = null;
		var i:Int;
		var l:Int = _tools.length;
		
		for (i in 0...l)
		{
			if (Std.is(_tools[i], ClassName))
			{
				tool = _tools[i];
				break;
			}
		}
		
		return tool;
	}
	
	public function activate():Void
	{
		// TODO: improve this!
		_tools[0].activate();
	}
	
	/**
	 * 
	 * @return
	 */
	public function getContainer():Sprite
	{
		return _container;
	}
	
	/**
	 * 
	 * @return
	 */
	public function getSelectedItems():FlxGroup
	{
		return _selectedItems;
	}
	
	/**
	 * 
	 */
	public function clearSelection():Void
	{
		_selectedItems.clear();
	}
}
