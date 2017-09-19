/*
 * Copyright (C) 2017 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */

import 'reflect-metadata';
import { TYPES, WebSocketDiagramServer, RequestModelAction, ActionHandlerRegistry, SelectCommand } from "sprotty/lib"
import { getParameters } from "./url-parameters"
import createContainer from "./di.config"

const WebSocket = require("reconnecting-websocket")

const urlParameters = getParameters()
const sourcePath = urlParameters.path.replace('/%3A/g', ':')
if (sourcePath) {
    const container = createContainer()
    const websocket = new WebSocket('ws://' + window.location.host + '/sprotty')

    const diagramServer = container.get<WebSocketDiagramServer>(TYPES.ModelSource)
    const actionHandlerRegistry = container.get<ActionHandlerRegistry>(TYPES.ActionHandlerRegistry)
    actionHandlerRegistry.register(SelectCommand.KIND, diagramServer)

    if (urlParameters.client)
        diagramServer.clientId = urlParameters.client
    diagramServer.listen(websocket)

    const link = document.createElement('link')
    link.rel = 'stylesheet'
    link.type = 'text/css'
    link.href = (urlParameters.theme === 'dark') 
        ? 'css/dark/diagram.css'
        : 'css/light/diagram.css'
    document.getElementsByTagName('head')[0].appendChild(link)
        
    websocket.addEventListener('open', event => {
        diagramServer.handle(new RequestModelAction({ sourceUri: 'file://' + sourcePath }))
    })

    websocket.addEventListener('error', event => {
        const element = document.getElementById('sprotty')!
        if (element.firstChild === null || element.firstChild.nodeName !== 'svg') {
            if (event.type === 'error')
                // Cannot derive further information from event
                element.innerHTML = `Cannot open diagram for ${sourcePath}`
            else
                element.innerHTML = `Cannot open diagram for ${sourcePath}<pre>${event}</pre>`
        }
    })
}
