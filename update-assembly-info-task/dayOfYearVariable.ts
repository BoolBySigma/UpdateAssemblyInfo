import * as task from 'vsts-task-lib/task';
import { StringUtils } from './stringUtils';
import * as dayOfYear from 'current-day-number';

export class DayOfYearVariable {
    replace = function(value: string): string{
        task.debug('DayOfYearVariable.replace');
        task.debug('value: ' + value);

        if (StringUtils.isNullOrEmpty(value)){
            return '';
        }

        value = value.replace(/\$\(DayOfYear\)/g, dayOfYear());
        task.debug('value: ' + value);

        return value;
    }
}