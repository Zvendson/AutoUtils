#cs════════════════╦═══════════════════╗
║ AutoIt Version   ║ 3.3.16.1          ║
╠══════════════════╬═══════════════════╣═══════════════════════════════════════╗
║ Author(s)        ║ Discord(s)        ║ E-Mail(s)                             ║
╠══════════════════╬═══════════════════╬═══════════════════════════════════════╣
║ Zvend            ║ zvend             ║ svendganske@hotmail.com               ║
╠═════════════╤════╩═══════════════════╩═══════════════════════════════════════╣
│ Description │ Simple converter script that lets you swap endianess of        │
├─────────────┘ numerics.                                                      │
#ce────────────────────────────────────────────────────────────────────────────┘

#include-once
#RequireAdmin
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



#cs────────────────────────────────────────────────────────────────────────────┐
│ Swaps the endianess of an 16 bit integer. Although there is no real int16 in │
│ AutoIt the values can still be interpreted from a Int32, so dont mind it.    │
│ Example: 0xFF66 => 0x66FF                                                    │
│                                                                              │
│ Parameter:                                                                   │
│   Int32  $nInt16                                                             │
│                                                                              │
│ Returns:                                                                     │
│   Int32                                                                      │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Endian_Swap16($nInt16)
    Local $nHiByte = BitAND(BitShift($nInt16, 8), 0xFF)
    Local $nLoByte = BitAND($nInt16, 0xFF)
    Return BitOR(BitShift($nLoByte, -8), $nHiByte)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Swaps the endianess of an 32 bit integer.                                    │
│ Example: 0xFFBB9922 => 0x2299BBFF                                            │
│                                                                              │
│ Parameter:                                                                   │
│   Int32  $nInt32                                                             │
│                                                                              │
│ Returns:                                                                     │
│   Int32                                                                      │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Endian_Swap32($nInt32)
    Local $nByte0 = BitAND($nInt32, 0xFF)
    Local $nByte1 = BitAND(BitShift($nInt32, 8), 0xFF)
    Local $nByte2 = BitAND(BitShift($nInt32, 16), 0xFF)
    Local $nByte3 = BitAND(BitShift($nInt32, 24), 0xFF)

    Return BitOR(BitShift($nByte0, -24), BitShift($nByte1, -16), BitShift($nByte2, -8), $nByte3)
EndFunc



