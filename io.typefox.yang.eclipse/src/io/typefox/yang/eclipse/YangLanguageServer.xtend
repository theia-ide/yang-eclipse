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
	
	static val SOCKET_MODE = true
	
	@Delegate
	val StreamConnectionProvider delegate

	new() {
		if (SOCKET_MODE) {
			this.delegate = new SocketStreamConnectionProvider(5007)
		} else {
			try {
				val commands = newArrayList
				commands += new File(FileLocator.resolve(executable).toURI).absolutePath
				this.delegate = new ProcessStreamConnectionProvider(commands, Platform.location.toOSString) {}
			} catch (Exception e) {
				throw new IllegalStateException(e)
			}
		}
	}
	
	private def getExecutable() {
		val bundle = Platform.getBundle('io.typefox.yang.eclipse')
		if (System.getProperty('os.name').toLowerCase.contains('win'))
			bundle.getResource('/yang-language-server/bin/yang-language-server.bat')
		else
			bundle.getResource('/yang-language-server/bin/yang-language-server')
	}
	
}
