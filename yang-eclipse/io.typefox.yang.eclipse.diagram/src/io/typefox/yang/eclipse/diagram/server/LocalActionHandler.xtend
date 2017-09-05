package io.typefox.yang.eclipse.diagram.server

import com.google.gson.JsonObject
import io.typefox.yang.eclipse.diagram.YangDiagramView
import io.typefox.yang.eclipse.diagram.sprotty.ActionMessage
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.dialogs.SaveAsDialog
import org.eclipse.xtext.util.StringInputStream
import org.eclipse.core.runtime.Path
import org.eclipse.swt.widgets.Composite

/**
 * Handles actions received from the client via the websocket instead of 
 * passing it to the server.
 */
class LocalActionHandler {

	def boolean handleLocally(ActionMessage actionMessage) {
		val action = actionMessage.action as JsonObject
		switch ((action).get('kind').asString) {
			case 'exportSvg':
				return handleExportToSvgAction(actionMessage)
			default:
				return false
		}
	}

	protected def boolean handleExportToSvgAction(ActionMessage actionMessage) {
		val action = actionMessage.action as JsonObject
		val svg = action.get('svg').asString
		Display.^default.asyncExec [
			val part = PlatformUI.workbench.activeWorkbenchWindow.activePage.activePart
			val root = ResourcesPlugin.workspace.root
			val proposedPath = if(part instanceof YangDiagramView) {
					val yangFile = root.getFileForLocation(new Path(part.filePath))
					yangFile.fullPath.removeFileExtension.addFileExtension('svg')
				} else {
					new Path('diagram.svg')
				}
			val activeShell = Display.^default.activeShell
			val saveAsDialog = new SaveAsDialog(activeShell) {
				
				override protected createContents(Composite parent) {
					val result = super.createContents(parent)
					title = 'Export to SVG'
					message = 'Choose the name and location of the SVG file.'
					result
				}
				
			}
			saveAsDialog.title = 'Export to SVG'
			saveAsDialog.originalFile = root.getFile(proposedPath)
			val result = saveAsDialog.open
			if(result == SaveAsDialog.OK) {
				val file = (root).getFile(saveAsDialog.result)
				val stream = new StringInputStream(svg)
				if(file.exists) 
					file.setContents(stream, true, true, null)
				else
					file.create(stream, true, null)
			}
		]
		return true
	}
}
