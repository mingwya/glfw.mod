
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow
	Method New()
		Super.New( Null )
		ClearColor( 0,0,1,1 )
	End Method
	
	Method OnRender( canvas:TCanvas ) Override
		canvas.BlendMode 3
		canvas.Color 0,0,0,.5
		canvas.DrawText "HELLO WORLD!",800/2+2,600/2+2,.5,.5
		
		canvas.BlendMode 1
		canvas.Color 1,1,0,1
		canvas.DrawText "HELLO WORLD!",800/2,600/2,.5,.5
	End Method
End Type

New TMyWindow

Repeat
	App.Update()
Forever
