/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram

import com.google.gson.Gson
import com.google.gson.JsonObject
import io.typefox.yang.eclipse.diagram.sprotty.ActionMessage
import io.typefox.yang.eclipse.diagram.sprotty.DiagramServer
import io.typefox.yang.eclipse.diagram.sprotty.ServerStatusAction
import java.net.URLEncoder
import org.apache.log4j.Logger
import org.eclipse.e4.ui.css.swt.theme.IThemeEngine
import org.eclipse.jetty.server.ServerConnector
import org.eclipse.lsp4e.LSPEclipseUtils
import org.eclipse.swt.SWT
import org.eclipse.swt.browser.Browser
import org.eclipse.swt.events.ControlAdapter
import org.eclipse.swt.events.ControlEvent
import org.eclipse.swt.events.MouseEvent
import org.eclipse.swt.events.MouseTrackAdapter
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.layout.RowLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Control
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.Label
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.IFileEditorInput
import org.eclipse.ui.IPartListener
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.internal.WorkbenchPlugin
import org.eclipse.ui.part.ViewPart

import static org.eclipse.ui.ISharedImages.*

class YangDiagramView extends ViewPart {

	static val LOG = Logger.getLogger(YangDiagramView)

	public static val ID = 'io.typefox.yang.eclipse.diagram'

	Browser browser

	String filePath

	Gson gson = new Gson()

	Composite comp
	Composite statusBar
	Label statusBarIcon
	Label statusBarMessage
	
	val sharedImages = WorkbenchPlugin.^default.sharedImages
	
	override createPartControl(Composite parent) {
		comp = new Composite(parent, SWT.NONE)
		comp.layout = new GridLayout => [
			numColumns = 1
		]
		browser = new Browser(comp, SWT.NONE)
		browser.layoutData = new GridData => [
			horizontalAlignment = GridData.FILL
			verticalAlignment = GridData.FILL
			grabExcessHorizontalSpace = true
			grabExcessVerticalSpace = true
		]
		statusBar = new Composite(comp, SWT.NONE)
		statusBar.layout = new RowLayout 
		statusBar.layoutData = new GridData => [
			exclude = true
		]
		statusBarIcon = new Label(statusBar, SWT.NONE)
		statusBarIcon.image = sharedImages.getImage(IMG_OBJS_INFO_TSK)
		statusBarMessage = new Label(statusBar, SWT.NONE)
		statusBarMessage.text = ''
		if (!viewSite.secondaryId.nullOrEmpty) {
			connect(viewSite.secondaryId.replace('%3A', ':'))
			partName = fileName
		} else {
			site.page.addPartListener(new IPartListener() {
				override partActivated(IWorkbenchPart part) {
					if (part.site.id == 'io.typefox.YangEditor') {
						disconnect()
						val file = ((part as IEditorPart).editorInput as IFileEditorInput).file
						val path = LSPEclipseUtils.toUri(file).path
						connect(path)
					}
				}

				override partBroughtToTop(IWorkbenchPart part) {
				}

				override partClosed(IWorkbenchPart part) {
					if (part.site.id == 'io.typefox.YangEditor')
						disconnect()
				}

				override partDeactivated(IWorkbenchPart part) {
				}

				override partOpened(IWorkbenchPart part) {
				}

			})
		}
		browser.addMouseTrackListener(new MouseTrackAdapter() {
			override mouseEnter(MouseEvent e) {
				browser.execute('''
					var event = new MouseEvent('mouseup', {
					});
					document.getElementById("sprotty").children[0].dispatchEvent(event);
				''')
			}
		})
		browser.addControlListener(new ControlAdapter() {
			override controlResized(ControlEvent e) {
				super.controlResized(e)
				val size = (e.widget as Control).size
				val action = new JsonObject => [
					addProperty('kind', 'initializeCanvasBounds')
					add('newCanvasBounds', new JsonObject => [
						addProperty('x', 0)
						addProperty('y', 0)
						addProperty('width', size.x)
						addProperty('height', size.y)
					])
				]
				sendAction(action)
			}
		})
	}

	protected def getFileName() {
		val fileNameWithExtension = filePath?.split('/')?.last
		if (fileNameWithExtension?.endsWith('.yang'))
			fileNameWithExtension.substring(0, fileNameWithExtension.length - 5)
		else
			fileNameWithExtension ?: 'YANG Diagram'
	}

	override setFocus() {
		browser.setFocus()
	}

	override dispose() {
		disconnect()
		super.dispose()
	}

	def String getClientId() {
		class.simpleName + '_' + hashCode
	}

	protected def void disconnect() {
		if (filePath !== null) {
			val bundle = YangDiagramPlugin.instance
			val server = bundle.getLanguageServer('file:' + filePath)
			if (server instanceof DiagramServer) {
				server.didClose(clientId)
			}
			val session = bundle.serverManager.getSessionFor(clientId)
			if (session !== null && session.isOpen) {
				session.close()
			}
		}
	}

	protected def void connect(String path) {
		this.filePath = path
		val serverManager = YangDiagramPlugin.instance.serverManager
		serverManager.start()
		val connector = serverManager.server.connectors.head as ServerConnector
		val url = '''http://«connector.host»:«connector.localPort»/diagram.html?client=«encodeParameter(clientId)»&path=«encodeParameter(path)»&theme=«colorTheme»'''
		browser.url = url
		LOG.warn(url)
	}

	protected def String encodeParameter(String parameter) {
		URLEncoder.encode(parameter, 'UTF-8')
	}

	def sendAction(JsonObject theAction) {
		val session = YangDiagramPlugin.instance.serverManager.getSessionFor(clientId)
		if (session !== null && session.isOpen) {
			val actionMessage = new ActionMessage() => [
				clientId = this.clientId
				action = theAction
			]
			val json = gson.toJson(actionMessage)
			session.asyncRemote.sendText(json)
		}
	}

	def getFilePath() {
		filePath
	}

	protected def getColorTheme() {
		var engine = Display.^default.getData("org.eclipse.e4.ui.css.swt.theme") as IThemeEngine
		val id = engine.activeTheme.id
		if (id.contains('dark'))
			return 'dark'
		else
			return 'light'
	}

	def void showServerState(ServerStatusAction serverStatus) {
		switch serverStatus.severity.toLowerCase {
			case 'ok': {
				statusBar.visible = false
				(statusBar.layoutData as GridData).exclude = true
			}
			case 'error': {
				statusBar.visible = true
				(statusBar.layoutData as GridData).exclude = false
				statusBarIcon.image = sharedImages.getImage(IMG_OBJS_ERROR_TSK)
			}
			case 'warning': {
				statusBar.visible = true
				(statusBar.layoutData as GridData).exclude = false
				statusBarIcon.image = sharedImages.getImage(IMG_OBJS_WARN_TSK)
			}
			case 'info': {
				statusBar.visible = true
				(statusBar.layoutData as GridData).exclude = false
				statusBarIcon.image = sharedImages.getImage(IMG_OBJS_INFO_TSK)
			}
		}
		statusBarMessage.text = serverStatus.message
		comp.layout(true, true)
	}
}
