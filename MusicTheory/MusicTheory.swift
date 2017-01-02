//
//  MusicTheory.swift
//  MusicTheory
//
//  Created by Cem Olcay on 29/12/2016.
//  Copyright © 2016 prototapp. All rights reserved.
//
//  https://github.com/cemolcay/MusicTheory
//

import Foundation

// MARK: - Note

/// Represents 12 base notes in music.
/// C, D, E, F, G, A, B with their flats.
public enum Note {
  case c
  case dFlat
  case d
  case eFlat
  case e
  case f
  case gFlat
  case g
  case aFlat
  case a
  case bFlat
  case b

  /// All the notes in static array
  public static let all: [Note] = [
    .c, .dFlat, .d, .eFlat, .e, .f,
    .gFlat, .g, .aFlat, .a, .bFlat, .b
  ]

  /// Halfstep higher note
  public var halfstepUp: Note {
    switch self {
    case .c: return .dFlat
    case .dFlat: return .d
    case .d: return .eFlat
    case .eFlat: return .e
    case .e: return .f
    case .f: return .gFlat
    case .gFlat: return .g
    case .g: return .aFlat
    case .aFlat: return .a
    case .a: return .bFlat
    case .bFlat: return .b
    case .b: return .c
    }
  }

  /// Halfstep lower note
  public var halfstepDown: Note {
    switch self {
    case .c: return .b
    case .dFlat: return .c
    case .d: return .dFlat
    case .eFlat: return .d
    case .e: return .eFlat
    case .f: return .e
    case .gFlat: return .f
    case .g: return .gFlat
    case .aFlat: return .g
    case .a: return .aFlat
    case .bFlat: return .a
    case .b: return .bFlat
    }
  }

  /// Higer note above `tone`
  public func next(tone: Tone) -> Note {
    switch tone {
    case .half:
      return next(tone: .custom(halfstep: 1))
    case .whole:
      return next(tone: .custom(halfstep: 2))
    case .oneAndHalf:
      return next(tone: .custom(halfstep: 3))
    case .custom(let halfstep) where halfstep > 0:
      var note = self
      var currentStep = halfstep
      while currentStep > 0 {
        note = note.halfstepUp
        currentStep -= 1
      }
      return note
    case .custom(let halfstep) where halfstep < 0:
      return previous(tone: .custom(halfstep: halfstep))
    case .custom(halfstep: 0):
      return self
    default:
      return self
    }
  }

  /// Lower note below `tone`
  public func previous(tone: Tone) -> Note {
    switch tone {
    case .half:
      return previous(tone: .custom(halfstep: 1))
    case .whole:
      return previous(tone: .custom(halfstep: 2))
    case .oneAndHalf:
      return previous(tone: .custom(halfstep: 3))
    case .custom(let halfstep) where halfstep > 0:
      var note = self
      var currentStep = halfstep
      while currentStep > 0 {
        note = note.halfstepDown
        currentStep -= 1
      }
      return note
    case .custom(let halfstep) where halfstep < 0:
      return next(tone: .custom(halfstep: halfstep))
    case .custom(halfstep: 0):
      return self
    default:
      return self
    }
  }

  /// Higher note above `interval`
  public func next(interval: Interval) -> Note {
    return next(tone: interval.tone)
  }

  /// Lower note below `interval`
  public func previous(interval: Interval) -> Note {
    return previous(tone: interval.tone)
  }
}

public extension Note {
  /// Returns the piano key index by octave based on a standard [1 - 88] key piano;
  /// Returns 0 if zeroth octave is other than A, Bflat or B, which is accurate on a real piano;
  /// Returns 0 if octave is negative.
  public func pianoKey(octave: Int) -> Int {
    if octave == 0 {
      switch self {
      case .a: return 1
      case .bFlat: return 2
      case .b: return 3
      default: return 0
      }
    }

    guard octave > 0 else { return 0 }
    var root = 0

    switch self {
    case .c: root = 4
    case .dFlat: root = 5
    case .d: root = 6
    case .eFlat: root = 7
    case .e: root = 8
    case .f: root = 9
    case .gFlat: root = 10
    case .g: root = 11
    case .aFlat: root = 12
    case .a: root = 13
    case .bFlat: root = 14
    case .b: root = 15
    }

    return root + ((octave - 1) * 12)
  }

