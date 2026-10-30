# প্রজেক্ট খাতা (Project Khata) - Google Play Store রিলিজ গাইড

এই নির্দেশিকাটি অনুসরণ করে আপনি খুব সহজেই **Project Khata** অ্যাপের প্রোডাকশন সাইনড অ্যান্ড্রয়েড অ্যাপ বান্ডেল (`.aab`) তৈরি করতে পারবেন এবং Google Play Console-এ আপলোড করে সফলভাবে অ্যাপটি রিলিজ করতে পারবেন।

---

## ১. আপলোড কীস্টোর (Upload Keystore) তৈরি

গুগল প্লে স্টোরে অ্যাপ আপলোড করতে একটি সাইনিং কি (Keystore) প্রয়োজন হয়। আপনার পিসির টার্মিনালে নিচের কমান্ডটি চালিয়ে একটি নতুন কীস্টোর তৈরি করুন:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> [!CAUTION]
> এই কীস্টোর ফাইল (`upload-keystore.jks`) এবং এর পাসওয়ার্ড অত্যন্ত গুরুত্বপূর্ণ। এটি হারিয়ে গেলে পরবর্তীতে প্লে স্টোরে অ্যাপের কোনো আপডেট আপলোড করা যাবে না। ফাইলটি এবং পাসওয়ার্ড নিরাপদে ব্যাকআপ রাখুন। এটি কখনোই গিটহাবে পুশ করবেন না।

---

## ২. লোকাল সাইনিং কনফিগারেশন (`key.properties`)

1. `app/android/key.properties.example` ফাইলটি কপি করে `app/android/key.properties` নামে সেভ করুন:
   ```bash
   cp app/android/key.properties.example app/android/key.properties
   ```
2. আপনার তৈরি করা `upload-keystore.jks` ফাইলটি `app/android/` ডিরেক্টরিতে রাখুন।
3. `app/android/key.properties` ফাইলে আপনার কীস্টোরের আসল পাসওয়ার্ড ও বিবরণ বসান:
   ```properties
   storePassword=আপনার_কীস্টোর_পাসওয়ার্ড
   keyPassword=আপনার_কী_পাসওয়ার্ড
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

*(নোট: `.gitignore`-এ ইতিমধ্যে `key.properties` ও `*.jks` ফাইল অন্তর্ভুক্ত থাকায় এটি গিটহাবে পুশ হবে না।)*

---

## ৩. লোকাল মেশিনে প্রোডাকশন AAB বিল্ড

টার্মিনালে `app` ফোল্ডারে গিয়ে নিচের কমান্ডটি চালান:

```bash
cd app
flutter pub get
flutter build appbundle --release
```

বিল্ড সম্পন্ন হলে আপনার রিলিজ AAB ফাইলটি এখানে পাবেন:
```
app/build/app/outputs/bundle/release/app-release.aab
```
এই `app-release.aab` ফাইলটি সরাসরি Google Play Console-এ আপলোড করা যাবে।

---

## ৪. GitHub Actions দিয়ে ক্লাউডে অটোমেটিক রিলিজ AAB তৈরি

যদি আপনি লোকাল মেশিনে না করে GitHub-এর মাধ্যমে অটোমেটিক রিলিজ AAB বানাতে চান:

1. আপনার কীস্টোর ফাইলটিকে Base64 স্ট্রিং-এ রূপান্তর করুন:
   - লিনাক্স/ম্যাক: `base64 -w 0 upload-keystore.jks`
   - উইন্ডোজ: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))`
2. GitHub-এ আপনার রিপোজিটরি সেটিংসে যান:
   **Settings** → **Secrets and variables** → **Actions** → **New repository secret**
3. নিচের ৪টি সিক্রেট যোগ করুন:
   - `KEYSTORE_BASE64`: বেস৬৪ এনকোডেড স্ট্রিং
   - `KEYSTORE_PASSWORD`: কীস্টোরের পাসওয়ার্ড
   - `KEY_PASSWORD`: কী-এর পাসওয়ার্ড
   - `KEY_ALIAS`: কী-এর নাম (সাধারণত `upload`)
