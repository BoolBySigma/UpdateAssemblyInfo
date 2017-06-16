import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { DateVariable } from '../dateVariable';

describe('DateVariable', function () {
    describe('replace', function () {
        it('should return empty string if null', function () {
            let value = new DateVariable().replace(null);
            assert.equal(value, '');
        });

        it('should return empty string if undefined', function () {
            let value = new DateVariable().replace(undefined);
            assert.equal(value, '');
        });

        it('should return empty string if empty', function () {
            let value = new DateVariable().replace('');
            assert.equal(value, '');
        });

        it('should replace $(Date:dd)', function(){
            let value = new DateVariable().replace('$(Date:dd)');
            assert(value.indexOf('$(Date:dd)') < 0);
        })

        it('should replace $(Date:dd) with day of month 01 if 2000,01,01', function(){
            let value = new DateVariable(new Date(2000, 1, 1)).replace('$(Date:dd)');
            assert.equal(value, '01');
        });

        it('should replace two instances of $(Date:dd) with day of month 01 if 2000,01,01', function(){
            let value = new DateVariable(new Date(2000, 1, 1)).replace('$(Date:dd) no variable $(Date:dd)');
            assert.equal(value, '01 no variable 01');
        });

        it('should return identic string if no $(Date) variable', function(){
            let value = new DateVariable().replace('no date variable');
            assert.equal(value, 'no date variable');
        });
    });
});