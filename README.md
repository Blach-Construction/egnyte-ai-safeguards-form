# Egnyte AI Safeguards — Folder Intake (single HTML file)

A self-contained web form for Blach department heads. They pick a department,
paste the **Egnyte folder paths** that hold sensitive content beside each
category, and click **Submit** — which auto-sends an alert email to
`dalton.kirkpatrick@blach.com` via EmailJS.

**The file to send people:** `Egnyte-AI-Safeguards-Form.html`
(everything — fonts, logo, styles, logic — is embedded; no other files needed).

- No database. Drafts auto-save to the user's own browser (localStorage).
- No server or build tooling required to *run* it.
- Categories per department are derived from *Egnyte AI Safeguards Policy v0.1*.

---

## 1. One-time setup: EmailJS (so Submit actually emails you)

1. Create a free account at <https://www.emailjs.com>.
2. **Email Services →** add a service (connect Outlook/Gmail). Copy the **Service ID**.
3. **Email Templates →** create a template and set:
   - **To email:** `dalton.kirkpatrick@blach.com`
   - **Subject:** `New AI Safeguards folders — {{department}}`
   - **Content** (these variable names must match exactly):

     ```
     A department head submitted Egnyte folder paths for AI Safeguards.

     Department:    {{department}}
     Submitted by:  {{submitted_by}}
     Submitted at:  {{submitted_at}}
     Total folders: {{total_folders}}

     ----------------------------------------
     {{summary}}
     ----------------------------------------

     Add these folders to the Egnyte AI Safeguards policy.
     ```

   Copy the **Template ID**.
4. **Account → General:** copy your **Public Key**.
5. Open `Egnyte-AI-Safeguards-Form.html`, find the **CONFIG** block near the top
   of the `<script>` (around the middle of the file), and paste your three values:

   ```js
   var EMAILJS_PUBLIC_KEY  = "your-public-key";
   var EMAILJS_SERVICE_ID  = "your-service-id";
   var EMAILJS_TEMPLATE_ID = "your-template-id";
   ```

That's it — re-save the file and send it out. Until these are filled in, the form
works but Submit just logs to the console instead of emailing.

## 2. Host it at a shareable URL (recommended)

Hosting at a real `https://` URL is the recommended way to share this — EmailJS
sends reliably from a proper domain (it can be flaky from a `file://` link), and
everyone always gets the latest version. The build produces a `deploy/` folder
containing `index.html` for exactly this.

**Fastest: Netlify Drop (free, no repo, private source)**
1. Fill in your EmailJS keys (section 1) and re-run `build.ps1`.
2. Go to <https://app.netlify.com/drop> and sign up (free) so the site persists.
3. Drag the whole **`deploy`** folder onto the page. You get a URL like
   `https://your-site.netlify.app` — rename it in site settings if you like.
4. In EmailJS **Account → Security**, add that domain to the allowed origins so
   the keys can't be reused elsewhere.
5. Open the URL, submit a test, confirm the email arrives.

**Alternative: GitHub Pages** — works too, but on a free account the repo must be
**public** (the source code is visible to anyone; the EmailJS public key is safe
to expose, but the rest is public). Push `deploy/index.html` to a repo, enable
Pages, done.

Note: any free static host gives a **publicly reachable** URL (no login). The page
only shows department names and generic category descriptions — actual folder
paths and submissions are never stored on the page, they only go out in the email.
Free email-login gating (if ever needed) is possible via Cloudflare Pages +
Cloudflare Access (free up to 50 users).

The free EmailJS tier allows 200 emails/month — far more than this intake needs.

## 3. Editing the form

- **Categories / departments:** edit the `DEPARTMENTS` and `CATEGORIES` objects in
  the `<script>`. Keep each `key` unique and stable (it's how drafts are stored).
- **Rebuilding from source:** the editable source is `template.html`; the fonts and
  logo live in `assets/`. After editing `template.html`, regenerate the standalone
  file with:

  ```
  powershell -ExecutionPolicy Bypass -File build.ps1
  ```

  (You can also just edit `Egnyte-AI-Safeguards-Form.html` directly for small
  changes like the EmailJS keys — the build step only re-embeds the assets.)

## Files

| File | What it is |
|---|---|
| `Egnyte-AI-Safeguards-Form.html` | **The deliverable** — self-contained, send this. |
| `template.html` | Editable source (assets referenced as tokens). |
| `build.ps1` | Embeds fonts + logo into the template → the deliverable. |
| `assets/` | Gotham WOFF fonts + Blach logo used by the build. |
