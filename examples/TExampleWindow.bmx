
Type TExampleWindow Extends TWindow
	
	Const WINDOW_WIDTH:Int=800
	Const WINDOW_HEIGHT:Int=600
	
	Method New( parent:TWindow=Null )
		Super.New( StripExt( StripDir( AppFile ) ),WINDOW_WIDTH,WINDOW_HEIGHT,parent )
	End Method
	
	Method OnClose() Override
		App.Terminate()
	End Method
	
	Method OnUpdate() Override 'fix logic version
		If Key.Hit( Key.ESCAPE ) Then OnClose()
		If Key.Rep( Key.ENTER,Modifier.ALT ) Then FullScreen( 1-FullScreen() )
	End Method
	
	Method OnUpdate( dt:Float ) Override 'dt version
		OnUpdate()
	End Method
End Type
