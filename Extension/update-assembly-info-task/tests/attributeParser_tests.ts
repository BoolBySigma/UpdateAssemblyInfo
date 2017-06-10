import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { AttributeParser } from '../attributeParser';
import { Language } from '../language';


describe('AttributeParser', function () {
    describe('parse', function () {
        it('should always return array', function () {
            let parser = new AttributeParser(Language.Cs);
            assert.isArray(parser.parse(null));
            assert.isArray(parser.parse(undefined));
            assert.isArray(parser.parse([]));
        });

        it('should find 0 attributes if no lines', function () {
            let parser = new AttributeParser(Language.Cs);
            assert.equal(Object.keys(parser.parse([])).length, 0);
        });

        it('should find only AssemblyVersion attribute', function () {
            let parser = new AttributeParser(Language.Cs);
            let attributes = parser.parse(['[assembly: AssemblyVersion("1.0.0.0")]']);
            assert.equal(Object.keys(attributes).length, 1);
            assert.equal(attributes['AssemblyVersion'].name, 'AssemblyVersion');
        });

        it('should find only AssemblyVersion attribute in line with indentation', function () {
            let parser = new AttributeParser(Language.Cs);
            let attributes = parser.parse(['    [    assembly    : AssemblyVersion    (    "1.0.0.0"    )    ]    ']);
            assert.equal(Object.keys(attributes).length, 1);
            assert.equal(attributes['AssemblyVersion'].name, 'AssemblyVersion');
        });

        it('should find only AssemblyVersion attribute value in line with indentation', function () {
            let parser = new AttributeParser(Language.Cs);
            let attributes = parser.parse(['    [    assembly    : AssemblyVersion    (    "1.0.0.0"    )    ]    ']);
            assert.equal(Object.keys(attributes).length, 1);
            assert.equal(attributes['AssemblyVersion'].value, '1.0.0.0');
        });

        it('should find only AssemblyFileVersion attribute in 3 lines', function () {
            let parser = new AttributeParser(Language.Cs);
            let attributes = parser.parse(['line1', '[assembly: AssemblyFileVersion("1.0.0.0")]', 'line3']);
            assert.equal(Object.keys(attributes).length, 1);
            assert.equal(attributes['AssemblyFileVersion'].name, 'AssemblyFileVersion');
        });

        it('should find AssemblyFileVersion attribute on second line', function () {
            let parser = new AttributeParser(Language.Cs);
            let attributes = parser.parse(['line1', '[assembly: AssemblyFileVersion("1.0.0.0")]', 'line3']);
            assert.equal(Object.keys(attributes).length, 1);
            assert.equal(attributes['AssemblyFileVersion'].lineIndex, 1);
        });
    });

    describe('containsAttribute', function () {
        it('should return true for AssemblyFileVersion', function () {
            let parser = new AttributeParser(Language.Cs);
            let foundAttribute = parser.containsAttribute('[assembly: AssemblyFileVersion("1.0.0.0")]');
            assert.isTrue(foundAttribute);
        });

        it('should return true for custom boolean attribute', function () {
            let parser = new AttributeParser(Language.Cs);
            let foundAttribute = parser.containsAttribute('[assembly: CustomAttribute(true)]');
            assert.isTrue(foundAttribute);
        });

        it('should return true for custom string attribute', function () {
            let parser = new AttributeParser(Language.Cs);
            let foundAttribute = parser.containsAttribute('[assembly: CustomAttribute("value")]');
            assert.isTrue(foundAttribute);
        });

        it('should return false for malformed attribute', function(){
            let parser = new AttributeParser(Language.Cs);
            let foundAttribute = parser.containsAttribute('[assemb: CustomAttribute]');
            assert.isFalse(foundAttribute);
        });

        it('should return false for empty', function(){            
            let parser = new AttributeParser(Language.Cs);
            let foundAttribute = parser.containsAttribute('');
            assert.isFalse(foundAttribute);
        });

        it('should return false for null', function(){            
            let parser = new AttributeParser(Language.Cs);
            let foundAttribute = parser.containsAttribute(null);
            assert.isFalse(foundAttribute);
        });

        it('should return false for undefined', function(){            
            let parser = new AttributeParser(Language.Cs);
            let foundAttribute = parser.containsAttribute(undefined);
            assert.isFalse(foundAttribute);
        });
    });

    describe('parseAttribute', function () {
        it('should find AssemblyVersion attribute', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: AssemblyVersion("1.0.0.0")]');
            assert.equal(attribute.name, 'AssemblyVersion');
        });

        it('should find AssemblyVersion attribute value', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: AssemblyVersion("1.0.0.0")]');
            assert.equal(attribute.value, '1.0.0.0');
        });

        it('should find AssemblyFileVersion attribute', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: AssemblyFileVersion("1.0.0.0")]');
            assert.equal(attribute.name, 'AssemblyFileVersion');
        });

        it('should find AssemblyFileVersion attribute value', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: AssemblyFileVersion("1.0.0.0")]');
            assert.equal(attribute.value, '1.0.0.0');
        });

        it('should find custom attribute', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: CustomAttribute("1.0.0.0")]');
            assert.equal(attribute.name, 'CustomAttribute');
        });

        it('should find custom attribute string value', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: CustomAttribute("1.0.0.0")]');
            assert.equal(attribute.value, '1.0.0.0');
        });

        it('should find custom attribute boolean value true', function () {
            let parser = new AttributeParser(Language.Cs);
            let attribute = parser.parseAttribute('[assembly: CustomAttribute(true)]');
            assert.isBoolean(attribute.value);
            assert.isTrue(attribute.value);
        });
    });

    describe('parseValue', function () {
        it('should return stripped string if enclosed in ""', function () {
            let parser = new AttributeParser(Language.Cs);
            let value = parser.parseValue('"1.0.0.0"');
            assert.equal(value, '1.0.0.0');
        });

        it('should return boolean true if true', function () {
            let parser = new AttributeParser(Language.Cs);
            let value = parser.parseValue('true');
            assert.isBoolean(value);
            assert.isTrue(value);
        });

        it('should return boolean true if True', function () {
            let parser = new AttributeParser(Language.Cs);
            let value = parser.parseValue('True');
            assert.isBoolean(value);
            assert.isTrue(value);
        });

        it('should return boolean false if false', function () {
            let parser = new AttributeParser(Language.Cs);
            let value = parser.parseValue('false');
            assert.isBoolean(value);
            assert.isFalse(value);
        });

        it('should return boolean false if False', function () {
            let parser = new AttributeParser(Language.Cs);
            let value = parser.parseValue('False');
            assert.isBoolean(value);
            assert.isFalse(value);
        });

        it('should return null if null', function () {
            let parser = new AttributeParser(Language.Cs);
            let value = parser.parseValue(null);
            assert.isNull(value);
        });

        it('should return null if undefined', function () {
            let parser = new AttributeParser(Language.Cs);
            let value = parser.parseValue(undefined);
            assert.isNull(value);
        });
    });
});