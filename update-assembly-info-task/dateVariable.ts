import * as task from 'vsts-task-lib/task';
import { StringUtils } from './stringUtils';
import * as dateformat from 'dateformat';

export class DateVariable {
    private date?: Date;

    constructor(date: Date = new Date()){
        this.date = date;
    }

    replace = function (value: string): string {
        task.debug('DateVariable.replace');
        task.debug('value: ' + value);

        if (StringUtils.isNullOrEmpty(value)) {
            return '';
        }

        var variables = value.match(/(\$\(Date:([^)]*))\)/g);
        task.debug('variables: ' + variables);

        if (!variables) {
            return value;
        }

        for (let variable of variables) {
            task.debug('variable: ' + variable);
            var formats = variable.match(/\$\(Date:([^)]*)\)/);
            var format = formats[1];
            task.debug('format: ' + format);

            var formattedDate = dateformat(this.date, format);
            task.debug('formattedDate: ' + formattedDate);

            value = value.replace(variable, formattedDate);
            task.debug('value: ' + value);
        }

        return value;
    }
}