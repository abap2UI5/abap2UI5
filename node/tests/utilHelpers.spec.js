// @ts-check
const { test, expect } = require('@playwright/test');
const { loadUtil } = require('./loadUtilModule');

// Tests the security and session helpers shipped in app/webapp/cc/Util.js.
// The module is loaded via a stubbed sap.ui.define (see loadUtilModule.js),
// with window.location.origin anchored to http://localhost:3000.

const ORIGIN = 'http://localhost:3000';

test.describe('isValidRedirectURL (same-origin http/https only)', () => {
    const { Util } = loadUtil();

    test('accepts a relative URL', () => {
        expect(Util.isValidRedirectURL('/sap/bc/ui5_ui5/index.html')).toBe(true);
    });

    test('accepts an absolute same-origin URL', () => {
        expect(Util.isValidRedirectURL(`${ORIGIN}/path?x=1#frag`)).toBe(true);
    });

    test('blocks a different origin', () => {
        expect(Util.isValidRedirectURL('https://evil.example.com/')).toBe(false);
    });

    test('blocks a different port on the same host', () => {
        expect(Util.isValidRedirectURL('http://localhost:8080/')).toBe(false);
    });

    test('blocks javascript: URLs', () => {
        expect(Util.isValidRedirectURL('javascript:alert(1)')).toBe(false);
    });

    test('blocks data: URLs', () => {
        expect(Util.isValidRedirectURL('data:text/html,<b>x</b>')).toBe(false);
    });

    test('rejects empty and missing input', () => {
        expect(Util.isValidRedirectURL('')).toBe(false);
        expect(Util.isValidRedirectURL(undefined)).toBe(false);
        expect(Util.isValidRedirectURL(null)).toBe(false);
    });
});

test.describe('isSafeRedirectProtocol (cross-origin allowed, http/https only)', () => {
    const { Util } = loadUtil();

    test('accepts a cross-origin https URL', () => {
        expect(Util.isSafeRedirectProtocol('https://example.com/page')).toBe(true);
    });

    test('accepts a relative URL', () => {
        expect(Util.isSafeRedirectProtocol('/local/path')).toBe(true);
    });

    test('blocks javascript: URLs', () => {
        expect(Util.isSafeRedirectProtocol('javascript:alert(1)')).toBe(false);
    });

    test('blocks vbscript: URLs', () => {
        expect(Util.isSafeRedirectProtocol('vbscript:msgbox(1)')).toBe(false);
    });

    test('blocks data: URLs', () => {
        expect(Util.isSafeRedirectProtocol('data:text/html,<b>x</b>')).toBe(false);
    });
});

test.describe('isSafeDownloadURL (data/blob/http/https)', () => {
    const { Util } = loadUtil();

    test('accepts data: URLs', () => {
        expect(Util.isSafeDownloadURL('data:image/png;base64,AAAA')).toBe(true);
    });

    test('accepts blob: URLs', () => {
        expect(Util.isSafeDownloadURL(`blob:${ORIGIN}/123-456`)).toBe(true);
    });

    test('accepts http(s) and relative URLs', () => {
        expect(Util.isSafeDownloadURL('https://example.com/file.pdf')).toBe(true);
        expect(Util.isSafeDownloadURL('/files/report.pdf')).toBe(true);
    });

    test('blocks javascript: URLs', () => {
        expect(Util.isSafeDownloadURL('javascript:alert(1)')).toBe(false);
    });

    test('rejects empty input', () => {
        expect(Util.isSafeDownloadURL('')).toBe(false);
    });
});

test.describe('isValidContextId', () => {
    const { Util } = loadUtil();

    test('accepts a real session id', () => {
        expect(Util.isValidContextId('SID:ANON:ldai1abc_ABC_00:xyz')).toBe(true);
    });

    test('rejects the empty string', () => {
        expect(Util.isValidContextId('')).toBe(false);
    });

    test('rejects the literal string "undefined"', () => {
        expect(Util.isValidContextId('undefined')).toBe(false);
    });

    test('rejects non-string values', () => {
        expect(Util.isValidContextId(undefined)).toBe(false);
        expect(Util.isValidContextId(null)).toBe(false);
        expect(Util.isValidContextId(42)).toBe(false);
    });
});

test.describe('logError', () => {
    test('caps the error log at 100 entries, dropping the oldest', () => {
        const { Util, sandbox } = loadUtil();
        for (let i = 0; i < 150; i++) Util.logError(`error ${i}`);
        expect(sandbox.z2ui5.errors.length).toBe(100);
        expect(sandbox.z2ui5.errors[0].message).toBe('error 50');
        expect(sandbox.z2ui5.errors[99].message).toBe('error 149');
    });

    test('stores the error object only when one was passed', () => {
        const { Util, sandbox } = loadUtil();
        Util.logError('plain message');
        Util.logError('with error', new Error('boom'));
        expect(sandbox.z2ui5.errors[0]).not.toHaveProperty('error');
        expect(sandbox.z2ui5.errors[1].error.message).toBe('boom');
        expect(sandbox.z2ui5.errors[1].ts).toBeTruthy();
    });
});
