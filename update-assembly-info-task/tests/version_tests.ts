import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { Version } from '../version';

describe('Version', function () {
    describe('parse', function () {
        it('should return version with major only for 0', function () {
            let version = Version.parse('0');
            assert.equal(version.major, 0);
            assert.isNaN(version.minor);
            assert.isNaN(version.build);
            assert.isNaN(version.revision);
        });

        it('should return version with major and minor only for 0.0', function () {
            let version = Version.parse('0.0');
            assert.equal(version.major, 0);
            assert.equal(version.minor, 0);
            assert.isNaN(version.build);
            assert.isNaN(version.revision);
        });

        it('should return version with major, minor and build only for 0.0.0', function () {
            let version = Version.parse('0.0.0');
            assert.equal(version.major, 0);
            assert.equal(version.minor, 0);
            assert.equal(version.build, 0);
            assert.isNaN(version.revision);
        });

        it('should return version with major, minor, build and revision for 0.0.0.0', function () {
            let version = Version.parse('0.0.0.0');
            assert.equal(version.major, 0);
            assert.equal(version.minor, 0);
            assert.equal(version.build, 0);
            assert.equal(version.revision, 0);
        });

        it('should return empty for *', function () {
            let version = Version.parse('*');
            assert.isNaN(version.major);
        });
        
        it('should return version with major only for 0.*', function () {
            let version = Version.parse('0.*');
            assert.equal(version.major, 0);
            assert.isNaN(version.minor);
            assert.isNaN(version.build);
            assert.isNaN(version.revision);
        });
        
        it('should return version with major and minor only for 0.0.*', function () {
            let version = Version.parse('0.0.*');
            assert.equal(version.major, 0);
            assert.equal(version.minor, 0);
            assert.isNaN(version.build);
            assert.isNaN(version.revision);
        });
        
        it('should return version with major, minor and build only for 0.0.0.*', function () {
            let version = Version.parse('0.0.0.*');
            assert.equal(version.major, 0);
            assert.equal(version.minor, 0);
            assert.equal(version.build, 0);
            assert.isNaN(version.revision);
        });
        
        it('should throw invalid version format error for i', function () {
            assert.throws(function(){
                let version = Version.parse('i');
            });
        });
    });

    describe('valid', function(){
        it('it should return true for 0', function(){
            assert.isTrue(Version.valid('0'));
        });

        it('it should return true for 0.0', function(){
            assert.isTrue(Version.valid('0.0'));
        });
        
        it('it should return true for 0.0.0', function(){
            assert.isTrue(Version.valid('0.0.0'));
        });
        
        it('it should return true for 0.0.0.0', function(){
            assert.isTrue(Version.valid('0.0.0.0'));
        });
        
        it('it should return false if empty', function(){
            assert.isFalse(Version.valid(''));
        });
        
        it('it should return false if null', function(){
            assert.isFalse(Version.valid(null));
        });
        
        it('it should return false if undefined', function(){
            assert.isFalse(Version.valid(undefined));
        });
        
        it('it should return false for 0.0.0.0.0', function(){
            assert.isFalse(Version.valid('0.0.0.0.0'));
        });
        
        it('it should return false for i', function(){
            assert.isFalse(Version.valid('i'));
        });
        
        it('it should return false for 0.i', function(){
            assert.isFalse(Version.valid('0.i'));
        });
        
        it('it should return false for 0.0.i', function(){
            assert.isFalse(Version.valid('0.0.i'));
        });
        
        it('it should return false for 0.0.0.i', function(){
            assert.isFalse(Version.valid('0.0.0.i'));
        });
        
        it('it should return true for *', function(){
            assert.isTrue(Version.valid('*'));
        });
        
        it('it should return true for 0.*', function(){
            assert.isTrue(Version.valid('0.*'));
        });
        
        it('it should return true for 0.0.*', function(){
            assert.isTrue(Version.valid('0.0.*'));
        });
        
        it('it should return true for 0.0.0.*', function(){
            assert.isTrue(Version.valid('0.0.0.*'));
        });
        
        it('it should return false for invalid delimiter , 0,0', function(){
            assert.isFalse(Version.valid('0,0'));
        });
    });

    describe('toString', function(){
        it('should return 0 for 0', function(){
            let version = Version.parse('0');
            assert.equal(version.toString(), '0');
        });

        it('should return 0.0 for 0.0', function(){
            let version = Version.parse('0.0');
            assert.equal(version.toString(), '0.0');
        });

        it('should return 0.0.0', function(){
            let version = Version.parse('0.0.0');
            assert.equal(version.toString(), '0.0.0');
        });

        it('should return 0.0.0.0', function(){
            let version = Version.parse('0.0.0.0');
            assert.equal(version.toString(), '0.0.0.0');
        });
        
        it('should return 0 for 0.*', function(){
            let version = Version.parse('0.*');
            assert.equal(version.toString(), '0');
        });
        
        it('should return 0.0 for 0.0.*', function(){
            let version = Version.parse('0.0.*');
            assert.equal(version.toString(), '0.0');
        });
        
        it('should return 0.0.0 for 0.0.0*', function(){
            let version = Version.parse('0.0.0.*');
            assert.equal(version.toString(), '0.0.0');
        });
    });

    describe('assign', function(){
        it('should return 1 from 0 assigned 1', function(){
            let target = Version.parse('0');
            let source = Version.parse('1');
            let result = target.assign(source);
            assert.equal(result.toString(), '1');
        });
        
        it('should return 1.0 from 0.0 assigned 1', function(){
            let target = Version.parse('0.0');
            let source = Version.parse('1');
            let result = target.assign(source);
            assert.equal(result.toString(), '1.0');
        });
        
        it('should return 1.0.0 from 0.0.0 assigned 1', function(){
            let target = Version.parse('0.0.0');
            let source = Version.parse('1');
            let result = target.assign(source);
            assert.equal(result.toString(), '1.0.0');
        });        
        
        it('should return 1.0.0.0 from 0.0.0.0 assigned 1', function(){
            let target = Version.parse('0.0.0.0');
            let source = Version.parse('1');
            let result = target.assign(source);
            assert.equal(result.toString(), '1.0.0.0');
        });
        
        it('should return 1.0 from 0 assigned 1.0', function(){
            let target = Version.parse('0');
            let source = Version.parse('1.0');
            let result = target.assign(source);
            assert.equal(result.toString(), '1.0');
        });
        
        it('should return 1.0.0 from 0 assigned 1.0.0', function(){
            let target = Version.parse('0');
            let source = Version.parse('1.0.0');
            let result = target.assign(source);
            assert.equal(result.toString(), '1.0.0');
        });
        
        it('should return 1.0.0.0 from 0 assigned 1.0.0.0', function(){
            let target = Version.parse('0');
            let source = Version.parse('1.0.0.0');
            let result = target.assign(source);
            assert.equal(result.toString(), '1.0.0.0');
        });
        
        it('should return 0.1 from 0 assigned *.1', function(){
            let target = Version.parse('0');
            let source = Version.parse('*.1');
            let result = target.assign(source);
            assert.equal(result.toString(), '0.1');
        });
        
        it('should return 0.0.1 from 0 assigned *.*.1', function(){
            let target = Version.parse('0');
            let source = Version.parse('*.*.1');
            let result = target.assign(source);
            assert.equal(result.toString(), '0.0.1');
        });
        
        it('should return 0.0.0.1 from 0 assigned *.*.*.1', function(){
            let target = Version.parse('0');
            let source = Version.parse('*.*.*.1');
            let result = target.assign(source);
            assert.equal(result.toString(), '0.0.0.1');
        });
    });

    describe('isEmpty', function(){
        it('should return true for *.*.*.*', function(){
            assert.isTrue(Version.isEmpty(Version.parse('*.*.*.*')));
        });

        it('should return true for *', function(){
            assert.isTrue(Version.isEmpty(Version.parse('*')));
        });

        it('should return false for 1', function(){
            assert.isFalse(Version.isEmpty(Version.parse('1')));
        });
    });
});