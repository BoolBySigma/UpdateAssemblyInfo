import { Language } from './language';
import { BooleanUtils } from './booleanUtils';
import { IAttribute, Attribute } from './attribute';

export class AttributeParser {
    attributeFormat = /^(\s*[\[<]<?\s*[Aa]ssembly\s*:\s*)(\w+?)(\s*\(\s*)(.*?)(\s*\)\s*>?[>\]].*)/;
    language: Language;

    constructor(language: Language) {
        this.language = language;
    }

    parse = function (lines: string[]): IAttribute[] {
        let attributes: IAttribute[] = [];

        for (let i in lines) {
            let line = lines[i];

            if (this.containsAttribute(line)) {
                let attribute = this.parseAttribute(line);
                attribute.lineIndex = i;

                attributes[attribute.name] = attribute;
            }
        }

        return attributes;
    }

    parseAttribute = function (text: string): IAttribute {
        let match = this.attributeFormat.exec(text);
        let name = match[2];
        let value = this.parseValue(match[4]);
        let format = match[1] + '{0}' + match[3] + '{1}' + match[5];
        return new Attribute(name, value, this.language, format);
    }

    parseValue = function (value: string): any {
        if (value === null || value === undefined) {
            return null;
        }

        /// string value
        if (value.startsWith('"') && value.endsWith('"')) {
            value = value.replace(/"/g, '');
            return value;
        }

        /// boolean value
        let result = BooleanUtils.tryParse(value);
        if (result.success) {
            return result.value;
        }

        return null;
    }

    containsAttribute = function (text: string): boolean {
        return this.attributeFormat.test(text);
    }
}