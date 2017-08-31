package io.typefox.yang.eclipse.diagram.sprotty

import com.google.gson.JsonElement
import org.eclipse.lsp4j.Location
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString

@Accessors
@ToString
class ActionMessage {
	String clientId
	JsonElement action
}

@Accessors
@ToString
class OpenInTextEditorMessage {
	Location location
	boolean forceOpen
}
