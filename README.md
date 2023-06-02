# ระบบเฝ้าระวังการออกนอกบ้านของผู้ป่วยอัลไซเมอร์

เป็นระบบที่ถูกพัฒนาขึ้นด้วยการเขียน Dart ในการรับค่าตำแหน่งของผู้ป่วยอัลไซเมอร์ โดยใช้การบอกตำแหน่งของ GPS ที่ติดกับ Hardware ของผู้ป่วยที่ถูกจัดเก็บข้อมูลไว้ใน Firebase และการคำนวณหาระยะห่างด้วย Haversine formula เพื่อตรวจสอบว่าผู้ป่วยออกจากขอบเขตพื้นที่การดูแลหรือไม่

## สารบัญ
- [ขั้นตอนในการติดตั้ง Code](#%E0%B8%82%E0%B8%B1%E0%B9%89%E0%B8%99%E0%B8%95%E0%B8%AD%E0%B8%99%E0%B9%83%E0%B8%99%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B8%95%E0%B8%B4%E0%B8%94%E0%B8%95%E0%B8%B1%E0%B9%89%E0%B8%87-code)
- [ขั้นตอนการติดตั้งแอปพลิเคชันจาก Code](#%E0%B8%82%E0%B8%B1%E0%B9%89%E0%B8%99%E0%B8%95%E0%B8%AD%E0%B8%99%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B8%95%E0%B8%B4%E0%B8%94%E0%B8%95%E0%B8%B1%E0%B9%89%E0%B8%87%E0%B9%81%E0%B8%AD%E0%B8%9B%E0%B8%9E%E0%B8%A5%E0%B8%B4%E0%B9%80%E0%B8%84%E0%B8%8A%E0%B8%B1%E0%B8%99%E0%B8%88%E0%B8%B2%E0%B8%81-code)
- [วิธีการใช้งานแอปพลิเคชัน](#%E0%B8%A7%E0%B8%B4%E0%B8%98%E0%B8%B5%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B9%83%E0%B8%8A%E0%B9%89%E0%B8%87%E0%B8%B2%E0%B8%99%E0%B9%81%E0%B8%AD%E0%B8%9B%E0%B8%9E%E0%B8%A5%E0%B8%B4%E0%B9%80%E0%B8%84%E0%B8%8A%E0%B8%B1%E0%B8%99)
- [ขั้นตอนการแสดงผลผ่าน Emulator](#%E0%B8%82%E0%B8%B1%E0%B9%89%E0%B8%99%E0%B8%95%E0%B8%AD%E0%B8%99%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B9%81%E0%B8%AA%E0%B8%94%E0%B8%87%E0%B8%9C%E0%B8%A5%E0%B8%9C%E0%B9%88%E0%B8%B2%E0%B8%99-emulator)
- [สูตรคำนวณ Haversine](#%E0%B8%AA%E0%B8%B9%E0%B8%95%E0%B8%A3%E0%B8%84%E0%B8%B3%E0%B8%99%E0%B8%A7%E0%B8%93-haversine)

## ขั้นตอนในการติดตั้ง Code

**Caregiver side**
```bash
git clond https://github.com/CodeJobToey/caregiver.git 

cd caregiver

flutter pub get #Adding a package dependency to an app
```
**Patient side**
```bash
git clond https://github.com/CodeJobToey/patient.git

cd patient

flutter pub get #Adding a package dependency to an app
```

## ขั้นตอนการติดตั้งแอปพลิเคชันจาก Code
```bash
flutter build apk #วิธีสร้างไฟล์ Android App Bundle
```
>Note : นำไฟล์ที่ได้ไปใส่ไว้บนโทรศัพท์มือถือระบบปฏิบัติการแอนดรอยด์

## ขั้นตอนการแสดงผลผ่าน Emulator
เปิดใช้งานโปรแกรมจำลอง `Android Emulator`

**Caregiver side**
```bash
cd caregiver
flutter run
```
**Patient side**
```bash
cd patient
flutter run
```

## สูตรคำนวณ Haversine
การคำนวณหาระยะห่างระหว่างจุด 2 จุดด้วย  *Haversine formula* สามารถทำได้ดังนี้
$$
D = 2r \sin^{-1}(\sqrt{\frac{lat_1-lat_2}{2}+\cos{lat_1}*\cos{lat_2}*\sin^2{\frac{lon_1-lon_2}{2}}})
$$


## เครดิต
ผู้จัดทำโครงงาน : นายประพันธ์พงษ์ เพียนจันทร์
อาจารย์ที่ปรึกษาโครงงาน : อาจารย์ปกรณ์ แววสว่างวงศ์
มหาวิทยาลัยธรรมศาสตร์ ศูนย์ลำปาง
