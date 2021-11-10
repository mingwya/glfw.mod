
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow
	
	Field drawlist:TDrawList=New TDrawList
	Field angle:Float
	
	Method New()
		Super.New( Null )
		For Local i:Int=0 Until 100
			drawList.Color Float(Rnd()),Float(Rnd()),Float(Rnd())
			drawList.DrawCircle Float(Rnd(800)-800/2),Float(Rnd(600)-600/2),Float(Rnd(10,20))
		Next
	End Method
	
	Method OnUpdate( dt:Float ) Override
		Super.OnUpdate()
		angle:+1*dt
	End Method
	
	Method OnRender( canvas:TCanvas ) Override
		canvas.Clear( 0,0,1 )
		canvas.RenderDrawList( drawList,Mouse.X(),Mouse.Y(),angle )
	End Method
End Type

New TMyWindow

Repeat
	DeltaTimeApp.Update()
Forever