/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
const webpack = require('webpack');
const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin');

const buildRoot = path.resolve(__dirname, 'lib');
const appRoot = path.resolve(__dirname, 'app');
const sprottyCssPath = 'node_modules/sprotty/css';

module.exports = function(env) {
    if (!env) {
        env = {}
    }
    const plugins = [
        new CopyWebpackPlugin([{
            from: sprottyCssPath,
            to: 'sprotty'
        }])
    ];
    if (env.uglify) {
        plugins.push(new webpack.optimize.UglifyJsPlugin());
    }
    return {
        entry: path.resolve(buildRoot, 'main'),
        output: {
            filename: 'bundle.js',
            path: appRoot
        },
        resolve: {
            extensions: ['.js']
        },
        devtool: 'source-map',
        target: 'web',
        node: {
            fs: 'empty',
            child_process: 'empty',
            net: 'empty',
            crypto: 'empty'
        },
        plugins: plugins
    }
}