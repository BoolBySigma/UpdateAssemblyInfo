import { Language } from './language';

export class Attribute {
    name: string;
    value: any;
    language: Language;
    format: string;
    lineIndex: number;
    constructor(name: string, value: any, language: Language, format: string, lineIndex?: number) {
        this.name = name;
        this.value = value;
        this.language = language;
        this.format = format;
        this.lineIndex = lineIndex;
    }

    getFormat = function (): string {
        if (typeof this.value === 'string') {
            return this.format.replace('{1}', '"{1}"');
        }
        return this.format;
    }

    getValue = function (): string {
        if (typeof this.value === 'boolean') {
            if (this.language === Language.Vb) {
                if (this.value) {
                    return 'True';
                }
                else {
                    return 'False';
                }
            }

            return this.value.toString();
        }

        return this.value;
    }

    toString = function (): string {
        let result: string = this.getFormat().replace('{0}', this.name);
        result = result.replace('{1}', this.getValue());

        return result;
    }
}