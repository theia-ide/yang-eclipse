/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram

import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IFile
import org.eclipse.jface.text.ITextSelection
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.lsp4e.LSPEclipseUtils
import org.eclipse.ui.IFileEditorInput
import org.eclipse.ui.IWorkbenchPage
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.handlers.HandlerUtil

class OpenDiagramHandler extends AbstractHandler {
	
	override execute(ExecutionEvent event) throws ExecutionException {
		val selection = HandlerUtil.getCurrentSelection(event)
		selection?.file?.openDiagram
		return null
	}
	
	protected def getFile(ISelection selection) {
		if(selection instanceof ITextSelection) {
			val editorInput = PlatformUI.workbench.activeWorkbenchWindow?.activePage?.activeEditor?.editorInput
			if(editorInput instanceof IFileEditorInput)
				return editorInput.file
		}
		if (selection instanceof IStructuredSelection) 
			selection.toList.filter(IFile).head
		
	}
 	
	protected def void openDiagram(IFile file) {
		val workbenchPage = PlatformUI.workbench.activeWorkbenchWindow?.activePage
		val fileUri = LSPEclipseUtils.toUri(file)
		val secondaryId = fileUri.path.replace(':', '%3A')
		val viewPart = workbenchPage?.showView(YangDiagramView.ID, secondaryId, IWorkbenchPage.VIEW_CREATE)
		if (viewPart !== null) {
			workbenchPage.activate(viewPart)
		}
	}
	
}