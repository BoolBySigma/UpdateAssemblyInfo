export class Line {
    text: string;
    isComment: boolean;

    constructor(text: string, isComment = false){
        this.text = text;
        this.isComment = isComment;
    }
}