
Public

Rem
	bbdoc: Application global variable.
End Rem
Global App:TApp

Rem
	bbdoc: Application base class.
End Rem
Type TApp

	Global fps:Int

	Method New()
		If App Then RuntimeError( "App is already exist." )
		App=Self
		
		'bmx_glfw_glfwWindowHint( $00020004,False ) 'visible=false
		TConsole.Init()
	End Method

	Method Update()
		TJoystick.Update()
		If TWindow.active
			TWindow.active.OnUpdate()
			TWindow.active.Render( False )
		End If
		For Local window:TWindow=EachIn TWindow.windows
			If window=TWindow.active Then Continue
			window.OnUpdate()
			window.Render( False )
		Next
		PollSystem()
		
		_fps:+1
		If MilliSecs()-_fpsTime>=1000
			fps=_fps
			_fps=0
			_fpsTime=MilliSecs()
		End If
	End Method
	
	Rem
	bbdoc: Return app terminate state
	returns: True if user has requested to terminate application
	End Rem
	Function Terminate()
		End
	End Function
	
	Function ActiveWindow:TWindow()
		Return TWindow.active
	End Function
	
	Method Operator[]:TWindow( id:Int )
		If id<0 Or id>=TWindow.Windows.Length Then Return Null
		Return TWindow.Windows[id]
	End Method
	
	'Method ObjectEnumerator:TListEnum()
	'	
	'End Method
	
	Protected
	
	Field _fps:Int,_fpsTime:Int
End Type

Rem
	bbdoc: Fixel rate logic application.
End Rem
Type TFixedLogicApp Extends TApp

	Global tween:Float
	
	Method New( freq:Int )
		Super.New()
		Hertz( freq )
		_ticker=MilliSecs()-_upTime
	End Method
	
	Method Hertz:Int()
		Return _hertz
	End Method
	
	Method Hertz( value:Int )
		_hertz=value
		_upTime=1000.0/Float( _hertz )
	End Method
	
	Method Update() Override
		
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
			If TWindow.active
				TWindow.active.OnUpdate()
			End If
			For Local i:Int=0 Until TWindow.windows.Length
				If TWindow.windows[i]=TWindow.active Then Continue
				TWindow.windows[i].OnUpdate()
			Next
			PollSystem()
		Next
		
		tween=Float( timeElapsed Mod _upTime )/_upTime
		
		For Local i:Int=0 Until TWindow.windows.Length
			TWindow.windows[i].Render( False )
		Next
		
		_fps:+1
		If MilliSecs()-_fpsTime>=1000
			fps=_fps
			_fps=0
			_fpsTime=MilliSecs()
		End If
	End Method
	
	Function Interpolate:Float( oldValue:Float,value:Float ) NoDebug
		Return oldValue+( value-oldValue )*tween
	End Function
	
	Private
	
	Field _hertz:Int=60
	Field _upTime:Float=1000.0/60.0
	Field _ticker:Float
End Type

Function Interpolate:Float( oldValue:Float,value:Float ) NoDebug
	Return oldValue+( value-oldValue )*TFixedLogicApp.tween
End Function

Rem
	bbdoc: Delta time application.
End Rem
Type TDeltaTimeApp Extends TApp
	
	Global dt:Float=1.0
	
	Method New( freq:Int )
		Super.New()
		Hertz( freq )
	End Method
	
	Method Hertz:Int()
		Return _hertz
	End Method
	
	Method Hertz( value:Int )
		_hertz=value
		_upTime=1000.0/Float( _hertz )
	End Method
	
	Method Update() Override
		
		Local frameTime:Int=MilliSecs()
		
		TJoystick.Update()
		If TWindow.active
			TWindow.active.OnUpdate( dt )
			TWindow.active.Render( False )
		End If
		For Local window:TWindow=EachIn TWindow.windows
			If window=TWindow.active Then Continue
			window.OnUpdate( dt )
			window.Render( False )
		Next
		PollSystem()
		
		frameTime=MilliSecs()-frameTime
		
		dt=frameTime/_upTime
		
		_fps:+1
		If MilliSecs()-_fpsTime>=1000
			fps=_fps
			_fps=0
			_fpsTime=MilliSecs()
		End If
	End Method
	
	Private
	
	Field _hertz:Int=60
	Field _upTime:Float=1000.0/60.0
End Type
