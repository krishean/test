Screen 12
'Color _RGB(Rnd * 255, Rnd * 255, Rnd * 255)
Color _RGB(&H5C, &HDD, &H08) ' chosen by fair dice roll.
                             ' guaranteed to be random.
Dim As Single Xp, Yp, X, Y, n
Dim As Integer i
For i = 1 To 100000
    n = Rnd
    If n < .01 Then
        Xp = 0
        Yp = .16 * Y
    ElseIf n >= .01 And n <= .08 Then
        Xp = .2 * X - .26 * Y
        Yp = .23 * X + .22 * Y + 1.6
    ElseIf n >= .08 And n <= .15 Then
        Xp = -.15 * X + .28 * Y
        Yp = .26 * X + .24 * Y + .44
    Else
        Xp = .85 * X + .04 * Y
        Yp = -.04 * X + .85 * Y + 1.6
    End If
    X = Xp
    Y = Yp
    PSet (X * 45 + 320, -(Y * 45 - 225) + 240)
Next i
