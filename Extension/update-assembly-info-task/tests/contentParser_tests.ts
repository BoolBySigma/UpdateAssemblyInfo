import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { ContentParser } from '../contentParser';
import { Language } from '../language';

describe('ContentParser', function () {
    describe('parse', function () {
        it('should always return array', function () {
            let parser = new ContentParser(Language.Cs);
            assert.isArray(parser.parse(''));
            assert.isArray(parser.parse(null));
            assert.isArray(parser.parse(undefined));
            assert.isArray(parser.parse(' '));
            assert.isArray(parser.parse('a line'));
        });

        it('should identify \\r as line break', function () {
            let contents = 'line1\rline2';
            let parser = new ContentParser(Language.Cs);
            let lines = parser.parse(contents);
            expect(lines.length).to.equal(2);
        });

        it('should identify \\n as line break', function () {
            let contents = 'line1\nline2';
            let parser = new ContentParser(Language.Cs);
            let lines = parser.parse(contents);
            expect(lines.length).to.equal(2);
        });

        it('should identify \\r\\n as line break', function () {
            let contents = 'line1\r\nline2';
            let parser = new ContentParser(Language.Cs);
            let lines = parser.parse(contents);
            expect(lines.length).to.equal(2);
        });

        it('should find 5 lines', function () {
            let contents = 'line1\r\nline2\rline3\nline4\nline5';
            let parser = new ContentParser(Language.Cs);
            let lines = parser.parse(contents);
            expect(lines.length).to.equal(5);
        });

        it('should find 5 empty lines', function () {
            let contents = '\r\r\r\r';
            let parser = new ContentParser(Language.Cs);
            let lines = parser.parse(contents);
            expect(lines.length).to.equal(5);
        });

        it('first line text should be same as input', function () {
            let contents = 'line1\r\nline2';
            let parser = new ContentParser(Language.Cs);
            let lines = parser.parse(contents);
            expect(lines[0]).equals('line1');
        });

        it('last line text should be same as input', function () {
            let contents = 'line1\nline2';
            let parser = new ContentParser(Language.Cs);
            let lines = parser.parse(contents);
            expect(lines[1]).equals('line2');
        });
    });
});