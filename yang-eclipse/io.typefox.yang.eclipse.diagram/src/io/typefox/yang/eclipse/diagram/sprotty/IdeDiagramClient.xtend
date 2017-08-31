package io.typefox.yang.eclipse.diagram.sprotty

import org.eclipse.lsp4j.jsonrpc.services.JsonNotification
import org.eclipse.lsp4j.jsonrpc.services.JsonSegment

@JsonSegment('diagram')
interface IdeDiagramClient extends DiagramEndpoint {

	@JsonNotification
	def void openInTextEditor(OpenInTextEditorMessage message)
	
}
