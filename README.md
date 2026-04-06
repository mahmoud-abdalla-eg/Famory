# 🏠 One Famory

FamilyHub AI is a smart family coordination platform designed to bring families closer together—no matter what language they speak. It replaces scattered WeChat groups, forgotten photo albums, and sticky-note chaos with one simple, private space where families can organize, share, and remember.

Think of it as your family's personal command center, but friendly, fun, and actually easy to use.

Whether you are planning dinner, splitting chores, or rediscovering that cute beach photo from last summer, FamilyHub helps you do it together—in Arabic, English, or Chinese.

✨ Features

📸 Smart Photo Gallery
Upload photos and let AI gently group them into meaningful events like "Weekend Park Trip" or "Grandma's Birthday"—with warm, localized captions in your language.

✅ Fair Chore Wheel
No more "But why do I always have to take out the trash?" AI suggests fair chore assignments based on schedules and preferences, with gentle reminders that respect quiet hours.

📊 Quick Family Polls
Pizza or noodles? Movie night or game night? Create a poll in seconds and get instant family votes—no more endless WeChat threads.

📅 "On This Day" Memories
Rediscover happy moments with gentle, AI-powered memory prompts that surface meaningful photos from the past—without being pushy.

🌐 Full Trilingual Support
Switch seamlessly between 🇸🇦 Arabic, 🇬🇧 English, and 🇨🇳 Chinese. Arabic users get native RTL layout that feels natural from day one.

🔒 Privacy-First by Design
Your family data stays yours. Photos are processed on-device when possible, cloud backup is opt-in and encrypted, and we never sell data or show ads.

💬 WeChat Mini-Program
Don't want to install another app? Join your family hub right inside WeChat with our lightweight Mini-Program—view photos, vote in polls, get reminders.

🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| 📱 Mobile App | Flutter (iOS + Android) + `intl` for i18n & RTL |
| 💬 WeChat Mini-Program | Flutter-to-MP bridge / Native MP fallback |
| 🌐 Showcase Website | Next.js / Vue.js + Vercel with `/en`, `/zh`, `/ar` routing |
| 🤖 AI Core | CLIP (photo clustering), Qwen-1.8B-Chat (multilingual captions), DBSCAN |
| 🔧 Backend | Firebase / Alibaba Serverless (Auth, Firestore, Cloud Functions) |
| 🎨 Design | Figma, Material Design 3, Noto Sans Arabic/CJK fonts |

📁 Project Structure
onefamory/
├─ mobile/            # Flutter app: i18n, AI, RTL layouts
├─ website/           # Vite React showcase site + language
├─ backend/           # Backend Logic And routing
└─ README.md          # You are here

---

## 🚀 Getting Started

### Prerequisites

Make sure the following tools are installed:

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | 3.x or later | Mobile app development |
| Node.js | v16+ | Website backend and build tools |
| npm or yarn | Latest | Package management |
| Git | Latest | Version control |

---

### 🌐 Website Setup (Next.js)

| Step | Command | Description |
|------|---------|-------------|
| 1 | `cd ../famory website` | Navigate to web folder |
| 2 | `npm install` | Install Node.js dependencies |
| 3 | `npm run dev` | Start development server |

---

## 🔮 Future Improvements

| Feature | Status | Description |
|---------|--------|-------------|
| ⭐ Family Achievement Badges | Planned | Gentle gamification to celebrate family milestones |
| 💬 Voice Notes with Transcription | Planned | Send audio messages that auto-transcribe in your language |
| 🗓️ Calendar Sync | Planned | Connect with Google or Apple Calendar for shared events |
| 🎁 Gift and Event Planner | Planned | AI assistant for budgeting and planning family celebrations |
| 🌍 More Languages | Planned | Expand to Spanish, French, Urdu, and more |
| 🤖 Smarter AI | Research | Mood-aware reminders and predictive chore balancing |

---

## 💡 Vision

The goal of One Famory is to make family life:

| Goal | Impact |
|------|--------|
| 🤝 More Connected | Bring families together across distances and languages |
| 🔒 More Private | Keep family data secure with on-device processing and encryption |
| 🌍 More Inclusive | Support Arabic, English, and Chinese with native RTL layout |
| ✨ More Joyful | Spend less time managing logistics and more time making memories |

---

## 👥 Team

| Role | Contributor | Contact |
|------|------------|---------|
| 💼 Project Lead | `@mahmoud-abdalla-eg`
| 📱 Mobile Developer | `@saeif-ahmed-ye / Zack/ @mahmoud-abdalla-eg`
| 🌐 Web Developer | `@mahmoud-abdalla-eg`
| 🎓 Faculty Advisor | `Prof. [Name]`

---

## 📜 License & Usage

| Item | Details |
|------|---------|
| 🔐 Code License | Private & Proprietary (Competition Phase) → Public Release (Post-Competition) |
| 🎓 Current Purpose | Academic project for Jinan University "AI+" Innovation Competition 2026 |
| 🚀 Future Plan | Open to public release after competition finals (June 2026) |
| 📬 Inquiries | Contact the team at `mahmouddesign01@gmail.com` for collaboration or early access |

> ⚠️ **Notice:** During the competition phase (April–June 2026), this repository is for academic demonstration and judging purposes only. After the competition concludes, we plan to open-source core components and release the app publicly. Stay tuned for updates! 🎉

---

> 💙 *Built with love for families everywhere. Because the best moments aren't stored in the cloud—they're lived together.* 🏠✨

Happy coding, and happy family time! 🧠👨‍👩‍👧‍👦🚀
