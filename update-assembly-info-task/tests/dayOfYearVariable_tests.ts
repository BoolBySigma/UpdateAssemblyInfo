import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { DayOfYearVariable } from '../dayOfYearVariable';

describe('DayOfYearVariable', function () {
    describe('replace', function () {
        it('should return empty string if null', function () {
            let value = new DayOfYearVariable().replace(null);
            assert.equal(value, '');
        });

        it('should return empty string if undefined', function () {
            let value = new DayOfYearVariable().replace(undefined);
            assert.equal(value, '');
        });

        it('should return empty string if empty', function () {
            let value = new DayOfYearVariable().replace('');
            assert.equal(value, '');
        });

        it('should replace $(DayOfYear)', function(){
            let value = new DayOfYearVariable().replace('$(DayOfYear) no variable');
            assert(value.indexOf('$(DayOfYear)') < 0);
            assert(value.endsWith('no variable'));
        });

        it('should return identic string if no $(DayOfYear) variable', function(){
            let value = new DayOfYearVariable().replace('no variable');
            assert.equal(value, 'no variable');
        });
    });
});