  /// Calculates and returns the frequency of note on octave based on its location of piano keys;
  /// Bases A4 note of 440Hz frequency standard.
  public func frequancy(octave: Int) -> Float {
    let fn = powf(2.0, Float(pianoKey(octave: octave) - 49) / 12.0)
    return fn * 440.0
  }

  /// Returns midi keys in range [0 - 127];
  /// Octave ranges [0 - 10];
  /// If octave range don't satisfy then returns -1.
  public func midiKey(octave: Int) -> Int {
    guard octave >= 0, octave <= 10 else { return -1 }
    var root = 0

    switch self {
    case .c: root = 0
    case .dFlat: root = 1
    case .d: root = 2
    case .eFlat: root = 3
    case .e: root = 4
    case .f: root = 5
    case .gFlat: root = 6
    case .g: root = 7
    case .aFlat: root = 8
    case .a: root = 9
    case .bFlat: root = 10
    case .b: root = 11
    }

    let key = root + (octave * 12)
    return key > 127 ? -1 : key
  }
}

extension Note: CustomStringConvertible {

  public var description: String {
    switch self {
    case .c: return "C"
    case .dFlat: return "D♭"
    case .d: return "D"
    case .eFlat: return "E♭"
    case .e: return "E"
    case .f: return "F"
    case .gFlat: return "G♭"
    case .g: return "G"
    case .aFlat: return "A♭"
    case .a: return "A"
    case .bFlat: return "B♭"
    case .b: return "B"
    }
  }
}

// MARK: - Tone

/// Halfstep intervals between `Note`s in human readable format for better usablity.
public enum Tone {
  case half
  case whole
  case oneAndHalf
  case custom(halfstep: Int)


  /// Initilizes `Tone` with halfstep value.
  ///
  /// - Parameter halfstep: Represents halfstep interval between notes. 2 halfstep is whole tone for example.
  public init(halfstep: Int) {
    switch halfstep {
    case 1: self = .half
    case 2: self = .whole
    case 3: self = .oneAndHalf
    default: self = .custom(halfstep: halfstep)
    }
  }

  /// Returns halfstep value.
  public var halfstep: Int {
    switch self {
    case .half: return 1
    case .whole: return 2
    case .oneAndHalf: return 3
    case .custom(let halfstep): return halfstep
    }
  }
}

// MARK: - Interval

/** Represents the interval between `Note`s in halfstep tones and degrees.

- unison: Zero halfstep and zero degree, the note itself.
- m2: One halfstep and one degree between notes.
- M2: Two halfsteps and one degree between notes.
- m3: Three halfsteps and two degree between notes.
- M3: Four halfsteps and two degree between notes.
- P4: Five halfsteps and three degree between notes.
- A4: Six halfsteps and three degree between notes.
- d5: Six halfsteps and four degree between notes.
- P5: Seven halfsteps and four degree between notes.
- A5: Eight halfsteps and four degree between notes.
- m6: Eight halfsteps and five degree between notes.
- M6: Nine halfsteps and five degree between notes.
- d7: Nine halfsteps and six degree between notes.
- m7: Ten halfsteps and six degree between notes.
- M7: Eleven halfsteps and six degree between notes.
- A7: Twelve halfsteps and six degree between notes.
- P8: Twelve halfsteps and seven degree between notes.
- custom: Custom halfsteps and degrees by given input between notes.
*/
public enum Interval {
  case unison
  case m2
  case M2
  case m3
  case M3
  case P4
  case A4
  case d5
  case P5
  case A5
  case m6
  case M6
  case d7
  case m7
  case M7
  case A7
  case P8
  case custom(degree: Int, halfstep: Int)


  /// Initilizes interval with its degree and halfstep.
  ///
  /// - Parameters:
  ///   - degree: Degree of interval
  ///   - halfstep: Halfstep of interval
  public init(degree: Int, halfstep: Int) {
    switch (degree, halfstep) {
    case (0, 0): self = .unison
    case (1, 1): self = .m2
    case (1, 2): self = .M2
    case (2, 3): self = .m3
    case (2, 4): self = .M3
    case (3, 5): self = .P4
    case (3, 6): self = .A4
    case (4, 6): self = .d5
    case (4, 7): self = .P5
    case (4, 8): self = .A5
    case (5, 8): self = .m6
    case (5, 9): self = .M6
    case (6, 9): self = .d7
    case (6, 10): self = .m7
    case (6, 11): self = .M7
    case (6, 12): self = .A7
    case (7, 12): self = .P8
    default: self = .custom(degree: degree, halfstep: halfstep)
    }
  }

