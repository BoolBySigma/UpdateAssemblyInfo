import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { BooleanUtils } from '../booleanUtils';

describe('BooleanUtils', function () {
    describe('tryParse', function () {
        it('should succeed if true', function () {
            let result = BooleanUtils.tryParse('true');
            assert.isTrue(result.success);
        });

        it('should succeed if True', function () {
            let result = BooleanUtils.tryParse('True');
            assert.isTrue(result.success);
        });

        it('should succeed if false', function () {
            let result = BooleanUtils.tryParse('false');
            assert.isTrue(result.success);
        });

        it('should succeed if False', function () {
            let result = BooleanUtils.tryParse('False');
            assert.isTrue(result.success);
        });

        it('should return value true if true', function () {
            let result = BooleanUtils.tryParse('true');
            assert.isTrue(result.value);
        });

        it('should return value false if false', function () {
            let result = BooleanUtils.tryParse('false');
            assert.isFalse(result.value);
        });

        it('should not succeed if null', function () {
            let result = BooleanUtils.tryParse(null);
            assert.isFalse(result.success);
        });

        it('should not succeed if undefined', function () {
            let result = BooleanUtils.tryParse(undefined);
            assert.isFalse(result.success);
        });

        it('should not succeed if "a"', function () {
            let result = BooleanUtils.tryParse('a');
            assert.isFalse(result.success);
        });
    });
});