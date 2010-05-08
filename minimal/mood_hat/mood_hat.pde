int inByte = 0;
int mood = 2;
int moodByte = '2';
int numMoods = 5;

int heartbeatPin = 13;
int ledPin = 9;
int buttonPin = 2;
int buttonNow = LOW;

void setup()
{
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);

  Serial.begin(9600);
}

void loop()
{
  buttonNow = digitalRead(buttonPin);

  if (buttonNow == LOW) {
    increaseHappiness();
    delay(100);
  }

  if (Serial.available() > 0) {
    inByte = Serial.read();

    if (inByte == '!') {
      mood = 2;
      Serial.print(inByte, BYTE);
    }
    else if (inByte == '+') {
      increaseHappiness();
    }
    else if (inByte == '-') {
      decreaseHappiness();
    }
    else if (inByte == '0') {
      mood = 0;
    }
    else if (inByte == '1') {
      mood = 1;
    }
    else if (inByte == '2') {
      mood = 2;
    }
    else if (inByte == '3') {
      mood = 3;
    }
    else if (inByte == '4') {
      mood = 4;
    }
    else if (inByte == '?') {
      moodByte = mood + '0';
      Serial.print(moodByte, BYTE);
    }
  }
  else {
    digitalWrite(heartbeatPin, HIGH);
    delay(50);
    digitalWrite(heartbeatPin, LOW);
    delay(50);
  }

  analogWrite(ledPin, mood * 255 / numMoods);
}

void increaseHappiness() {
  mood = (mood + 1) % numMoods;
}

void decreaseHappiness() {
  mood = (mood + numMoods - 1) % numMoods;
}

