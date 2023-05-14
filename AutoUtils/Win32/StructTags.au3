#cs ----------------------------------------------------------------------------

 AutoIt Version:  3.3.16.1
 Author(s):       Zvend
 Discord(s):      Zvend#6666
 Created:         Sunday 14 May 2023

 Description:

 Script Functions:

 Internal Functions:

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



Global Const $tagDOS_HEADER = "" _
    & "WORD  e_magic;" _
    & "WORD  e_cblp;" _
    & "WORD  e_cp;" _
    & "WORD  e_crlc;" _
    & "WORD  e_cparhdr;" _
    & "WORD  e_minalloc;" _
    & "WORD  e_maxalloc;" _
    & "WORD  e_ss;" _
    & "WORD  e_sp;" _
    & "WORD  e_csum;" _
    & "WORD  e_ip;" _
    & "WORD  e_cs;" _
    & "WORD  e_lfarlc;" _
    & "WORD  e_ovno;" _
    & "WORD  e_res;" _
    & "WORD  unk0022[3];" _
    & "WORD  e_oemid;" _
    & "WORD  e_oeminfo;" _
    & "WORD  e_res2;" _
    & "WORD  unk002A[9];" _
    & "DWORD e_lfanew;"
Global Const $sizeDOS_HEADER = DllStructGetSize(DllStructCreate($tagDOS_HEADER))


Global Const $tagNT_HEADER = "" _
    & "DWORD Signature;" _
    & "WORD  Machine;" _
    & "WORD  NumberOfSections;" _
    & "DWORD TimeDateStamp;" _
    & "DWORD PointerToSymbolTable;" _
    & "DWORD NumberOfSymbols;" _
    & "WORD  SizeOfOptionalHeader;" _
    & "WORD  Characteristics;" _
    & "WORD  Magic;" _
    & "BYTE  MajorLinkerVersion;" _
    & "BYTE  MinorLinkerVersion;" _
    & "DWORD SizeOfCode;" _
    & "DWORD SizeOfInitializedData;" _
    & "DWORD SizeOfUninitializedData;" _
    & "DWORD AddressOfEntryPoint;" _
    & "DWORD BaseOfCode;" _
    & "DWORD BaseOfData;" _
    & "DWORD ImageBase;" _
    & "DWORD SectionAlignment;" _
    & "DWORD FileAlignment;" _
    & "WORD  MajorOperatingSystemVersion;" _
    & "WORD  MinorOperatingSystemVersion;" _
    & "WORD  MajorImageVersion;" _
    & "WORD  MinorImageVersion;" _
    & "WORD  MajorSubsystemVersion;" _
    & "WORD  MinorSubsystemVersion;" _
    & "DWORD Win32VersionValue;" _
    & "DWORD SizeOfImage;" _
    & "DWORD SizeOfHeaders;" _
    & "DWORD CheckSum;" _
    & "WORD  Subsystem;" _
    & "WORD  DllCharacteristics;" _
    & "DWORD SizeOfStackReserve;" _
    & "DWORD SizeOfStackCommit;" _
    & "DWORD SizeOfHeapReserve;" _
    & "DWORD SizeOfHeapCommit;" _
    & "DWORD LoaderFlags;" _
    & "DWORD NumberOfRvaAndSizes;" _
    & "DWORD ExportDirectory[2];" _ ;=> DWORD VirtualAddress;DWORD Size;
    & "DWORD ImportDirectory[2];" _
    & "DWORD ResourceDirectory[2];" _
    & "DWORD ExceptionDirectory[2];" _
    & "DWORD SecurityDirectory[2];" _
    & "DWORD RelocationDirectory[2];" _
    & "DWORD DebugDirectory[2];" _
    & "DWORD ArchitectureDirectory[2];" _
    & "DWORD Reserved[2];" _
    & "DWORD TLSDirectory[2];" _
    & "DWORD ConfigurationDirectory[2];" _
    & "DWORD BoundDirectory[2];" _
    & "DWORD ImportAddressDirectory[2];" _
    & "DWORD DelayImportDirectory[2];" _
    & "DWORD NETMetaDataDirectory[2];" _
    & "DWORD[2];"



Global Const $tagSECTION_HEADER = "" _
    & "CHAR  Name[8];" _
    & "DWORD VirtualSize;" _
    & "DWORD VirtualAddress;" _
    & "DWORD SizeOfRawData;" _
    & "DWORD PointerToRawData;" _
    & "DWORD PointerToRelocations;" _
    & "DWORD PointerToLinenumbers;" _
    & "WORD  NumberOfRelocations;" _
    & "WORD  NumberOfLinenumbers;" _
    & "DWORD Characteristics;"
Global Const $sizeSECTION_HEADER = DllStructGetSize(DllStructCreate($tagSECTION_HEADER))



Global Const $tagEXPORT_DIRECTORY = "" _
    & "DWORD Characteristics;" _
    & "DWORD TimeDateStamp;" _
    & "WORD  MajorVersion;" _
    & "WORD  MinorVersion;" _
    & "DWORD Name;" _
    & "DWORD Base;" _
    & "DWORD NumberOfFunctions;" _
    & "DWORD NumberOfNames;" _
    & "DWORD AddressOfFunctions;" _
    & "DWORD AddressOfNames;" _
    & "DWORD AddressOfNameOrdinals;"




Global Const $__IMAGE_FILE_EXECUTABLE_IMAGE = 0x0002
Global Const $__IMAGE_FILE_32BIT_MACHINE    = 0x0100
Global Const $__IMAGE_FILE_DLL              = 0x2000


