import * as task from 'vsts-task-lib/task';
import { StringUtils } from './stringUtils';

export class Version {
    major: number;
    minor: number;
    build: number;
    revision: number;

    constructor(major: number, minor: number, build: number, revision: number) {
        this.major = major;
        this.minor = minor;
        this.build = build;
        this.revision = revision;
    }

    assign(source: Version): Version {
        task.debug('Version.assign');
        task.debug('this: ' + this.toString());
        task.debug('source: ' + source.toString());
        if (!Number.isNaN(source.major)) {
            this.major = source.major;
        }

        if (!Number.isNaN(source.minor)) {
            if (Number.isNaN(this.major)) {
                task.debug('major = 0');
                this.major = 0;
            }
            this.minor = source.minor
        }

        if (!Number.isNaN(source.build)) {
            if (Number.isNaN(this.major)) {
                task.debug('major = 0');
                this.major = 0;
            }
            if (Number.isNaN(this.minor)) {
                task.debug('minor = 0');
                this.minor = 0;
            }
            this.build = source.build;
        }

        if (!Number.isNaN(source.revision)) {
            if (Number.isNaN(this.major)) {
                task.debug('major = 0');
                this.major = 0;
            }
            if (Number.isNaN(this.minor)) {
                task.debug('minor = 0');
                this.minor = 0;
            }
            if (Number.isNaN(this.build)) {
                task.debug('build = 0');
                this.build = 0;
            }
            this.revision = source.revision;
        }

        task.debug('this after assign: ' + this.toString());

        return this;
    }

    toString(): string {
        task.debug('Version.toString');
        var result = ''

        if (!Number.isNaN(this.major)) {
            result += this.major.toString();
        }
        if (!Number.isNaN(this.minor)) {
            result += '.' + this.minor.toString();
        }
        if (!Number.isNaN(this.build)) {
            result += '.' + this.build.toString();
        }
        if (!Number.isNaN(this.revision)) {
            result += '.' + this.revision.toString();
        }

        return result;
    }

    static parse = function (versionString: string): Version {
        task.debug('Version.parse');
        task.debug('versionString: ' + versionString);

        if (!Version.valid(versionString)){
            throw new Error('Invalid version format: ' + versionString);
        }

        var major: number = Number.NaN;
        var minor: number = Number.NaN;
        var build: number = Number.NaN;
        var revision: number = Number.NaN;

        var parts = versionString.split('.');
        task.debug('parts: ' + JSON.stringify(parts));
        if (parts[0]) {
            task.debug('0: ' + parts[0]);
            major = Number(parts[0]);
        }

        if (parts[1]) {
            task.debug('1: ' + parts[1]);
            minor = Number(parts[1]);
        }

        if (parts[2]) {
            task.debug('2: ' + parts[2]);
            build = Number(parts[2]);
        }

        if (parts[3]) {
            task.debug('3: ' + parts[3]);
            revision = Number(parts[3]);
        }

        var version = new Version(major, minor, build, revision);
        task.debug('version: ' + version.toString());
        return version;
    }

    static valid = function (value: string): boolean {
        task.debug('Version.valid');
        task.debug('value: ' + value);

        if (StringUtils.isNullOrEmpty(value)){
            return false;
        }

        var parts = value.split('.');
        task.debug('parts: ' + JSON.stringify(parts));
        task.debug('parts.lenght: ' + JSON.stringify(parts.length));
        if (parts.length > 4) {
            return false;
        }
        for (let part of parts) {
            task.debug('part: ' + JSON.stringify(part));
            if (part === '*'){
                continue;
            }
            if (Number.isNaN(Number(part))) {
                task.debug(part + ' is not a valid numeric value');
                return false;
            }
        }

        return true
    }

    static isEmpty = function(version: Version): boolean {
        return Number.isNaN(version.major) && Number.isNaN(version.minor) && Number.isNaN(version.build) && Number.isNaN(version.revision);
    }
}