export class AttributeUpdateOptions {
    name: string;
    value: any;
    ensureAttribute: boolean;

    constructor(name: string, value: any, ensureAttribute: boolean){
        this.name = name;
        this.value = value;
        this.ensureAttribute = ensureAttribute;
    }
}