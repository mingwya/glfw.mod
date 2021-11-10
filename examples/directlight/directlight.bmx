
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow
	
	Field tile:TImage=TImage.Load( "..\assets\t3.png" )
	
	Method New( parent:TWindow=Null )
		Super.New( parent )
		ClearColor( 0,0,1,1 )
	End Method
	
	Method OnRender( canvas:TCanvas ) Override
		canvas.AmbientLight .2,.2,.2
		'Set light 0
		canvas.LightType 0,1
		canvas.LightColor 0,0,1,1'.3
		canvas.LightPosition 0,Mouse.X(),Mouse.Y(),-100
		canvas.LightRange 0,200
		
		'canvas.FogColor(1,1,1,.9)
		'Light will affect subsequent rendering...
		For Local x:Int=0 Until 800 Step 128 'GraphicsWidth() Step 128
			For Local y:Int=0 Until 128*6 Step 128 'GraphicsHeight() Step 128	
				canvas.DrawImage tile,x,y
			Next
		Next
	End Method
End Type

New TMyWindow '( New TMyWindow )

Repeat
	DeltaTimeApp.Update()
Forever