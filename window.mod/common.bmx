
Public

Function PollSystem()
	If _busy Then Return
	_busy=True
	bmx_glfw_glfwPollEvents()
	_busy=False
End Function

Function WaitSystem()
	If _busy Then Return
	_busy=True
	bmx_glfw_glfwWaitEvents()
	_busy=False
End Function

Private

Global _busy:Int

If bmx_glfw_glfwInit()
	bmx_glfw_glfwWindowHint( $00022002,3 ) ' opengl 3
	bmx_glfw_glfwWindowHint( $00022003,3 ) ' opengl 3.3
	bmx_glfw_glfwWindowHint( $00022008, GLFW_OPENGL_CORE_PROFILE )
	
?MacOS ' Ewww...
	bmx_glfw_glfwWindowHint( GLFW_OPENGL_FORWARD_COMPAT,GL_TRUE )
?
		
	OnEnd( bmx_glfw_glfwTerminate )
Else
	RuntimeError( "[glfw]:not inited." )
End If

Extern
	
	Function bmx_glfw_glfwInit:Int()="glfwInit"
	Function bmx_glfw_glfwTerminate()="glfwTerminate"
	Function bmx_glfw_glfwPollEvents()="glfwPollEvents"
	Function bmx_glfw_glfwWaitEvents()="glfwWaitEvents"
	
	'Function bmx_glfw_glfwGetWindowUserPointer:TWindow(window:Byte Ptr)="glfwGetWindowUserPointer"
	'Function bmx_glfw_glfwSetWindowUserPointer(window:Byte Ptr, win:TWindow)="glfwSetWindowUserPointer"
	Function bmx_glfw_glfwCreateCursor:Byte Ptr(image:GLFWimage Var, xhot:Int, yhot:Int)="glfwCreateCursor"

	Function bmx_glfw_glfwDefaultWindowHints()="glfwDefaultWindowHints"
	Function bmx_glfw_glfwWindowHint(hint:Int, value:Int)="glfwWindowHint"
	Function bmx_glfw_glfwWindowHintString(hint:Int, value:Byte Ptr)="glfwWindowHintString"
	Function bmx_glfw_glfwCreateWindow:Byte Ptr(width:Int, height:Int, title:Byte Ptr, monitor:Byte Ptr, share:Byte Ptr)="glfwCreateWindow"
	Function bmx_glfw_glfwDestroyWindow(window:Byte Ptr)="glfwDestroyWindow"
	Function bmx_glfw_glfwWindowShouldClose:Int(window:Byte Ptr)="glfwWindowShouldClose"
	Function bmx_glfw_glfwSetWindowShouldClose(window:Byte Ptr, value:Int)="glfwSetWindowShouldClose"
	Function bmx_glfw_glfwSetWindowTitle(window:Byte Ptr, title:Byte Ptr)="glfwSetWindowTitle"
	Function bmx_glfw_glfwGetWindowPos(window:Byte Ptr, x:Int Var, y:Int Var)="glfwGetWindowPos"
	Function bmx_glfw_glfwSetWindowPos(window:Byte Ptr, x:Int, y:Int)="glfwSetWindowPos"
	Function bmx_glfw_glfwGetWindowSize(window:Byte Ptr, w:Int Var, h:Int Var)="glfwGetWindowSize"
	Function bmx_glfw_glfwSetWindowSizeLimits(window:Byte Ptr, minWidth:Int, minHeight:Int, maxWidth:Int, maxHeight:Int)="glfwSetWindowSizeLimits"
	Function bmx_glfw_glfwSetWindowAspectRatio(window:Byte Ptr, numer:Int, denom:Int)="glfwSetWindowAspectRatio"
	Function bmx_glfw_glfwSetWindowSize(window:Byte Ptr, w:Int, h:Int)="glfwSetWindowSize"
	Function bmx_glfw_glfwGetFramebufferSize(window:Byte Ptr, width:Int Var, height:Int Var)="glfwGetFramebufferSize"
	Function bmx_glfw_glfwGetWindowFrameSize(window:Byte Ptr, Left:Int Var, top:Int Var, Right:Int Var, bottom:Int Var)="glfwGetWindowFrameSize"
	Function bmx_glfw_glfwGetWindowContentScale(window:Byte Ptr, xscale:Float Var, yscale:Float Var)="glfwGetWindowContentScale"
	Function bmx_glfw_glfwGetWindowOpacity:Float(window:Byte Ptr)="glfwGetWindowOpacity"
	Function bmx_glfw_glfwSetWindowOpacity(window:Byte Ptr, opacity:Float)="glfwSetWindowOpacity"
	Function bmx_glfw_glfwIconifyWindow(window:Byte Ptr)="glfwIconifyWindow"
	Function bmx_glfw_glfwRestoreWindow(window:Byte Ptr)="glfwRestoreWindow"
	Function bmx_glfw_glfwMaximizeWindow(window:Byte Ptr)="glfwMaximizeWindow"
	Function bmx_glfw_glfwShowWindow(window:Byte Ptr)="glfwShowWindow"
	Function bmx_glfw_glfwHideWindow(window:Byte Ptr)="glfwHideWindow"
	Function bmx_glfw_glfwFocusWindow(window:Byte Ptr)="glfwFocusWindow"
	Function bmx_glfw_glfwRequestWindowAttention(window:Byte Ptr)="glfwRequestWindowAttention"
	Function bmx_glfw_glfwGetWindowAttrib:Int(window:Byte Ptr, attrib:Int)="glfwGetWindowAttrib"
	Function bmx_glfw_glfwSetWindowAttrib(window:Byte Ptr, attrib:Int, value:Int)="glfwSetWindowAttrib"
	Function bmx_glfw_glfwGetWindowMonitor:Byte Ptr(window:Byte Ptr)="glfwGetWindowMonitor"
	Function bmx_glfw_glfwSetWindowMonitor(window:Byte Ptr, monitor:Byte Ptr, xpos:Int, ypos:Int, width:Int, height:Int, refreshRate:Int)="glfwSetWindowMonitor"
	Function bmx_glfw_glfwSetWindowIcon(window:Byte Ptr, count:Int, images:Byte Ptr)="glfwSetWindowIcon"

	Function bmx_glfw_glfwMakeContextCurrent(window:Byte Ptr)="glfwMakeContextCurrent"
	Function bmx_glfw_glfwSwapBuffers(window:Byte Ptr)="glfwSwapBuffers"
	
	Function bmx_glfw_glfwGetInputMode:Int(window:Byte Ptr, Mode:Int)="glfwGetInputMode"
	Function bmx_glfw_glfwSetInputMode(window:Byte Ptr, Mode:Int, value:Int)="glfwSetInputMode"
	Function bmx_glfw_glfwGetKey:Int(window:Byte Ptr, Key:Int)="glfwGetKey"
	Function bmx_glfw_glfwGetMouseButton:Int(window:Byte Ptr, button:Int)="glfwGetMouseButton"
	Function bmx_glfw_glfwGetCursorPos(window:Byte Ptr, x:Double Var, y:Double Var)="glfwGetCursorPos"
	Function bmx_glfw_glfwSetCursorPos(window:Byte Ptr, x:Double, y:Double)="glfwSetCursorPos"

	Function bmx_glfw_glfwRawMouseMotionSupported:Int()="glfwRawMouseMotionSupported"
	Function bmx_glfw_glfwGetKeyName:Byte Ptr(Key:Int, scancode:Int)="glfwGetKeyName"
	Function bmx_glfw_glfwGetKeyScancode:Int(Key:Int)="glfwGetKeyScancode"

	Function bmx_glfw_glfwSetWindowPosCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, x:Int, y:Int))="glfwSetWindowPosCallback"
	Function bmx_glfw_glfwSetWindowSizeCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, w:Int, h:Int))="glfwSetWindowSizeCallback"
	Function bmx_glfw_glfwSetWindowCloseCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr))="glfwSetWindowCloseCallback"
	Function bmx_glfw_glfwSetWindowRefreshCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr))="glfwSetWindowRefreshCallback"
	Function bmx_glfw_glfwSetWindowFocusCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, focused:Int))="glfwSetWindowFocusCallback"
	Function bmx_glfw_glfwSetWindowIconifyCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, iconified:Int))="glfwSetWindowIconifyCallback"
	Function bmx_glfw_glfwSetWindowMaximizeCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, maximized:Int))="glfwSetWindowMaximizeCallback"
	Function bmx_glfw_glfwSetFramebufferSizeCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, w:Int, h:Int))="glfwSetFramebufferSizeCallback"
	Function bmx_glfw_glfwSetWindowContentScaleCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, xScale:Float, yScale:Float))="glfwSetWindowContentScaleCallback"
	Function bmx_glfw_glfwSetMouseButtonCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, button:Int, action:Int, mods:Int))="glfwSetMouseButtonCallback"
	Function bmx_glfw_glfwSetCursorPosCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, x:Double, y:Double))="glfwSetCursorPosCallback"
	Function bmx_glfw_glfwSetCursorEnterCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, entered:Int))="glfwSetCursorEnterCallback"
	Function bmx_glfw_glfwSetScrollCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, xOffset:Double, yOffset:Double))="glfwSetScrollCallback"
	Function bmx_glfw_glfwSetKeyCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, Key:Int, scancode:Int, action:Int, mods:Int))="glfwSetKeyCallback"
	Function bmx_glfw_glfwSetCharCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, char:UInt))="glfwSetCharCallback"
	Function bmx_glfw_glfwSetCharModsCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, codepoint:UInt, mods:Int))="glfwSetCharModsCallback"
	
	'Function bmx_glfw_glfwSetDropCallback:Byte Ptr(window:Byte Ptr, func(win:Byte Ptr, path_count:Int,paths))="glfwSetDropCallback"
	
	Function bmx_glfw_glfwCreateStandardCursor:Byte Ptr(shape:Int)="glfwCreateStandardCursor"
	Function bmx_glfw_glfwDestroyCursor(Cursor:Byte Ptr)="glfwDestroyCursor"
	Function bmx_glfw_glfwSetCursor(window:Byte Ptr, Cursor:Byte Ptr)="glfwSetCursor"
	
	'joystick
	Function bmx_glfw_glfwJoystickPresent:Int(id:Int)="glfwJoystickPresent"
	Function bmx_glfw_glfwGetJoystickAxes:Float Ptr(id:Int, count:Int Var)="glfwGetJoystickAxes"
	Function bmx_glfw_glfwGetJoystickButtons:Byte Ptr(id:Int, count:Int Var)="glfwGetJoystickButtons"
	Function bmx_glfw_glfwGetJoystickHats:Byte Ptr(id:Int, count:Int Var)="glfwGetJoystickHats"
	Function bmx_glfw_glfwGetJoystickName:Byte Ptr(id:Int)="glfwGetJoystickName"
	Function bmx_glfw_glfwGetJoystickGUID:Byte Ptr(id:Int)="glfwGetJoystickGUID"
	Function bmx_glfw_glfwJoystickIsGamepad:Int(id:Int)="glfwJoystickIsGamepad"
	Function bmx_glfw_glfwSetJoystickCallback(func(id:Int, event:Int))="glfwSetJoystickCallback"
	
	Function bmx_glfw_glfwGetGamepadState:Int(id:Int, state:GLFWgamepadstate Var)="glfwGetGamepadState"
	Function bmx_glfw_glfwUpdateGamepadMappings:Int(txt:Byte Ptr)="glfwUpdateGamepadMappings"
	Function bmx_glfw_glfwGetGamepadName:Byte Ptr(id:Int)="glfwGetGamepadName"
