import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;
import * as path from 'path';

import { File } from '../file';
import { Language } from '../language';
import { Attribute } from '../attribute';

describe('File', function () {
    describe('constructor', function () {
        it('should throw file not found error for invalid file path', function () {
            assert.throws(function () {
                let filePath = path.join(__dirname, 'files/invalidfilepath');
                let file = new File(filePath);
            }, 'File not found');
        });

        it('should not throw file not found error for valid file path', function () {
            assert.doesNotThrow(function () {
                let filePath = path.join(__dirname, 'files/empty.cs');
                let file = new File(filePath);
            }, 'threw file not found error');
        });

        it('should find 10 lines in file with 10 lines', function () {
            let filePath = path.join(__dirname, 'files/assemblyInfo_singlelinecomments.cs');
            let file = new File(filePath);
            assert.equal(file.lines.length, 10);
        });

        it('should find 3 attributes in file with 3 attributes and 3 single-line commented attributes', function () {
            let filePath = path.join(__dirname, 'files/assemblyInfo_singlelinecomments.cs');
            let file = new File(filePath);
            assert.equal(Object.keys(file.attributes).length, 3);
        });

        it('should find 3 comment lines in file with 3 single-line commented attributes', function () {
            let filePath = path.join(__dirname, 'files/assemblyInfo_singlelinecomments.cs');
            let file = new File(filePath);
            assert.equal((file.lines.filter(line => line.isComment)).length, 3);
        });

        it('should find 3 attributes in file with 3 attributes and 3 multi-line commented attributes', function () {
            let filePath = path.join(__dirname, 'files/assemblyInfo_multilinecomments.cs');
            let file = new File(filePath);
            assert.equal(Object.keys(file.attributes).length, 3);
        });

        it('should find 3 comment lines in file with 3 multi-line commented attributes', function () {
            let filePath = path.join(__dirname, 'files/assemblyInfo_multilinecomments.cs');
            let file = new File(filePath);
            assert.equal((file.lines.filter(line => line.isComment)).length, 3);
        });

        it('should find 5 lines', function () {
            let file = new File(null, { contents: 'line1\rline2\r\nline3\nline4\nline5' });
            assert.equal(file.lines.length, 5);
        });

        it('should find 2 attributes', function () {
            let file = new File(null, { contents: 'line1\r[assembly: AssemblyVersion("1.0.0.0")]\r\nline3\n[assembly: AssemblyFileVersion("1.0.0.0")]\nline5' });
            assert.equal(Object.keys(file.attributes).length, 2);
        });
    });

    describe('determineLanguage', function () {
        it('should return Cs for .cs file', function () {
            let file = new File(null, { contents: '' });
            let language = file.determineLanguage('c:\\file.cs');
            assert.equal(language, Language.Cs);
        });
        it('should return Vb for .vb file', function () {
            let file = new File(null, { contents: '' });
            let language = file.determineLanguage('c:\\file.vb');
            assert.equal(language, Language.Vb);
        });
        it('should return Fs for .fs file', function () {
            let file = new File(null, { contents: '' });
            let language = file.determineLanguage('c:\\file.fs');
            assert.equal(language, Language.Fs);
        });
    });

    describe('updateAttribute', function () {
        it('should find AssemblyVersion attribute and update value to 2.2.2.2', function () {
            let file = new File(null, { contents: 'line1\r[assembly: AssemblyVersion("1.0.0.0")]\r\nline3\n[assembly: AssemblyFileVersion("1.0.0.0")]\nline5' });
            let attribute = file.updateAttribute({ name: 'AssemblyVersion', value: '2.2.2.2', ensureAttribute: false });
            assert.equal(attribute.value, '2.2.2.2');
            assert.equal(attribute.toString(), '[assembly: AssemblyVersion("2.2.2.2")]');
            let line = file.lines[attribute.lineIndex];
            assert.equal(line.text, '[assembly: AssemblyVersion("2.2.2.2")]');
        });

        it('should find AssemblyVersion attribute with indentations and update value to 2.2.2.2', function () {
            let file = new File(null, { contents: 'line1\r    [    assembly    : AssemblyVersion    ("1.0.0.0"    )    ]    \r\nline3\n[assembly: AssemblyFileVersion("1.0.0.0")]\nline5' });
            let attribute = file.updateAttribute({ name: 'AssemblyVersion', value: '2.2.2.2', ensureAttribute: false });
            assert.equal(attribute.value, '2.2.2.2');
            assert.equal(attribute.toString(), '    [    assembly    : AssemblyVersion    ("2.2.2.2"    )    ]    ');
            let line = file.lines[attribute.lineIndex];
            assert.equal(line.text, '    [    assembly    : AssemblyVersion    ("2.2.2.2"    )    ]    ');
        });

        it('should return attribute if not ensureAttribute and attribute exists', function () {
            let file = new File(null, { contents: 'line1\r    [    assembly    : AssemblyVersion    ("1.0.0.0"    )    ]    \r\nline3\n[assembly: AssemblyFileVersion("1.0.0.0")]\nline5' });
            let attribute = file.updateAttribute({ name: 'AssemblyVersion', value: 'CustomValue', ensureAttribute: false });
            assert.instanceOf(attribute, Attribute);
            assert.equal(attribute.name, 'AssemblyVersion');
            assert.equal(attribute.value, 'CustomValue');
        });

        it('should return attribute if ensureAttribute and attribute exists', function () {
            let file = new File(null, { contents: 'line1\r    [    assembly    : AssemblyVersion    ("1.0.0.0"    )    ]    \r\nline3\n[assembly: AssemblyFileVersion("1.0.0.0")]\nline5' });
            let attribute = file.updateAttribute({ name: 'AssemblyVersion', value: 'CustomValue', ensureAttribute: true });
            assert.equal(attribute.name, 'AssemblyVersion');
            assert.equal(attribute.value, 'CustomValue');
            assert.instanceOf(attribute, Attribute);
        });

        it('should return null if not ensureAttribute and attribute does not exist', function () {
            let file = new File(null, { contents: 'line1\r    [    assembly    : AssemblyVersion    ("1.0.0.0"    )    ]    \r\nline3\n[assembly: AssemblyFileVersion("1.0.0.0")]\nline5' });
            let attribute = file.updateAttribute({ name: 'CustomAttribute', value: 'CustomValue', ensureAttribute: false });
            assert.isNull(attribute);
        });

        it('should return new attribute if ensureAttribute and attribute does not exist', function () {
            let file = new File(null, { contents: 'line1\r    [    assembly    : AssemblyVersion    ("1.0.0.0"    )    ]    \r\nline3\n[assembly: AssemblyFileVersion("1.0.0.0")]\nline5' });
            let attribute = file.updateAttribute({ name: 'CustomAttribute', value: 'CustomValue', ensureAttribute: true });
            assert.equal(attribute.name, 'CustomAttribute');
            assert.equal(attribute.value, 'CustomValue');
            assert.instanceOf(attribute, Attribute);
        });

        it('should return new c-sharp formatted attribute with string value if ensureAttribute and attribute does not exist', function () {
            let file = new File(null, { contents: 'line1\r    [    assembly    : AssemblyVersion    ("1.0.0.0"    )    ]    \r\nline3\n[assembly: AssemblyFileVersion("1.0.0.0")]\nline5' });
            let attribute = file.updateAttribute({ name: 'CustomAttribute', value: 'CustomValue', ensureAttribute: true });
            let line = file.lines[attribute.lineIndex];

            assert.instanceOf(attribute, Attribute);
            assert.equal(attribute.name, 'CustomAttribute');
            assert.equal(attribute.value, 'CustomValue');
            assert.equal(attribute.toString(), '[assembly: CustomAttribute("CustomValue")]');
            assert.equal(line.text, '[assembly: CustomAttribute("CustomValue")]');
        });

        it('should return new c-sharp formatted attribute with boolean value if ensureAttribute and attribute does not exist', function () {
            let file = new File(null, { contents: 'line1\r    [    assembly    : AssemblyVersion    ("1.0.0.0"    )    ]    \r\nline3\n[assembly: AssemblyFileVersion("1.0.0.0")]\nline5' });
            let attribute = file.updateAttribute({ name: 'CustomAttribute', value: false, ensureAttribute: true });
            let line = file.lines[attribute.lineIndex];

            assert.instanceOf(attribute, Attribute);
            assert.equal(attribute.name, 'CustomAttribute');
            assert.equal(attribute.value, false);
            assert.equal(attribute.toString(), '[assembly: CustomAttribute(false)]');
            assert.equal(line.text, '[assembly: CustomAttribute(false)]');
        });

        it('should return new vb formatted attribute with string value if ensureAttribute and attribute does not exist', function () {
            let file = new File(null, { contents: 'line1\r    <    Assembly    : AssemblyVersion    ("1.0.0.0"    )    >    \r\nline3\n<Assembly: AssemblyFileVersion("1.0.0.0")>\nline5' });
            file.language = Language.Vb;
            let attribute = file.updateAttribute({ name: 'CustomAttribute', value: 'CustomValue', ensureAttribute: true });
            let line = file.lines[attribute.lineIndex];

            assert.instanceOf(attribute, Attribute);
            assert.equal(attribute.name, 'CustomAttribute');
            assert.equal(attribute.value, 'CustomValue');
            assert.equal(attribute.toString(), '<Assembly: CustomAttribute("CustomValue")>');
            assert.equal(line.text, '<Assembly: CustomAttribute("CustomValue")>');
        });

        it('should return new vb formatted attribute with boolean value if ensureAttribute and attribute does not exist', function () {
            let file = new File(null, { contents: 'line1\r    <    Assembly    : AssemblyVersion    ("1.0.0.0"    )    >    \r\nline3\n<Assembly: AssemblyFileVersion("1.0.0.0")>\nline5' });
            file.language = Language.Vb;
            let attribute = file.updateAttribute({ name: 'CustomAttribute', value: true, ensureAttribute: true });
            let line = file.lines[attribute.lineIndex];

            assert.instanceOf(attribute, Attribute);
            assert.equal(attribute.name, 'CustomAttribute');
            assert.equal(attribute.value, true);
            assert.equal(attribute.toString(), '<Assembly: CustomAttribute(True)>');
            assert.equal(line.text, '<Assembly: CustomAttribute(True)>');
        });
    });

    describe('createAttributeFormat', function () {
        it('should return csharp format if language cs', function () {
            let file = new File(null, { contents: '' });
            file.language = Language.Cs;
            let format = file.createAttributeFormat();
            assert.equal(format, '[assembly: {0}({1})]');
        });

        it('should return vb format if language vb', function () {
            let file = new File(null, { contents: '' });
            file.language = Language.Vb;
            let format = file.createAttributeFormat();
            assert.equal(format, '<Assembly: {0}({1})>');
        });

        it('should return fsharp format if language fs', function () {
            let file = new File(null, { contents: '' });
            file.language = Language.Fs;
            let format = file.createAttributeFormat();
            assert.equal(format, '[<assembly: {0}({1})>]');
        });
    });

    describe('createAttribute', function () {
        it('should throw ensure attribute not enabled error if ensureAttribute is false', function () {
            assert.throws(function () {
                let file = new File(null, { contents: '' });
                let attribute = file.createAttribute({ name: 'CustomAttribute', value: false, ensureAttribute: false });
            }, 'Ensure attribute not enabled');
        });

        it('should not throw ensure attribute not enabled error if ensureAttribute is true', function () {
            assert.doesNotThrow(function () {
                let file = new File(null, { contents: '' });
                let attribute = file.createAttribute({ name: 'CustomAttribute', value: false, ensureAttribute: true });
            }, 'Ensure attribute not enabled');
        });

        it('should return attribute with name CustomAttribute', function () {
            let file = new File(null, { contents: '' });
            let attribute = file.createAttribute({ name: 'CustomAttribute', value: false, ensureAttribute: true });
            assert.equal(attribute.name, 'CustomAttribute');
        });

        it('should return attribute with boolean value false', function () {
            let file = new File(null, { contents: '' });
            let attribute = file.createAttribute({ name: 'CustomAttribute', value: false, ensureAttribute: true });
            assert.isBoolean(attribute.value);
            assert.equal(attribute.value, false);
        });

        it('should return attribute with string value CustomValue', function () {
            let file = new File(null, { contents: '' });
            let attribute = file.createAttribute({ name: 'CustomAttribute', value: 'CustomValue', ensureAttribute: true });
            assert.isString(attribute.value);
            assert.equal(attribute.value, 'CustomValue');
        });

        it('should return attribute with lineIndex 1', function () {
            let file = new File(null, { contents: 'firstLine' });
            let attribute = file.createAttribute({ name: 'CustomAttribute', value: false, ensureAttribute: true });
            assert.equal(attribute.lineIndex, 1);
        });
    });
});