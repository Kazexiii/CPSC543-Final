 char val; // Data received from the serial port
 int VR = 6; // Set the pin to digital I/O 6

 void setup() {
   pinMode(VR, OUTPUT); // Set pin as OUTPUT
   Serial.begin(9600); // Start serial communication at 9600 bps
 }

 void loop() {
   if (Serial.available()) 
   { // If data is available to read,
     val = Serial.read(); // read it and store it in val
   }
   if (val == 'A') 
   {
        digitalWrite(VR, HIGH); // turn the LED on
        delay(600);
        digitalWrite(VR, LOW);
        delay(600);
   } 

   else if (val == 'B') 
   { // If 1 was received
        digitalWrite(VR, HIGH); // turn the LED on
        delay(400);
        digitalWrite(VR, LOW);
        delay(400);
   } 

   else if (val == 'C') 
   { // If 1 was received
        digitalWrite(VR, HIGH); // turn the LED on
        delay(1000);
        digitalWrite(VR, LOW);
        delay(1000);
   } 

   else if (val == 'D') 
   { // If 1 was received
        digitalWrite(VR, HIGH); // turn the LED on
        delay(200);
        digitalWrite(VR, LOW);
        delay(200);
   } 

   else if (val == 'E') 
   { // If 1 was received
        digitalWrite(VR, HIGH); // turn the LED on
        delay(100);
        digitalWrite(VR, LOW);
        delay(100);
   } 

}
