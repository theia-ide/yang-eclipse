# yang-eclipse

An Eclipse Plug-in for YANG using a YANG nanguage server and a sprotty diagram

## Getting Started

Point your Eclipse update manager to our [Jenkins update-site](http://services.typefox.io/open-source/jenkins/job/yang-eclipse/job/master/lastSuccessfulBuild/artifact/yang-eclipse/io.typefox.yang.eclipse.repository/target/repository/)

## Build It Yourself

```bash
git clone https://github.com/yang-tools/yang-eclipse.git
cd yang-eclipse/diagram
yarn install
yarn run setup
yarn run build
cd ../yang-eclipse
mvn clean install
```
