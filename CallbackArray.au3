#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author(s):       Zvend
 Discord(s):      zvend

 Script Function:
    _CallbackArray_Init(Const $nSize) -> Array[$nSize]
    _CallbackArray_Get(ByRef $aArray, Const $nIndex) -> Array[N>0]
    _CallbackArray_Add(ByRef $aArray, Const $nIndex, Const $sCallback) -> Bool
    _CallbackArray_Remove(ByRef $aArray, Const $nIndex, Const $sCallbackToRemove) -> Bool

 Description:
    Callback Arrays are 1D arrays storing sub arrays of strings. They are meant to be ID controlled.
    Those are meant for a wider callback structure than only one simple array.

#ce ----------------------------------------------------------------------------

#cs - Guide --------------------------------------------------------------------

    Example: You make an event system with 3 events.
        Global Enum _
            $EVENT_MOUSE_BTN_DOWN, _
            $EVENT_MOUSE_BTN_UP  , _
            $EVENT_MOUSE_MOVE    , _
            $EVENT_COUNT

    So you initialize your array like:
        Global $g_aMyCallbacks = _CallbackArray_Init($EVENT_COUNT)    // Note that resizing is not supported

    Now you can add (multiple) function callbacks to each event:
        _CallbackArray_Add($g_aMyCallbacks, $EVENT_MOUSE_BTN_DOWN, "OnMouseButtonDown1")
        _CallbackArray_Add($g_aMyCallbacks, $EVENT_MOUSE_BTN_DOWN, "OnMouseButtonDown2")
        _CallbackArray_Add($g_aMyCallbacks, $EVENT_MOUSE_BTN_DOWN, "OnMouseButtonDown3")
        _CallbackArray_Add($g_aMyCallbacks, $EVENT_MOUSE_BTN_UP  , "OnMouseButtonUp1")
        _CallbackArray_Add($g_aMyCallbacks, $EVENT_MOUSE_BTN_UP  , "OnMouseButtonUp2")
        _CallbackArray_Add($g_aMyCallbacks, $EVENT_MOUSE_MOVE    , "OnMouseMove")

    Your array would look like this now:
        Global $g_aMyCallbacks =
        [ ;~ [Count, Name_1, Name_2, ..., Name_N]
            [3, "OnMouseButtonDown", "OnMouseButtonDown", "OnMouseButtonDown"],
            [2, "OnMouseButtonUp", "OnMouseButtonUp"],
            [1, "OnMouseMove"]
        ]

    But this would cause an error in autoit since the sub arrays are not of the same size.
    They all would need to be a subarray of size 4.
    But I use a workaround for it, so you dont have to worry about the structure of the array.
    Just make sure to get the callbacks over the _CallbackArray_Get() function.

    Example:
        Func Broadcast_MouseButtonDown(Const $nButtonId)
            Local $aCallbacks = _CallbackArray_Get($g_aMyCallbacks, $EVENT_MOUSE_BTN_DOWN)
            If @error Then Return 0

            Local $nCallbackCount = $aCallbacks[0]
            If $nCallbackCount = 0 Then Return 0

            For $i = 1 To $nCallbackCount
                Call($aCallbacks[$i], $nButtonId)
            Next

            Return 1
        EndFunc

    And now you can call all callbacks for $EVENT_MOUSE_BTN_DOWN using this broadcast function.
    This array supports n-doubles - So you can add the same callback multiple time and it would
    be called multiple times. Could not think of a usecase why this is useful but it didnt hurt
    to support that feature.

    Removing a specific callback can be done like this:
        _CallbackArray_Remove($g_aMyCallbacks, $EVENT_MOUSE_BTN_DOWN, "OnMouseButtonDown1")

    Note that if you have added the callback more than once -> all of them will be removed!

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



Func _CallbackArray_Init(Const $nSize)
    ;~ using a temp array here cause ReDim only works if the given var is already
    ;~ declared as an array. Neat trick to get rid of it.

    Local $aTemp[$nSize]
    Local $aEmptyArray = [0]

    For $i = 0 To $nSize - 1
        $aTemp[$i] = $aEmptyArray
    Next

    Return $aTemp
EndFunc



Func _CallbackArray_Get(Const ByRef $aArray, Const $nIndex)
    Static Local $aEmptyArray = [0]

    If Not IsArray($aArray) Then
        Return SetError(1, 0, $aEmptyArray)
    EndIf

    Local $nSize = UBound($aArray)
    If $nIndex >= $nSize Or $nIndex < 0 Then
        Return SetError(2, 0, $aEmptyArray)
    EndIf

    Return $aArray[$nIndex]
EndFunc



Func _CallbackArray_Add(ByRef $aArray, Const $nIndex, Const $sCallback)
    If Not IsString($sCallback) Then
        Return SetError(1, 0, 0)
    EndIf

    If Not IsArray($aArray) Then
        Return SetError(2, 0, 0)
    EndIf

    Local $nSize = UBound($aArray)
    If $nIndex >= $nSize Or $nIndex < 0 Then
        Return SetError(3, 0, 0)
    EndIf

    Local $aCurrentCallbacks = $aArray[$nIndex]

    $aCurrentCallbacks[0] += 1
    ReDim $aCurrentCallbacks[$aCurrentCallbacks[0] + 1]
    $aCurrentCallbacks[$aCurrentCallbacks[0]] = $sCallback

    $aArray[$nIndex] = $aCurrentCallbacks

    Return 1
EndFunc



Func _CallbackArray_Remove(ByRef $aArray, Const $nIndex, Const $sCallbackToRemove)
    If Not IsString($sCallbackToRemove) Then
        Return SetError(1, 0, 0)
    EndIf

    If Not IsArray($aArray) Then
        Return SetError(2, 0, 0)
    EndIf

    Local $nSize = UBound($aArray)
    If $nSize <= 0 Then
        Return 1
    EndIf

    If $nIndex >= $nSize Or $nIndex < 0 Then
        Return SetError(3, 0, 0)
    EndIf

    Local $aCurrentCallbacks = $aArray[$nIndex]
    Local $i = 0
    Local $j = 0

    Local $aNewCallbacks[UBound($aCurrentCallbacks)]

    While $i < $aCurrentCallbacks[0]
        $i += 1
        If $aCurrentCallbacks[$i] == $sCallbackToRemove Then
            ContinueLoop
        EndIf

        $j += 1
        $aNewCallbacks[$j] = $aCurrentCallbacks[$i]
    WEnd

    ReDim $aNewCallbacks[$j + 1]
    $aNewCallbacks[0] = $j
    $aArray[$nIndex] = $aNewCallbacks

    Return 1
EndFunc


