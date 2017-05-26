import { Language } from './language';

export class ContentParser {
    language: Language;

    constructor(language: Language) {
        this.language = language;
    }
    parse = function (contents: string): string[] {
        if (contents === null || contents === undefined) {
            return [];
        }

        let lines: string[] = [];

        let textLines = contents.split(/\r\n|\r|\n/);
        for (let text of textLines) {
            lines.push(text);
        }

        return lines;
    }
}