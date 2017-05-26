export interface IParseResult {
    success: boolean;
    value: boolean;
}
export class BooleanUtils {
    static tryParse = function (value: string): IParseResult {
        if (value === null || value === undefined) {
            return { success: false, value: null };
        }
        value = value.toLowerCase();

        let result: IParseResult = { success: false, value: null };

        if (value === 'true'){
            result.success = true;
            result.value = true;
        }
        if (value === 'false'){
            result.success = true;
            result.value = false;
        }

        return result;
    }
}