  /// Returns the degree of the `Interval`.
  public var degree: Int {
    switch self {
    case .unison: return 0
    case .m2, .M2: return 1
    case .M3, .m3: return 2
    case .P4, .A4: return 3
    case .d5, .P5, .A5: return 4
    case .m6, .M6: return 5
    case .d7, .m7, .M7, .A7: return 6
    case .P8: return 7
    case .custom(let d, _): return d
    }
  }

  /// Returns halfstep representation of `Interval.`
  public var halfstep: Int {
    switch self {
    case .unison: return 0
    case .m2: return 1
    case .M2: return 2
    case .m3: return 3
    case .M3: return 4
    case .P4: return 5
    case .A4, .d5: return 6
    case .P5: return 7
    case .A5, .m6: return 8
    case .M6, .d7: return 9
    case .m7: return 10
    case .M7, .A7: return 11
    case .P8: return 12
    case .custom(_, let h): return h
    }
  }

  /// Returns `Tone` representation of `Interval` by its halfsteps.
  public var tone: Tone {
    return Tone(halfstep: halfstep)
  }
}

extension Interval: CustomStringConvertible {

  public var description: String {
    switch self {
    case .unison: return "unison"
    case .m2: return "minor second"
    case .M2: return "major second"
    case .m3: return "minor third"
    case .M3: return "major third"
    case .P4: return "perfect forth"
    case .A4: return "agumented fourth"
    case .d5: return "diminished fifth"
    case .P5: return "perfect fifth"
    case .A5: return "agumented fifth"
    case .m6: return "minor sixth"
    case .M6: return "major sixth"
    case .d7: return "diminished seventh"
    case .m7: return "minor seventh"
    case .M7: return "major seventh"
    case .A7: return "agumented seventh"
    case .P8: return "octave"
    case .custom(let degree, let halfstep): return "\(degree), \(halfstep)"
    }
  }
}

// MARK: - Scale

/** Represents scale of `Note`s by the intervals between note sequences based on a key `Note`.

- major: Major scale.
- minor: Minor scale
- harmonicMinor: Harmonic minor scale
- dorian: Dorian scale
- phrygian: Phrygian scale
- lydian: Lydian scale
- mixolydian: Mixolydian scale
- locrian: Locrian scale
- custom: Custom scale by given base key and intervals.
*/
public enum Scale {
  case major(key: Note)
  case minor(key: Note)
  case harmonicMinor(key: Note)
  case dorian(key: Note)
  case phrygian(key: Note)
  case lydian(key: Note)
  case mixolydian(key: Note)
  case locrian(key: Note)
  case custom(key: Note, intervals: [Interval])

  /// Key of the scale
  public var key: Note {
    switch self {
    case .major(let key),
         .minor(let key),
         .harmonicMinor(let key),
         .dorian(let key),
         .phrygian(let key),
         .lydian(let key),
         .mixolydian(let key),
         .locrian(let key),
         .custom(let key, _):
      return key
    }
  }

  /// Intervals of the scale based on the scale's key.
  public var intervals: [Interval] {
    switch self {
    case .major: return [.unison, .M2, .M3, .P4, .P5, .M6, .M7]
    case .minor: return [.unison, .M2, .m3, .P4, .P5, .m6, .m7]
    case .harmonicMinor: return [.unison, .M2, .m3, .P4, .P5, .M6, .m7]
    case .dorian: return [.unison, .M2, .m3, .P4, .P5, .M6, .m7]
    case .phrygian: return [.unison, .m2, .m3, .P4, .P5, .m6, .m7]
    case .lydian: return [.unison, .M2, .M3, .A4, .P5, .M6, .M7]
    case .mixolydian: return [.unison, .M2, .M3, .P4, .P5, .M6, .m7]
    case .locrian: return [.unison, .m2, .m3, .P4, .d5, .m6, .m7]
    case .custom(_, let intervals): return intervals
    }
  }

  /// Notes generated by the intervals of the scale.
  public var notes: [Note] {
    return intervals.map({ key.next(interval: $0) })
  }

  /// All notes in the scale in midi key form.
  public var midiKeys: [Int] {
    var midiNotes = [Int]()
    for octave in 0...10 {
      midiNotes.append(contentsOf: notes.map({ $0.midiKey(octave: octave) }).filter({ $0 != -1 }))
    }
    return midiNotes
  }
}

// MARK: - Chord

