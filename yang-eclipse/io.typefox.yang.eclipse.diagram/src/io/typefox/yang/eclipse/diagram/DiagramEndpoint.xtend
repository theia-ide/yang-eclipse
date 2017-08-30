/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram

import com.google.gson.JsonElement
import org.eclipse.lsp4j.jsonrpc.services.JsonNotification
import org.eclipse.lsp4j.jsonrpc.services.JsonSegment
import org.eclipse.lsp4j.services.LanguageServer
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString

@JsonSegment('diagram')
interface DiagramEndpoint {

	@JsonNotification
	def void accept(ActionMessage actionMessage);

}

@Accessors
@ToString
class ActionMessage {
	String clientId
	JsonElement action
}

@JsonSegment('diagram')
interface DiagramServer extends DiagramEndpoint {
	
	@JsonNotification
	def void didClose(String clientId)
	
}

interface DiagramAwareLanguageServer extends LanguageServer, DiagramServer {
	
}
