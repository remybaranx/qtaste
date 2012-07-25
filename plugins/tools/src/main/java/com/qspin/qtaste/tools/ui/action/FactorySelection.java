package com.qspin.qtaste.tools.ui.action;

import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

import com.qspin.qtaste.tools.factory.TreeFactory;
import com.qspin.qtaste.tools.ui.EventTree;

public class FactorySelection implements ItemListener
{
	public FactorySelection(EventTree pTree, TreeFactory pFactory)
	{
		mTree = pTree;
		mFactory = pFactory;
	}
	
	public void itemStateChanged(ItemEvent pEvt) {
		if(  pEvt.getStateChange() == ItemEvent.SELECTED )
		{
			mTree.setTreeBuilder(mFactory);
		}
	}
	
	private TreeFactory mFactory;
	private EventTree mTree;
}