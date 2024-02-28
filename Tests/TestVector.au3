#include ".\..\UnitTest.au3"
#include ".\..\Vector.au3"

UTInit()
testVectorInit()
testVectorSetComparatorCallback()
testIsVector()
testVectorPush()
testVectorPop()
testVectorGetSize()
testVectorGetCapacity()
UTExit()



Func testVectorInit()
    UTStart("_Vector_Init()")

    UTAssert(_Vector_Init(32, Null, 1)     = Null, "_Vector_Init(32, Null, 1)     = Null")
    UTAssert(_Vector_Init(32, Null, 1.4)   = Null, "_Vector_Init(32, Null, 1.4)   = Null")
    UTAssert(_Vector_Init(32, Null, 10.0) <> Null, "_Vector_Init(32, Null, 10.0) <> Null")
    UTAssert(_Vector_Init()               <> Null, "_Vector_Init()               <> Null")

    UTStop()
EndFunc



Func testVectorSetComparatorCallback()
    Local $bTest
    Local $aTestVector = _Vector_Init()
    UTStart("_Vector_Init")

    $bTest = _Vector_SetComparatorCallback($aTestVector, 'ThisShouldFail') = 0
    UTAssert($bTest, "_Vector_SetComparatorCallback($aTestVector, 'ThisShouldFail') = 0")

    $bTest = _Vector_SetComparatorCallback($aTestVector, 0) = 0
    UTAssert($bTest, "_Vector_SetComparatorCallback($aTestVector, 0) = 0")

    $bTest = _Vector_SetComparatorCallback($aTestVector, True) = 0
    UTAssert($bTest, "_Vector_SetComparatorCallback($aTestVector, True) = 0")

    $bTest = _Vector_SetComparatorCallback($aTestVector, Binary('0xFF')) = 0
    UTAssert($bTest, "_Vector_SetComparatorCallback($aTestVector, Binary('0xFF')) = 0")

    $bTest = _Vector_SetComparatorCallback($aTestVector, 10.0) = 0
    UTAssert($bTest, "_Vector_SetComparatorCallback($aTestVector, 10.0) = 0")

    $bTest = _Vector_SetComparatorCallback($aTestVector, VectorCallback) = 1
    UTAssert($bTest, "_Vector_SetComparatorCallback($aTestVector, VectorCallback) = 1")

    UTStop()
EndFunc



Func testIsVector()
    Local $aTestVector = _Vector_Init()
    UTStart("_Vector_IsVector")

    UTAssert(_Vector_IsVector($aTestVector)   = 1, "_Vector_IsVector($aTestVector)   = 1")
    UTAssert(_Vector_IsVector(True)           = 0, "_Vector_IsVector(True)           = 0")
    UTAssert(_Vector_IsVector(100)            = 0, "_Vector_IsVector(100)            = 0")
    UTAssert(_Vector_IsVector(VectorCallback) = 0, "_Vector_IsVector(VectorCallback) = 0")
    UTAssert(_Vector_IsVector('IAmAVector')   = 0, "_Vector_IsVector('IAmAVector')   = 0")
    UTAssert(_Vector_IsVector(Binary('0xFF')) = 0, "_Vector_IsVector(Binary('0xFF')) = 0")

    UTStop()
EndFunc



Func testVectorPush()
    Local $aTestVector = _Vector_Init()
    UTStart("_Vector_Push")

    UTAssert(_Vector_Push($aTestVector, 10)                       = 1, "_Vector_Push($aTestVector, 10)                       = 1")
    UTAssert(_Vector_Push($aTestVector, 'Hello World')            = 1, "_Vector_Push($aTestVector, 'Hello World')            = 1")
    UTAssert(_Vector_Push($aTestVector, Binary('0xDEADBEEF'))     = 1, "_Vector_Push($aTestVector, Binary('0xDEADBEEF'))     = 1")
    UTAssert(_Vector_Push($aTestVector, Default)                  = 1, "_Vector_Push($aTestVector, Default)                  = 1")
    UTAssert(_Vector_Push($aTestVector, Null)                     = 1, "_Vector_Push($aTestVector, Null)                     = 1")
    UTAssert(_Vector_Push($aTestVector, True)                     = 1, "_Vector_Push($aTestVector, True)                     = 1")
    UTAssert(_Vector_Push($aTestVector, False)                    = 1, "_Vector_Push($aTestVector, False)                    = 1")
    UTAssert(_Vector_Push($aTestVector, DllStructCreate('DWORD')) = 1, "_Vector_Push($aTestVector, DllStructCreate('DWORD')) = 1")

    UTStop()
EndFunc



