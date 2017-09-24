package io.typefox.yang.eclipse.diagram.sprotty

import com.google.gson.JsonObject
import java.util.List
import org.eclipse.lsp4j.Location
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString

@Accessors
@ToString
class ActionMessage {
	String clientId
	JsonObject action
}

@Accessors
@ToString
class OpenInTextEditorMessage {
	Location location
	boolean forceOpen
}

@Accessors
@ToString(skipNulls = true)
class LoggingAction {
	public static val KIND = 'logging'
	String kind = KIND
	
	String severity
	String time
	String caller
	String message
	List<String> params
}

@Accessors
@ToString(skipNulls = true)
class ExportSvgAction {
    public static val KIND = 'exportSvg'
    String svg
    String kind = KIND

}

@Accessors
@ToString(skipNulls = true)
class ServerStatusAction {
    public static val KIND = 'serverStatus'
    String severity
    String message
    String kind = KIND
}