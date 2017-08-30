/*
 * Copyright (C) 2017 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */

// FIXME This code has been copied from the yangster repository. It should be extracted to a separate package.

import { Container, ContainerModule } from "inversify"
import {
    ClassNodeView, CompositionEdgeView, DashedEdgeView, ImportEdgeView, ModuleNodeView, NoteView,
    ArrowEdgeView, YangClassHeaderView, ChoiceNodeView, CaseNodeView
} from "./views"
import { YangDiagramFactory } from "./model-factory"
import {
    boundsModule,
    defaultModule,
    exportModule,
    hoverModule,
    HtmlRootView,
    moveModule,
    overrideViewerOptions,
    PolylineEdgeView,
    PreRenderedView,
    SCompartmentView,
    selectModule,
    SGraphView,
    SLabelView,
    TYPES,
    undoRedoModule,
    viewportModule,
    ViewRegistry,
    WebSocketDiagramServer,
    LogLevel,
    ForwardingLogger
} from 'sprotty/lib'

const yangDiagramModule = new ContainerModule((bind, unbind, isBound, rebind) => {
    rebind(TYPES.ILogger).to(ForwardingLogger).inSingletonScope()
    rebind(TYPES.LogLevel).toConstantValue(LogLevel.info)
    rebind(TYPES.IModelFactory).to(YangDiagramFactory).inSingletonScope()
    bind(TYPES.ModelSource).to(WebSocketDiagramServer).inSingletonScope()
})

export default function createContainer(): Container {
    const container = new Container()
    container.load(defaultModule, selectModule, moveModule, boundsModule, undoRedoModule, viewportModule,
        hoverModule, exportModule, yangDiagramModule)
    overrideViewerOptions(container, {
        needsClientLayout: true,
        needsServerLayout: true
    })

    // Register views
    const viewRegistry = container.get<ViewRegistry>(TYPES.ViewRegistry)
    viewRegistry.register('graph', SGraphView)
    viewRegistry.register('node:class', ClassNodeView)
    viewRegistry.register('node:module', ModuleNodeView)
    viewRegistry.register('node:choice', ChoiceNodeView)
    viewRegistry.register('node:case', CaseNodeView)
    viewRegistry.register('node:note', NoteView)
    viewRegistry.register('label:heading', SLabelView)
    viewRegistry.register('label:text', SLabelView)
    viewRegistry.register('comp:comp', SCompartmentView)
    viewRegistry.register('comp:classHeader', YangClassHeaderView)
    viewRegistry.register('edge:straight', PolylineEdgeView)
    viewRegistry.register('edge:composition', CompositionEdgeView)
    viewRegistry.register('edge:dashed', DashedEdgeView)
    viewRegistry.register('edge:import', ImportEdgeView)
    viewRegistry.register('edge:uses', ArrowEdgeView)
    viewRegistry.register('edge:augments', ArrowEdgeView)
    viewRegistry.register('html', HtmlRootView)
    viewRegistry.register('pre-rendered', PreRenderedView)

    return container
}