Func testVectorPop()
    Local $aTestVector = _Vector_Init()
    UTStart("_Vector_Pop")

    _Vector_Push($aTestVector, 10)
    _Vector_Push($aTestVector, 'Hello World')
    _Vector_Push($aTestVector, Binary('0xDEADBEEF'))
    _Vector_Push($aTestVector, Default)
    _Vector_Push($aTestVector, Null)
    _Vector_Push($aTestVector, True)
    _Vector_Push($aTestVector, False)
    _Vector_Push($aTestVector, DllStructCreate('DWORD'))

    UTAssert(_Vector_Pop($aTestVector) <> Null                , "_Vector_Pop($aTestVector) <> Null                ")
    UTAssert(_Vector_Pop($aTestVector) =  False               , "_Vector_Pop($aTestVector) =  False               ")
    UTAssert(_Vector_Pop($aTestVector) =  True                , "_Vector_Pop($aTestVector) =  True                ")
    UTAssert(_Vector_Pop($aTestVector) =  Null                , "_Vector_Pop($aTestVector) =  Null                ")
    UTAssert(_Vector_Pop($aTestVector) =  Default             , "_Vector_Pop($aTestVector) =  Default             ")
    UTAssert(_Vector_Pop($aTestVector) =  Binary('0xDEADBEEF'), "_Vector_Pop($aTestVector) =  Binary('0xDEADBEEF')")
    UTAssert(_Vector_Pop($aTestVector) == 'Hello World'       , "_Vector_Pop($aTestVector) == 'Hello World'       ")
    UTAssert(_Vector_Pop($aTestVector) =  10                  , "_Vector_Pop($aTestVector) =  10                  ")
    UTAssert(_Vector_Pop($aTestVector) =  Null                , "_Vector_Pop($aTestVector) =  Null                ")

    UTStop()
EndFunc



Func testVectorGetSize()
    Local $aTestVector = _Vector_Init()
    UTStart("_Vector_GetSize")

    _Vector_Push($aTestVector, 10)
    _Vector_Push($aTestVector, 'Hello World')
    _Vector_Push($aTestVector, Binary('0xDEADBEEF'))
    _Vector_Push($aTestVector, Default)
    _Vector_Push($aTestVector, Null)
    _Vector_Push($aTestVector, True)
    _Vector_Push($aTestVector, False)
    _Vector_Push($aTestVector, DllStructCreate('DWORD'))

    UTAssert(_Vector_GetSize($aTestVector) = 8, "_Vector_GetSize($aTestVector) = 8 // Pushed 8 values")
    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)
    UTAssert(_Vector_GetSize($aTestVector) = 6, "_Vector_GetSize($aTestVector) = 6 // Popped 2 values")
    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)
    UTAssert(_Vector_GetSize($aTestVector) = 4, "_Vector_GetSize($aTestVector) = 4 // Popped 2 values")
    UTAssert(_Vector_GetSize($aTestVector) = 4, "_Vector_GetSize($aTestVector) = 4 // Popped nothing")
    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)
    UTAssert(_Vector_GetSize($aTestVector) = 0, "_Vector_GetSize($aTestVector) = 0 // Popped 5 values")

    UTStop()
EndFunc



Func testVectorGetCapacity()
    Local $aTestVector = _Vector_Init()
    UTStart("_Vector_GetCapacity")

    UTAssert(_Vector_GetCapacity($aTestVector) =  32  , "_Vector_GetCapacity($aTestVector) =  32   // Default Init")
    $aTestVector = _Vector_Init(500)
    UTAssert(_Vector_GetCapacity($aTestVector) =  500 , "_Vector_GetCapacity($aTestVector) =  500  // Init of 500")
    $aTestVector = _Vector_Init(0)
    UTAssert(_Vector_GetCapacity($aTestVector) =  0   , "_Vector_GetCapacity($aTestVector) =  0    // Init of 0")
    $aTestVector = _Vector_Init(3)
    UTAssert(_Vector_GetCapacity($aTestVector) =  0   , "_Vector_GetCapacity($aTestVector) =  0    // Init of 3")
    $aTestVector = _Vector_Init(-100)
    UTAssert(_Vector_GetCapacity($aTestVector) =  0   , "_Vector_GetCapacity($aTestVector) =  0    // Init of -100")
    $aTestVector = _Vector_Init(4)
    UTAssert(_Vector_GetCapacity($aTestVector) <> 0   , "_Vector_GetCapacity($aTestVector) <> 0    // Init of 4")
    _Vector_Reserve($aTestVector, 1000)
    UTAssert(_Vector_GetCapacity($aTestVector) >= 1000, "_Vector_GetCapacity($aTestVector) >= 1000 // Reserve of 1000")

    UTStop()
EndFunc



Func VectorCallback(Const $vVal1, Const $vVal2)
    #forceref $vVal1, $vVal2
EndFunc


