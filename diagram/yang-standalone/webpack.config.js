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
const yangThemes = 'node_modules/yang-sprotty/css/themes';
const sprottyCss = 'node_modules/sprotty/css';

module.exports = function(env) {
    if (!env) {
        env = {}
    }
    const plugins = [
        new CopyWebpackPlugin([{
            from: yangThemes,
            to: 'css'
        },{
            from: sprottyCss,
            to: 'css'
        }])
    ];
    if (env.uglify) {
        plugins.push(new webpack.optimize.UglifyJsPlugin());
    }
    return {
        entry: [
            'core-js/es6/map', 
            'core-js/es6/promise', 
            'core-js/es6/string', 
            'core-js/es6/symbol', 
            path.resolve(buildRoot, 'main')
        ],
        output: {
            filename: 'bundle.js',
            path: appRoot
        },
        resolve: {
            extensions: ['.js']
        },
        devtool: 'inline-source-map',
        target: 'web',
        node: {
            fs: 'empty',
            child_process: 'empty',
            net: 'empty',
            crypto: 'empty'
        },
        plugins: plugins,
        module: {
            rules: [
                {
                    test: /\.css$/,
                    loader: 'style-loader!css-loader'
                },
                {
                    test: /\.(ttf|eot|svg)(\?v=\d+\.\d+\.\d+)?$/,
                    loader: 'url-loader?limit=10000&mimetype=image/svg+xml'
                },
                {
                    test: /\.js$/,
                    enforce: 'pre',
                    loader: 'source-map-loader'
                },
                {
                    test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                    loader: "url-loader?limit=10000&mimetype=application/font-woff"
                }
            ],
            noParse: /vscode-languageserver-types|vscode-uri/
        }
    }
}