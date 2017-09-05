/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.eclipse.diagram.server

import io.typefox.yang.eclipse.diagram.YangDiagramPlugin
import java.io.File
import java.net.InetSocketAddress
import javax.websocket.Session
import javax.websocket.server.ServerEndpointConfig
import org.eclipse.core.runtime.FileLocator
import org.eclipse.jetty.server.Server
import org.eclipse.jetty.servlet.DefaultServlet
import org.eclipse.jetty.servlet.ServletContextHandler
import org.eclipse.jetty.servlet.ServletHolder
import org.eclipse.jetty.websocket.jsr356.server.ServerContainer
import org.eclipse.jetty.websocket.jsr356.server.deploy.WebSocketServerContainerInitializer
import org.eclipse.xtend.lib.annotations.Accessors

class SprottyServerManager {
	
	@Accessors(PUBLIC_GETTER)
	Server server
	
	ServerContainer container
	
	def synchronized void start() {
		if (server === null || !server.isRunning) {
			server = new Server(new InetSocketAddress('localhost', 0))
			configure(server)
			server.start()
		}
	}
	
	protected def void configure(Server server) {
        val context = new ServletContextHandler(ServletContextHandler.SESSIONS)
        context.contextPath = '/'
        server.handler = context

        val defaultServletHolder = new ServletHolder('default', new DefaultServlet)
		// TODO support the case when this plug-in is packaged in a jar
		val bundle = YangDiagramPlugin.instance.bundle
        val resourceBase = new File(FileLocator.resolve(bundle.getResource('./diagram')).toURI).absolutePath
        defaultServletHolder.setInitParameter('resourceBase', resourceBase)
        defaultServletHolder.setInitParameter('dirAllowed', 'false')
        context.addServlet(defaultServletHolder, '/')

        container = WebSocketServerContainerInitializer.configureContext(context)
        val webSocketConfig = ServerEndpointConfig.Builder.create(WebsocketDiagramEndpoint, '/sprotty').build()
        container.addEndpoint(webSocketConfig)
        container.defaultMaxTextMessageBufferSize = 1 << 20
		
		server.stopAtShutdown = true
	}
	
	def synchronized void stop() {
		if (server !== null) {
			server.stop()
		}
	}
	
	def Session getSessionFor(String clientId) {
		container?.openSessions?.findFirst[userProperties.get('clientId') == clientId]
	}
	
}