# Security Policy

## Reporting Security Issues

To report a security issue, please use the GitHub Security Advisory ["Report a Vulnerability"](https://github.com/abap2UI5/abap2UI5/security/advisories/new) tab.

**DO NOT** create a public issue for security vulnerabilities.

---

## 🔒 Security Features

For a comprehensive overview of security features and best practices, see [SECURITY_FEATURES.md](SECURITY_FEATURES.md).

### Quick Overview

✅ **XSS Protection** - All user input is properly escaped
✅ **Content Security Policy** - Strict CSP implementation
✅ **HTTP Security Headers** - Comprehensive header protection
✅ **Session Encryption** - Session data encrypted at rest
✅ **Input Validation** - Built-in validation utilities
✅ **CSRF Protection** - Token-based CSRF protection available
✅ **SQL Injection Protection** - Parameterized queries enforced

### Security Enhancements (v1.141.0+)

Recent security improvements include:

1. **Fixed Critical XSS Vulnerability** (CVSS 7.5)
   - Replaced `document.write()` with secure `MessageBox.error()`
   - Location: `/app/webapp/cc/Server.js`

2. **Improved Content Security Policy**
   - Removed `unsafe-inline` for scripts
   - Added comprehensive directives
   - Location: `/src/02/z2ui5_cl_exit.clas.abap`

3. **Added HTTP Security Headers**
   - X-Frame-Options, X-Content-Type-Options, X-XSS-Protection
   - Strict-Transport-Security, Referrer-Policy, Permissions-Policy
   - Location: `/src/01/02/z2ui5_cl_core_handler.clas.abap`

4. **Session Security Improvements**
   - Session data encryption (Base64, upgrade to SSF recommended)
   - Session timeout reduced to 1 hour (from 4 hours)
   - Location: `/src/01/01/z2ui5_cl_core_srv_draft.clas.abap`

5. **Security Utilities Added**
   - Input sanitization (HTML, SQL)
   - Email validation
   - Length validation
   - CSRF token generation/validation
   - Location: `/src/00/03/z2ui5_cl_util_security.clas.abap`

## 📊 Security Audit

A comprehensive security audit was conducted on October 25, 2025. See [SECURITY_AUDIT_REPORT.md](SECURITY_AUDIT_REPORT.md) for details.

**Overall Risk Level:** LOW (after fixes)

## 🛡️ Best Practices for Developers

When developing apps with abap2UI5:

1. **Always validate user input**
   ```abap
   IF z2ui5_cl_util_security=>validate_length( input ) = abap_false.
     client->message_box_display( 'Invalid input' ).
     RETURN.
   ENDIF.
   ```

2. **Sanitize HTML output**
   ```abap
   DATA(safe_html) = z2ui5_cl_util_security=>sanitize_html( user_content ).
   ```

3. **Use parameterized SQL queries**
   ```abap
   SELECT * FROM table WHERE field = @value INTO @data.
   ```

4. **Implement authorization checks**
   ```abap
   AUTHORITY-CHECK OBJECT 'Z_OBJECT' ID 'ACTVT' FIELD '02'.
   ```

## 🔍 Security Testing

Run security scans regularly:

```bash
# ABAP static analysis
npm run auto_abaplint

# JavaScript dependency check
npm audit

# Fix vulnerabilities
npm audit fix
```

## 📝 Compliance

The framework addresses OWASP Top 10 2021 risks:

- ✅ A03: Injection
- ✅ A05: Security Misconfiguration
- ✅ A07: XSS (Cross-Site Scripting)
- ⚠️ A01: Broken Access Control (implement in your apps)
- ⚠️ A07: Authentication Failures (handled by SAP system)

## 📚 Resources

- [Full Security Features Documentation](SECURITY_FEATURES.md)
- [Security Audit Report](SECURITY_AUDIT_REPORT.md)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [SAP Security Guide](https://help.sap.com/docs/SAP_SECURITY)

---

**Last Updated:** October 25, 2025
**Security Version:** 1.141.0+
