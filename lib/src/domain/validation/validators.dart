final RegExp _emailRegExp = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');

/// Whether [value] looks like a well formed email address.
///
/// Deliberately permissive: it rejects obvious typos without trying to be a
/// full RFC 5322 parser. The authoritative check is the verification email.
bool isValidEmail(String value) => _emailRegExp.hasMatch(value);
