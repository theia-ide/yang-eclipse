# yang-eclipse

An Eclipse Plug-in for YANG using a [YANG language server](https://github.com/theia-ide/yang-lsp) and a [YANG diagram](https://github.com/theia-ide/yang-sprotty) based on [sprotty]().

## Install it

YANG for Eclipse is available from the [Eclipse Marketplace](https://marketplace.eclipse.org/content/yang-eclipse). Just drag this button to your running Eclipse

[![Drag to your running Eclipse* workspace. *Requires Eclipse Marketplace Client](https://marketplace.eclipse.org/sites/all/themes/solstice/public/images/marketplace/btn-install.png)](http://marketplace.eclipse.org/marketplace-client-intro?mpc_install=3710118 "Drag to your running Eclipse* workspace. *Requires Eclipse Marketplace Client") 

## Build It Yourself

Requirements: Java 8, node 8, yarn 1.0.2

```bash
git clone --recursive https://github.com/theia-ide/yang-eclipse.git
cd yang-eclipse/diagram
yarn 
cd ../yang-eclipse
mvn clean install
```
