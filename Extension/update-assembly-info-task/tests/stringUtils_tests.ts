import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { StringUtils } from '../stringUtils';

describe('StringUtils', function () {
    describe('isNullOrEmpty', function () {
        it('should return true if null', function () {
            assert.isTrue(StringUtils.isNullOrEmpty(null));
        });

        it('should return true if undefined', function () {
            assert.isTrue(StringUtils.isNullOrEmpty(undefined));
        });

        it('should return true if empty', function () {
            assert.isTrue(StringUtils.isNullOrEmpty(''));
        });

        it('should return false if white space', function () {
            assert.isFalse(StringUtils.isNullOrEmpty(' '));
        });

        it('should return false if contains characters', function () {
            assert.isFalse(StringUtils.isNullOrEmpty('a'));
        });
    });
});