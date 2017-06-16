import * as task from 'vsts-task-lib/task';

async function run() {
    try {
        var assemblyInfoFiles = task.getPathInput('assemblyInfoFiles', false, false);

        var ensureAttribute = task.getBoolInput('ensureAttribute', false);
        var description = task.getInput('description', false);
        var configuration = task.getInput('configuration', false);
        var company = task.getInput('company', false);
        var product = task.getInput('product', false);
        var copyright = task.getInput('copyright', false);
        var trademark = task.getInput('trademark', false);
        var culture = task.getInput('culture', false);
        var informationalVersion = task.getInput('informationalVersion', false);
        var comVisible = task.getInput('comVisible', false);
        var clsCompliant = task.getInput('clsCompliant', false);

        var fileVersionMajor = task.getInput('fileVersionMajor', false);
        var fileVersionMinor = task.getInput('fileVersionMinor', false);
        var fileVersionBuild = task.getInput('fileVersionBuild', false);
        var fileVersionRevision = task.getInput('fileVersionRevision', false);

        var assemblyVersionMajor = task.getInput('assemblyVersionMajor', false);
        var assemblyVersionMinor = task.getInput('assemblyVersionMinor', false);
        var assemblyVersionBuild = task.getInput('assemblyVersionBuild', false);
        var assemblyVersionRevision = task.getInput('assemblyVersionRevision', false);

        var customAttributes = task.getInput('customAttributes', false);

    } catch (error) {
        task.setResult(task.TaskResult.Failed, error.message);
    }
}

run();