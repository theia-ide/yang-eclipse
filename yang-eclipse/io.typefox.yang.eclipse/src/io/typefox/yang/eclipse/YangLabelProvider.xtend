package io.typefox.yang.eclipse

import org.eclipse.lsp4e.outline.SymbolsLabelProvider
import org.eclipse.lsp4j.SymbolInformation

import static io.typefox.yang.eclipse.YangImages.*

class YangLabelProvider extends SymbolsLabelProvider {
	
	new() {
		super(false, false)
	}
	
	override getImage(Object element) {
		if (element instanceof SymbolInformation) {
			switch element.kind {
				case Array:
					return YangImages.getImage(IMG_LIST)
				case Boolean:
					return YangImages.getImage(IMG_FEATURE)
				case Class:
					return YangImages.getImage(IMG_GROUPING)
				case Constant:
					return YangImages.getImage(IMG_IDENTITY)
				case Constructor:
					return YangImages.getImage(IMG_OUTPUT)
				case Enum:
					return YangImages.getImage(IMG_TYPEDEF)
				case Function:
					return YangImages.getImage(IMG_NOTIFICATION)
				case Field:
					return YangImages.getImage(IMG_FEATURE)
				case Property: 
					return YangImages.getImage(IMG_INPUT)
				case Method: 
					return YangImages.getImage(IMG_RPC)
				case Module: 
					return YangImages.getImage(IMG_EXTENSION)
				case Namespace: 
					return YangImages.getImage(IMG_CONTAINER)
				case Number: 
					return YangImages.getImage(IMG_CHOICE)
				case String: 
					return YangImages.getImage(IMG_CASE)
				case Variable: 
					return YangImages.getImage(IMG_LEAF)
			}			
		}
		super.getImage(element)
	}
	
}