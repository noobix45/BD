# Interfață și Bază de Date pentru Platformă de Streaming

Proiect realizat pentru cursul **„Baze de Date”**, constând într-o aplicație C# (Windows Forms) și o bază de date Oracle.

Aplicația oferă o interfață simplă pentru gestionarea datelor unei platforme de streaming (utilizatori, filme, abonamente etc.).

---

## 🔧 Instalare și rulare

1. **Creează baza de date:**
   - Deschide `database/Platforma_Streaming_Script_Final.sql` în SQL Developer.
   - Rulează scriptul pentru a crea tabelele și datele inițiale.

2. **Configurează conexiunea:**
   - Deschide fișierul `Form1.cs`.
   - Actualizează `User Id`, `Password` și `Data Source` în connection string dacă este nevoie.

3. **Rulează aplicația:**
   - Execută fișierul `interfata.exe` din `bin/Debug/net8.0-windows/`  
     *(sau folosește comanda `dotnet run` din terminal)*

După aceste pași, aplicația ar trebui să fie **plug & play**, fără alte modificări.

---

## 💡 Detalii adiționale
- Proiect local de laborator — nu folosește servere externe.  
- Poți modifica credențialele bazei de date liber; conexiunea este doar locală.  
- Documentația completă se află în folderul `documentatie/`.

---

> Proiect personal — realizat în cadrul cursului de Baze de Date.