End Extern

Const GLFW_JOYSTICK_1:Int = 0
Const GLFW_JOYSTICK_2:Int = 1
Const GLFW_JOYSTICK_3:Int = 2
Const GLFW_JOYSTICK_4:Int = 3
Const GLFW_JOYSTICK_5:Int = 4
Const GLFW_JOYSTICK_6:Int = 5
Const GLFW_JOYSTICK_7:Int = 6
Const GLFW_JOYSTICK_8:Int = 7
Const GLFW_JOYSTICK_9:Int = 8
Const GLFW_JOYSTICK_10:Int = 9
Const GLFW_JOYSTICK_11:Int = 10
Const GLFW_JOYSTICK_12:Int = 11
Const GLFW_JOYSTICK_13:Int = 12
Const GLFW_JOYSTICK_14:Int = 13
Const GLFW_JOYSTICK_15:Int = 14
Const GLFW_JOYSTICK_16:Int = 15
Const GLFW_JOYSTICK_LAST:Int = GLFW_JOYSTICK_16

Rem
bbdoc: Describes the input state of a gamepad.
End Rem
Struct GLFWgamepadstate
	Rem
	bbdoc: The states of each gamepad button, #GLFW_PRESS or #GLFW_RELEASE.
	End Rem
	Field StaticArray buttons:Byte[15]
	Rem
	bbdoc: The states of each gamepad axis, in the range -1.0 to 1.0 inclusive.
	End Rem
	Field StaticArray axes:Float[6]
