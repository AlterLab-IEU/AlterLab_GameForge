# Playtest Consent and Privacy Basics

Playtests collect personal data: faces, voices, screen recordings, opinions, sometimes device
details and telemetry. Treat it with the same care you would want for yourself. This is practical
guidance, not legal advice; for a commercial program with many testers, or anything involving
minors, get a short review from a lawyer in your jurisdiction.

## 1. Principles

- **Informed**: testers know exactly what is recorded, why, who sees it, and for how long.
- **Freely given and specific**: separate opt-ins for screen recording, webcam, voice and telemetry.
  A tester can say no to the webcam and still play.
- **Minimal**: collect only what answers this round's questions. No names in filenames, no
  free-text fields that invite personal details, no IP or fingerprint logging.
- **Revocable**: testers can withdraw and have their recordings deleted. Make it one email.
- **Bounded**: a retention period (for example 30 or 90 days for raw recordings) that you actually
  honor. Findings (pseudonymized) can be kept; raw video should not live forever.

## 2. Consent form template

```markdown
# Playtest Consent -- [Game working title], [Studio/your name]
Session date: [YYYY-MM-DD] | Tester ID: [P03] (used instead of your name in all notes)

**What this is.** You will play an unfinished build of [game] for about [45] minutes and answer
some questions. We are testing the game, not you. You can stop at any time without giving a reason.

**What we record** (tick what you agree to):
- [ ] Screen and game audio
- [ ] Your voice (comments during play and the interview)
- [ ] Your webcam (face)
- [ ] Gameplay telemetry: [list events, e.g. deaths, level times, settings changed]

**Who sees it.** [Names or roles, e.g. "the two-person dev team"]. It is never published or shared
publicly. [If applicable: Notes and transcripts may be processed by [tool name] to help summarize
feedback; recordings are / are not uploaded to it.]

**How long we keep it.** Raw recordings are deleted by [date]. Pseudonymized notes may be kept
for the life of the project.

**Confidentiality.** The build is unreleased. Please do not share it, stream it or post screenshots
[until DATE / without permission].

**Withdrawing.** Email [address] with your tester ID and we will delete your recordings and data
within [14] days.

**Thank-you.** [Key, credit in the game, gift card, nothing -- state it plainly.]

Signature / typed name: __________  Date: ________
Age confirmation: [ ] I am 18 or older (or: guardian consent attached)
```

Keep signed forms separate from session data; the mapping from name to tester ID lives only with
the consent records.

## 3. Minors

- Default to adult testers. Test with minors only when the game targets them and you have a reason.
- Get written guardian consent in addition to the young person's own agreement, and have the
  guardian present or reachable during remote sessions.
- In the US, collecting personal information from children under 13 online triggers COPPA
  (verifiable parental consent). In the EU and UK the age at which a child can consent to online
  services varies by country (13-16). If in doubt, do not record minors at all; take notes only.

## 4. EU and UK testers

If testers are in the EU or UK, the GDPR (or UK GDPR) applies to their data even if you are
elsewhere. In practice for a small playtest:
- Your lawful basis is usually consent: the form above, with separate tick boxes.
- Tell people their rights (access, deletion, withdrawal) and honor requests promptly.
- If recordings or transcripts go to an outside service (cloud storage, transcription, an AI
  summarizer), that service processes personal data on your behalf. Use services that offer a data
  processing agreement and say so in the consent form.
- Do not move recordings into tools or regions you did not disclose.

## 5. AI processing

- Only send recordings, transcripts or survey text to an AI service if the consent form says so.
- Prefer sending text over video, and pseudonymized text over raw text.
- Check the service's data-retention and training terms; choose settings that do not train on your
  data where available.
- Keep the original material: AI summaries are derived work and must be checkable against it.

## 6. Telemetry

- List every event in the consent form. If you add events between rounds, update the form.
- Do not collect identifiers beyond a random per-session ID.
- Offer a local export option (the tester sends the log) for small rounds; it makes the consent
  real and the data flow obvious.
- Ongoing analytics for released games (consent banners, privacy policy, platform rules) belong to
  `/gameforge:game-analytics-setup`.

## 7. Storage and deletion checklist

- [ ] Recordings in one access-controlled folder, named by tester ID and date only
- [ ] Consent forms stored separately from recordings
- [ ] Deletion date in the calendar; deletion done and noted in the report's "Data Handling" line
- [ ] Withdrawal requests logged and completed
- [ ] No recordings in chat apps, email threads or shared drives beyond the listed people
