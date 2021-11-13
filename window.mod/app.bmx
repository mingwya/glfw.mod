
Public

TConsole.Variable( "fps",0 )
TConsole.Variable( "memory",0 )

Rem
	bbdoc: Application base class.
End Rem
Type App

	Global fps:Int

	Method New()
		RuntimeError( "Type App is not instancable." )
	End Method
	
	Rem
	bbdoc: Return app terminate state
	returns: True if user has requested to terminate application
	End Rem
	Function Update()
		
		If _suspend
			Repeat
				Delay( 100 )
				PollSystem()
				If Not _suspend Then Exit
			Forever
		End If
		
		TJoystick.Update()
		If _active
			_active.Update()
			_active.Render( False )
		End If
		For Local i:Int=0 Until _countWindows
			If _windows[i]=_active Then Continue
			_windows[i].Update()
			_windows[i].Render( False )
		Next
		PollSystem()
		
		UpdateFps()
	End Function
	
	Rem
	bbdoc: Return app terminate state
	returns: True if user has requested to terminate application
	End Rem
	Function Terminate()
		'For Local i:Int=0 Until _countWindows
		'	_windows[i].Free()
		'Next
		End
	End Function
	
	Rem
	bbdoc: Return app terminate state
	returns: True if user has requested to terminate application
	End Rem
	Function Suspend( state:Int=True )
		_suspend=state
	End Function
	
	Rem
	bbdoc: Return app terminate state
	returns: True if user has requested to terminate application
	End Rem
	Function ActiveWindow:TWindow()
		Return _active
	End Function
	
	Rem
	bbdoc: Return app terminate state
	returns: True if user has requested to terminate application
	End Rem
	Function CountWindows:Int()
		Return _countWindows
	End Function
	
	Rem
	bbdoc: Return app terminate state
	returns: True if user has requested to terminate application
	End Rem
	Function GetWindow:TWindow( index:Int )
		Return _windows[index]
	End Function
	
	Protected
	
	Global _fps:Int,_fpsTime:Int
	
	Global _suspend:Int
	
	Global _active:TWindow
	Global _windows:TWindow[1]
	Global _countWindows:Int=0
	
	Function UpdateFps()
		_fps:+1
		If MilliSecs()-_fpsTime>=1000
			fps=_fps
			_fps=0
			_fpsTime=MilliSecs()
		End If
	End Function
	
	Function AddWindow:Int( window:TWindow )
		If _windows.Length=_countWindows Then _windows=_windows[.._windows.Length Shl 1]
		_windows[_countWindows]=window
		_countWindows:+1
		Return _countWindows-1
	End Function
	
	Function GetWindowIndex:Int( window:TWindow )
		For Local i:Int=0 Until _countWindows
			If _windows[i]=window Then Return i
		Next
		Return -1
	End Function
	
	Function RemWindow:Int( window:TWindow )
		Local i:Int=GetWindowIndex( window )
		If i=-1 Then Return False
		Return RemWindow( i )
	End Function
	
	Function RemWindow:Int( index:Int )
		_windows[index]=Null
		_countWindows:-1
		If index=_countWindows Then Return True
		_windows[index]=_windows[_countWindows]
		_windows[_countWindows]=Null
		Return True
	End Function
End Type

Rem
	bbdoc: Fixel rate logic application.
End Rem
Type FixedLogicApp Extends App

	Global tween:Float
	
	Function Init( freq:Int )
		Hertz( freq )
		_ticker=MilliSecs()-_upTime
	End Function
	
	Function Hertz:Int()
		Return _hertz
	End Function
	
	Function Hertz( value:Int )
		_hertz=value
		_upTime=1000.0/Float( _hertz )
	End Function
	
	Function Update() Override
		
		If _suspend
			Repeat
				Delay( 100 )
				PollSystem()
				If Not _suspend Then Exit
			Forever
		End If

		Local timeElapsed:Float
			
		Repeat
			timeElapsed=MilliSecs()-_ticker
		Until timeElapsed
			
		If timeElapsed>200
			timeElapsed=200
			_ticker=MilliSecs()
		End If
			
		Local frameTicks:Int=timeElapsed/_upTime
		
		For Local j:Int=0 Until frameTicks
			_ticker:+_upTime
			
			TJoystick.Update()
			If _active And Not _active.Hidden()
				_active.Update()
			End If
			For Local i:Int=0 Until _windows.Length
				If _windows[i]=_active Then Continue
				If _windows[i].Hidden() Then Continue
				_windows[i].Update()
			Next
			PollSystem()
		Next
		
		tween=Float( timeElapsed Mod _upTime )/_upTime
		
		For Local i:Int=0 Until _windows.Length
			If _windows[i].Hidden() Then Continue
			_windows[i].Render( False )
		Next
		
		UpdateFps()
	End Function
	
	Function Interpolate:Float( oldValue:Float,value:Float ) NoDebug
		Return oldValue+( value-oldValue )*tween
	End Function
	
	Private
	
	Global _hertz:Int=60
	Global _upTime:Float=1000.0/60.0
	Global _ticker:Float
End Type

Function Interpolate:Float( oldValue:Float,value:Float ) NoDebug
	Return oldValue+( value-oldValue )*FixedLogicApp.tween
End Function

Rem
	bbdoc: Delta time application.
End Rem
Type DeltaTimeApp Extends App
	
	Global dt:Float=1.0
	
	Function Init( freq:Int=60 )
		Hertz( freq )
	End Function
	
	Function Hertz:Int()
		Return _hertz
	End Function
	
	Function Hertz( value:Int )
		_hertz=value
		_upTime=1000.0/Float( _hertz )
	End Function
	
	Function Update() Override
		
		If _suspend
			Repeat
				Delay( 100 )
				PollSystem()
				If Not _suspend Then Exit
			Forever
		End If
		
		Local frameTime:Int=MilliSecs()
		
		TJoystick.Update()
		If _active
			_active.Update( dt )
			_active.Render( False )
		End If
		For Local i:Int=0 Until _windows.Length
			If _windows[i]=_active Then Continue
			_windows[i].Update( dt )
			_windows[i].Render( False )
		Next
		PollSystem()
		
		frameTime=MilliSecs()-frameTime
		
		dt=frameTime/_upTime
		
		UpdateFps()
	End Function
	
	Private
	
	Global _hertz:Int=60
	Global _upTime:Float=1000.0/60.0
End Type
