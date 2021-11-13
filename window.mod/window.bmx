
SuperStrict

Rem
	bbdoc: GLFW Window.
End Rem
Module GLFW.Window

Import GLFW.GLFW
Import GLFW.Mojo
Import BRL.Reflection

Import "monitor.bmx"

Include "common.bmx"
Include "app.bmx"
Include "console.bmx"
Include "input.bmx"
'Include "widget.bmx"

Public

Rem
	bbdoc: Window creation flags.
	about:
| @WindowFlags	| @Description
|:--------------|:-----------
| CenterX		| Center window horizontally.
| CenterY		| Center window vertically.
| Center		| Center window.
| Hidden		| Window is initally hidden.
| Resizable		| Window is resizable.
| Borderless	| Window has no border
| Fullscreen	| Window is a fullscreen window.
| Maximized     | Window is maximized.
| Minimized     | Window is minimized.
| Autorender	| Window render automatic.
| Console		| Window has console.
End Rem
Type WindowFlags
	Global DefaultFlags:Int=Center|Resizeable|AutoRender|Console

	Const CenterX:Int	=1
	Const CenterY:Int	=2
	Const Center:Int	=CenterX|CenterY
	Const Hidden:Int	=4
	Const Resizeable:Int=8
	Const Borderless:Int=16
	Const FullScreen:Int=32
	Const Maximized:Int	=64
	Const Minimized:Int	=128
	Const AutoRender:Int=256
	Const Console:Int	=512
	'Const Widget:Int	=1024
End Type

Rem
	bbdoc: Window layout flags.
End Rem
Type WindowLayout
	Const Fill:Int		=0 'View is resized to fit its layout frame.
	Const Stretch:Int	=1 'View is stretched non-uniformly to fit its layout frame.
	Const Letterbox:Int	=2 'View is uniformly stretched on both axii and centered within its layout frame.
End Type

Rem
	bbdoc: The Window class.
