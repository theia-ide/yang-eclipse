package io.typefox.yang.eclipse.diagram.server

import com.google.gson.Gson
import com.google.gson.JsonObject
import io.typefox.yang.eclipse.diagram.YangDiagramPlugin
import io.typefox.yang.eclipse.diagram.YangDiagramView
import io.typefox.yang.eclipse.diagram.sprotty.ActionMessage
import io.typefox.yang.eclipse.diagram.sprotty.LoggingAction
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Status
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.dialogs.SaveAsDialog
import org.eclipse.ui.statushandlers.StatusManager
import org.eclipse.xtext.util.StringInputStream
import io.typefox.yang.eclipse.diagram.sprotty.ExportSvgAction
import io.typefox.yang.eclipse.diagram.sprotty.ServerStatusAction

/**
 * Handles actions received from the client via the websocket instead of 
 * passing it to the server.
 */
class LocalActionHandler {

	val gson = new Gson
	
	def boolean handleLocally(ActionMessage actionMessage) {
		val action = actionMessage.action as JsonObject
		switch ((action).get('kind').asString) {
			case LoggingAction.KIND:
				return handleLogMessage(gson.fromJson(action, LoggingAction))
			case ExportSvgAction.KIND:
				return handleExportSvgAction(gson.fromJson(action, ExportSvgAction))
			case ServerStatusAction.KIND:
				return handleServerStatus(gson.fromJson(action, ServerStatusAction), actionMessage.clientId)
			default:
				return false
		}
	}
	
	protected def boolean handleExportSvgAction(ExportSvgAction action) {
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
				val stream = new StringInputStream(action.svg)
				if(file.exists) 
					file.setContents(stream, true, true, null)
				else
					file.create(stream, true, null)
			}
		]
		return true
	}

	protected def handleServerStatus(ServerStatusAction serverStatus, String theClientId) {
		Display.^default.asyncExec [
			PlatformUI
				.workbench
				.activeWorkbenchWindow
				.activePage
				.viewReferences
				.filter[ id == YangDiagramView.ID ]
				.map[ getPart(true) ]
				.filter(YangDiagramView)
				.filter[ clientId == theClientId ]
				.forEach [ showServerState(serverStatus) ]
		]
		return true
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
		return true
	}
}
