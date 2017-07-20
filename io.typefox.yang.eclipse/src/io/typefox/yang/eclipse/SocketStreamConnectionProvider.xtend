/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse

import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.net.Socket
import org.eclipse.lsp4e.server.StreamConnectionProvider
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class SocketStreamConnectionProvider implements StreamConnectionProvider {

	val int port
	
	Socket socket
	InputStream inputStream
	OutputStream outputStream

	override start() throws IOException {
		socket = new Socket('localhost', port)
		inputStream = new BufferedInputStream(socket.inputStream)
		outputStream = new BufferedOutputStream(socket.outputStream)
	}

	override getInputStream() {
		return inputStream
	}

	override getOutputStream() {
		return outputStream
	}

	override stop() {
		if (socket !== null) {
			try {
				socket.close()
			} catch (IOException e) {
				e.printStackTrace()
			}
		}
	}
}