End Rem
Type TWindow
	
	Rem
		bbdoc: Create a new window.
	End Rem
	Method New( title:String,width:Int,height:Int,parent:TWindow=Null,flags:Int=-1 )
		
		If flags=-1 Then flags=WindowFlags.DefaultFlags
		
		Local monitor:TGLFWMonitor
		If flags&WindowFlags.FullScreen
			monitor=TGLFWMonitor.GetPrimaryMonitor()
			Local ok:Int=False
			For Local vm:SGLFWvidmode=EachIn monitor.GetVideoModes()
				If vm.width<>width Then Continue
				If vm.height<>height Then Continue
				If vm.redBits*4<>DesktopDepth() Then Continue
				If vm.refreshRate<>DesktopHertz() Then Continue
				ok=True
			Next
			If Not ok Then monitor=Null
		End If
		
		Local monitorPtr:Byte Ptr
		If monitor
			monitorPtr=monitor.monitorPtr
		Else
			_measureWidth=width
			_measureHeight=height
		End If
		
		Local parentPtr:Byte Ptr
		If parent Then parentPtr=parent._windowPtr
		
		Local t:Byte Ptr = title.ToUTF8String()
		_windowPtr=bmx_glfw_glfwCreateWindow( width,height,title,monitorPtr,parentPtr )
		
		Assert _windowPtr,"window not created!"
		
		If flags&WindowFlags.Hidden Then Hide() Else App._active=Self
		
		App.AddWindow( Self )
		
		Local xp:Int=30,yp:Int=30
		If flags&WindowFlags.CenterX Then xp=DesktopWidth() Shr 1-width Shr 1
		If flags&WindowFlags.CenterY Then yp=DesktopHeight() Shr 1-height Shr 1
		
		bmx_glfw_glfwSetWindowAttrib( _windowPtr,$00020003,( flags&WindowFlags.Resizeable )>0 )
		bmx_glfw_glfwSetWindowAttrib( _windowPtr,$00020005,( flags&WindowFlags.Borderless )=0 )
		
		X( xp )
		Y( yp )
		
		_title=title
		
		If flags&WindowFlags.Maximized Then Maximize()
		If flags&WindowFlags.Minimized Then Minimize()
		
		'Mouse
		bmx_glfw_glfwSetScrollCallback( _windowPtr,Mouse.OnScroll )
		bmx_glfw_glfwSetMouseButtonCallback( _windowPtr,Mouse.OnButton ) '_OnMouseButton )
		bmx_glfw_glfwSetCursorPosCallback( _windowPtr,Mouse.OnCursorPosition )
		
		'Keys
		bmx_glfw_glfwSetKeyCallback( _windowPtr,Key.OnKey )
		bmx_glfw_glfwSetCharCallback( _windowPtr,Key.OnChar )
		
		'Window
		bmx_glfw_glfwSetWindowRefreshCallback( _windowPtr,_OnRefresh )
		'bmx_glfw_glfwSetWindowContentScaleCallback( _windowPtr,_OnContentScale )
		bmx_glfw_glfwSetFramebufferSizeCallback( _windowPtr,_OnFramebufferSize )
		bmx_glfw_glfwSetWindowFocusCallback( _windowPtr,_OnFocus )
		bmx_glfw_glfwSetWindowCloseCallback( _windowPtr,_OnClose )
		bmx_glfw_glfwSetWindowIconifyCallback( _windowPtr,_OnMinimize)
		bmx_glfw_glfwSetWindowMaximizeCallback( _windowPtr,_OnMaximize )
		
		bmx_glfw_glfwMakeContextCurrent( _windowPtr )
		
		_vao=GenVAO()
		
		_canvas=New TCanvas( width,height )
		
		If flags&WindowFlags.AutoRender Then _reqRender=2
		If flags&WindowFlags.Console 	Then TConsole.Init()
		'If flags&WindowFlags.Widget		Then _desktop=New TDesktop ; WriteStdout("window+desktop~n")
		
		_flags=flags
		
		Cursor.Init()
		bmx_glfw_glfwSetInputMode( _windowPtr,GLFW_CURSOR,Mouse._visible )
		bmx_glfw_glfwSetCursor( _windowPtr,Cursor.cursors[Mouse._cursor]._cursor.cursorPtr )
		
		Layout( _layout )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Free()
		If _windowPtr
			OnClose()
			App.RemWindow( Self )
			bmx_glfw_glfwDestroyWindow( _windowPtr )
			_windowPtr=Null
			DelVao( _vao )
			_vao=0
		End If
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnRender( canvas:TCanvas )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnUpdate()
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnUpdate( dt:Float )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnMeasure:Int[]()
		Return [_measureWidth,_measureHeight]
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnMinimize()
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnRestore()
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnMaximize()
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnClose()
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnFocus() ' focused:Int )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method OnLostFocus()
	End Method
	
	Rem
		bbdoc:
	End Rem
	'Method OnDrop( paths:String[] )
	'End Method
	
	Rem
		bbdoc: The window clear color.
	End Rem
	Method ClearColor:Float[]()
		Return _clearColor[..]
	End Method
	
	Rem
		bbdoc: The window clear color.
	End Rem
	Method ClearColor( r:Float,g:Float,b:Float,a:Float=1 )
		_clearColor=[r,g,b,a]
	End Method
	
	Rem
		bbdoc: True if window clearing is enabled.
	End Rem
	Method ClearEnabled:Int()
		Return _clearEnabled
	End Method
	
	Rem
		bbdoc: True if window clearing is enabled.
	End Rem
	Method ClearEnabled( state:Int )
		_clearEnabled=state
	End Method
	
	Rem
		bbdoc: Window fullscreen state.
	End Rem
	Method FullScreen:Int()
		Return _flags&WindowFlags.FullScreen
	End Method
	
	Rem
		bbdoc: Window fullscreen state.
	End Rem
	Method FullScreen( state:Int )
		state=state>0
		If FullScreen()=state Then Return
		If state
			_sx=X()
			_sy=Y()
			_sw=width()
			_sh=height()
			_flags:|WindowFlags.FullScreen
			bmx_glfw_glfwSetWindowMonitor( _windowPtr,TGLFWMonitor.GetPrimaryMonitor().monitorPtr,..
			0,0,DesktopWidth(),DesktopHeight(),DesktopHertz() )
		Else
			_flags:~WindowFlags.FullScreen
			bmx_glfw_glfwSetWindowMonitor( _windowPtr,Null,_sx,_sy,_sw,_sh,0 )'TApp.DesktopHertz() )
		End If
	End Method
	
	Rem
		bbdoc: The window title text.
	End Rem
	Method Title:String()
		Return _title
	End Method
	
	Rem
		bbdoc: The window title text.
	End Rem
	Method Title( str:String )
		Local t:Byte Ptr=str.ToUTF8String()
		bmx_glfw_glfwSetWindowTitle( _windowPtr,t )
		MemFree( t )
		_title=str
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method SetIcon( pixmaps:TPixmap[]=Null )
		If Not pixmaps Or pixmaps.length = 0 Then
			bmx_glfw_glfwSetWindowIcon( _windowPtr,0,Null )
		Else
			Local images:GLFWimage[pixmaps.length]
			
			Local pixs:TPixmap[pixmaps.length] ' cache
			For Local i:Int = 0 Until pixmaps.length
				Local pix:TPixmap=pixmaps[i]
				If pix.format<>PF_RGBA8888
					pix=pix.Convert(PF_RGBA8888)
				End If
				pixs[i]=pix
				
				images[i]=New GLFWimage( pix.width,pix.height,pix.pixels )
			Next
			
			bmx_glfw_glfwSetWindowIcon( _windowPtr,pixmaps.length,images )
			pixs=Null ' refer to cache - prevent compiler optimizing it away because we don't reference it otherwise after the loop
		End If
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method SetIcon( pixmap:TPixmap )
		SetIcon( [pixmap] )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method X:Int()
		Local xx:Int,yy:Int
		bmx_glfw_glfwGetWindowPos( _windowPtr,xx,yy )
		Return xx
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method X( v:Int )
		bmx_glfw_glfwSetWindowPos( _windowPtr,v,Y() )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Y:Int()
		Local xx:Int,yy:Int
		bmx_glfw_glfwGetWindowPos( _windowPtr,xx,yy )
		Return yy
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Y( v:Int )
		bmx_glfw_glfwSetWindowPos( _windowPtr,X(),v )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method width:Int()
		Local w:Int,h:Int
		bmx_glfw_glfwGetWindowSize( _windowPtr,w,h )
		Return w
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method width( w:Int )
		bmx_glfw_glfwSetWindowSize( _windowPtr,w,height() )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method height:Int()
		Local w:Int,h:Int
		bmx_glfw_glfwGetWindowSize( _windowPtr,w,h )
		Return h
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method height( h:Int )
		bmx_glfw_glfwSetWindowSize( _windowPtr,width(),h )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method SetMinMax( minWidth:Int,minHeight:Int,maxWidth:Int,maxHeight:Int )
		bmx_glfw_glfwSetWindowSizeLimits( _windowPtr,minWidth,minHeight,maxWidth,maxHeight )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Minimize()
		bmx_glfw_glfwIconifyWindow( _windowPtr )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Maximize()
		bmx_glfw_glfwMaximizeWindow( _windowPtr )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Restore()
		bmx_glfw_glfwRestoreWindow( _windowPtr )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Show()
		bmx_glfw_glfwShowWindow( _windowPtr )
		_hidden=False
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Hide()
		bmx_glfw_glfwHideWindow( _windowPtr )
		_hidden=True
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Hidden:Int()
		Return _hidden
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Focus()
		bmx_glfw_glfwFocusWindow( _windowPtr )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Layout:Int()
		Return _layout
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Layout( state:Int )
		If _layout=state Then Return
		_layout=state
		_OnFrameBufferSize( _windowPtr,width(),height() )
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method RequestRender()
		If _reqRender=2 Then Return
		_reqRender=1
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method GraphicsWidth:Int()
		If _layout=WindowLayout.Fill Then Return width()
		Return OnMeasure()[0]
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method GraphicsHeight:Int()
		If _layout=WindowLayout.Fill Then Return height()
		Return OnMeasure()[1]
	End Method
	
	'Method AddWidget( widget:TWidget )
	'	If _desktop
	'		If _desktop.childs.Contains( widget ) Then Return
	'		_desktop.childs.AddLast( widget )
	'	End If
	'End Method
	
	'Method RemoveWidget( widget:TWidget )
	'	If _desktop Then _desktop.childs.Remove( widget )
	'End Method
	
	Private
	
	Global context:Byte Ptr
	
	Field _windowPtr:Byte Ptr
	Field _vao:Int
	
	Field _flags:Int
	
	Field _reqRender:Byte=1
	
	Field _title:String
	Field _hidden:Int
	Field _layout:Int=WindowLayout.Stretch
	
	Field _sx:Int=DesktopWidth()  Shr 2
	Field _sy:Int=DesktopHeight() Shr 2
	Field _sw:Int=DesktopWidth()  Shr 1
	Field _sh:Int=DesktopHeight() Shr 1
	
	Field _measureWidth:Int=DesktopWidth()  Shr 1
	Field _measureHeight:Int=DesktopHeight() Shr 1
	
	Field _canvas:TCanvas
	
	Field _clearColor:Float[]=[0.0,0.0,0.0,1.0]
	Field _clearEnabled:Int=True
	
	'Field _desktop:TDesktop
	
	Method Render( raw:Int=False )
		If _hidden Then Return
		
		If Not raw
			If Not _reqRender Then Return
			If _reqRender=1 Then _reqRender=0
		End If
		
		If context<>_windowPtr
			bmx_glfw_glfwMakeContextCurrent( _windowPtr )
			SetVAO( _vao )
			context=_windowPtr
		End If
		
		If _clearEnabled
			_canvas.Clear( _clearColor[0],_clearColor[1],_clearColor[2],_clearColor[3] )
		End If
			
		_canvas.ResetMatrix()
		_canvas.Color( 1,1,1,1 )
		_canvas.BlendMode( TBlendMode.Alpha )
		_canvas.Font( Null )
		_canvas.LineWidth( 1 )
		
		_canvas.PushMatrix()
		
		OnRender( _canvas )
		
		_canvas.PopMatrix()
		
		_canvas.Color( 1,1,1,1 )
		_canvas.BlendMode( TBlendMode.Alpha )
		_canvas.Font( Null )
		_canvas.LineWidth( 1 )
		
		'If _desktop Then _desktop.OnRender( _canvas )
		
		If _flags&WindowFlags.Console
			
			Local info:String
			If TConsole.Variable( "fps" ).ToInt() Then info:+" Fps:"+App.fps
			If TConsole.Variable( "memory" ).ToInt() Then info:+" Mem:"+GCMemAlloced()
			If info<>""
				_canvas.DrawText( info,10,10 )
			End If
		
			'_canvas.ResetMatrix()
			'_canvas.Color( 1,1,1,1 )
			'_canvas.BlendMode( TBlendMode.Alpha )
			'_canvas.Font( Null )
			'_canvas.LineWidth( 1 )
		
			TConsole.Update( Self,_canvas )
			TConsole.Draw( _canvas,1.0 )
		End If
		_canvas.Flush()
		
		bmx_glfw_glfwSwapBuffers( _windowPtr )
	End Method
	
	Method Update()
		'If _desktop Then _desktop.OnUpdate()
		OnUpdate()
	End Method
	
	Method Update( dt:Float )
		'If _desktop Then _desktop.OnUpdate( dt )
		OnUpdate( dt )
	End Method
	
	'console commands
	'Function cmdFps()
	'	drawFps=1-drawFps
	'End Function
	
	'Function cmdMemory()
	'	drawMem=1-drawMem
	'End Function
	
	Function cmdClearMode( mode:Int )
		If Not App._active Then Return
		App._active.ClearEnabled( mode>0 )
		Print( "Clear mode set:"+mode )
	End Function
	
	Function cmdLayout()
		If Not App._active Then Return
		App._active.Layout( ( App._active.Layout()+1 ) Mod 3 )
	End Function
	
	'Function _OnContentScale( windowPtr:Byte Ptr,xScale:Float,yScale:Float )
	'	For Local w:TWindow=EachIn windows
	'		If w._windowPtr<>windowPtr Then Continue
	'		DebugLog "ContentScale:"+xScale+"*"+yScale
	'		Return
	'	Next
	'End Function
	
	Function _OnFramebufferSize( windowPtr:Byte Ptr,width:Int,height:Int )
		For Local i:Int=0 Until App._countWindows
			Local w:TWindow=App._windows[i]
			
			If w._windowPtr<>windowPtr Then Continue
			
			w._canvas.RenderTarget( width,height )
			
			Local m:Int[]
			
			Select w._layout
			Case WindowLayout.Stretch
			
				m=w.OnMeasure()
				w._canvas.Viewport( 0,0,width,height )
				w._canvas.SetProjection2d( 0,m[0],0,m[1] )
				
			Case WindowLayout.Letterbox
				
				m=w.OnMeasure()
				Local VirtualAspect:Float=Float( m[0] )/m[1]
				Local DAspect:Float=Float( width )/height
				
				Local rect:Int[4]
				
				If DAspect>VirtualAspect
					rect[2] = height*VirtualAspect
					rect[3] = height
					rect[0] = ( width-rect[2] )/2 '+devrect[0]
					rect[1] = 0 'devrect[1]
				Else
					rect[2] = width
					rect[3] = width/VirtualAspect
					rect[0] = 0'devrect[0]
					rect[1] = ( height-rect[3] )/2 '+devrect[1]
				EndIf
				
				w._canvas.Viewport( 0,0,width,height )
				w._canvas.Clear( 0,0,0 )
				
				w._canvas.Viewport( rect[0],rect[1],rect[2],rect[3] )
				w._canvas.SetProjection2d( 0,m[0],0,m[1] )
				w.Render( True )'Flip()
				
				w._Canvas.Viewport( 0,0,width,height ) 'vp[0],vp[1],vp[2],vp[3] )
				
				w._canvas.Clear( 0,0,0 )
				
				w._canvas.Viewport( rect[0],rect[1],rect[2],rect[3] )
				
			Default 'Fill
			
				w._canvas.Viewport( 0,0,width,height )
				w._canvas.SetProjection2d( 0,width,0,height )
			
			End Select
			
			w.Render( True )
			
			Return
		Next
	End Function
	
	Function _OnFocus( windowPtr:Byte Ptr,focused:Int )
		For Local window:TWindow=EachIn App._windows
			If window._windowPtr<>windowPtr Then Continue
			If focused
				App._active=window
				window.OnFocus()
			Else
				window.OnLostFocus()
				If App._active=window Then App._active=Null
			End If
			Return
		Next
	End Function
	
	Function _OnClose( windowPtr:Byte Ptr )
		For Local w:TWindow=EachIn App._windows
			If w._windowPtr<>windowPtr Then Continue
			w.OnClose()
			Return
		Next
	End Function
	
	Function _OnMinimize( windowPtr:Byte Ptr,minimized:Int )
		For Local w:TWindow=EachIn App._windows
			If w._windowPtr<>windowPtr Then Continue
			If minimized
				w.OnMinimize()
				w._hidden=True
			Else
				w._hidden=False
				w.OnRestore()
			End If
			Return
		Next
	End Function
	
	Function _OnMaximize( windowPtr:Byte Ptr,maximized:Int )
		For Local w:TWindow=EachIn App._windows
			If w._windowPtr<>windowPtr Then Continue
			If maximized Then w.OnMaximize()
			Return
		Next
	End Function
	
	Function _OnRefresh( windowPtr:Byte Ptr )
		For Local w:TWindow=EachIn App._windows
			If w._windowPtr<>windowPtr Then Continue
			'DebugLog "Refresh"
			Return
		Next
	End Function
End Type
