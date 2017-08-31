/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram

import java.net.URI
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.jface.text.IDocument
import org.eclipse.lsp4j.Position
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.part.FileEditorInput
import org.eclipse.ui.texteditor.ITextEditor
import io.typefox.yang.eclipse.diagram.sprotty.OpenInTextEditorMessage

class YangEditorOpener {
	
	def openInTextEditor(OpenInTextEditorMessage message) {
		val fileURI = URI.create(message.location.uri)
		val workspaceRoot = ResourcesPlugin.workspace.root
		val workspaceURI = workspaceRoot.locationURI
		val workspaceRelativeURI = workspaceURI.relativize(fileURI)
		if (workspaceRelativeURI !== fileURI) {
			val file = workspaceRoot.getFile(new Path(workspaceRelativeURI.toString))
			if(file.accessible) {
				val editorInput = new FileEditorInput(file)
				Display.^default.asyncExec [
					val editor = PlatformUI.workbench.activeWorkbenchWindow.activePage.openEditor(editorInput, 'io.typefox.YangEditor')
					if (editor instanceof ITextEditor) {
						val document = editor.documentProvider.getDocument(editorInput)
						val range = message.location.range
						editor.selectAndReveal(document.getOffset(range.start), 0)
					}
				]
			}
		}
	}
	
	protected def getOffset(IDocument document, Position position) {
		document.getLineOffset(position.line) + position.character
	} 
	
}