import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { BuildNumberRevisionVariable } from '../buildNumberRevisionVariable';

describe('BuildNumberRevisionVariable', function () {
    describe('replace', function () {
        it('should return empty string if null', function () {
            let value = new BuildNumberRevisionVariable(1).replace(null);
            assert.equal(value, '');
        });

        it('should return empty string if undefined', function () {
            let value = new BuildNumberRevisionVariable(1).replace(undefined);
            assert.equal(value, '');
        });

        it('should return empty string if empty', function () {
            let value = new BuildNumberRevisionVariable(1).replace('');
            assert.equal(value, '');
        });

        it('should replace $(Rev:rr)', function(){
            let value = new BuildNumberRevisionVariable(1).replace('$(Rev:rr) no variable');
            assert(value.indexOf('$(Rev:rr)') < 0);
            assert(value.endsWith('no variable'));
        });

        it('should return identic string if no $(Rev:rr) variable', function(){
            let value = new BuildNumberRevisionVariable(1).replace('no variable');
            assert.equal(value, 'no variable');
        });

        it('should replace $(Rev:r) with single digit string', function(){
            let value = new BuildNumberRevisionVariable(1).replace('$(Rev:r) no variable');
            assert.equal(value, '1 no variable');
        });

        it('should replace $(Rev:rr) with two digit string', function(){
            let value = new BuildNumberRevisionVariable(1).replace('$(Rev:rr) no variable');
            assert.equal(value, '01 no variable');
        });

        it('should replace $(Rev:rrr) with three digit string', function(){
            let value = new BuildNumberRevisionVariable(1).replace('$(Rev:rrr) no variable');
            assert.equal(value, '001 no variable');
        });
    });

    describe('isUsed', function(){
        it('should return false if $(Rev) varible not in any parameter', function(){
            assert.isFalse(BuildNumberRevisionVariable.isUsed(['1', '2', '3']));
        });

        it('should return true if $(Rev) is in a parameter', function(){
            assert.isTrue(BuildNumberRevisionVariable.isUsed(['1', '$(Rev:r) 2', '3']));
        });

        it('should return true if $(Rev) is in multiple parameters', function(){
            assert.isTrue(BuildNumberRevisionVariable.isUsed(['1', '2 $(Rev:rr)', '3 $(Rev:rr)']));
        });
    });
});