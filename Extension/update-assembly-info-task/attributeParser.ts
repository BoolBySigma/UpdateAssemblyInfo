import { Language } from './language';
import { BooleanUtils } from './booleanUtils';
import { IAttribute, Attribute } from './attribute';
import { Line } from './line';

export class AttributeParser {
    attributeFormat = /^(\s*[\[<]<?\s*[Aa]ssembly\s*:\s*)(\w+?)(\s*\(\s*)(.*?)(\s*\)\s*>?[>\]].*)/;
    language: Language;

    constructor(language: Language) {
        this.language = language;
    }

    parse = function (lines: Line[]): IAttribute[] {
        let attributes: IAttribute[] = [];

        for (let i in lines) {
            let line: Line = lines[i];

            if (line.isComment){
                continue;
            }

            if (this.containsAttribute(line.text)) {
                let attribute = this.parseAttribute(line.text);
                attribute.lineIndex = i;

                attributes[attribute.name] = attribute;
            }
        }

        return attributes;
    }

    parseAttribute = function (line: string): IAttribute {
        let match = this.attributeFormat.exec(line);
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