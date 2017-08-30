/*
 * Copyright (C) 2017 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */

import { Container } from "inversify"
import { createYangDiagramContainer } from 'yang-sprotty/lib'
import {
    WebSocketDiagramServer, TYPES
} from 'sprotty/lib'

export default function createContainer(): Container {
    const container = createYangDiagramContainer('sprotty')
    container.bind(TYPES.ModelSource).to(WebSocketDiagramServer).inSingletonScope()
    return container
}
