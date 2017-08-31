/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram

import io.typefox.yang.eclipse.diagram.sprotty.DiagramServer
import java.net.URLEncoder
import org.eclipse.jetty.server.ServerConnector
import org.eclipse.swt.SWT
import org.eclipse.swt.browser.Browser
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.part.ViewPart

class YangDiagramView extends ViewPart {
	
	public static val ID = 'io.typefox.yang.eclipse.diagram'
	
	Browser browser
	
	String filePath
	
	override createPartControl(Composite parent) {
		parent.layout = new FillLayout
		browser = new Browser(parent, SWT.NONE)
		if (!viewSite.secondaryId.nullOrEmpty) {
			showFile(viewSite.secondaryId)
		}
	}
	
	override setFocus() {
		browser.setFocus()
	}
	
	override dispose() {
		val bundle = YangDiagramPlugin.instance
		val server = bundle.getLanguageServer('file:' + filePath)
		if (server instanceof DiagramServer) {
			server.didClose(clientId)
		}
		val session = bundle.serverManager.getSessionFor(clientId)
		if (session !== null && session.isOpen) {
			session.close()
		}
		super.dispose()
	}
	
	def String getClientId() {
		class.simpleName + '_' + hashCode
	}
	
	protected def void showFile(String path) {
		this.filePath = path
		val serverManager = YangDiagramPlugin.instance.serverManager
		serverManager.start()
		val connector = serverManager.server.connectors.head as ServerConnector
		browser.url = '''http://«connector.host»:«connector.localPort»/diagram.html?client=«encodeParameter(clientId)»&path=«encodeParameter(path)»'''
	}
	
	protected def String encodeParameter(String parameter) {
		URLEncoder.encode(parameter, 'UTF-8')
	}
	
}