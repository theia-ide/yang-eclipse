package io.typefox.yang.eclipse

import org.eclipse.ui.plugin.AbstractUIPlugin

class YangEclipseActivator extends AbstractUIPlugin {
	
	public static val PLUGIN_ID = 'io.typefox.yang.eclipse'
	
	static YangEclipseActivator INSTANCE
	
	new() {
		INSTANCE = this
		YangImages.initalize(imageRegistry)
	}
	
	def static getInstance() {
		INSTANCE
	} 
}
