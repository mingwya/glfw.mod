
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow
	
	Field m:TResManager=New TResManager
	Field frame:Float
	Field image:TImage[]
	
	Method New()
		Super.New( Null )
		image=m.LoadAnimImage( "..\assets\fly.png",46,32,0,7,0 )
	End Method
	
	Method OnUpdate( dt:Float ) Override
		Super.OnUpdate()
		frame:+0.2*dt
	End Method
	
	Method OnRender( canvas:TCanvas ) Override
		canvas.Clear( 0,0,0 )
		Local c:Int=frame Mod 7
		canvas.DrawImage( image[c],Mouse.X(),Mouse.Y(),0,4,4 )
		canvas.DrawText( "frame:"+c,10,10 )
	End Method
End Type

New TDeltaTimeApp
New TMyWindow

Repeat
	App.Update()
Forever
