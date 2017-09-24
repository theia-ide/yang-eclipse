/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram.server

import com.google.gson.Gson
import io.typefox.yang.eclipse.diagram.YangDiagramPlugin
import io.typefox.yang.eclipse.diagram.YangEditorOpener
import io.typefox.yang.eclipse.diagram.sprotty.ActionMessage
import io.typefox.yang.eclipse.diagram.sprotty.IdeDiagramClient
import io.typefox.yang.eclipse.diagram.sprotty.OpenInTextEditorMessage
import org.eclipse.lsp4e.LanguageClientImpl

class DiagramAwareLanguageClientImpl extends LanguageClientImpl implements IdeDiagramClient {
	
	val gson = new Gson
	
	val opener = new YangEditorOpener
	
	val localActionHandler = new LocalActionHandler()
	
	override accept(ActionMessage actionMessage) {
		val session = YangDiagramPlugin.instance.serverManager.getSessionFor(actionMessage.clientId)
		if (!localActionHandler.handleLocally(actionMessage)) {
			if (session !== null && session.isOpen) {
				val json = gson.toJson(actionMessage)
				session.asyncRemote.sendText(json)
			}
		}
	}
	
	override openInTextEditor(OpenInTextEditorMessage message) {
		opener.openInTextEditor(message)
		return
	}
	
	
}