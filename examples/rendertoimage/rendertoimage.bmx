
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow
	
	Field image:TImage = New TImage( 256,256 )
	Field icanvas:TCanvas=New TCanvas( image )
	
	Method OnRender( canvas:TCanvas ) Override
		
		'render to image...
		For Local x:Int=0 Until 16
			For Local y:Int=0 Until 16
				If (x~y)&1
					icanvas.Color( Sinus( MilliSecs()*.1 )*.5+.5,Cosinus( MilliSecs()*.1 )*.5+.5,.5 )
				Else
					icanvas.Color( 1,1,0 )
				EndIf
				icanvas.DrawRect( x*16,y*16,16,16 )
			Next
		Next
		icanvas.Flush()
		
		'render to main canvas...
		canvas.DrawImage( image,Mouse.X(),Mouse.Y() )
	End Method
End Type

New TApp
New TMyWindow( Null )

Repeat
	App.Update()
Forever
