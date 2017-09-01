package io.typefox.yang.eclipse

import org.eclipse.lsp4e.LSPEclipseUtils
import org.eclipse.lsp4e.LanguageServiceAccessor
import org.eclipse.lsp4j.TextDocumentIdentifier
import org.eclipse.lsp4j.TextDocumentPositionParams
import org.eclipse.swt.custom.CaretListener
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.internal.genericeditor.ExtensionBasedTextEditor

class YangEditor extends ExtensionBasedTextEditor {
	
	CaretListener caretListener = [
			val document = documentProvider.getDocument(editorInput)
			val infos = LanguageServiceAccessor.getLSPDocumentInfosFor(document)
				[ capabilities | capabilities.getDocumentHighlightProvider() ]
			val position = LSPEclipseUtils.toPosition(caretOffset, document)
			infos.forEach[ info |
				val identifier = new TextDocumentIdentifier(info.getFileUri().toString());
				val params = new TextDocumentPositionParams(identifier, position);
				info.languageClient.textDocumentService.documentHighlight(params)
			]
		]
	
	override createPartControl(Composite parent) {
		super.createPartControl(parent)
		sourceViewer.textWidget.addCaretListener(caretListener)
	}
	
	override dispose() {
		sourceViewer.textWidget.removeCaretListener(caretListener)
		super.dispose()
	}
}