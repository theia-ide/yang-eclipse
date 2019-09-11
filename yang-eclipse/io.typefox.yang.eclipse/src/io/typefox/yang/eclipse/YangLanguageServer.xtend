/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse

import java.io.File
import java.io.IOException
import java.util.ArrayList
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Platform
import org.eclipse.lsp4e.server.ProcessStreamConnectionProvider
import org.eclipse.lsp4e.server.StreamConnectionProvider
import org.eclipse.xtend.lib.annotations.Delegate
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

class YangLanguageServer implements StreamConnectionProvider {
	
	static val SOCKET_MODE = false
	
	@Delegate
	val StreamConnectionProvider delegate

	new() {
		this.delegate = if (SOCKET_MODE) {
			new SocketStreamConnectionProvider(5007)
		} else {
			try {
				val executableUrl = getExecutable
				if (executableUrl === null)
					throw new IllegalStateException("Could not find YANG language server.")
				// TODO support the case when this plug-in is packaged in a jar
				val executableFile = new File(FileLocator.resolve(executableUrl).toURI)
				if (!executableFile.canExecute)
					executableFile.setExecutable(true, false)
				val commands = new ArrayList
				commands += executableFile.absolutePath
				new ProcessStreamConnectionProvider(commands, Platform.location.toOSString) {}
			} catch (Exception e) {
				new NullStreamConnectionProvider(e)
			}
		}
		if (delegate instanceof ProcessStreamConnectionProvider) {
			Runtime.runtime.addShutdownHook(new Thread [
				(delegate as ProcessStreamConnectionProvider)?.stop()
			])
		}
	}
	
	private def getExecutable() {
		val bundle = Platform.getBundle('io.typefox.yang.eclipse')
		if (System.getProperty('os.name').toLowerCase.contains('win'))
			bundle.getResource('/language-server/bin/yang-language-server.bat')
		else
			bundle.getResource('/language-server/bin/yang-language-server')
	}
	
	@FinalFieldsConstructor
	static class NullStreamConnectionProvider implements StreamConnectionProvider {
		
		val Exception cause
		
		override getInputStream() {
			throw new RuntimeException(cause)
		}
		
		override getOutputStream() {
			throw new RuntimeException(cause)
		}

		override getErrorStream() {
			throw new RuntimeException(cause)
		}

		override start() throws IOException {
			throw new RuntimeException(cause)
		}
		
		override stop() {
			throw new RuntimeException(cause)
		}
		
	}
	
}
