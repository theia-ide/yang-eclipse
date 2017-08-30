/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram

import io.typefox.yang.eclipse.diagram.server.SprottyServerManager
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.Plugin
import org.eclipse.lsp4e.LSPEclipseUtils
import org.eclipse.lsp4e.LanguageServersRegistry
import org.eclipse.lsp4e.LanguageServiceAccessor
import org.eclipse.xtend.lib.annotations.Accessors
import org.osgi.framework.BundleContext

class YangDiagramPlugin extends Plugin {
	
	public static val PLUGIN_ID = 'io.typefox.yang.eclipse.diagram'
	
	@Accessors(PUBLIC_GETTER)
	static YangDiagramPlugin instance
	
	@Accessors(PUBLIC_GETTER)
	val SprottyServerManager serverManager = new SprottyServerManager
	
	override start(BundleContext context) throws Exception {
		super.start(context)
		instance = this
	}
	
	override stop(BundleContext context) throws Exception {
		serverManager.stop()
		instance = null
		super.stop(context)
	}
	
	def getLanguageServer(String fileUri) {
		val sourceFile = LSPEclipseUtils.findResourceFor(fileUri)
		if (sourceFile instanceof IFile)
			return getLanguageServer(sourceFile)
	}
	
	def getLanguageServer(IFile file) {
		if (file !== null) {
			val definition = LanguageServersRegistry.instance.getDefinition('io.typefox.yang.eclipse.server')
			return LanguageServiceAccessor.getLanguageServer(file, definition)
		}
	}
	
}