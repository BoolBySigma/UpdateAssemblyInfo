import * as fs from 'fs';
import * as path from 'path';
import { BooleanUtils } from './booleanUtils';
import { Language } from './language';
import { AttributeUpdateOptions } from './attributeUpdateOptions';
import { ContentParser } from './contentParser';
import { Line } from './line';
import { AttributeParser } from './attributeParser';
import { Attribute } from './attribute';

export class File {
    lines: Line[] = [];
    attributes: Attribute[] = [];

    language = Language.Cs;

    constructor(filePath: string, overrideOptions?: { contents: string, language?: Language }) {
        let contents = '';
        if (overrideOptions) {
            contents = overrideOptions.contents;
            if (overrideOptions.language) {
                this.language = overrideOptions.language;
            }
        } else {
            if (!fs.existsSync(filePath)) {
                throw new Error('File not found: ' + filePath);
            }

            contents = fs.readFileSync(filePath, 'utf8');

            this.language = this.determineLanguage(filePath);
        }

        let contentParser = new ContentParser(this.language);
        this.lines = contentParser.parse(contents);

        let attributeParser = new AttributeParser(this.language);
        this.attributes = attributeParser.parse(this.lines);
    }

    determineLanguage = function (filePath: string): Language {
        let ext = path.extname(filePath).toLowerCase();

        if (ext === '.vb') {
            return Language.Vb;
        }
        if (ext === '.cs') {
            return Language.Cs;
        }

        return Language.Fs;
    }

    updateAttribute = function (options: AttributeUpdateOptions): Attribute {
        let attribute: Attribute = this.attributes[options.name];

        if (attribute === undefined || attribute === null) {
            if (options.ensureAttribute) {
                if (options.value !== undefined && options.value !== null) {
                    attribute = this.createAttribute(options);
                }
            }
            else {
                return null;
            }
        }

        if (options.value === undefined || options.value === null) {
            return attribute;
        }

        attribute.value = options.value;
        
        this.lines[attribute.lineIndex].text = attribute.toString();

        return attribute;
    }

    createAttribute = function (options: AttributeUpdateOptions): Attribute {
        if (!options.ensureAttribute){
            throw new Error('Ensure attribute not enabled');
        }
        let length: number = this.lines.push(new Line(''));
        let lineIndex = length - 1;
        let format = this.createAttributeFormat();
        return new Attribute(options.name, options.value, this.language, format, lineIndex);
    }

    createAttributeFormat = function () {
        if (this.language === Language.Vb) {
            return '<Assembly: {0}({1})>';
        }
        if (this.language === Language.Fs) {
            return '[<assembly: {0}({1})>]';
        }

        return '[assembly: {0}({1})]';
    }
}