End Struct

Rem
bbdoc: A GLFW cursor
End Rem
Struct GLFWcursor
Private
	Field cursorPtr:Byte Ptr
	Field custom:Int
	
	Method New(cursorPtr:Byte Ptr, custom:Int)
		Self.cursorPtr = cursorPtr
		Self.custom = custom
	End Method
Public
	Rem
	bbdoc: Creates a new custom cursor image that can be set for a window with #SetCursor.
	about: The cursor can be destroyed with #Destroy. Any remaining cursors are destroyed on program termination.

	The cursor hotspot is specified in pixels, relative to the upper-left corner of the cursor image.
	Like all other coordinate systems in GLFW, the X-axis points to the right and the Y-axis points down.
	End Rem
	Function Create:GLFWcursor(pix:TPixmap, xhot:Int, yhot:Int)
		If pix.format <> PF_RGBA8888 Then
			pix = pix.Convert(PF_RGBA8888)
		End If

		Local image:GLFWimage=New GLFWimage( pix.width,pix.height,pix.pixels)
		Local Cursor:GLFWcursor=New GLFwcursor(bmx_glfw_glfwCreateCursor(image, xhot, yhot), True)
		pix = Null

		Return Cursor
	End Function

	Rem
	bbdoc: Returns a cursor with a standard shape, that can be set for a window with #SetCursor.
	about: Standard shapes include #GLFW_ARROW_CURSOR, #GLFW_IBEAM_CURSOR, #GLFW_CROSSHAIR_CURSOR, #GLFW_HAND_CURSOR, #GLFW_HRESIZE_CURSOR and #GLFW_VRESIZE_CURSOR.
	End Rem
	Function CreateStandard:GLFWcursor(shape:Int)
		Return New GLFWcursor(bmx_glfw_glfwCreateStandardCursor(shape), False)
	End Function

	Rem
	bbdoc: Destroys a cursor previously created with #Create. 
	about: Any remaining cursors will be destroyed on program termination.

	If the specified cursor is current for any window, that window will be reverted to the default cursor. This does not affect the cursor mode.
	End Rem
	Method Destroy()
		If custom Then
			bmx_glfw_glfwDestroyCursor(cursorPtr)
		End If
	End Method
	
End Struct

Rem
bbdoc: Image data.
about: This describes a single 2D image.
See the documentation for each related function what the expected pixel format is.
End Rem
Struct GLFWimage
	Rem
	bbdoc: The width, in pixels, of this image.
	End Rem
	Field width:Int
	Rem
	bbdoc: The height, in pixels, of this image.
	End Rem
	Field height:Int
	Rem
	bbdoc: The pixel data of this image, arranged left-to-right, top-to-bottom.
	End Rem
	Field pixels:Byte Ptr
	
	Method New(width:Int, height:Int, pixels:Byte Ptr)
		Self.width = width
		Self.height = height
		Self.pixels = pixels
	End Method
End Struct
