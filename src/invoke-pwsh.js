
const core = require('@actions/core');
const exec = require('@actions/exec');
const path = require('path');

async function run() {
    try {
        const pwshFolder = __dirname.replace(/[/\\]_init$/, '');
        const pwshScript = `${pwshFolder}${path.sep}action.ps1`
        await exec.exec('pwsh', [ '-f', pwshScript ]);
    } catch (error) {
        core.setFailed(error.message);
    }
}
run();
