package com.qspin.qtaste.tools.model.event;

public class TreeSelectionEvent extends Event {
	
	public TreeSelectionEvent(Event pEvent) {
		super();
		setComponentName(pEvent.getComponentName());
		setSourceClass(pEvent.getSourceClass());
		setTimeStamp(pEvent.getTimeStamp());
		setType(pEvent.getType());
	}

	public String getSelectedPath() {
		return mSelectedPath;
	}
	public void setExpansionPath(String pExpansionPath) {
		this.mSelectedPath = pExpansionPath;
	}

	private String mSelectedPath;
}