/** Represents chords by note sequences initilized by their intervals.

- maj: Major chord.
- min: Minor chord.
- aug: Augmented chord.
- b5: Power chord.
- dim: Dimineshed chord.
- sus: Suspended chord.
- sus2: Suspended second chord.
- M6: Major sixth chord.
- m6: Minor sixth chord.
- dom7: Dominant seventh chord.
- M7: Major seventh chord.
- m7: Minor seventh chord.
- aug7: Augmented seventh chord.
- dim7: Diminished seventh chord.
- M7b5: Major seventh power chord.
- m7b5: Minor seventh power chord.
- custom: Custom chord with given base key `Note` and intervals.
*/
public enum Chord {
  case maj(key: Note)
  case min(key: Note)
  case aug(key: Note)
  case b5(key: Note)
  case dim(key: Note)
  case sus(key: Note)
  case sus2(key: Note)
  case M6(key: Note)
  case m6(key: Note)
  case dom7(key: Note)
  case M7(key: Note)
  case m7(key: Note)
  case aug7(key: Note)
  case dim7(key: Note)
  case M7b5(key: Note)
  case m7b5(key: Note)
  case custom(key: Note, intervals: [Interval], description: String)

  /// Key of the chord.
  public var key: Note {
    switch self {
    case .maj(let key), .min(let key), .aug(let key), .b5(let key),
    .dim(let key), .sus(let key), .sus2(let key), .M6(let key),
    .m6(let key), .dom7(let key), .M7(let key), .m7(let key), .aug7(let key),
    .dim7(let key), .M7b5(let key), .m7b5(let key), .custom(let key, _, _):
      return key
    }
  }

  /// Intervals of the chord based on the chord's key.
  public var intervals: [Interval] {
    switch self {
    case .maj: return [.unison, .M3, .P5]
    case .min: return [.unison, .m3, .P5]
    case .aug: return [.unison, .M3, .A5]
    case .b5: return [.unison, .M3, .d5]
    case .dim: return [.unison, .m3, .d5]
    case .sus: return [.unison, .P4, .P5]
    case .sus2: return [.unison, .M2, .P5]
    case .M6: return [.unison, .M3, .P5, .M6]
    case .m6: return [.unison, .m3, .P5, .M6]
    case .dom7: return [.unison, .M3, .P5, .m7]
    case .M7: return [.unison, .M3, .P5, .M7]
    case .m7: return [.unison, .m3, .P5, .m7]
    case .aug7: return [.unison, .M3, .A5, .m7]
    case .dim7: return [.unison, .m3, .d5, .d7]
    case .M7b5: return [.unison, .M3, .A5, .M7]
    case .m7b5: return [.unison, .M3, .d5, .M7]
    case .custom(_, let intervals, _): return intervals
    }
  }

  /// Notes generated by the intervals of the chord.
  public var notes: [Note] {
    return intervals.map({ key.next(interval: $0) })
  }

  /// All notes in the chord in midi key form.
  public var midiKeys: [Int] {
    var midiNotes = [Int]()
    for octave in 0...10 {
      midiNotes.append(contentsOf: notes.map({ $0.midiKey(octave: octave) }).filter({ $0 != -1 }))
    }
    return midiNotes
  }
}

extension Chord: CustomStringConvertible {

  public var description: String {
    switch self {
    case .maj(let key): return "\(key)maj"
    case .min(let key): return "\(key)min"
    case .aug(let key): return "\(key)aug"
    case .b5(let key): return "\(key)b5"
    case .dim(let key): return "\(key)dim"
    case .sus(let key): return "\(key)sus4"
    case .sus2(let key): return "\(key)sus2"
    case .M6(let key): return "\(key)6"
    case .m6(let key): return "\(key)m6"
    case .dom7(let key): return "\(key)7"
    case .M7(let key): return "\(key)M7"
    case .m7(let key): return "\(key)m7"
    case .aug7(let key): return "\(key)+7"
    case .dim7(let key): return "\(key)dim7"
    case .M7b5(let key): return "\(key)7b5"
    case .m7b5(let key): return "\(key)m7b5"
    case .custom(let key, _, let description): return "\(key)\(description)"
    }
  }
}

/// Checks the equability between two chords by their base key and notes.
///
/// - Parameters:
///   - left: Left handside of the equation.
///   - right: Right handside of the equation.
/// - Returns: Returns Bool value of equation of two given chords.
public func ==(left: Chord, right: Chord) -> Bool {
  return left.key == right.key && left.notes == right.notes
}