4. এখন GitHub-এর **Actions** ট্যাবে গিয়ে **Build & Release Google Play AAB** ওয়ার্কফ্লোটি `Run workflow`-এ ক্লিক করলেই সাইনড `app-release.aab` ফাইল তৈরি হয়ে আর্টিকেক্ট আকারে ডাউনলোড করতে পারবেন। অথবা `v1.0.0` ট্যাগ পুশ করলেই এটি স্বয়ংক্রিয়ভাবে চালু হবে।

---

## ৫. Google Play Console-এ আপলোডের চেকলিস্ট

Google Play Console (play.google.com/console)-এ নতুন অ্যাপ তৈরি করে নিচের ধাপগুলো সম্পন্ন করুন:

### ক. অ্যাপ বিবরণ (App Details)
- **App name**: প্রজেক্ট খাতা (Project Khata)
- **Short description**: ঠিকাদার ও কনস্ট্রাকশন খাতা ও সাইট ম্যানেজমেন্ট অ্যাপ
- **Full description**: প্রজেক্ট খাতা বাংলাদেশের কনস্ট্রাকশন ঠিকাদার, সাইট সুপারভাইজার ও ক্লায়েন্টদের জন্য তৈরি একটি পূর্ণাঙ্গ ডিজিটাল খাতা ও প্রজেক্ট ম্যানেজমেন্ট প্ল্যাটফর্ম। সাইট হাজিরা, মজুরি হিসাব, মালামাল ও খরচের হিসাব এক অ্যাপেই সমাধান।

### খ. গ্রাফিক্স অ্যাসেট (Graphic Assets)
1. **App Icon**: 512 x 512 px, 32-bit PNG (স্বচ্ছ ব্যাকগ্রাউন্ড নয়)।
2. **Feature Graphic**: 1024 x 500 px, JPG বা 24-bit PNG।
3. **Screenshots**: কমপক্ষে ২টি ফোন স্ক্রিনশট (১৬:৯ বা ৯:১৬ অ্যাসপেক্ট রেশিও)।

### গ. পলিসি ও কমপ্লায়েন্স (App Content & Policy)
1. **Privacy Policy**: আপনার প্রজেক্টের প্রাইভেসি পলিসির একটি বৈধ পাবলিক URL।
2. **App Access**: অ্যাপের সব ফিচার পরীক্ষা করার জন্য একটি টেস্ট একাউন্টের তথ্য (যেমন ডেমো ঠিকাদারের মোবাইল/ইমেইল ও পাসওয়ার্ড)।
3. **Ads**: অ্যাপে কোনো বিজ্ঞাপন না থাকলে "No, my app does not contain ads" নির্বাচন করুন।
4. **Content Rating**: প্রশ্নাবলীর উত্তর দিয়ে কনটেন্ট রেটিং সার্টিফিকেট সম্পন্ন করুন (উপযুক্ত ক্যাটাগরি: Business/Productivity)।
5. **Target Audience**: ১৮ বছর বা তার বেশি বয়সী কর্মজীবী মানুষ।
6. **Data Safety**:
   - Location (সাইট হাজিরা যাচাইয়ের জন্য জিও-ফেন্সিং ও লোকেশন অ্যাক্সেস)
   - Personal info (নাম, ফোন নম্বর, ইমেইল)
   - Financial info (সাইট খরচ ও মজুরির হিসাব)

### ঘ. রিলিজ প্রকাশ (Release Track)
1. Play Console-এর মেনু থেকে **Testing** → **Internal testing** অথবা **Closed testing** নির্বাচন করুন।
2. **Create new release**-এ ক্লিক করে আপনার সাইনড `app-release.aab` ফাইলটি আপলোড করুন।
3. রিলিজ নাম দিন (যেমন: `1.0.0 (1)`), রিলিজ নোট বাংলায় লিখুন এবং **Save** করে **Review release** দিন।
4. অভ্যন্তরীণ যাচাই শেষে **Production** ট্র্যাকে রোলআউট করে দিন।
