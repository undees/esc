Feature: Waveform Type

  In order to drive my circuit
  As an engineer
  I want to control the geometry of the signal

  Scenario: Sine Wave
    Given a waveform
    When I set the Waveform Type to "Sine"
    Then the Duty Cycle setting should be disabled
