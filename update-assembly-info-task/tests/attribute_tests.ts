import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { AttributeParser } from '../attributeParser';
import { Language } from '../language';

describe('Attribute', function () {
    describe('toString', function () {
        it('should return identic line', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: CustomAttribute("1.0.0.0")]');
            assert.equal(attribute.toString(), '[assembly: CustomAttribute("1.0.0.0")]');
        });

        it('should return identic line with indentations', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('    [    assembly    : CustomAttribute(    "1.0.0.0"    )    ]    ');
            assert.equal(attribute.toString(), '    [    assembly    : CustomAttribute(    "1.0.0.0"    )    ]    ');
        });

        it('should return identic line with indentations and trailing comments', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('    [    assembly    : CustomAttribute(    "1.0.0.0"    )    ]    \/\/ comment');
            assert.equal(attribute.toString(), '    [    assembly    : CustomAttribute(    "1.0.0.0"    )    ]    \/\/ comment');
        });

        it('should return line with updated string value', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: CustomAttribute("1.0.0.0")]');
            attribute.value = '2.2.2.2';
            assert.equal(attribute.toString(), '[assembly: CustomAttribute("2.2.2.2")]');
        });

        it('should return line with updated boolean value', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: CustomAttribute(true)]');
            attribute.value = false;
            assert.equal(attribute.toString(), '[assembly: CustomAttribute(false)]');
        });

        it('should return line with value changed from string to boolean', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: CustomAttribute("1.0.0.0")]');
            attribute.value = false;
            assert.equal(attribute.toString(), '[assembly: CustomAttribute(false)]');
        });

        it('should return line with value changed from boolean to string', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: CustomAttribute(false)]');
            attribute.value = '1.0.0.0';
            assert.equal(attribute.toString(), '[assembly: CustomAttribute("1.0.0.0")]');
        });
    });
});