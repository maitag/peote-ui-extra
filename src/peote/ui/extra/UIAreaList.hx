package peote.ui.extra;

import peote.ui.interactive.UIArea;
import peote.ui.interactive.Interactive;
import peote.ui.interactive.interfaces.ParentElement;

//import peote.ui.config.AreaConfig;

class UIAreaList extends UIArea implements ParentElement
{
	// TODO: setter here to update layout
	var horizontal:Bool = false;

	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int = 0, ?config:AreaListConfig)
	{	
		super(xPosition, yPosition, width, height, zIndex, config);

		horizontal = config.horizontal;
		
		// ------------------------------------
		// --------- RESIZE HANDLING ----------		
		// ------------------------------------
		
		// TODO: extra _handler for the Slider 
	
		setOnResizeWidthIntern(this, function(_,_,_) {
			for (child in childs) {
				if (horizontal)
					child.height = this.height-((maskSpace != null) ? maskSpace.top + maskSpace.bottom : 0);
				else
					child.width = this.width-((maskSpace != null) ? maskSpace.left + maskSpace.right : 0);
				// child.maskByElement(this);
				// child.updateLayout();
			}
		});

		// this._onResizeHeight = (_, height:Int, delta:Int) -> {}
	}

	function isTextChild(child):Bool {
		return (Type.getClassName(Type.getClass(child)).indexOf("peote.ui.interactive.UIText") >= 0);
	}

	var _firstTimeAdded = true;
	var _autosizedChilds = new Array<Interactive>();
	override function onAddUIElementToDisplay()
	{
		if (_firstTimeAdded) { // detect where is text-elements what have autosize and is zero at first run
			for (child in childs) {
				if ( child.height == 0 && isTextChild(child) ) {
					_autosizedChilds.push(child);
				}
			}
		}

		super.onAddUIElementToDisplay();

		if (_firstTimeAdded) {
			_firstTimeAdded = false;
			for (child in _autosizedChilds) {
				if (horizontal)
					updateChildOnResize(child, 0, child.width);
				else
					updateChildOnResize(child, 0, child.height);
			}
			_autosizedChilds = null;		
		}

	}

	// -----------------------------------------------------------

	public function addResizable(child:Interactive) _add(child, true); // TODO: later only "add" and with options per child
	override public function add(child:Interactive) _add(child, false);
	function _add(child:Interactive, addResizeInternEvent:Bool)
	{
		if (horizontal) {
			child.y = 0;
			child.height = height - ((maskSpace != null) ? maskSpace.top + maskSpace.bottom : 0);
		}
		else {
			child.x = 0;
			child.width = width - ((maskSpace != null) ? maskSpace.left + maskSpace.right : 0);
		}

		if (childs.length == 0) {
			if (horizontal) child.y = 0; else child.x = 0;
		}
		else {
			if (horizontal)
				child.x = childs[childs.length-1].right - x - ((maskSpace != null) ? maskSpace.left : 0);
			else 
				child.y = childs[childs.length-1].bottom - y - ((maskSpace != null) ? maskSpace.top : 0);
		}
		
		super.add(child);
		
		// TODO: this maybe for text-elements later
		if (addResizeInternEvent) {
			if (horizontal)
				child.setOnResizeHeightIntern(child, updateChildOnResize);
			else 
				child.setOnResizeWidthIntern(child, updateChildOnResize);
		}
	}
	
	override public function remove(child:Interactive)
	{
		var index = childs.indexOf(child);

		if (index == childs.length-1) {
			
		}
		else {
			var offset = (horizontal) ? child.width : child.height;
			moveChildsByOffset(index+1, -offset);
		}

		// TODO: remove resize-handler if there was added some!

		super.remove(child);

	}

	// -----------------------------------------------------------

	public function updateChildOnResize(child:Interactive, size:Int, delta:Int)
	{
		// detect where is text-elements what have autosize and is zero before added
		if ( _firstTimeAdded && size == delta && isTextChild(child) ) return;

		var childIndex:Int = childs.indexOf(child);
		if (childIndex < 0) return;


		// TODO: glitchy/hacky here with textfields:

		if ( ! (size == delta && isTextChild(child)) )
			child.maskByElement(this, maskSpace);

		// if (child.isVisible)
		if ( ! (size == delta && isTextChild(child)) )
			child.updateLayout(); // Problem if it is a masked textfield and triggers this before gets visible (and triggers its onresize event)
		
		moveChildsByOffset(childIndex+1, delta);

		if (horizontal) {
			innerRight += delta;	
			if (_onResizeInnerWidth != null) _onResizeInnerWidth(this, innerWidth, delta); // TODO: extra event for this!
			if (onResizeInnerWidth != null) onResizeInnerWidth(this, innerWidth, delta);
		}
		else {
			innerBottom += delta;	
			if (_onResizeInnerHeight != null) _onResizeInnerHeight(this, innerHeight, delta); // TODO: extra event for this!
			if (onResizeInnerHeight != null) onResizeInnerHeight(this, innerHeight, delta);
		}
	}
	
	function moveChildsByOffset(fromIndex:Int, offset:Int) {
		for (i in fromIndex...childs.length) {
			if (horizontal) 
				childs[i].x += offset;
			else
				childs[i].y += offset;

			//  if (childs[i].isVisible) {
				childs[i].maskByElement(this, maskSpace);
				childs[i].updateLayout();
			// }
		}
		//updateLayout();
	}
	



}
