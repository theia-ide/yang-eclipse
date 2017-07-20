/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram

import com.google.gson.Gson
import org.eclipse.lsp4e.LanguageClientImpl

class DiagramAwareLanguageClientImpl extends LanguageClientImpl implements DiagramEndpoint {
	
	val gson = new Gson
	
	override accept(ActionMessage actionMessage) {
		val session = YangDiagramPlugin.instance.serverManager.getSessionFor(actionMessage.clientId)
		if (session !== null && session.isOpen) {
			val json = gson.toJson(actionMessage)
			session.asyncRemote.sendText(json)
		}
	}
	
}