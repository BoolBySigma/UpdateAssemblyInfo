import * as task from 'vsts-task-lib/task';
import { StringUtils } from './stringUtils';
import * as numeral from 'numeral';

export class BuildNumberRevisionVariable {
    private buildNumberRevision: number;

    constructor(buildNumberRevision: number) {
        this.buildNumberRevision = buildNumberRevision
    }

    replace = function (value: string): string {
        task.debug('BuildNumberRevisionVariable.replace');
        task.debug('value: ' + value);

        if (StringUtils.isNullOrEmpty(value)) {
            return '';
        }

        var variables = value.match(/(\$\(Rev:([^\)]*)\))/g);
        task.debug('variables: ' + variables);

        if (!variables) {
            return value;
        }

        for (let variable of variables) {
            task.debug('variable: ' + variable);
            var formats = variable.match(/\$\(Rev:([^\)]*)\)/);
            var format = formats[1];
            task.debug('format: ' + format);

            format = format.replace(/r/g, '0');
            task.debug('format: ' + format);

            value = value.replace(variable, numeral(this.buildNumberRevision).format(format));
            task.debug('value: ' + value);
        }

        return value;
    }

    static isUsed = function (parameters: string[]): boolean {
        task.debug('BuildNumberRevisionVariable.isUsed');
        var variableFormat = RegExp(/(\$\(Rev:([^\)]*)\))/g);
        for (let parameter of parameters) {
            if (variableFormat.test(parameter)) {
                task.debug('$(Rev) used in \'' + parameter + '\'');
                return true;
            }
        }

        return false;
    }
}