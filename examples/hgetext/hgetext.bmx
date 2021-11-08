
SuperStrict

Framework glfw.Window

Include "..\TExampleWindow.bmx"

Type TMyWindow Extends TExampleWindow

	Field fa:TFont,fb:TFont
	Field text:String="Hello World!!!~nNikas papandopolus!~nAnd so what do you do?"
	
	Field image:TImage
	
	Global cnt:Int=0
	
	Method New( parent:TWindow=Null )
		Super.New( parent )
		
		?Debug
		TResManager.debug=True
		?
		
		Local a:TResManager=New TResManager
		Local b:TResManager=New TResManager

		fa=a.loadfont( "font.fnt",0 )
		a.loadfont( "font.fnt",0 )
		fb=b.loadfont( "font.fnt",0 )

		a.Free()
		b.Free()

		If fa=fb
			DebugLog("fa=fb!")
		Else
			DebugLog("fa<>fb????")
		End If
		
		image=TImage.Load( "..\assets\default_player.png" )
		
		ClearColor( 0,0,1,1 )
		
		cnt:+1
		Title( "Window="+cnt )
		
		mouse.Cursor( Cursor.Hand )
	End Method
	
	Field r:Float
	
	Method OnUpdate( dt:Float ) Override
		Super.OnUpdate( dt )
		r:+1.0*dt
		
		If Key.Hit( KEY.UP ) Then fa.lineKerning( fa.lineKerning()+1 )
		If Key.Hit( KEY.DOWN ) Then fa.lineKerning( fa.lineKerning()-1 )
	End Method
	
	Field xx#,yy#
	
	Method OnRender( canvas:TCanvas ) Override
		'If App.ActiveWindow()=Self
			xx=mouse.x()
			yy=mouse.y()
		'End If
		
		canvas.Font( fa )
		canvas.color(.5,.5,.5)
		canvas.DrawRect( xx-fa.TextWidth(text)*0,yy-fa.TextHeight(text)*1,fa.TextWidth( text ),fa.TextHeight( text ) )
		canvas.color(1,1,1,1)
		canvas.DrawText( text,xx,yy,1,1,1 ) ',rot,.5,.5 )
		
		canvas.Translate( 320,240 )
		canvas.Rotate( r )
		
		canvas.DrawImage image ',320,240
	End Method
End Type

New TDeltaTimeApp
New TMyWindow( New TMyWindow )

Repeat
	App.Update()
	Local w:TWindow=TWindow(App.ActiveWindow())
	If w
		WriteStdout( w.title()+"~n" )
	End If
Forever

