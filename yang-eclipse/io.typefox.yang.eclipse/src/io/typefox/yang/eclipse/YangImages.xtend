/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */

package io.typefox.yang.eclipse

import java.net.URL
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.jface.resource.ImageRegistry
import org.eclipse.lsp4j.SymbolKind
import org.eclipse.swt.graphics.Image

class YangImages {
	
	private new() {
	}

	static ImageRegistry imageRegistry

	static val String ICONS_PATH = "$nl$/icons/"
	
	static val String OBJECT = ICONS_PATH 
	
	public static val String IMG_ACTION = "IMG_ACTION"
	
	public static val String IMG_AUGMENT = "IMG_AUGMENT"
	
	public static val String IMG_CASE = "IMG_CASE"
	
	public static val String IMG_CHOICE = "IMG_CHOICE"
	
	public static val String IMG_CONTAINER = "IMG_CONTAINER"
	
	public static val String IMG_EXTENSION = "IMG_EXTENSION"
	
	public static val String IMG_FEATURE = "IMG_FEATURE"
	
	public static val String IMG_GROUPING = "IMG_GROUPING"
	
	public static val String IMG_IDENTITY = "IMG_IDENTITY"

	public static val String IMG_INPUT = "IMG_INPUT"
	
	public static val String IMG_LEAF = "IMG_LEAF"
	
	public static val String IMG_LIST = "IMG_LIST"

	public static val String IMG_MODULE = "IMG_MODULE"

	public static val String IMG_NOTIFICATION = "IMG_NOTIFICATION"

	public static val String IMG_OUTPUT = "IMG_OUTPUT"
	
	public static val String IMG_RPC = "IMG_RPC"	

	public static val String IMG_TYPEDEF = "IMG_TYPEDEF"	
	
	def static void initalize(ImageRegistry registry) {
		imageRegistry = registry
		declareRegistryImage(IMG_ACTION, '''«OBJECT»action.png''')
		declareRegistryImage(IMG_AUGMENT, '''«OBJECT»augment.png''')
		declareRegistryImage(IMG_CASE, '''«OBJECT»case.png''')
		declareRegistryImage(IMG_CHOICE, '''«OBJECT»choice.png''')
		declareRegistryImage(IMG_CONTAINER, '''«OBJECT»container.png''')
		declareRegistryImage(IMG_EXTENSION, '''«OBJECT»extension.png''')
		declareRegistryImage(IMG_FEATURE, '''«OBJECT»feature.png''')
		declareRegistryImage(IMG_GROUPING, '''«OBJECT»grouping.png''')
		declareRegistryImage(IMG_IDENTITY, '''«OBJECT»identity.png''')
		declareRegistryImage(IMG_INPUT, '''«OBJECT»input.png''')
		declareRegistryImage(IMG_LEAF, '''«OBJECT»leaf.png''')
		declareRegistryImage(IMG_LIST, '''«OBJECT»list.png''')
		declareRegistryImage(IMG_MODULE, '''«OBJECT»module.png''')
		declareRegistryImage(IMG_NOTIFICATION, '''«OBJECT»notification.png''')
		declareRegistryImage(IMG_OUTPUT, '''«OBJECT»output.png''')
		declareRegistryImage(IMG_RPC, '''«OBJECT»rpc.png''')
		declareRegistryImage(IMG_TYPEDEF, '''«OBJECT»typedef.png''')
	}

	def private final static void declareRegistryImage(String key, String path) {
		var desc = ImageDescriptor.missingImageDescriptor
		var bundle = Platform.getBundle(YangEclipseActivator.PLUGIN_ID)
		var URL url = null
		if (bundle !== null) {
			url = FileLocator.find(bundle, new Path(path), null)
			if (url !== null) {
				desc = ImageDescriptor.createFromURL(url)
			}
		}
		imageRegistry.put(key, desc)
	}

	def static Image getImage(String key) {
		return imageRegistry.get(key)
	}

	def static ImageDescriptor getImageDescriptor(String key) {
		return imageRegistry.getDescriptor(key)
	}

	def static ImageRegistry getImageRegistry() {
		if (imageRegistry === null) {
			imageRegistry = YangEclipseActivator.instance.imageRegistry
		}
		return imageRegistry
	}

	def static Image imageFromSymbolKind(SymbolKind kind) {

		switch (kind) {
			/*
			 case Boolean: {
				return getImage(IMG_BOOLEAN)
			}
			case Class: {
				return getImage(IMG_CLASS)
			}
			case Constant: {
				return getImage(IMG_CONSTANT)
			}
			case Field: {
				return getImage(IMG_FIELD)
			}
			case Function: {
				return getImage(IMG_FUNCTION)
			}
			case Module: {
				return getImage(IMG_MODULE)
			}
			case Number: {
				return getImage(IMG_NUMBER)
			}
			case Property: {
				return getImage(IMG_PROPERTY)
			}*/
			default: {
				getImage(IMG_AUGMENT)
			}
		}
		return null
	}
}
