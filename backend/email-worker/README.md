# GJandAsher transactional email worker

This Cloudflare Worker sends the two transactional emails used by the app:

| Endpoint | Used by | Purpose |
| --- | --- | --- |
| `POST /staff-approved` | Admin approval screen | Tells a staff member their account was approved. |
| `POST /password-reset` | Forgot-password dialog | Generates a Firebase reset link and emails it from your verified domain. |

The app calls this worker only when it is built with `EMAIL_WORKER_URL` and
`EMAIL_API_KEY`. If the worker is not configured, or a request fails, staff
approval still succeeds in Firestore and password reset falls back to Firebase
Auth's built-in reset email. That fallback keeps the app usable while you set
up the domain.

---

## Why a worker?

A mobile app cannot safely hold an SMTP password or a Resend API key. The worker
keeps those secrets on Cloudflare and exposes only a small, rate-limitable
endpoint. It also generates the Firebase password-reset link server-side, so the
email can be branded and sent from your own authenticated domain instead of
`firebaseapp.com`.

## Prerequisites

1. A **Cloudflare** account (the same one already hosting the FCM worker is fine).
2. A **Resend** account: <https://resend.com>.
3. A **domain you own** (for example `gjandasher.com`). Resend must verify this
   domain before it can send to arbitrary recipients. Resend's shared
   `onboarding@resend.dev` sender is only for testing to your own account email.
4. A **Firebase service account** for the `shiptracker-v2` project.

> Inbox placement is never guaranteed by code. A verified domain with SPF, DKIM,
> and DMARC is the single biggest factor. Follow the deliverability checklist
> below.

---

## 1. Verify a sending domain in Resend

1. In Resend, open **Domains → Add Domain** and enter your domain (or a
   subdomain such as `mail.gjandasher.com`).
2. Add the DNS records Resend gives you:
   - **SPF** (`TXT` on the sending domain)
   - **DKIM** (`TXT` records)
   - **DMARC** (`TXT` on `_dmarc.yourdomain.com`)
3. Wait for Resend to show **Verified**.
4. Create an API key under **API Keys** and copy it.

A reasonable DMARC starter record:

```text
v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com; adkim=s; aspf=s; pct=100
```

Start with `p=none` while testing, then move to `p=quarantine` once you have
confirmed that legitimate mail passes.

Set `MAIL_FROM` in `wrangler.toml` to an address on the verified domain, for
example:

```toml
MAIL_FROM = "GJandAsher Digital Printing <notifications@mail.gjandasher.com>"
REPLY_TO = "support@gjandasher.com"
```

Use a real, monitored Reply-To address. Do not use `no-reply@` unless you also
monitor it; replies improve sender reputation.

## 2. Create a Firebase service account

1. Firebase Console → **Project settings → Service accounts**.
2. Click **Generate new private key** and save the JSON file somewhere safe.
3. In Google Cloud IAM, give the service account a role that can manage
   Firebase Authentication, such as **Firebase Authentication Admin** or
   **Firebase Admin SDK Administrator Service Agent**.

The worker needs `client_email` and `private_key` from the JSON file.

## 3. Configure and deploy

From this directory (`backend/email-worker`):

```powershell
npm install

# Non-secret values live in wrangler.toml. Edit MAIL_FROM / REPLY_TO first.

# Store secrets (PowerShell examples):
$sa = Get-Content .\service-account.json -Raw | ConvertFrom-Json
$sa.client_email | npx wrangler secret put FIREBASE_CLIENT_EMAIL
$sa.private_key | npx wrangler secret put FIREBASE_PRIVATE_KEY
npx wrangler secret put RESEND_API_KEY
npx wrangler secret put API_KEY
```

Use a long random value for `API_KEY` (for example, 32+ random characters).
Then deploy:

```powershell
npx wrangler deploy
```

Wrangler prints the worker URL, for example:

```text
https://gjandasher-email.your-subdomain.workers.dev
```

## 4. Build the app with the worker URL

Pass both values at build time:

```powershell
flutter build apk --release `
  --dart-define=EMAIL_WORKER_URL=https://gjandasher-email.your-subdomain.workers.dev `
  --dart-define=EMAIL_API_KEY=your-long-random-key
```

For local testing:

```powershell
flutter run `
  --dart-define=EMAIL_WORKER_URL=https://gjandasher-email.your-subdomain.workers.dev `
  --dart-define=EMAIL_API_KEY=your-long-random-key
```

If you later build an Android App Bundle for Play Store, pass the same
`--dart-define` flags to `flutter build appbundle`.

## 5. Test the endpoints

Health check:

```powershell
curl.exe https://gjandasher-email.your-subdomain.workers.dev/health
```

Approval email:

```powershell
curl.exe -X POST "https://gjandasher-email.your-subdomain.workers.dev/staff-approved" `
  -H "Content-Type: application/json" `
  -H "x-api-key: your-long-random-key" `
  -d "{\"to\":\"you@example.com\",\"name\":\"Test Staff\"}"
```

Password reset:

```powershell
curl.exe -X POST "https://gjandasher-email.your-subdomain.workers.dev/password-reset" `
  -H "Content-Type: application/json" `
  -H "x-api-key: your-long-random-key" `
  -d "{\"email\":\"you@example.com\"}"
```

Check the Resend dashboard for delivery events. If Resend accepts the message
but it lands in spam, work through the checklist below.

---

## Deliverability checklist

- [ ] Sending domain is **verified in Resend** (SPF + DKIM records present).
- [ ] DMARC record exists and passes for the sending domain.
- [ ] `MAIL_FROM` uses the verified domain, not a free Gmail/Outlook address.
- [ ] `REPLY_TO` is a real, monitored mailbox.
- [ ] Both HTML and plain-text bodies are sent (the worker does this).
- [ ] No URL shorteners, no misleading subjects, no ALL CAPS, no excessive
      exclamation marks, no attachments.
- [ ] The reset link uses HTTPS.
- [ ] You send from a consistent address over time; sudden volume spikes hurt
      reputation.
- [ ] You monitor Resend's bounce/complaint events and remove bad addresses.
- [ ] Users who report missing mail are asked to check Spam and mark the sender
      as **Not spam**. This trains their mailbox and helps future messages.

No provider can promise 100% inbox placement. Gmail, Outlook, and corporate
filters make the final decision. The setup above is the standard way to maximize
the chance of inbox delivery.

## Security notes

- The `API_KEY` is compiled into the mobile app and can be extracted by a
  determined attacker. Treat it as a spam-abuse speed bump, not a strong secret.
- Add a **Cloudflare Rate Limiting** rule for the worker (for example, 20
  requests per minute per IP) and rotate `API_KEY` if you see abuse.
- For a higher-security setup, replace the shared key with Firebase ID-token
  verification and check that the caller is an admin before sending approval
  mail. Password reset should remain callable without a session.
- Never commit `service-account.json`, `.dev.vars`, or real API keys.

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| `401 Unauthorized` | `x-api-key` does not match the `API_KEY` secret. |
| `500 ... Missing: ...` | A secret or `wrangler.toml` var is not set. |
| `Resend rejected ... 403` | The domain is not verified, or `MAIL_FROM` is not on the verified domain. |
| `Could not obtain a Firebase access token` | Wrong `FIREBASE_CLIENT_EMAIL` / `FIREBASE_PRIVATE_KEY`, or the service account lacks permission. |
| Password reset returns `sent: false` | Firebase reported no account for that email. The app intentionally shows success to avoid account enumeration. |
| Mail accepted but in spam | Domain authentication/reputation issue; see the checklist. |
