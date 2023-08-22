#cs ----------------------------------------------------------------------------

 AutoIt Version:  3.3.16.1
 Author(s):       Zvend       Nadav
 Discord(s):      Zvend#6666  Abaddon#9048

 Description:
    Small UnitTest library for GitHub Workflows

 Script Functions:
    UTInit()                            -> 0
    UTExit()                            -> 0
    UTStart(Const $sTitle)              -> 0
    UTStop()                            -> 0
    UTAssert(Const $bBool, Const $sOut) -> Bool

#ce ----------------------------------------------------------------------------

#include-once

Global $fuOutFunction ;Requires one param: string
Global $nUnitTestCount = 0
Global $nUnitTestSuccessCount = 0
Global $nUnitTestFailCount = 0

Global $hTotalStopwatch
Global $hStopwatch



Func UTInit($fuCallback = ConsoleWrite)
	$hTotalStopwatch = TimerInit()
    $fuOutFunction = $fuCallback
EndFunc


Func UTExit()
    Call($fuOutFunction, StringFormat("%3d total UnitTests.\n", $nUnitTestCount))
    Call($fuOutFunction, StringFormat("%3d UnitTests were successful.\n", $nUnitTestSuccessCount))
    Call($fuOutFunction, StringFormat("%3d UnitTests have failed.\n", $nUnitTestFailCount))
	Call($fuOutFunction, StringFormat("Test time passed: %0.3fms\n", TimerDiff($hTotalStopwatch)))

    If $nUnitTestFailCount Then
        Exit(1)
    EndIf

    Exit(0)
EndFunc



Func UTStart(Const $sTitle)
	Call($fuOutFunction, StringFormat("Testing: %s\n", $sTitle))
    $hStopwatch = TimerInit()
EndFunc



Func UTStop()
	Call($fuOutFunction, StringFormat(" > Time passed: %0.3fms\n", TimerDiff($hStopwatch)))
EndFunc



Func UTAssert(Const $bBool, Const $sOut)
	$nUnitTestCount += 1

    If $bBool Then
		$nUnitTestSuccessCount += 1
        Call($fuOutFunction, StringFormat("\tAssert Success: %s\n", $sOut))
	Else
		$nUnitTestFailCount += 1
        Call($fuOutFunction, StringFormat("\tAssert Failure: %s\n", $sOut))
    EndIf

    Return $bBool
EndFunc
