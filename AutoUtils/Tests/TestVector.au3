#include ".\..\UnitTest.au3"
#include ".\..\Vector.au3"

UTInit()
testVectorInit()
testVectorSetComparatorCallback()
testVectorIsVector()
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
	UTStart("_Vector_Init()")

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


Func testVectorIsVector()
	Local $aTestVector = _Vector_Init()
	UTStart("_Vector_Init()")

	UTAssert(_Vector_IsVector($aTestVector)   = 1, "_Vector_IsVector($aTestVector)   = 1")
	UTAssert(_Vector_IsVector(True)           = 0, "_Vector_IsVector(True)           = 0")
	UTAssert(_Vector_IsVector(100)            = 0, "_Vector_IsVector(100)            = 0")
	UTAssert(_Vector_IsVector(VectorCallback) = 0, "_Vector_IsVector(VectorCallback) = 0")
	UTAssert(_Vector_IsVector('IAmAVector')   = 0, "_Vector_IsVector('IAmAVector')   = 0")
	UTAssert(_Vector_IsVector(Binary('0xFF')) = 0, "_Vector_IsVector(Binary('0xFF')) = 0")

	UTStop()
EndFunc



Func VectorCallback(Const $vVal1, Const $vVal2)
	#forceref $vVal1, $vVal2
EndFunc


