import { Language } from './language';
import { Line } from './line';

export class ContentParser {
    singleLineCommentFormat = /^\s*(\/\/|')/;
    multiLineCommentStartFormat = /^\s*(\/\*|\(\*)/;
    multiLineCommentEndFormat = /.*?(\*\/|\*\))/;

    language: Language;

    constructor(language: Language) {
        this.language = language;
    }

    parse = function (contents: string): Line[] {
        if (contents === null || contents === undefined) {
            return [];
        }

        let lines: Line[] = [];

        let textLines = contents.split(/\r\n|\r|\n/);

        let isMultiLineComment = false;

        for (let text of textLines) {
            if (this.isSingleLineComment(text)) {
                lines.push(new Line(text, true));
                continue;
            }

            if (this.isMultiLineCommentStart(text)) {
                isMultiLineComment = true;
                lines.push(new Line(text, true));
                continue;
            }

            if (this.isMultiLineCommentEnd(text) && isMultiLineComment) {
                isMultiLineComment = false;
                lines.push(new Line(text, true));
                continue;
            }

            if (isMultiLineComment) {
                lines.push(new Line(text, true));
                continue;
            }

            lines.push(new Line(text));
        }

        return lines;
    }

    isSingleLineComment = function (text: string): boolean {
        if (this.singleLineCommentFormat.test(text)) {
            return true;
        }

        return this.multiLineCommentStartFormat.test(text) && this.multiLineCommentEndFormat.test(text);
    }

    isMultiLineCommentStart = function (text: string): boolean {
        return this.multiLineCommentStartFormat.test(text);
    }

    isMultiLineCommentEnd = function (text: string): boolean {
        return this.multiLineCommentEndFormat.test(text);
    }
}