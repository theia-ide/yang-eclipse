/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse

import java.io.File
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Platform
import org.eclipse.lsp4e.server.ProcessStreamConnectionProvider
import org.eclipse.lsp4e.server.StreamConnectionProvider
import org.eclipse.xtend.lib.annotations.Delegate

class YangLanguageServer implements StreamConnectionProvider {
	
	static val SOCKET_MODE = false
	
	@Delegate
	val StreamConnectionProvider delegate

	new() {
		if (SOCKET_MODE) {
			this.delegate = new SocketStreamConnectionProvider(5007)
		} else {
			try {
				// TODO support the case when this plug-in is packaged in a jar
				val commands = newArrayList
				val executableFile = new File(FileLocator.resolve(executable).toURI)
				if(!executableFile.canExecute)
					executableFile.setExecutable(true, false)
				commands += executableFile.absolutePath
				this.delegate = new ProcessStreamConnectionProvider(commands, Platform.location.toOSString) {}
				Runtime.runtime.addShutdownHook(new Thread() {
					override run() {
						(delegate as ProcessStreamConnectionProvider)?.stop()
					}
				})
				
			} catch (Exception e) {
				throw new IllegalStateException(e)
			}
		}
	}
	
	private def getExecutable() {
		val bundle = Platform.getBundle('io.typefox.yang.eclipse')
		if (System.getProperty('os.name').toLowerCase.contains('win'))
			bundle.getResource('/language-server/bin/yang-language-server.bat')
		else
			bundle.getResource('/language-server/bin/yang-language-server')
	}
	
}
