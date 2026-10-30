# gjandasher_shiptracker

Flutter app for GJandAsher Digital Printing: outbound parcel tracking, returns,
customer QR registry, analytics, and staff/customer portals.

## Staff registration approvals

New staff accounts are created with `status: pending` and are signed out
immediately. They cannot enter the Staff Portal until an admin/owner approves
them from:

**Profile → Administration → Staff Registration Approvals**

Approving an account sets it to `active` and sends an approval email to the
staff member's registered address. Rejected accounts are blocked at login.

The `users` Firestore rules enforce this workflow:

- customers are created `active`
- staff are created `pending`
- only an admin can change another user's role or status
- users can never change their own role or status

Deploy the rules with:

```powershell
firebase deploy --only firestore:rules --project shiptracker-v2
```

## Transactional email

Approval and password-reset emails are sent through a Cloudflare Worker using
Resend. See [`backend/email-worker/README.md`](backend/email-worker/README.md)
for domain verification, DNS/SPF/DKIM/DMARC setup, secrets, deployment, and
deliverability guidance.

Build the app with the worker URL and shared key:

```powershell
flutter build apk --release `
  --dart-define=EMAIL_WORKER_URL=https://your-worker.workers.dev `
  --dart-define=EMAIL_API_KEY=your-shared-key
```

If the worker is not configured, staff approval still succeeds in Firestore
(the admin sees a warning), and password reset falls back to Firebase Auth's
built-in reset email.

> Inbox placement cannot be guaranteed by code. A verified sending domain with
> SPF, DKIM, and DMARC is the standard way to maximize deliverability.

## Development

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```
