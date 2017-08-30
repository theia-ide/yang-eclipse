/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram.server

import com.google.gson.Gson
import io.typefox.yang.eclipse.diagram.ActionMessage
import io.typefox.yang.eclipse.diagram.DiagramServer
import io.typefox.yang.eclipse.diagram.YangDiagramPlugin
import javax.websocket.Endpoint
import javax.websocket.EndpointConfig
import javax.websocket.MessageHandler
import javax.websocket.Session
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.Status
import org.eclipse.lsp4e.LSPEclipseUtils
import org.eclipse.ui.statushandlers.StatusManager

class DiagramEndpoint extends Endpoint implements MessageHandler.Whole<String> {
	
	val gson = new Gson
	
	Session session
	
	IFile sourceFile
	
	override onOpen(Session session, EndpointConfig config) {
		this.session = session
		session.maxIdleTimeout = 0
		session.addMessageHandler(this)
	}
	
	override onError(Session session, Throwable throwable) {
		StatusManager.manager.handle(new Status(IStatus.ERROR, YangDiagramPlugin.PLUGIN_ID,
				"Error in diagram web socket", throwable))
	}
	
	override onMessage(String message) {
		try {
			val actionMessage = gson.fromJson(message, ActionMessage)
			val action = actionMessage.action.asJsonObject
			val kind = action.get('kind')?.asString
			if (kind == LoggingAction.KIND) {
				handleLogMessage(gson.fromJson(action, LoggingAction))
			} else {
				val server = findLanguageServerFor(actionMessage, kind)
				if (server instanceof DiagramServer)
					server.accept(actionMessage)
			}
		} catch (Exception exception) {
			StatusManager.manager.handle(new Status(IStatus.ERROR, YangDiagramPlugin.PLUGIN_ID,
					"Error while processing client message", exception))
		}
	}
	
	protected def findLanguageServerFor(ActionMessage message, String kind) {
		if (kind == 'requestModel') {
			session.userProperties.put('clientId', message.clientId)
			val action = message.action.asJsonObject
			val options = action.get('options')?.asJsonObject
			val sourceUri = options?.get('sourceUri')
			if (sourceUri !== null)
				sourceFile = LSPEclipseUtils.findResourceFor(sourceUri.asString) as IFile
		}
		return YangDiagramPlugin.instance.getLanguageServer(sourceFile)
	}
	
	protected def handleLogMessage(LoggingAction action) {
		val parameters = if (action.params !== null && !action.params.empty) ' (' + action.params.join(', ') + ')' else ''
		val content = action.caller + ': ' + action.message + parameters
		val severity = switch action.severity {
			case 'error': IStatus.ERROR
			case 'warn': IStatus.WARNING
			default: IStatus.INFO
		}
		val messageStatus = new Status(severity, YangDiagramPlugin.PLUGIN_ID, content)
		StatusManager.manager.handle(messageStatus, StatusManager.LOG)
	}
	
}
