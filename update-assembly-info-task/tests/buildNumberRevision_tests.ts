import * as task from 'vsts-task-lib/task';

import * as mocha from 'mocha';
import * as chai from 'chai';
let expect = chai.expect;
let assert = chai.assert;

import { BuildNumberRevision } from '../buildNumberRevision';

describe('BuildNumberRevision', function () {
    describe('get', function () {
        it('should throw system.enableAccessToken must be enabled error if system.enableAccessToken not true', function () {
            assert.throws(function () {
                let buildNumberRevision = new BuildNumberRevision();
                let revision = buildNumberRevision.get();
            }, '\'Allow Scripts to Access OAuth Token\' must be enabled');
        });

        it('should not throw system.enableAccessToken must be enabled error if system.enableAccessToken is true', function () {
            assert.doesNotThrow(function () {
                task.setVariable('system.enableAccessToken', 'true');
                let buildNumberRevision = new BuildNumberRevision();
                let revision = buildNumberRevision.get();
                task.setVariable('system.enableAccessToken', undefined);
            });
        });

        it('should return a promise', function () {
            task.setVariable('system.enableAccessToken', 'true');
            let buildNumberRevision = new BuildNumberRevision();
            let revision = buildNumberRevision.get();
            assert.instanceOf(revision, Promise);
            task.setVariable('system.enableAccessToken', undefined);
        });
    });
});