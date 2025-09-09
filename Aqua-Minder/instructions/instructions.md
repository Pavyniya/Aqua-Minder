You are an experienced iOS app developer who explains things in grade 5 level english without technical jargon
Create a simple, step-by-step REQUIREMENTS DOCUMENT for an iOS app idea using Swift, SwiftUI, and Xcode.

The goal is for this document to:

1. Be easy to understand for someone who codes for fun.
2. Use plain language, not technical jargon.
3. Number each item clearly so I can refer to them later when asking you to implement in Cursor.

## Sections to include (in order):

# Water Reminder App (iOS)

## 1. App Overview
This app helps people drink enough water every day. It is made for anyone who wants to stay healthy and remember to drink water. The app is super simple: one tap to log a sip or bottle, and it shows a ring that fills up as you reach your daily goal.  

---

## 2. Main Goals
1. Make it very easy to log water (1 tap).  
2. Remind users to drink water during the day.  
3. Show how much water they have already drunk.  
4. Let them fix mistakes if they log the wrong amount.  
5. Keep a history so users can see past days.  

---

## 3. User Stories
- **US-001**: As a user, I want to log a sip with one tap so that it’s fast and easy.  
- **US-002**: As a user, I want to log a full bottle so that I don’t need to tap many times.  
- **US-003**: As a user, I want to see my daily goal as a ring so I can see progress.  
- **US-004**: As a user, I want reminders so that I don’t forget to drink water.  
- **US-005**: As a user, I want an undo button so I can fix mistakes quickly.  
- **US-006**: As a user, I want to see my water history so I can track past days.  

---

## 4. Features
- **F-001 (Quick Logging):**  
  - Single tap = log sip (default 50ml).  
  - Double tap = log default bottle (e.g., 750ml).  
  - Long press = choose bottle size.  
  - If user taps wrong, show “Undo” option.  

- **F-002 (Progress Ring):**  
  - Big ring shows how close you are to your goal.  
  - Text in the middle shows today’s total (e.g., 1.2L / 2.5L).  
  - If goal is reached, ring glows or celebrates.  

- **F-003 (Reminders):**  
  - App sends simple notifications (e.g., “Time for a sip 💧”).  
  - If tapped, it adds a sip right away.  

- **F-004 (History):**  
  - Tapping the ring opens today’s log list.  
  - Show time and amount of each entry.  
  - Swipe left to delete an entry.  
  - Can switch to weekly or monthly chart.  

- **F-005 (Settings):**  
  - Change daily goal.  
  - Change sip size.  
  - Change default bottle size.  
  - Pick reminder times.  

---

## 5. Screens
- **S-001 (Onboarding Screen):**  
  - User sets daily goal, sip size, default bottle, and reminders.  
  - Shown only when first opening the app.  

- **S-002 (Main Screen):**  
  - Shows progress ring.  
  - One big button to log water.  
  - Undo snackbar at the bottom after each log.  

- **S-003 (History Screen):**  
  - List of today’s logs.  
  - Option to switch to weekly/monthly chart.  

- **S-004 (Settings Screen):**  
  - Options to change goal, sip size, bottle presets, and reminders.  

---

## 6. Data
- **D-001:** Daily water goal (number in ml).  
- **D-002:** Default sip size (ml).  
- **D-003:** Default bottle size (ml).  
- **D-004:** List of water logs (amount + time).  
- **D-005:** Reminder settings (times and frequency).  

---

## 7. Extra Details
- Works offline (no internet needed).  
- Saves data on the phone.  
- Needs permission for notifications.  
- Should support light mode and dark mode.  

---

## 8. Build Steps
- **B-001:** Build **S-002 (Main Screen)** with **F-001 (Quick Logging)**.  
- **B-002:** Add **F-002 (Progress Ring)** and connect to **D-001 + D-004**.  
- **B-003:** Add **Undo snackbar** to fix mistakes.  
- **B-004:** Build **S-003 (History Screen)** and connect to logs.  
- **B-005:** Build **S-004 (Settings Screen)** to update goal, sip, and bottle sizes.  
- **B-006:** Build **S-001 (Onboarding)** to set first-time values.  
- **B-007:** Add **F-003 (Reminders)** using notification permission.  
- **B-008:** Connect all screens with simple navigation.  

---


## Style & Clarity Rules
- Keep it simple.
- Use short sentences.
- No advanced architecture or design patterns.
- No heavy technical words unless explained in plain English.
- Format this document in markdown

---- AAPP IDEA: A simple Water Reminder app that lets users quickly log a sip or a bottle with one tap, track their progress with a hydration ring, and get smart reminders to drink water during the day. It’s for anyone who wants to stay healthy and meet their daily hydration goals without extra effort.----