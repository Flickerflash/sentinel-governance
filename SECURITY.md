# Security Policy

## Reporting
If you find a security issue, open a private security advisory or contact the repository owner directly before publishing details.

## Sensitive Material
Do not commit:
- live API keys
- webhook secrets
- private keys
- production environment files

## Hardening
This repository runs governance and secret-scanning checks in CI. Any change that weakens those checks should be called out explicitly in review.
