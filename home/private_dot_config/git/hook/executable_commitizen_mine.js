#!/usr/bin/env node
"use strict";

const path = require('path');
const bootstrap = require('commitizen/dist/cli/git-cz').bootstrap;

bootstrap({
  cliPath: path.join(process.env.NODE_PATH, '/commitizen'),
  // this is new
  config: {
    "path": "cz-conventional-changelog-zh"
  }
});
